local v = require("cc.expect")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

local text = require("text")
local progressLib = require("progressLib")

local eventLib = {}
eventLib.e = {}
eventLib.e.type = "am_eventLib"
eventLib.e.progress = "am_progress"
eventLib.e.progress_quarry = "quarry"
eventLib.e.turtle = "am_turtle"
eventLib.e.turtle_started = "started"
eventLib.e.turtle_exited = "exited"
eventLib.e.turtle_completed = "completed"
eventLib.e.turtle_halted = "halted"
eventLib.e.turtle_paused = "paused"
eventLib.e.turtle_empty = "empty"
eventLib.e.turtle_getFill = "getFill"
eventLib.e.turtle_refuel = "refuel"
eventLib.e.turtle_dig = "dig"
eventLib.e.turtle_dig_forward = 1
eventLib.e.turtle_dig_down = 2
eventLib.e.turtle_dig_up = 3
eventLib.e.turtle_error = "error"
eventLib.e.pathfind = "am_pathfind"
eventLib.e.pathfind_pos = "pos"
eventLib.e.pathfind_node = "node"
eventLib.e.pathfind_resetNodes = "resetNodes"
eventLib.e.pathfind_reset = "reset"
eventLib.e.pathfind_turn = "turn"
eventLib.e.pathfind_goTo = "goTo"
eventLib.e.pathfind_goToOrigin = "goToOrigin"
eventLib.e.pathfind_goToReturn = "goToReturn"


local initalizedNetwork = false
eventLib.online = false

eventLib.getName = function()
    local label = os.getComputerLabel()
    if label == nil then
        label = tostring(os.getComputerID())
    end

    return label
end

eventLib.initNetwork = function()
    if initalizedNetwork then
        return
    end

    eventLib.online = false
    local modems = { peripheral.find("modem", function(name, modem)
        return modem.isWireless()
    end) }

    if #modems > 0 then
        rednet.open(peripheral.getName(modems[1]))
        eventLib.online = true
    end
    initalizedNetwork = true
end

eventLib.printProgress = function(event, name, output)
    if name == nil then
        name = eventLib.getName()
    end
    if output == nil then
        output = term
    end

    local progressType = event[2]
    if progressType == eventLib.e.progress_quarry then
        progressLib.quarry(output, event[3], event[4], event[5], name, eventLib.online)
    end
end

eventLib.b = {}
eventLib.b.raw = function(event)
    v.expect(1, event, "table")

    os.queueEvent(table.unpack(event))
    eventLib.initNetwork()
    if eventLib.online then
        rednet.broadcast({
            type = eventLib.e.type,
            name = eventLib.getName(),
            event = event
        })
    end
end

eventLib.b.progressQuarry = function(job, progress, pos)
    v.expect(1, job, "table")
    v.expect(2, progress, "table")
    v.expect(3, pos, "table")

    eventLib.b.raw({eventLib.e.progress, eventLib.e.progress_quarry, job, progress, pos})
end

eventLib.b.pathfindPos = function(pos)
    v.expect(1, pos, "table")

    eventLib.b.raw({eventLib.e.pathfind, eventLib.e.pathfind_pos, pos})
end

eventLib.b.pathfindNode = function(pos, isReturn)
    v.expect(1, pos, "table")
    if isReturn == nil then
        isReturn = false
    end
    v.expect(2, isReturn, "boolean")

    eventLib.b.raw({eventLib.e.pathfind, eventLib.e.pathfind_node, pos, isReturn})
end

eventLib.b.pathfindResetNodes = function(isReturn)
    if isReturn == nil then
        isReturn = false
    end
    v.expect(1, isReturn, "boolean")

    eventLib.b.raw({eventLib.e.pathfind, eventLib.e.pathfind_resetNodes, isReturn})
end

eventLib.b.pathfindTurn = function(dir, success)
    v.expect(1, dir, "number")
    v.range(dir, 1, 4)
    if success ~= nil then
        v.expect(2, success, "boolean")
    end

    eventLib.b.raw({eventLib.e.pathfind, eventLib.e.pathfind_turn, dir, success})
end

eventLib.b.pathfindGoTo = function(destPos, startPos, success)
    v.expect(1, destPos, "table")
    v.expect(2, startPos, "table")
    if success ~= nil then
        v.expect(3, success, "boolean")
    end

    eventLib.b.raw({eventLib.e.pathfind, eventLib.e.pathfind_goTo, destPos, startPos, success})
end

eventLib.b.pathfindGoToOrigin = function(startPos, success)
    v.expect(1, startPos, "table")
    if success ~= nil then
        v.expect(2, success, "boolean")
    end

    eventLib.b.raw({eventLib.e.pathfind, eventLib.e.pathfind_goToOrigin, startPos, success})
end

eventLib.b.pathfindGoToReturn = function(destPos, startPos, success)
    v.expect(1, destPos, "table")
    v.expect(2, startPos, "table")
    if success ~= nil then
        v.expect(3, success, "boolean")
    end

    eventLib.b.raw({eventLib.e.pathfind, eventLib.e.pathfind_goToReturn, destPos, startPos, success})
end

eventLib.b.pathfindResetNode = function(isReturn)
    if isReturn == nil then
        isReturn = false
    end
    v.expect(1, isReturn, "boolean")

    eventLib.b.raw({eventLib.e.pathfind, eventLib.e.pathfind_resetNodes, isReturn})
end

eventLib.b.turtleError = function(msg)
    v.expect(1, msg, "string")

    eventLib.b.raw({eventLib.e.turtle, eventLib.e.turtle_error, msg})
end

eventLib.b.turtleStarted = function()
    eventLib.b.raw({eventLib.e.turtle, eventLib.e.turtle_started})
end

eventLib.b.turtleCompleted = function()
    eventLib.b.raw({eventLib.e.turtle, eventLib.e.turtle_completed})
    eventLib.b.raw({eventLib.e.turtle, eventLib.e.turtle_exited})
end

eventLib.b.turtleHalted = function()
    eventLib.b.raw({eventLib.e.turtle, eventLib.e.turtle_halted})
    eventLib.b.raw({eventLib.e.turtle, eventLib.e.turtle_exited})
end

eventLib.b.turtlePaused = function()
    eventLib.b.raw({eventLib.e.turtle, eventLib.e.turtle_paused})
    eventLib.b.raw({eventLib.e.turtle, eventLib.e.turtle_exited})
end

eventLib.b.turtleEmpty = function()
    eventLib.b.raw({eventLib.e.turtle, eventLib.e.turtle_empty})
end

eventLib.b.turtleGetFill = function()
    eventLib.b.raw({eventLib.e.turtle, eventLib.e.turtle_getFill})
end

eventLib.b.turtleRefuel = function(count, empty)
    v.expect(1, count, "number")
    v.expect(2, empty, "boolean")

    eventLib.b.raw({eventLib.e.turtle, eventLib.e.turtle_refuel, count, empty})
end

eventLib.b.turtleDig = function(dir, count)
    v.expect(1, dir, "number")
    v.expect(2, count, "number")
    v.range(dir, 1, 3)
    v.range(count, 1)

    eventLib.b.raw({eventLib.e.turtle, eventLib.e.turtle_dig, dir, count})
end

eventLib.b.turtleDigForward = function(count)
    v.expect(1, count, "number")
    v.range(count, 1)

    eventLib.b.turtleDig(eventLib.e.turtle_dig_forward, count)
end

eventLib.b.turtleDigDown = function(count)
    v.expect(1, count, "number")
    v.range(count, 1)

    eventLib.b.turtleDig(eventLib.e.turtle_dig_down, count)
end

eventLib.b.turtleDigUp = function(count)
    v.expect(1, count, "number")
    v.range(count, 1)

    eventLib.b.turtleDig(eventLib.e.turtle_dig_up, count)
end

return eventLib
