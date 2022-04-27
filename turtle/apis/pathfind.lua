local v = require("cc.expect")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")

local pathfind = {}

pathfind.c = {}
pathfind.c.FORWARD = 1
pathfind.c.RIGHT = 2
pathfind.c.BACK = 3
pathfind.c.LEFT = 4

pathfind.s = {}
pathfind.s.position = {
    name = "pathfind.position",
    default = {x=0, y=0, z=0, dir=pathfind.c.FORWARD},
    type = "table"
}
pathfind.s.nodes = {
    name = "pathfind.nodes",
    default = {},
    type = "table"
}
pathfind.s.returnNodes = {
    name = "pathfind.returnNodes",
    default = {},
    type = "table"
}

settings.define(pathfind.s.position.name, pathfind.s.position)
settings.define(pathfind.s.nodes.name, pathfind.s.nodes)
settings.define(pathfind.s.returnNodes.name, pathfind.s.returnNodes)

pathfind.getPosition = function()
    return ghu.copy(settings.get(pathfind.s.position.name))
end

pathfind.setPosition = function(pos)
    v.expect(1, pos, "table")

    settings.set(pathfind.s.position.name, pos)
    settings.save()
    os.queueEvent("pathfind_pos", pos)
end

pathfind.getNodes = function()
    return settings.get(pathfind.s.nodes.name)
end

pathfind.getReturnNodes = function()
    return settings.get(pathfind.s.returnNodes.name)
end

pathfind.addNode = function()
    local pos = pathfind.getPosition()
    local nodes = pathfind.getNodes()
    nodes[#nodes + 1] = pos
    settings.set(pathfind.s.nodes.name, nodes)
    settings.save()

    os.queueEvent("pathfind_node", pos, false)
    return pos
end

pathfind.addReturnNode = function()
    local pos = pathfind.getPosition()
    local nodes = pathfind.getReturnNodes()
    nodes[#nodes + 1] = pos
    settings.set(pathfind.s.returnNodes.name, nodes)
    settings.save()

    os.queueEvent("pathfind_node", pos, true)
    return pos
end

pathfind.getLastNode = function()
    nodes = pathfind.getNodes()
    return nodes[#nodes]
end

pathfind.getLastReturnNode = function()
    nodes = pathfind.getReturnNodes()
    return nodes[#nodes]
end

pathfind.resetNodes = function()
    settings.set(pathfind.s.nodes.name, {})
    settings.save()
    os.queueEvent("pathfind_resetNodes", false)
end

pathfind.resetReturnNodes = function()
    settings.set(pathfind.s.returnNodes.name, {})
    settings.save()
    os.queueEvent("pathfind_resetNodes", true)
end

pathfind.resetPosition = function()
    pathfind.setPosition({x=0, y=0, z=0, dir=pathfind.c.FORWARD})
    pathfind.resetNodes()
    pathfind.resetReturnNodes()
    os.queueEvent("pathfind_reset")
end

pathfind.forward = function()
    local pos = pathfind.getPosition()
    if pos.dir == pathfind.c.FORWARD then
        pos.z = pos.z + 1
    elseif pos.dir == pathfind.c.RIGHT then
        pos.x = pos.x + 1
    elseif pos.dir == pathfind.c.BACK then
        pos.z = pos.z - 1
    else
        pos.x = pos.x - 1
    end

    local success = turtle.forward()
    if success then
        pathfind.setPosition(pos)
    end
    return success
end

pathfind.back = function()
    local pos = pathfind.getPosition()
    if pos.dir == pathfind.c.FORWARD then
        pos.z = pos.z - 1
    elseif pos.dir == pathfind.c.RIGHT then
        pos.x = pos.x - 1
    elseif pos.dir == pathfind.c.BACK then
        pos.z = pos.z + 1
    else
        pos.x = pos.x + 1
    end

    local success = turtle.back()
    if success then
        pathfind.setPosition(pos)
    end
    return success
end

pathfind.up = function()
    local pos = pathfind.getPosition()
    pos.y = pos.y + 1
    local success = turtle.up()

    if success then
        pathfind.setPosition(pos)
    end
    return success
end

pathfind.down = function()
    local pos = pathfind.getPosition()
    pos.y = pos.y - 1

    local success = turtle.down()
    if success then
        pathfind.setPosition(pos)
    end
    return success
end

pathfind.turnLeft = function()
    local pos = pathfind.getPosition()
    pos.dir = pos.dir - 1
    if pos.dir < 1 then
        pos.dir = pathfind.c.LEFT
    end

    local success = turtle.turnLeft()
    if success then
        pathfind.setPosition(pos)
    end
    return success
end

pathfind.turnRight = function()
    local pos = pathfind.getPosition()
    pos.dir = pos.dir + 1
    if pos.dir > 4 then
        pos.dir = pathfind.c.FORWARD
    end

    local success = turtle.turnRight()
    if success then
        pathfind.setPosition(pos)
    end
    return success
end

local function goForward(count)
    if count == nil then
        count = 1
    end
    v.expect(1, count, "number")

    local success = false
    while count > 0 do
        success = pathfind.forward()
        if not success then
            return false
        end
        count = count - 1
    end
end

local function goBack(count)
    if count == nil then
        count = 1
    end
    v.expect(1, count, "number")

    local success = false
    while count > 0 do
        success = pathfind.back()
        if not success then
            return false
        end
        count = count - 1
    end
end

local function goUp(count)
    if count == nil then
        count = 1
    end
    v.expect(1, count, "number")

    local success = false
    while count > 0 do
        success = pathfind.up()
        if not success then
            return false
        end
        count = count - 1
    end
end

local function goDown(count)
    if count == nil then
        count = 1
    end
    v.expect(1, count, "number")

    local success = false
    while count > 0 do
        success = pathfind.down()
        if not success then
            return false
        end
        count = count - 1
    end
end

pathfind.go = function(count)
    if count == nil then
        count = 1
    end
    v.expect(1, count, "number")

    if count > 0 then
        return goForward(count)
    else
        return goBack(math.abs(count))
    end
end

pathfind.goVert = function(count)
    if count == nil then
        count = 1
    end
    v.expect(1, count, "number")

    if count > 0 then
        return goUp(count)
    else
        return goDown(math.abs(count))
    end
end

local preferLeft = {pathfind.c.LEFT, pathfind.c.FORWARD, pathfind.c.RIGHT, pathfind.c.BACK}
pathfind.turnTo = function(dir)
    if dir == nil then
        dir = pathfind.c.FORWARD
    end
    v.expect(1, dir, "number")
    v.range(dir, 1, 4)

    os.queueEvent("pathfind_turn", dir, nil)
    local pos = pathfind.getPosition()
    if preferLeft[pos.dir] == dir then
        return pathfind.turnLeft()
    end

    local success = false
    while pos.dir ~= dir do
        success = pathfind.turnRight()
        if not success then
            os.queueEvent("pathfind_turn", dir, false)
            return false
        end
        pos = pathfind.getPosition()
    end
    os.queueEvent("pathfind_turn", dir, true)
    return true
end

pathfind.goTo = function(x, z, y, dir)
    local startPos = pathfind.getPosition()
    if y == nil then
        y = startPos.y
    end
    v.expect(1, x, "number")
    v.expect(2, z, "number")
    v.expect(3, y, "number")
    if dir ~= nil then
        v.expect(4, dir, "number")
        v.range(dir, 1, 4)
    end
    local destPos = {x=x, y=y, z=z, dir=dir}
    os.queueEvent("pathfind_goTo", destPos, startPos, nil)

    local success = true
    local xDiff = -(startPos.x - x)
    if xDiff ~= 0 then
        if xDiff > 0 then
            pathfind.turnTo(pathfind.c.RIGHT)
        else
            pathfind.turnTo(pathfind.c.LEFT)
            xDiff = -xDiff
        end
        success = pathfind.go(xDiff) and success
    end

    local zDiff = -(startPos.z - z)
    if zDiff ~= 0 then
        if zDiff > 0 then
            pathfind.turnTo(pathfind.c.FORWARD)
        else
            pathfind.turnTo(pathfind.c.BACK)
            zDiff = -zDiff
        end
        success = pathfind.go(zDiff) and success
    end

    local yDiff = -(startPos.y - y)
    if yDiff ~= 0 then
        success = pathfind.goVert(yDiff) and success
    end

    if not success then
        local pos = pathfind.getPosition()
        if startPos.x == pos.x and startPos.y == pos.y and startPos.z == pos.z then
            os.queueEvent("pathfind_goTo", destPos, startPos, false)
            return false
        end
        return pathfind.goTo(x, z, y, dir)
    end

    if success and dir ~= nil then
        pathfind.turnTo(dir)
    end
    os.queueEvent("pathfind_goTo", destPos, startPos, success)
    return success
end

pathfind.goToPreviousNode = function()
    local nodes = pathfind.getNodes()
    if #nodes == 0 then
        return false, {}
    end
    local pos = nodes[#nodes]

    local success = pathfind.goTo(pos.x, pos.z, pos.y, pos.dir)
    if success then
        table.remove(nodes, #nodes)
        settings.set(pathfind.s.nodes.name, nodes)
        settings.save()
    end

    return success, pos
end

pathfind.goToPreviousReturnNode = function()
    local nodes = pathfind.getReturnNodes()
    local pos = nodes[#nodes]

    local success = pathfind.goTo(pos.x, pos.z, pos.y, pos.dir)
    if success then
        table.remove(nodes, #nodes)
        settings.set(pathfind.s.returnNodes.name, nodes)
        settings.save()
    end

    return success, pos
end

pathfind.goToOrigin = function()
    local startPos = pathfind.getPosition()
    os.queueEvent("pathfind_goToOrigin", startPos, nil)
    pathfind.resetReturnNodes()
    pathfind.addReturnNode()

    local nodes = pathfind.getNodes()
    local success = true
    local pos = pathfind.getPosition()
    while #nodes > 0 do
        success, pos = pathfind.goToPreviousNode()
        if not success then
            os.queueEvent("pathfind_goToOrigin", startPos, false)
            return false
        end
        pathfind.addReturnNode()
        nodes = pathfind.getNodes()
    end
    pathfind.resetNodes()
    local success = pathfind.goTo(0, 0, 0, pathfind.c.FORWARD)
    os.queueEvent("pathfind_goToOrigin", startPos, success)
    return success
end

pathfind.goToReturn = function()
    local nodes = pathfind.getReturnNodes()
    local destPos = nil
    if #nodes > 0 then
        destPos = nodes[1]
    end

    local startPos = pathfind.getPosition()
    os.queueEvent("pathfind_goToReturn", destPos, startPos, nil)
    if destPost == nil then
        os.queueEvent("pathfind_goToReturn", destPos, startPos, false)
    end

    pathfind.resetNodes()
    pathfind.addNode()

    local success = true
    local pos = pathfind.getPosition()
    while #nodes > 0 do
        success, pos = pathfind.goToPreviousReturnNode()
        if not success then
            os.queueEvent("pathfind_goToReturn", destPos, startPos, false)
            return false
        end
        pathfind.addNode()
        nodes = pathfind.getReturnNodes()
    end
    pathfind.resetReturnNodes()
    os.queueEvent("pathfind_goToReturn", destPos, startPos, true)
    return true
end

pathfind.dirFromString = function(dir)
    if dir == nil then
        return nil
    end

    if dir == "left" then
        dir = pathfind.c.LEFT
    elseif dir == "right" then
        dir = pathfind.c.RIGHT
    elseif dir == "forward" then
        dir = pathfind.c.FORWARD
    elseif dir == "back" then
        dir = pathfind.c.BACK
    else
        dir = tonumber(dir)
    end
    v.expect(1, dir, "number")
    v.range(dir, 1, 4)

    return dir
end

return pathfind
