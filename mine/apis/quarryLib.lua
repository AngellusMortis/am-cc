local v = require("cc.expect")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

local log = require("log")
local eventLib = require("eventLib")
local pathfind = require("pathfind")
local turtleCore = require("turtleCore")

local quarry = {}
quarry.s = {}
quarry.s.job = {
    name = "quarry.job",
    default = {
        left = 16, forward = 16, levels = 1,
        refuelTarget = 320, refuelLevel = 1,
        levelProgress = 1,
    },
    type = "table"
}
quarry.s.progress = {
    name = "quarry.progress",
    default = {
        total = 0, level = 0,
        completedLevels = 0, currentRow = 1,
        finished = true, status = "",
    },
    type = "table"
}
quarry.s.autoResume = {
    name = "quarry.autoResume",
    default = true,
    type = "boolean"
}

settings.define(quarry.s.job.name, quarry.s.job)
settings.define(quarry.s.progress.name, quarry.s.progress)
settings.define(quarry.s.autoResume.name, quarry.s.autoResume)

local function getProgress()
    return ghu.copy(settings.get(quarry.s.progress.name))
end

local function getJob()
    return settings.get(quarry.s.job.name)
end

local function fireProgressEvent(pos)
    if pos == nil then
        pos = pathfind.getPosition()
    end

    local job = getJob()
    local progress = getProgress()
    eventLib.b.progressQuarry(job, progress, pos)
end

local function setProgress(progress)
    v.expect(1, progress, "table")

    settings.set(quarry.s.progress.name, progress)
    settings.save()
    fireProgressEvent()
end

local function setStatus(status)
    v.expect(1, status, "string")

    local progress = getProgress()
    progress.status = status

    setProgress(progress)
end

local function calulateRefuel(left, forward, levels)
    v.expect(1, left, "number")
    v.expect(2, forward, "number")
    v.expect(3, levels, "number")
    v.range(left, 1)
    v.range(forward, 1)
    v.range(levels, 1)

    local fuelPerLevel = left * forward + (left * 2) + (forward * 2)
    local requiredFuel = fuelPerLevel
    local refuelLevel = levels
    if turtle.getFuelLimit() == "unlimited" then
        requiredFuel = fuelPerLevel * levels
    else
        refuelLevel = 1
        while refuelLevel < levels and (requiredFuel + fuelPerLevel) < turtle.getFuelLimit() do
            requiredFuel = requiredFuel + fuelPerLevel
            refuelLevel = refuelLevel + 1
        end
    end

    return requiredFuel, refuelLevel
end

local function startRow(rowNum)
    v.expect(1, rowNum, "number")
    v.range(rowNum, 1)

    local progress = getProgress()
    local job = getJob()

    progress.currentRow = rowNum
    progress.level = (progress.currentRow - 1) / job.left
    progress.total = progress.completedLevels / job.levels + job.levelProgress * progress.level
    progress.status = string.format("Digging Row %d", progress.currentRow)
    setProgress(progress)

    log.log(string.format(
        "..Start row %d of %d (%d%%, %d%%)",
        progress.currentRow, job.left,
        progress.level * 100, progress.total * 100
    ))
end

local function completeRow()
    local progress = getProgress()
    local job = getJob()

    progress.level = progress.currentRow / job.left
    progress.total = progress.completedLevels / job.levels + job.levelProgress * progress.level
    progress.status = string.format("Completing Row %d", progress.currentRow)
    setProgress(progress)
end

local function startLevel()
    local progress = getProgress()
    local job = getJob()

    progress.level = 0
    progress.status = string.format("Starting Level %d", progress.completedLevels + 1)
    setProgress(progress)

    log.log(string.format(
        ".Start level %d of %d (%d%%, %d%%)",
        progress.completedLevels + 1, job.levels,
        progress.level * 100, progress.total * 100
    ))
end

local function completeLevel()
    local progress = getProgress()
    local job = getJob()

    progress.completedLevels = progress.completedLevels + 1
    progress.level = 1
    progress.total = progress.completedLevels / job.levels
    progress.status = string.format("Completing Level %d", progress.completedLevels - 1)
    setProgress(progress)
end

local function finishJob()
    local progress = getProgress()
    progress.finished = true
    progress.status = "Finishing Job"
    setProgress(progress)
end

local function digLevel()
    local job = getJob()
    local progressOneLevel = 1 / job.levels
    pathfind.turnTo(pathfind.c.FORWARD)

    startLevel()
    local pos = pathfind.getPosition()
    if pos.x == 0 and pos.z == 0 then
        turtleCore.digForward()
    end

    local progress = getProgress()
    if progress.completedLevels > 0 then
        turtleCore.digDown(progress.completedLevels + pos.y)
    end

    for row = 1, job.left, 1 do
        startRow(row)
        turtleCore.digForward(job.forward - 1)

        if row < job.left then
            pathfind.turnTo(pathfind.c.LEFT)
            turtleCore.digForward()

            if row % 2 == 0 then
                pathfind.turnTo(pathfind.c.FORWARD)
            else
                pathfind.turnTo(pathfind.c.BACK)
            end
        end
        completeRow()
    end

    progress = getProgress()
    log.log(string.format(
        "..Return to start (%d%%, %d%%)",
        progress.level * 100, progress.total * 100
    ))
    if not pathfind.goTo(0, 1) then
        error("Could not return to start")
    end
    completeLevel()
end

quarry.canResume = function()
    local progress = getProgress()
    return settings.get(quarry.s.autoResume.name) and not progress.finished
end

quarry.setJob = function(left, forward, levels)
    v.expect(1, left, "number")
    v.expect(2, forward, "number")
    v.expect(3, levels, "number")
    v.range(left, 1)
    v.range(forward, 1)
    v.range(levels, 1)

    local refuelTarget, refuelLevel = calulateRefuel(left, forward, levels)
    local levelProgress = 1 / levels
    settings.set(quarry.s.job.name, {
        left = left, forward = forward, levels = levels,
        refuelTarget = refuelTarget, refuelLevel = refuelLevel,
        levelProgress = levelProgress,
    })
    settings.save()

    local progress = ghu.copy(quarry.s.progress.default)
    progress.finished = false
    setProgress(progress)
end

local runLoop = function()
    local job = getJob()

    turtleCore.emptyInventory()
    local progress = getProgress()
    while progress.completedLevels < job.levels do
        if progress.completedLevels % job.refuelLevel == 0 then
            turtleCore.goRefuel(job.refuelLevel, progress.completedLevels ~= 0)
        end
        digLevel()
        progress = getProgress()
    end
    finishJob()
    turtleCore.emptyInventory()
end

local eventLoop = function()
    while true do
        local data = {os.pullEvent()}
        local event = data[1]
        local subEvent = data[2]

        if event == eventLib.e.turtle then
            if subEvent == eventLib.e.turtle_empty then
                setStatus("Emptying Inventory")
            elseif subEvent == eventLib.e.turtle_refuel then
                setStatus("Refueling")
            elseif subEvent == eventLib.e.turtle_error then
                setStatus(string.format("Error:%s", data[3]))
            end
        elseif event == eventLib.e.pathfind then
            if subEvent == eventLib.e.pathfind_pos then
                fireProgressEvent(data[3])
            elseif subEvent == eventLib.e.pathfind_goToReturn then
                setStatus("Resuming")
            end
        elseif event == eventLib.e.progress then
            if not settings.get(log.s.print.name) then
                eventLib.printProgress(data)
            end
        end
    end
end

quarry.runJob = function(resume)
    if resume == nil then
        resume = false
    end
    v.expect(1, resume, "boolean")

    local job = getJob()
    term.clear()
    term.setCursorPos(1, 1)
    if resume then
        log.log(string.format("Resume Quarry: %d x %d (%d)", job.left, job.forward, job.levels))
        setStatus("Resuming")
        if not settings.get(log.s.print.name) then
            eventLib.printQuarryProgress(job, getProgress(), pathfind.getPosition(), eventLib.getName())
        end
    else
        log.log(string.format("Quarry: %d x %d (%d)", job.left, job.forward, job.levels))
    end

    parallel.waitForAny(runLoop, eventLoop)
    term.setCursorBlink(true)
    log.setPrint(true)
end

return quarry
