local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local BaseObject = require("am.ui.base").BaseObject

local core = require("am.core")

local h = require("am.helpers")
local e = require("am.event")

local p = {}

---@class am.p.TurtlePosition:am.ui.b.BaseObject
local TurtlePosition = BaseObject:extend("am.p.TurtlePosition")
p.TurtlePosition = TurtlePosition
function TurtlePosition:init(vector, direction)
    v.expect(1, vector, "table")
    v.expect(2, direction, "number", "nil")
    if direction ~= nil then
        v.range(direction, 1, 4)
    end
    h.requireVector(1, vector)
    TurtlePosition.super.init(self)

    self.v = vector
    self.dir = direction
    return self
end

---@param raw table
---@param many? boolean
---@return am.p.TurtlePosition
function TurtlePosition:deserialize(raw, many)
    v.expect(2, many, "boolean", "nil")
    if many == nil then
        many = false
    end

    if many then
        local new = {}
        for i, pos in ipairs(raw) do
            new[i] = TurtlePosition(vector.new(pos.v.x, pos.v.y, pos.v.z), pos.dir)
        end
        return new
    end
    return TurtlePosition(vector.new(raw.v.x, raw.v.y, raw.v.z), raw.dir)
end

---@return am.p.TurtlePosition
function TurtlePosition:copy()
    return TurtlePosition(vector.new(self.v.x, self.v.y, self.v.z), self.dir)
end

local d = {}
d.position = {
    name = "position",
    default = TurtlePosition(vector.new(0, 0, 0), e.c.Turtle.Direction.Front),
    type = "table"
}
d.nodes = {
    name = "nodes",
    default = {},
    type = "table"
}
d.returnNodes = {
    name = "returnNodes",
    default = {},
    type = "table"
}
p.d = core.makeDataWrapper(d, "pf")

p.c = {}
---@type table<string, number>
p.c.Turtle = e.c.Turtle

---@type table<string, number>
p.c.DirType = {
    Turn = 1,
    Move = 2,
}

---@return am.p.TurtlePosition
local function getPos()
    return TurtlePosition.deserialize(nil, p.d.position.get())
end

---@param pos am.p.TurtlePosition
local function setPos(pos)
    p.d.position.set(pos)
    e.PositionUpdateEvent(pos):send()
end

---@return am.p.TurtlePosition
local function getNodes()
    return TurtlePosition.deserialize(nil, p.d.nodes.get(), true)
end

---@return am.p.TurtlePosition
local function getReturnNodes()
    return TurtlePosition.deserialize(nil, p.d.returnNodes.get(), true)
end

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
        pos = getPos():copy()
    end
    if isReturn == nil then
        isReturn = false
    end
    h.requirePosition(1, pos)

    local nodes
    if isReturn then
        nodes = getReturnNodes()
        nodes[#nodes + 1] = pos
        p.d.returnNodes.set(nodes)
    else
        nodes = getNodes()
        nodes[#nodes + 1] = pos
        p.d.nodes.set(nodes)
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
        nodes = getReturnNodes()
    else
        nodes = getNodes()
    end
    return nodes[#nodes]
end

---@param isReturn? boolean
local function resetNodes(isReturn)
    if isReturn == nil then
        isReturn = false
    end
    if isReturn then
        p.d.returnNodes.set({})
    else
        p.d.nodes.set({})
    end
    e.ResetNodesEvent(isReturn):send()
end

local function resetPosition()
    setPos(p.d.position.default:copy())
    resetNodes(false)
    resetNodes(true)
    e.ResetPathfindEvent():send()
end

---@return boolean
local function forward()
    local pos = getPos()
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
        setPos(pos)
    end
    return success
end

---@return boolean
local function back()
    local pos = getPos()
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
        setPos(pos)
    end
    return success
end

---@return boolean
local function up()
    local pos = getPos()
    pos.v.y = pos.v.y + 1
    local success = turtle.up()

    if success then
        setPos(pos)
    end
    return success
end

---@return boolean
local function down()
    local pos = getPos()
    pos.v.y = pos.v.y - 1

    local success = turtle.down()
    if success then
        setPos(pos)
    end
    return success
end

---@return boolean
local function turnLeft()
    local pos = getPos()
    pos.dir = pos.dir - 1
    if pos.dir < 1 then
        pos.dir = e.c.Turtle.Direction.Left
    end

    local success = turtle.turnLeft()
    if success then
        setPos(pos)
    end
    return success
end

---@return boolean
local function turnRight()
    local pos = getPos()
    pos.dir = pos.dir + 1
    if pos.dir > 4 then
        pos.dir = e.c.Turtle.Direction.Front
    end

    local success = turtle.turnRight()
    if success then
        setPos(pos)
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

    local event = e.PathfindTurnEvent(dir, nil)
    event:send()
    local pos = getPos()
    local success = false
    if preferLeft[pos.dir] == dir then
        success = turnLeft()
    else
        while pos.dir ~= dir do
            success = turnRight()
            if not success then
                break
            end
            pos = getPos()
        end
    end
    event.success = success
    event:send()
    return success
end

---@param dir number
---@param count? number
---@param dig? boolean
---@return boolean
local function goDir(dir, count, dig)
    v.expect(1, dir, "number")
    v.expect(2, count, "number", "nil")
    v.expect(3, dig, "boolean", "nil")
    if count == nil then
        count = 1
    end
    if dig == nil then
        dig = false
    end

    local callable
    local digCallable = nil
    if dir == e.c.Turtle.Direction.Up then
        callable = up
        digCallable = turtle.digUp
    elseif dir == e.c.Turtle.Direction.Down then
        callable = down
        digCallable = turtle.digDown
    elseif dir == e.c.Turtle.Direction.Front then
        callable = forward
        digCallable = turtle.dig
    else
        callable = back
    end

    local success = false
    while count > 0 do
        if dig and digCallable ~= nil then
            digCallable()
        end
        success = callable()
        if not success then
            return false
        end
        count = count - 1
    end
    return true
end

---@param count? number
---@param dig? boolean
---@return boolean
local function goForward(count, dig)
    v.expect(1, count, "number", "nil")
    v.expect(2, dig, "boolean", "nil")
    return goDir(e.c.Turtle.Direction.Front, count, dig)
end

---@param count? number
---@return boolean
local function goBack(count)
    v.expect(1, count, "number", "nil")
    return goDir(e.c.Turtle.Direction.Back, count)
end

---@param count? number
---@param dig? boolean
---@return boolean
local function goUp(count, dig)
    v.expect(1, count, "number", "nil")
    v.expect(2, dig, "boolean", "nil")
    return goDir(e.c.Turtle.Direction.Up, count, dig)
end

---@param count? number
---@param dig? boolean
---@return boolean
local function goDown(count, dig)
    v.expect(1, count, "number", "nil")
    v.expect(2, dig, "boolean", "nil")
    if dig == nil then
        dig = false
    end
    return goDir(e.c.Turtle.Direction.Down, count, dig)
end

---@param count? number
---@param dig? boolean
---@return boolean
local function goHorizontal(count, dig)
    v.expect(1, count, "number", "nil")
    v.expect(2, dig, "boolean", "nil")
    if count == nil then
        count = 1
    end
    if dig == nil then
        dig = false
    end

    if count > 0 then
        return goForward(count, dig)
    else
        return goBack(math.abs(count))
    end
end

---@param count? number
---@param dig? boolean
---@return boolean
local function goVertical(count, dig)
    v.expect(1, count, "number", "nil")
    v.expect(2, dig, "boolean", "nil")
    if count == nil then
        count = 1
    end
    if dig == nil then
        dig = false
    end

    if count > 0 then
        return goUp(count, dig)
    else
        return goDown(math.abs(count), dig)
    end
end

---@param x number
---@param z number
---@param y? number
---@param dir? number
---@param dig? boolean
---@return boolean
local function goTo(x, z, y, dir, dig)
    v.expect(1, x, "number")
    v.expect(2, z, "number")
    v.expect(3, y, "number", "nil")
    v.expect(4, dir, "number", "nil")
    v.expect(5, dig, "boolean", "nil")
    if dir ~= nil then
        v.range(dir, 1, 4)
    end
    if dig == nil then
        dig = false
    end

    local startPos = getPos()
    if y == nil then
        y = startPos.v.y
    end
    local destPos = TurtlePosition(vector.new(x, y, z), dir)
    local event = e.PathfindGoToEvent(destPos, startPos, e.c.Turtle.GoTo.Node, nil)
    event:send()

    local success = true
    local xDiff = -(startPos.v.x - x)
    if xDiff ~= 0 then
        if xDiff > 0 then
            turnTo(e.c.Turtle.Direction.Right)
        else
            turnTo(e.c.Turtle.Direction.Left)
            xDiff = -xDiff
        end
        success = goHorizontal(xDiff, dig) and success
    end

    local zDiff = -(startPos.v.z - z)
    if zDiff ~= 0 then
        if zDiff > 0 then
            turnTo(e.c.Turtle.Direction.Front)
        else
            turnTo(e.c.Turtle.Direction.Back)
            zDiff = -zDiff
        end
        success = goHorizontal(zDiff, dig) and success
    end

    local yDiff = -(startPos.v.y - y)
    if yDiff ~= 0 then
        success = goVertical(yDiff, dig) and success
    end

    if not success then
        local pos = getPos()
        if startPos.v.x == pos.v.x and startPos.v.y == pos.v.y and startPos.v.z == pos.v.z then
            event.success = false
            event:send()
            return false
        end
        return goTo(x, z, y, dir)
    end

    if success and dir ~= nil then
        turnTo(dir)
    end
    event.success = success
    event:send()
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
        nodes = getReturnNodes()
    else
        nodes = getNodes()
    end
    if #nodes == 0 then
        return false, {}
    end
    local pos = nodes[#nodes]

    local success = goTo(pos.v.x, pos.v.z, pos.v.y, pos.dir)
    if success then
        table.remove(nodes, #nodes)
        if isReturn then
            nodes = p.d.returnNodes.set(nodes)
        else
            nodes = p.d.nodes.set(nodes)
        end
    end

    return success, pos
end

---@return boolean
local function goToOrigin()
    local startPos = getPos()
    local origin = p.d.position.default:copy()
    local event = e.PathfindGoToEvent(
        startPos, origin, e.c.Turtle.GoTo.Origin, nil
    )
    event:send()
    resetNodes(true)
    addNode(nil, true)

    local nodes = getNodes()
    local success = true
    local pos = startPos
    while #nodes > 0 do
        success, pos = goToPreviousNode()
        if not success then
            event.success = false
            event:send()
            return false
        end
        addNode(nil, true)
        nodes = getNodes()
    end
    resetNodes(false)
    success = goTo(origin.v.x, origin.v.z, origin.v.y, origin.dir)
    event.success = success
    event:send()
    return success
end

---@return boolean
local function goToReturn()
    local nodes = getReturnNodes()
    local destPos = nil
    if #nodes > 0 then
        destPos = nodes[1]
    end
    if destPos == nil then
        return false
    end

    local startPos = getPos()
    local event = e.PathfindGoToEvent(
        startPos, destPos, e.c.Turtle.GoTo.Return, nil
    )
    event:send()
    resetNodes(false)
    addNode()

    local success = true
    local pos = startPos
    while #nodes > 0 do
        success, pos = goToPreviousNode(true)
        if not success then
            event.success = false
            event:send()
            return false
        end
        addNode()
        nodes = getReturnNodes()
    end
    resetNodes(true)
    event.success = success
    event:send()
    return true
end

---@return boolean
local function atOrigin()
    local pos = getPos()
    return pos.v.x == 0 and pos.v.y == 0 and pos.v.z == 0
end

p.getPos = getPos
p.setPos = setPos
p.getReturnNodes = getReturnNodes
p.getNodes = getNodes
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
p.goHorizontal = goHorizontal
p.goVertical = goVertical
p.goTo = goTo
p.goToPreviousNode = goToPreviousNode
p.goToOrigin = goToOrigin
p.goToReturn = goToReturn
p.atOrigin = atOrigin

return p
