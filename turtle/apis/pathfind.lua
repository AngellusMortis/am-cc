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
    local pos = settings.get(pathfind.s.position.name)
    return {x=pos.x, y=pos.y, z=pos.z, dir=pos.dir}
end

pathfind.setPosition = function(pos)
    settings.set(pathfind.s.position.name, pos)
    settings.save()
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
end

pathfind.addReturnNode = function(pos)
    local pos = pathfind.getPosition()
    local nodes = pathfind.getReturnNodes()
    nodes[#nodes + 1] = pos
    settings.set(pathfind.s.returnNodes.name, nodes)
    settings.save()
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
end

pathfind.resetReturnNodes = function()
    settings.set(pathfind.s.returnNodes.name, {})
    settings.save()
end

pathfind.formatNodes = function()
    local nodes = pathfind.getNodes()
    local value = string.format("%d Nodes: {", #nodes)
    for i, node in ipairs(nodes) do
        value = string.format("%s %d: %s,", value, i, pathfind.formatPosition(node))
    end
    return string.format("%s }", value)
end

pathfind.resetPosition = function()
    pathfind.setPosition({x=0, y=0, z=0, dir=pathfind.c.FORWARD})
    pathfind.resetNodes()
end

pathfind.formatPosition = function(pos)
    return string.format("(%d, %d, %d) dir: %d", pos.x, pos.y, pos.z, pos.dir)
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

    local pos = pathfind.getPosition()
    if preferLeft[pos.dir] == dir then
        return pathfind.turnLeft()
    end

    local success = false
    while pos.dir ~= dir do
        success = pathfind.turnRight()
        if not success then
            return false
        end
        pos = pathfind.getPosition()
    end
end

pathfind.goTo = function(x, z, y, dir)
    local startPos = pathfind.getPosition()
    if y == nil then
        y = startPos.y
    end

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
        pos = pathfind.getPosition()
        if startPos.x == pos.x and startPos.y == pos.y and startPos.z == pos.z then
            return false
        end
        return pathfind.goTo(x, z, y, dir)
    end

    if success and dir ~= nil then
        pathfind.turnTo(dir)
    end
    return success
end

pathfind.goToPreviousNode = function()
    local nodes = pathfind.getNodes()
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
    pathfind.resetReturnNodes()
    pathfind.addReturnNode()

    local nodes = pathfind.getNodes()
    while #nodes > 0 do
        success, pos = pathfind.goToPreviousNode()
        if not success then
            return false
        end
        pathfind.addReturnNode()
        nodes = pathfind.getNodes()
    end
    pathfind.resetNodes()
    return pathfind.goTo(0, 0, 0, pathfind.c.FORWARD)
end

pathfind.goToReturn = function()
    pathfind.resetNodes()
    pathfind.addNode()

    local nodes = pathfind.getReturnNodes()
    while #nodes > 0 do
        success, pos = pathfind.goToPreviousReturnNode()
        if not success then
            return false
        end
        pathfind.addNode()
        nodes = pathfind.getReturnNodes()
    end
    pathfind.resetReturnNodes()
    return true
end

return pathfind
