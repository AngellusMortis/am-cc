local v = require("cc.expect")

local object = require("ext.object")

---@class cc.item_simple
---@field name string
---@field count number
---@field nbt string|nil

---@class cc.item:cc.item_simple
---@field displayName string
---@field maxCount number
---@field tags table<string, boolean>

---@class cc.item.colonies:cc.item
---@field inventories table<string, number[]>

---@class cc.block
---@field name string
---@field state table
---@field tags table<string, boolean>

---@class cc.vector
---@field x number
---@field y number
---@field z number
---@field add fun(cc.vector): cc.vector
---@field sub fun(cc.vector): cc.vector
---@field mul fun(cc.vector): cc.vector
---@field div fun(cc.vector): cc.vector
---@field unm fun(): cc.vector
---@field dot fun(cc.vector): cc.vector
---@field cross fun(cc.vector): cc.vector
---@field length fun(): number
---@field normalize fun(): cc.vector
---@field round fun(number?): cc.vector
---@field tostring fun(): string
---@field equals fun(cc.vector): boolean

---@param item1 cc.item
---@param item2 cc.item
---@return boolean
local function sortItemCountAsc(item1, item2)
    return item1.count < item2.count
end

---@param item1 cc.item|am.collect_rate
---@param item2 cc.item|am.collect_rate
---@return boolean
local function sortItemCountDesc(item1, item2)
    if item1.rate ~= nil then
        return item1.rate > item2.rate
    end
    return item1.count > item2.count
end

---@param item1 cc.item|am.collect_rate
---@param item2 cc.item|am.collect_rate
---@return boolean
local function sortItemNameAsc(item1, item2)
    if item1.item ~= nil then
        return item1.item.displayName:lower() > item2.item.displayName:lower()
    end
    return item1.displayName:lower() < item2.displayName:lower()
end

---@param item1 cc.item
---@param item2 cc.item
---@return boolean
local function sortItemNameDesc(item1, item2)
    return item1.displayName:lower() > item2.displayName:lower()
end

---@param items cc.item[]|am.collect_rate[]
---@param asc? boolean
local function sortItemsByCount(items, asc)
    if asc == nil then
        asc = false
    end

    if asc then
        table.sort(items, sortItemCountAsc)
    else
        table.sort(items, sortItemCountDesc)
    end
end

---@param items cc.item[]|am.collect_rate[]
---@param asc? boolean
local function sortItemsByName(items, asc)
    if asc == nil then
        asc = false
    end

    if asc then
        table.sort(items, sortItemNameAsc)
    else
        table.sort(items, sortItemNameDesc)
    end
end

local metricSuffixes = {"K", "M", "T", "P"}

---@param value number
---@return string
local function metricString(value)
    local suffixIndex = 0
    while value > 1000 do
        value = value / 1000
        suffixIndex = suffixIndex + 1
    end

    local suffix = ""
    if suffixIndex > 0 then
        suffix = metricSuffixes[suffixIndex]
    end
    return string.format("%.1f%s", value, suffix)
end

local function isVector(obj)
    return obj.normalize ~= nil and obj.x ~= nil and obj.y ~= nil and obj.z ~= nil
end

local function requireVector(index, obj)
    v.expect(1, index, "number")
    if not isVector(obj) then
        local t = type(obj)
        local name
        local ok, info = pcall(debug.getinfo, 3, "nS")
        if ok and info.name and info.name ~= "" and info.what ~= "C" then
            name = info.name
        end

        if name then
            error(("bad argument #%d to '%s' (expected Vector, got %s)"):format(index, name, t), 3)
        else
            error(("bad argument #%d (expected Vector, got %s)"):format(index, t), 3)
        end
    end
end

local function isPosition(obj)
    local log = require("am.log")
    return object.has(obj, "am.p.TurtlePosition")
end

local function requirePosition(index, obj)
    v.expect(1, index, "number")
    if not isPosition(obj) then
        local t = type(obj)
        local name
        local ok, info = pcall(debug.getinfo, 3, "nS")
        if ok and info.name and info.name ~= "" and info.what ~= "C" then
            name = info.name
        end

        if name then
            error(("bad argument #%d to '%s' (expected TurtlePosition, got %s)"):format(index, name, t), 3)
        else
            error(("bad argument #%d (expected TurtlePosition, got %s)"):format(index, t), 3)
        end
    end
end

local function isOrigin(pos)
    return isPosition(pos) and pos.v.x == 0 and pos.v.y == 0 and pos.v.z == 0
end

local h = {}

h.isVector = isVector
h.requireVector = requireVector
h.isPosition = isPosition
h.requirePosition = requirePosition
h.isOrigin = isOrigin
h.metricString = metricString
h.sortItemsByCount = sortItemsByCount
h.sortItemsByName = sortItemsByName

return h
