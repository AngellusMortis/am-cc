local v = require("cc.expect")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

local text = require("text")
local ui = require("buttonH").terminal

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

local initNetwork = function()
    if initalizedNetwork then
        return
    end

    eventLib.online = false
    peripheral.find("modem", function(name, modem)
        rednet.open(name)
        eventLib.online = true
    end)
    initalizedNetwork = true
end

local printQuarryProgress = function(job, progress, pos, name)
    v.expect(1, job, "table")
    v.expect(2, progress, "table")
    v.expect(3, pos, "table")

    initNetwork()
    local width, height = term.getSize()

    term.clear()
    term.setCursorPos(1, 1)
    term.setCursorBlink(false)
    local title = string.format("Quarry: %d x %d (%d)", job.left, job.forward, job.levels)
    if name ~= nil then
        if eventLib.online then
            title = string.format("[%s] %s", name, title)
        else
            title = string.format("|%s| %s", name, title)
        end
    end
    text.center(title)

    term.setCursorPos(1, 3)
    term.write(string.format("Total Progress %d%% (%d of %d)", progress.total * 100, progress.completedLevels + 1, job.levels))
    ui.bar(
        2, 5, width-1, 1, progress.total, 1,
        "lightGray", "green", "gray",
        false, false, "", true, true, false
    )

    term.setCursorPos(1, 7)
    term.write(string.format("Level Progress %d%% (%d of %d)", progress.level * 100, progress.currentRow, job.left))
    ui.bar(
        2, 9, width-1, 1, progress.level, 1,
        "lightGray", "green", "gray",
        false, false, "", true, true, false
    )

    term.setCursorPos(1, 11)
    text.center(progress.status)

    term.setCursorPos(1, height)
    text.center(string.format("pos (%d, %d) e: %d, d: %d", pos.x, pos.z, pos.y, pos.dir))
    term.setCursorPos(1, height)
end

eventLib.printProgress = function(event, name)
    if name == nil then
        name = eventLib.getName()
    end

    local progressType = event[2]
    if progressType == eventLib.e.progress_quarry then
        printQuarryProgress(event[3], event[4], event[5], name)
    end
end

eventLib.broadcast = function(event)
    v.expect(1, event, "table")

    os.queueEvent(table.unpack(event))
    initNetwork()
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
