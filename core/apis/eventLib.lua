local v = require("cc.expect")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

local text = require("text")
local ui = require("buttonH")

local eventLib = {}
eventLib.e = {}
eventLib.e.progress = "am_progress"
eventLib.e.progress_quarry = "quarry"
eventLib.e.turtle = "am_turtle"
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

local function isTerm(output)
    v.expect(1, output, "table")

    return output.redirect ~= nil
end

local function bar(output, x, y, current, total, length, height, background, fill, border)
    local width, _ = output.getSize()
    if total == nil then
        total = 1
    end
    if length == nil then
        length = width - 1
    end
    if height == nil then
        height = 1
    end
    if background == nil then
        background = "lightGray"
    end
    if fill == nil then
        fill = "green"
    end
    if border == nil then
        border = "gray"
    end
    v.expect(1, output, "table")
    v.expect(2, x, "number")
    v.expect(3, y, "number")
    v.expect(4, current, "number")
    v.expect(5, total, "number")
    v.expect(6, length, "number")
    v.expect(7, height, "number")
    v.expect(8, background, "string")
    v.expect(9, fill, "string")
    v.expect(10, border, "string")

    if isTerm(output) then
        ui.terminal.bar(
            x, y, length, height,
            current, total,
            background, fill, border,
            false, false, "", true, true, false
        )
    else
        ui.monitor.bar(
            peripheral.getName(output),
            x, y, length, height,
            current, total,
            background, fill, border,
            false, false, "", true, true, false
        )
    end
end

eventLib.printQuarryProgress = function(job, progress, pos, name, output)
    if output == nil then
        output = term
    end
    v.expect(1, job, "table")
    v.expect(2, progress, "table")
    v.expect(3, pos, "table")
    if name ~= nil then
        v.expect(4, name, "string")
    end
    v.expect(5, output, "table")

    eventLib.initNetwork()
    local width, height = output.getSize()

    output.clear()
    output.setCursorPos(1, 1)
    output.setCursorBlink(false)
    if name ~= nil then
        if eventLib.online then
            output.setTextColor(colors.blue)
        else
            output.setTextColor(colors.white)
        end
        text.center(name, output)
        output.setCursorPos(1, 2)
    end
    local title = string.format("Quarry: %d x %d (%d)", job.left, job.forward, job.levels)
    local line = ""

    output.setTextColor(colors.white)
    text.center(title, output)

    local currentLevel = math.min(progress.completedLevels + 1, job.levels)
    output.setCursorPos(1, 3)
    output.setTextColor(colors.white)
    line = string.format("Total Progress %d%% (%d of %d)", progress.total * 100, currentLevel, job.levels)
    if width < 30 then
        line = string.format("Total %d%% (%d of %d)", progress.total * 100, currentLevel, job.levels)
    end
    output.write(line)
    bar(output, 2, 5, progress.total)

    output.setCursorPos(1, 7)
    output.setTextColor(colors.white)
    line = string.format("Level Progress %d%% (%d of %d)", progress.level * 100, progress.currentRow, job.left)
    if width < 30 then
        line = string.format("Level %d%% (%d of %d)", progress.level * 100, progress.currentRow, job.left)
    end
    output.write(line)
    bar(output, 2, 9, progress.level)

    output.setCursorPos(1, 11)
    local status = progress.status
    local parts = ghu.split(progress.status, ":")
    output.setTextColor(colors.white)
    if #parts == 2 then
        if parts[1] == "Error" then
            output.setTextColor(colors.red)
            status = parts[2]
        end
    end
    text.center(status, output)

    output.setCursorPos(1, height)
    output.setTextColor(colors.white)
    line = string.format("pos (%d, %d) e: %d, d: %d", pos.x, pos.z, pos.y, pos.dir)
    if width < 30 then
        line = string.format("(%d,%d) e:%d, d:%d", pos.x, pos.z, pos.y, pos.dir)
    end
    text.center(line, output)
    output.setCursorPos(1, height)
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
        eventLib.printQuarryProgress(event[3], event[4], event[5], name, output)
    end
end

eventLib.b = {}
eventLib.b.raw = function(event)
    v.expect(1, event, "table")

    os.queueEvent(table.unpack(event))
    eventLib.initNetwork()
    if eventLib.online then
        rednet.broadcast({
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
