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
    return obj.normalized ~= nil and obj.x ~= nil and obj.y ~= nil and obj.z ~= nil
end

local function requireVector(obj)
    if not isVector(obj) then
        error("must be a vector")
    end
end

local function isPosition(obj)
    return object.has(obj, "am.p.TurtlePosition")
end

local function requirePosition(obj)
    if not isPosition(obj) then
        error("must be a vector")
    end
end

local h = {}

h.isVector = isVector
h.requireVector = requireVector
h.isPosition = isPosition
h.requirePosition = requirePosition

return h
