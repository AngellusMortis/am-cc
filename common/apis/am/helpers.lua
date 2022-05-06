local v = require("cc.expect")

local object = require("ext.object")

---@class cc.item
---@field name string
---@field count number

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

return h
