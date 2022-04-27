local v = require("cc.expect")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

local text = require("text")
local ui = require("buttonH")

local eventLib = {}
eventLib.e = {}
eventLib.e.progress = "am_progress"
eventLib.e.progress_quarry = "quarry"

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

local printQuarryProgress = function(job, progress, pos, name, output)
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
    local width, height = term.getSize()

    output.clear()
    output.setCursorPos(1, 1)
    output.setCursorBlink(false)
    local title = string.format("Quarry: %d x %d (%d)", job.left, job.forward, job.levels)
    if name ~= nil then
        if eventLib.online then
            title = string.format("[%s] %s", name, title)
        else
            title = string.format("|%s| %s", name, title)
        end
    end
    output.setTextColor(colors.white)
    text.center(title, output)

    output.setCursorPos(1, 3)
    output.setTextColor(colors.white)
    output.write(string.format("Total Progress %d%% (%d of %d)", progress.total * 100, progress.completedLevels + 1, job.levels))
    bar(output, 2, 5, progress.total)

    output.setCursorPos(1, 7)
    output.setTextColor(colors.white)
    output.write(string.format("Level Progress %d%% (%d of %d)", progress.level * 100, progress.currentRow, job.left))
    bar(output, 2, 9, progress.level)

    output.setCursorPos(1, 11)
    output.setTextColor(colors.white)
    text.center(progress.status, output)

    output.setCursorPos(1, height)
    output.setTextColor(colors.white)
    text.center(
        string.format("pos (%d, %d) e: %d, d: %d", pos.x, pos.z, pos.y, pos.dir),
        output
    )
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
        printQuarryProgress(event[3], event[4], event[5], name, output)
    end
end

eventLib.broadcast = function(event)
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

eventLib.broadcastProgressQuarry = function(job, progress, pos)
    v.expect(1, job, "table")
    v.expect(2, progress, "table")
    v.expect(3, pos, "table")

    eventLib.broadcast({eventLib.e.progress, eventLib.e.progress_quarry, job, progress, pos})
end

return eventLib
