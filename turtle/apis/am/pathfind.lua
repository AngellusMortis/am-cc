local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local BaseObject = require("am.ui").b.BaseObject

local core = require("am.core")

local h = require("am.helpers")
local e = require("am.event")

local p = {}

---@class am.p.TurtlePosition:am.ui.b.BaseObject
local TurtlePosition = BaseObject:extend("am.p.TurtlePosition")
p.TurtlePosition = TurtlePosition
function TurtlePosition:init(vector, direction)
    v.expect(1, vector, "table")
    v.expect(2, direction, "number")
    v.range(direction, 1, 4)
    h.requireVector(vector)
    TurtlePosition.super.init(self)

    self.v = vector
    self.dir = direction
    return self
end

function TurtlePosition:copy()
    return TurtlePosition(vector.new(self.v.x, self.v.y, self.v.z), self.dir)
end

local s = {}
s.position = {
    name = "pathfind.position",
    default = TurtlePosition(vector.new(0, 0, 0), e.c.Turtle.Direction.Front),
    type = "table"
}
s.nodes = {
    name = "pathfind.nodes",
    default = {},
    type = "table"
}
s.returnNodes = {
    name = "pathfind.returnNodes",
    default = {},
    type = "table"
}
p.s = core.makeSettingWrapper(s)

p.c = {}
---@type table<string, number>
p.c.DirType {
    Turn = 1,
    Move = 2,
}

---@param dir? string
---@param dirType? number
---@return number|nil
local function dirFromString(dir, dirType)
    v.expect(2, dirType, "number", "nil")
    if dir == nil then
        return nil
    end
    local turnOnly = false
    local moveOnly = false
    if dirType ~= nil then
        v.range(dirType, 1, 2)
        if dirType == p.c.DirType.Turn then
            turnOnly = true
        else
            moveOnly = true
        end
    end

    if not moveOnly and dir == "left" then
        dir = e.c.Turtle.Direction.Left
    elseif not moveOnly and dir == "right" then
        dir = e.c.Turtle.Direction.Right
    elseif dir == "front" then
        dir = e.c.Turtle.Direction.Front
    elseif not moveOnly and dir == "back" then
        dir = e.c.Turtle.Direction.Back
    elseif not turnOnly and dir == "up" then
        dir = e.c.Turtle.Direction.Up
    elseif not turnOnly and dir == "down" then
        dir = e.c.Turtle.Direction.Down
    else
        dir = tonumber(dir)
    end
    v.expect(1, dir, "number")
    v.range(dir, -1, 4)
    return dir
end

---@param pos? am.p.TurtlePosition
---@param isReturn? boolean
---@return am.p.TurtlePosition
local function addNode(pos, isReturn)
    v.expect(1, pos, "table", "nil")
    v.expect(2, isReturn, "boolean", "nil")
    if pos == nil then
        pos = p.s.position.get():copy()
    end
    if isReturn == nil then
        isReturn = false
    end
    h.requirePosition(pos)

    local nodes
    if isReturn then
        nodes = p.s.returnNodes.get()
        nodes[#nodes + 1] = pos
        p.s.returnNodes.set(nodes)
    else
        nodes = p.s.nodes.get()
        nodes[#nodes + 1] = pos
        p.s.nodes.set(nodes)
    end
    e.NewNodeEvent(pos, false):send()
    return pos
end

---@param isReturn? boolean
---@return am.p.TurtlePosition
local function getLastNode(isReturn)
    if isReturn == nil then
        isReturn = false
    end
    local nodes
    if isReturn then
        nodes = p.s.returnNodes.get()
    else
        nodes = p.s.nodes.get()
    end
    return nodes[#nodes]
end

---@param isReturn? boolean
local function resetNodes(isReturn)
    if isReturn == nil then
        isReturn = false
    end
    local nodes
    if isReturn then
        p.s.returnNodes.set({})
    else
        p.s.nodes.set({})
    end
    e.ResetNodesEvent(isReturn):send()
end

local function resetPosition()
    p.s.position.set(p.s.default:copy())
    resetNodes(false)
    resetNodes(true)
    e.ResetPathfindEvent():send()
end

---@return boolean
local function forward()
    local pos = p.s.position.get()
    if pos.dir == e.c.Turtle.Direction.Front then
        pos.v.z = pos.v.z + 1
    elseif pos.dir == e.c.Turtle.Direction.Right then
        pos.v.x = pos.v.x + 1
    elseif pos.dir == e.c.Turtle.Direction.Back then
        pos.v.z = pos.v.z - 1
    else
        pos.v.x = pos.v.x - 1
    end

    local success = turtle.forward()
    if success then
        p.s.position.set(pos)
    end
    return success
end

---@return boolean
local function back()
    local pos = p.s.position.get()
    if pos.dir == e.c.Turtle.Direction.Front then
        pos.v.z = pos.v.z - 1
    elseif pos.dir == e.c.Turtle.Direction.Right then
        pos.v.x = pos.v.x - 1
    elseif pos.dir == e.c.Turtle.Direction.Back then
        pos.v.z = pos.v.z + 1
    else
        pos.v.x = pos.v.x + 1
    end

    local success = turtle.back()
    if success then
        p.s.position.set(pos)
    end
    return success
end

---@return boolean
local function up()
    local pos = p.s.position.get()
    pos.v.y = pos.v.y + 1
    local success = turtle.up()

    if success then
        p.s.position.set(pos)
    end
    return success
end

---@return boolean
local function down()
    local pos = p.s.position.get()
    pos.v.y = pos.v.y - 1

    local success = turtle.down()
    if success then
        p.s.position.set(pos)
    end
    return success
end

---@return boolean
local function turnLeft()
    local pos = p.s.position.get()
    pos.dir = pos.dir - 1
    if pos.dir < 1 then
        pos.dir = e.c.Turtle.Direction.Left
    end

    local success = turtle.turnLeft()
    if success then
        p.s.position.set(pos)
    end
    return success
end

---@return boolean
local function turnRight()
    local pos = p.s.position.get()
    pos.dir = pos.dir + 1
    if pos.dir > 4 then
        pos.dir = e.c.Turtle.Direction.Front
    end

    local success = turtle.turnRight()
    if success then
        p.s.position.set(pos)
    end
    return success
end

local preferLeft = {
    e.c.Turtle.Direction.Left,
    e.c.Turtle.Direction.Front,
    e.c.Turtle.Direction.Right,
    e.c.Turtle.Direction.Back,
}
---@param dir number
---@return boolean
local function turnTo(dir)
    v.expect(1, dir, "number", "nil")
    if dir == nil then
        dir = e.c.Turtle.Direction.Front
    end
    v.range(dir, 1, 4)

    e.PathfindTurnEvent(dir, nil):send()
    local pos = p.s.position.get()
    local success = false
    if preferLeft[pos.dir] == dir then
        success = turnLeft()
    else
        while pos.dir ~= dir do
            success = turnRight()
            if not success then
                break
            end
            pos = p.s.position.get()
        end
    end
    e.PathfindTurnEvent(dir, success):send()
    return success
end

---@param dir number
---@param count? number
---@return boolean
local function goDir(dir, count)
    v.expect(1, dir, "number")
    v.expect(2, count, "number", "nil")
    v.range(dir, -1, 1)
    if count == nil then
        count = 1
    end

    local callable
    if dir == e.c.Turtle.Direction.Up then
        callable = up
    elseif dir == e.c.Turtle.Direction.Down then
        callable = down
    elseif dir == e.c.Turtle.Direction.Front then
        callable = forward
    else
        callable = back
    end

    local success = false
    while count > 0 do
        success = callable()
        if not success then
            return false
        end
        count = count - 1
    end
    return true
end

---@param count? number
---@return boolean
local function goForward(count)
    v.expect(1, count, "number", "nil")
    return goDir(e.c.Turtle.Direction.Front, count)
end

---@param count? number
---@return boolean
local function goBack(count)
    v.expect(1, count, "number", "nil")
    return goDir(e.c.Turtle.Direction.Back, count)
end

---@param count? number
---@return boolean
local function goUp(count)
    v.expect(1, count, "number", "nil")
    return goDir(e.c.Turtle.Direction.Up, count)
end

---@param count? number
---@return boolean
local function goDown(count)
    v.expect(1, count, "number", "nil")
    return goDir(e.c.Turtle.Direction.Down, count)
end

---@param count? number
---@return boolean
local function goHorizontal(count)
    v.expect(1, count, "number", "nil")
    if count == nil then
        count = 1
    end

    if count > 0 then
        return goForward(count)
    else
        return goBack(math.abs(count))
    end
end

---@param count? number
---@return boolean
local function goVertical(count)
    v.expect(1, count, "number", "nil")
    if count == nil then
        count = 1
    end

    if count > 0 then
        return goUp(count)
    else
        return goDown(math.abs(count))
    end
end

---@param x number
---@param z number
---@param y? number
---@param dir? number
---@return boolean
local function goTo(x, z, y, dir)
    v.expect(1, x, "number")
    v.expect(2, z, "number")
    v.expect(3, y, "number", "nil")
    v.expect(4, dir, "number", "nil")
    if dir ~= nil then
        v.range(dir, 1, 4)
    end

    local startPos = p.s.position.get()
    if y == nil then
        y = startPos.y
    end
    local destPos = TurtlePosition(vector.new(x, y, z), dir)
    e.PathfindGoToEvent(destPos, startPos, e.c.Turtle.GoTo.Node, nil):send()

    local success = true
    local xDiff = -(startPos.x - x)
    if xDiff ~= 0 then
        if xDiff > 0 then
            turnTo(e.c.Turtle.Direction.Right)
        else
            turnTo(e.c.Turtle.Direction.Left)
            xDiff = -xDiff
        end
        success = goHorizontal(xDiff) and success
    end

    local zDiff = -(startPos.z - z)
    if zDiff ~= 0 then
        if zDiff > 0 then
            turnTo(e.c.Turtle.Direction.Front)
        else
            turnTo(e.c.Turtle.Direction.Back)
            zDiff = -zDiff
        end
        success = goHorizontal(zDiff) and success
    end

    local yDiff = -(startPos.y - y)
    if yDiff ~= 0 then
        success = goVertical(yDiff) and success
    end

    if not success then
        local pos = p.s.position.get()
        if startPos.x == pos.x and startPos.y == pos.y and startPos.z == pos.z then
            e.PathfindGoToEvent(destPos, startPos, e.c.Turtle.GoTo.Node, false):send()
            return false
        end
        return goTo(x, z, y, dir)
    end

    if success and dir ~= nil then
        turnTo(dir)
    end
    e.PathfindGoToEvent(destPos, startPos, e.c.Turtle.GoTo.Node, success):send()
    return success
end

---@param isReturn? boolean
---@return boolean, am.p.TurtlePosition
local function goToPreviousNode(isReturn)
    v.expect(1, isReturn, "boolean", "nil")
    if isReturn == nil then
        isReturn = false
    end

    local nodes
    if isReturn then
        nodes = p.s.returnNodes.get()
    else
        nodes = p.s.nodes.get()
    end
    if #nodes == 0 then
        return false, {}
    end
    local pos = nodes[#nodes]

    local success = goTo(pos.x, pos.z, pos.y, pos.dir)
    if success then
        table.remove(nodes, #nodes)
        if isReturn then
            nodes = p.s.returnNodes.set(nodes)
        else
            nodes = p.s.nodes.set(nodes)
        end
    end

    return success, pos
end

---@return boolean
local function goToOrigin()
    local startPos = p.s.position.get()
    local origin = p.s.position.default:copy()
    e.PathfindGoToEvent(
        startPos, origin, e.c.Turtle.GoTo.Origin, nil
    ):send()
    resetNodes(true)
    addNode(nil, true)

    local nodes = p.s.nodes.get()
    local success = true
    local pos = startPos
    while #nodes > 0 do
        success, pos = goToPreviousNode()
        if not success then
            e.PathfindGoToEvent(
                startPos, origin, e.c.Turtle.GoTo.Origin, false
            ):send()
            return false
        end
        addNode(nil, true)
        nodes = p.s.node.get()
    end
    resetNodes(false)
    success = goTo(origin.v.x, origin.v.z, origin.v.y, origin.dir)
    e.PathfindGoToEvent(
        startPos, origin, e.c.Turtle.GoTo.Origin, success
    ):send()
    return success
end

---@return boolean
local function goToReturn()
    local nodes = p.s.returnNodes.get()
    local destPos = nil
    if #nodes > 0 then
        destPos = nodes[1]
    end

    local startPos = p.s.position.get()
    e.PathfindGoToEvent(
        startPos, destPos, e.c.Turtle.GoTo.Return, nil
    ):send()
    if destPos == nil then
        e.PathfindGoToEvent(
            startPos, destPos, e.c.Turtle.GoTo.Return, false
        ):send()
        return false
    end

    resetNodes(false)
    addNode()

    local success = true
    local pos = startPos
    while #nodes > 0 do
        success, pos = goToPreviousNode(true)
        if not success then
            e.PathfindGoToEvent(
                startPos, destPos, e.c.Turtle.GoTo.Return, false
            ):send()
            return false
        end
        addNode()
        nodes = p.s.returnNodes.get()
    end
    resetNodes(true)
    e.PathfindGoToEvent(
        startPos, destPos, e.c.Turtle.GoTo.Return, true
    ):send()
    return true
end

p.dirFromString = dirFromString
p.addNode = addNode
p.getLastNode = getLastNode
p.resetNodes = resetNodes
p.resetPosition = resetPosition
p.forward = forward
p.back = back
p.up = up
p.down = down
p.turnLeft = turnLeft
p.turnRight = turnRight
p.turnTo = turnTo
p.goForward = goForward
p.goBack = goBack
p.goUp = goUp
p.goDown = goDown
p.goTo = goTo
p.goToPreviousNode = goToPreviousNode

return p
