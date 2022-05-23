local v = require("cc.expect")

local core = require("am.core")

local pc = {}

---@type table<number, table<string, cc.item>>
local ITEM_COUNTS = {}
local ONE_MINUTE = 60
local ONE_HOUR = ONE_MINUTE * 60
---@type am.collect_rate[]
local RATES = {}
local START_TIME = 0

---@class cc.inventory
---@field size fun(): number
---@field list fun(): table<number, cc.item_simple>
---@field getItemDetail fun(number): cc.item|nil
---@field getItemLimit fun(number): number
---@field pushItems fun(string, number, number?, number?): number
---@field pullItems fun(string, number, number?, number?): number

---@return string|nil
local function getLocalName()
    local modem = peripheral.find("modem", function(_, p) return not p.isWireless() end)
    if modem == nil then
        return nil
    end
    return modem.getNameLocal()
end

---@param newCount? table<string, cc.item>
local function calculateRates(newCount)
    local now = os.clock()
    local cutoff = math.max(START_TIME, now - ONE_HOUR)
    local elapsed = now - cutoff
    local minutes = 60
    if elapsed < ONE_HOUR then
        minutes = elapsed / ONE_MINUTE
    end
    local addedCounts = false
    local newCounts = {[now] = {}}
    ---@cast newCounts table<number, table<string, cc.item>>
    local totals = {}
    ---@cast totals table<string, cc.item>
    if newCount ~= nil then
        for _, count in pairs(newCount) do
            addedCounts = true
            if count.count > 0 then
                newCounts[now][count.name] = core.copy(count)
                totals[count.name] = core.copy(count)
            end
        end
    end
    if not addedCounts then
        newCounts = {}
        ---@cast newCounts table<number, table<string, cc.item>>
    end

    for time, prevCounts in pairs(ITEM_COUNTS) do
        if time >= cutoff then
            newCounts[time] = core.copy(prevCounts)
            for _, prevCount in pairs(prevCounts) do
                local total = totals[prevCount.name]
                if total == nil then
                    total = core.copy(prevCount)
                else
                    total.count = total.count + prevCount.count
                end
                totals[prevCount.name] = total
            end
        end
    end

    RATES = {}
    for _, total in pairs(totals) do
        local item = core.copy(total)
        item.count = 0
        RATES[#RATES + 1] = {item=item, rate=total.count / minutes}
    end
    ITEM_COUNTS = newCounts
end

---@param event am.e.TurtleEmptyEvent
local function addItems(event)
    local newCount = {}
    for _, item in ipairs(event.items) do
        ---@cast item cc.item
        local count = newCount[item.name]
        if count == nil then
            count = core.copy(item)
        else
            count.count = count.count + item.count
        end
        newCount[item.name] = count
    end

    calculateRates(newCount)
end

---@param fromName string
---@param toName string
---@param count? number
---@param toSlot? number
---@param fromSlot? number
---@return boolean
local function pullItem(fromName, toName, count, toSlot, fromSlot)
    v.expect(1, fromName, "string")
    v.expect(2, toName, "string")
    v.expect(3, count, "number", "nil")
    v.expect(4, toSlot, "number", "nil")
    v.expect(5, fromSlot, "number", "nil")

    if count ~= nil then
        v.range(count, 0, 64)
    end
    if count == 0 then
        return false
    end

    if toSlot ~= nil then
        local slotCount = 16
        if toName ~= getLocalName() then
            slotCount = peripheral.wrap(toName).size()
        end
        v.range(toSlot, 1, slotCount)
    else
        if toName == getLocalName() then
            toSlot = turtle.getSelectedSlot()
        else
            local to = peripheral.wrap(toName)
            ---@cast to cc.inventory
            for x = 1, to.size(), 1 do
                if to.getItemDetail(x) == nil then
                    toSlot = x
                    break
                end
            end
        end
    end

    local from = peripheral.wrap(fromName)
    ---@cast from cc.inventory
    if fromSlot ~= nil then
        v.range(fromSlot, 1, from.size())
    else
        for key, _ in pairs(from.list()) do
            fromSlot = key
            break
        end
    end

    local success = false
    if fromSlot ~= nil then
        success = pcall(function () from.pushItems(toName, fromSlot, count, toSlot) end)
    end

    return success
end

---@param toName string
---@param fromName string
---@param count? number
---@param toSlot? number
---@param fromSlot? number
---@return boolean
local function pushItem(toName, fromName, count, toSlot, fromSlot)
    v.expect(1, toName, "string")
    v.expect(2, fromName, "string")
    v.expect(3, count, "number", "nil")
    v.expect(4, toSlot, "number", "nil")
    v.expect(5, fromSlot, "number", "nil")

    if count ~= nil then
        v.range(count, 0, 64)
    end
    if count == 0 then
        return false
    end

    local to = peripheral.wrap(toName)
    ---@cast to cc.inventory
    if toSlot ~= nil then
        v.range(toSlot, 1, to.size())
    else
        for key, _ in pairs(to.list()) do
            toSlot = key
            break
        end
    end

    if fromSlot ~= nil then
        local slotCount = 16
        if fromName ~= getLocalName() then
            slotCount = peripheral.wrap(fromName).size()
        end
        v.range(fromSlot, 1, slotCount)
    else
        if fromName == getLocalName() then
            fromSlot = turtle.getSelectedSlot()
        else
            local from = peripheral.wrap(fromName)
            ---@cast from cc.inventory
            for x = 1, from.size(), 1 do
                if from.getItemDetail(x) == nil then
                    fromSlot = x
                    break
                end
            end
        end
    end

    local success = false
    if fromSlot ~= nil then
        success = pcall(function () to.pullItems(fromName, fromSlot, count, toSlot) end)
    end

    return success
end

---@return string[]
local function getMonitorNames()
    local monitors = {}
    for _, name in ipairs(peripheral.getNames()) do
        if peripheral.getType(name) == "monitor" then
            monitors[#monitors + 1] = name
        end
    end

    return monitors
end

---@return table<string, boolean>
local function getMonitorLookup()
    local monitors = {}
    for _, name in ipairs(peripheral.getNames()) do
        if peripheral.getType(name) == "monitor" then
            monitors[name] = true
        end
    end

    return monitors
end

---@return string[]
local function getInventoryNames()
    local inventories = {}
    for _, name in ipairs(peripheral.getNames()) do
        if peripheral.hasType(name, "inventory") then
            inventories[#inventories + 1] = name
        end
    end
    return inventories
end

---@return table<string, boolean>
local function getInventoryLookup()
    local inventories = {}
    for _, name in ipairs(peripheral.getNames()) do
        if peripheral.hasType(name, "inventory") then
            inventories[name] = true
        end
    end
    return inventories
end

pc.getLocalName = getLocalName
pc.addItems = addItems
pc.calculateRates = calculateRates
pc.pullItem = pullItem
pc.pushItem = pushItem
pc.getMonitorNames = getMonitorNames
pc.getMonitorLookup = getMonitorLookup
pc.getInventoryNames = getInventoryNames
pc.getInventoryLookup = getInventoryLookup

return pc
