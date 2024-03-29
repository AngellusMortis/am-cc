local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local core = require("am.core")
local log = require("am.log")
local pc = require("am.peripheral")
local e = require("am.event")

local colonies = {}

local s = {}
s.mods = {
    name = "colonies.blacklistedMods",
    default = {
        ["minecraft"] = true,
        ["domum_ornamentum"] = true,
        ["minecolonies"] = true,
    },
    type = "table"
}
s.maxStacks = {
    name = "colonies.maxStacks",
    default = 4,
    type = "number"
}
s.importChest = {
    name = "colonies.importChest",
    default = "",
    type = "string"
}
colonies.s = core.makeSettingWrapper(s)

local COLONY = nil
local BRIDGE = nil
---@type table<string, boolean>
local RECENT_FULFILLS = {}
---@type table<number, string>
local FULFILL_TIMES = {}
local RECENT_TIME = 300

---@return table
local function getColony()
    if COLONY == nil then
        COLONY = peripheral.find("colonyIntegrator")
        if COLONY == nil then
            error("Could not find Colony Integrator")
        end
    end

    return COLONY
end

---@return table
local function getBridge()
    if BRIDGE == nil then
        BRIDGE = peripheral.find("meBridge")
        if BRIDGE == nil then
            error("Could not find ME Bridge")
        end
    end

    return BRIDGE
end

---@return table|nil
local function getImportChest()
    local chestName = colonies.s.importChest.get()
    if chestName ~= "" then
        return peripheral.wrap(chestName)
    end
    return nil
end

---@param chest table
---@return number|nil
local function getEmptySlot(chest)
    v.expect(1, chest, "table")

    local toSlot = nil
    local items = chest.list()
    for i = 1, chest.size(), 1 do
        if items[i] == nil then
            toSlot = i
            break
        end
    end
    return toSlot
end

---@class cc.colony.location
---@field x number
---@field y number
---@field z number

---@class cc.colony.dim_location:cc.colony.location
---@field world string

---@class cc.colony.player
---@field name string
---@field rank string
---@field present boolean

---@class cc.colony.rank
---@field name string
---@field hostile string
---@field permissions table

---@class cc.colony.player_detail
---@field players cc.colony.player[]
---@field ranks cc.colony.rank[]

---@class cc.colony.skill
---@field level number
---@field xp number

---@class cc.colony.visitor
---@field id number
---@field name string
---@field location cc.colony.location
---@field chair cc.colony.location
---@field age string
---@field sex string
---@field saturation number
---@field happiness number
---@field skills table<string, cc.colony.skill>
---@field cost cc.item

---@class cc.colony.footprint
---@field corner1 cc.colony.location
---@field corner2 cc.colony.location
---@field mirror boolean
---@field rotation number

---@class cc.colony.citizen_ref
---@field id number
---@field name string

---@class cc.colony.building
---@field location cc.colony.location
---@field type string
---@field style string
---@field level number
---@field maxLevel number
---@field name string
---@field claimRadius number
---@field built boolean
---@field wip boolean
---@field priority number
---@field footprint cc.colony.footprint
---@field citizens cc.colony.citizen_ref[]
---@field storageBlocks number
---@field storageSlots number
---@field guarded boolean

---@class cc.colony.request
---@field count number
---@field desc string
---@field items cc.item
---@field minCount number
---@field name string
---@field state string
---@field target string

---@class cc.colony.home_location
---@field level number
---@field location cc.colony.location
---@field type string

---@class cc.colony.work_location
---@field level number
---@field location cc.colony.location
---@field name string
---@field type string

---@class cc.colony.citizen
---@field id number
---@field name string
---@field location cc.colony.location
---@field bed cc.colony.location
---@field home cc.colony.home_location
---@field work cc.colony.work_location|nil
---@field status string
---@field age string
---@field sex string
---@field saturation number
---@field happiness number
---@field skills table<string, cc.colony.skill>
---@field health number
---@field max_health number
---@field armor number
---@field toughness number
---@field job string

---@class cc.colony_base
---@field id number
---@field name string
---@field style string
---@field active boolean
---@field location cc.colony.dim_location
---@field happiness number
---@field raid boolean
---@field citizens number
---@field maxCitizens number

---@class cc.colony:cc.colony_base
---@field graves number
---@field constructionCount number
---@field tavernCount number
---@field buildings cc.colony.building[]
---@field players cc.colony.player[]
---@field visitorCount number
---@field visitors table<number, cc.colony.visitor>
---@field citizenCount number
---@field citizens table<number, cc.colony.citizen>
---@field requests cc.colony.request[]

---@return cc.colony
local function pollColony()
    if colony == nil or not colony.isValid() then
        error("Could not find colony info")
    end

    local c = getColony()
    local status = colony.getInfo()
    ---@cast status cc.colony_base

    if not status.active then
        error("Colony is not active")
    end

    status.graves = c.amountOfGraves()
    status.constructionCount = c.amountOfConstructionSites()
    status.players = colony.getPlayers().players
    status.requests = colony.getRequests()
    local buildings = colony.getBuildings()
    status.buildings = {}
    status.tavernCount = 0
    for _, building in ipairs(buildings) do
        if building.type == "tavern" and building.level > 0 then
            status.tavernCount = status.tavernCount + 1
        end
        if building.type ~= "postbox" and building.type ~= "stash" then
            status.buildings[#status.buildings + 1] = building
        end
    end

    local visitors = colony.getVisitors()
    status.visitorCount = #visitors
    status.visitors = {}
    for _, visitor in ipairs(visitors) do
        status.visitors[visitor.id] = visitor
    end

    local citizens = colony.getCitizens()
    status.citizenCount = #citizens
    status.citizens = {}
    for _, citizen in ipairs(citizens) do
        status.citizens[citizen.id] = citizen
    end
    ---@cast status cc.colony

    return status
end

---@return table<string, cc.item.colonies>, number
local function scanItems()
    log.info("Scanning Warehouse...")
    local peripherals = pc.getInventoryNames()
    local items = {}
    local usedSlots = 0
    local totalSlots = 0
    for _, name in ipairs(peripherals) do
        if name:sub(1, 18) == "minecolonies:rack_" then
            log.debug(string.format(".Scanning %s...", name))
            local rack = peripheral.wrap(name)
            ---@cast rack cc.inventory
            totalSlots = totalSlots + rack.size()
            for slot, item in pairs(rack.list()) do
                usedSlots = usedSlots + 1
                ---@case item cc.item_simple
                local key = item.name
                if item.nbt ~= nil then
                    key = key ..":" .. item.nbt
                end

                if items[key] == nil then
                    item = rack.getItemDetail(slot)
                    if item ~= nil then
                        ---@cast item cc.item.colonies
                        item.inventories = {[name]={slot}}
                        items[key] = item
                    end
                else
                    local existingItem = items[key]
                    existingItem.count = existingItem.count + item.count
                    local inventorySlots = existingItem.inventories[name]
                    if inventorySlots == nil then
                        inventorySlots = {slot}
                    else
                        inventorySlots[#inventorySlots + 1] = slot
                    end
                    existingItem.inventories[name] = inventorySlots
                    items[key] = existingItem
                end
            end
        end
    end

    return items, usedSlots, totalSlots
end

---@param item cc.item.colonies
---@param count? number
local function emptyItem(item, count)
    v.expect(1, item, "table")
    v.expect(2, count, "number", "nil")
    if count == nil then
        count = item.count
    end

    log.info(string.format(".Empty %s %s", item.name, count))
    local chest = getImportChest()
    if chest == nil then
        error("Could not find dump chest")
        return
    end
    local emptyCount = 0
    for name, slots in pairs(item.inventories) do
        local inventory = peripheral.wrap(name)
        for _, slot in ipairs(slots) do
            local emptySlot = nil
            while emptySlot == nil do
                emptySlot = getEmptySlot(chest)
                if emptySlot == nil then
                    log.info("Waiting for dump chest to empty...")
                    sleep(5)
                end
            end
            local curItem = inventory.getItemDetail(slot)
            if curItem ~= nil and curItem.name == item.name then
                local importCount = curItem.count
                if importCount > count then
                    importCount = count
                end
                emptyCount = emptyCount + importCount
                log.debug(string.format("%s %s %s %s %s", peripheral.getName(chest), name, slot, importCount, emptySlot))
                chest.pullItems(name, slot, importCount, emptySlot)
                if emptyCount >= count then
                    break
                end
            end
        end
    end
end

---@param items table<string, cc.item.colonies>
---@return boolean
local function emptyItems(items)
    log.debug("Emptying Items...")

    local emptied = false
    for _, item in pairs(items) do
        local parts = core.split(item.name, ":")
        if not colonies.s.mods.get()[parts[1]] then
            emptyItem(item)
        else
            local stacks = item.count / item.maxCount
            local stacksToEmpty = stacks - colonies.s.maxStacks.get()
            if stacksToEmpty > 0 then
                emptied = true
                emptyItem(item, stacksToEmpty * item.maxCount)
            end
        end
    end

    return emptied
end

local function emptyWarehouse()
    if colony == nil or not colony.isValid() then
        error("Could not find colony info")
    end

    local emptied = true
    local items, usedSlots, totalSlots
    while emptied do
        items, usedSlots, totalSlots = scanItems()
        emptied = emptyItems(items)

        if emptied then
            log.info(".Rescanning warehouse")
        end
    end

    local itemsList = {}
    ---@cast itemsList cc.item.colonies[]
    for _, item in pairs(items) do
        itemsList[#itemsList + 1] = item
    end

    e.ColonyWarehousePollEvent(colony.getInfo().id, itemsList, usedSlots, totalSlots):send()
end

---@return string|nil
local function getFreeRack()
    local peripherals = pc.getInventoryNames()
    for _, name in ipairs(peripherals) do
        if name:sub(1, 18) == "minecolonies:rack_" then
            local rack = peripheral.wrap(name)
            --@cast rack cc.inventory
            local items = rack.list()
            if #items < rack.size() then
                return name
            end
        end
    end
    return nil
end

---@param item cc.item
---@param count number
---@return number
local function fulfillItem(item, count)
    local bridge = getBridge()
    local meItem = bridge.getItem({name=item.name})
    if meItem == nil then
        return 0
    end
    if count > meItem.amount then
        count = meItem.amount
    end

    local rackName = getFreeRack()
    if rackName == nil then
        return 0
    end
    local success = false
    success, count = pcall(function()
        return bridge.exportItemToPeripheral({name=item.name, count=count}, rackName)
    end)
    if success then
        return count
    end
    return 0
end

---@param request cc.colony.request
---@return string
local function getRequestHash(request)
    local requestHash = request.name .. request.desc
    if request.target ~= nil then
        requestHash = requestHash .. request.target
    end
    if request.count ~= nil then
        requestHash = requestHash .. tostring(request.count)
    end

    return requestHash
end

local function cleanRecentFulfilled()
    local now = os.clock()
    local newFulfillTimes = {}
    for time, requestHash in pairs(FULFILL_TIMES) do
        if time + RECENT_TIME > now then
            newFulfillTimes[time] = requestHash
        else
            RECENT_FULFILLS[requestHash] = nil
        end
    end
    FULFILL_TIMES = newFulfillTimes
end

local function fulfillRequests()
    local failedItems = {}
    local requests = colony.getRequests()
    for _, request in ipairs(requests) do
        if not failedItems[request.name] then
            local requestHash = getRequestHash(request)
            if not RECENT_FULFILLS[requestHash] then
                local count = 0
                for _, item in ipairs(request.items) do
                    count = fulfillItem(item, request.count)
                    if count > 0 then
                        break
                    end
                end
                log.debug(string.format(".Fulfil %s..%s", request.name, count))
                if count == 0 then
                    failedItems[request.name] = true
                else
                    FULFILL_TIMES[os.clock()] = requestHash
                    RECENT_FULFILLS[requestHash] = true
                end
            end
        end
    end
    cleanRecentFulfilled()
end

---@return boolean
local function canResume()
    return getImportChest() ~= nil
end

colonies.pollColony = pollColony
colonies.scanItems = scanItems
colonies.emptyWarehouse = emptyWarehouse
colonies.canResume = canResume
colonies.fulfillRequests = fulfillRequests

return colonies
