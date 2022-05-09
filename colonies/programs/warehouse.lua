local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local log = require("am.log")
local e = require("am.event")
local core = require("am.core")
local colonies = require("am.colonies")

local BRIDGE = nil

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

---@return table<string, cc.item.colonies>
local function scanItems()
    log.debug("Scanning Warehouse...")
    local peripherals = peripheral.getNames()
    local items = {}
    for _, name in ipairs(peripherals) do
        if name:sub(1, 18) == "minecolonies:rack_" then
            log.debug(string.format(".Scanning %s...", name))
            local rack = peripheral.wrap(name)
            for slot, item in pairs(rack.list()) do
                ---@case item cc.item_simple
                local key = item.name
                if item.nbt ~= nil then
                    key = key ..":" .. item.nbt
                end

                if items[key] == nil then
                    item = rack.getItemDetail(slot)
                    ---@cast item cc.item.colonies
                    item.inventories = {[name]={slot}}
                    items[key] = item
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

    e.ColoniesScanEvent(items):send()
    return items
end

---@param item cc.item.colonies
---@param count? number
local function emptyItem(item, count)
    v.expect(1, item, "table")
    v.expect(2, count, "number", "nil")
    if count == nil then
        count = item.count
    end

    log.debug(string.format(".Empty %s %s", item.name, count))
    local bridge = getBridge()
    local emptyCount = 0
    log.debug(item)
    -- for name, slots in pairs(item.inventories) do
    --     local inventory = peripheral.wrap(name)
    --     for _, slot in ipairs(slots) do
    --         local curItem = inventory.getItemDetail(slot)
    --         local importCount = curItem.count
    --         if importCount > count then
    --             importCount = count
    --         end
    --         emptyCount = emptyCount + importCount
    --         bridge.importItemFromPeripheral({
    --             name=item.name,
    --             nbt=item.nbt,
    --             count=importCount
    --         }, name)
    --         if emptyCount >= count then
    --             break
    --         end
    --     end
    -- end
end

---@param items table<string, cc.item.colonies>
local function emptyItems(items)
    log.debug("Emptying Items...")

    local toEmpty = {}
    for key, item in pairs(items) do
        local parts = core.split(item.name, ":")
        if not colonies.s.mods.get()[parts[1]] then
            emptyItem(item)
        else
            local stacks = item.count / item.maxCount
            local stacksToEmpty = colonies.s.maxStacks.get() - stacks
            if stacksToEmpty > 0 then
                emptyItem(item, stacksToEmpty * item.maxCount)
            end
        end
    end
end

local items = scanItems()
-- log.debug("Scanned Items:")
-- for key, item in pairs(items) do
--     log.debug(string.format("%s: %d", key, item.count))
-- end

emptyItems(items)
