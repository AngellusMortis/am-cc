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
        finished = true
    },
    type = "table"
}

settings.define(quarry.s.job.name, quarry.s.job)
settings.define(quarry.s.progress.name, quarry.s.progress)

local function getProgress()
    local progress = settings.get(quarry.s.progress.name)
    return {
        total = progress.total,
        level = progress.level,
        completedLevels = progress.completedLevels,
        finished = progress.finished
    }
end

local function setProgress(progress)
    settings.set(quarry.s.progress.name, progress)
end

local function getJob()
    return settings.get(quarry.s.job.name)
end

local function calulateRefuel(left, forward, levels)
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
    local progress = getProgress()
    local job = getJob()

    progress.currentRow = rowNum
    progress.level = (progress.currentRow - 1) / job.left
    progress.total = progress.completedLevels / job.levels + job.levelProgress * progress.level
    setProgress(progress)

    print(string.format(
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
    setProgress(progress)
end

local function startLevel()
    local progress = getProgress()
    local job = getJob()

    progress.level = 0
    setProgress(progress)

    print(string.format(
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
    setProgress(progress)
end

local function finishJob()
    local progress = getProgress()
    progress.finished = true
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
    print(string.format(
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
    return not progress.finished
end

quarry.setJob = function(left, forward, levels)
    local refuelTarget, refuelLevel = calulateRefuel(left, forward, levels)
    local levelProgress = 1 / levels
    settings.set(quarry.s.job.name, {
        left = left, forward = forward, levels = levels,
        refuelTarget = refuelTarget, refuelLevel = refuelLevel,
        levelProgress = levelProgress,
    })
    setProgress(ghu.copy(quarry.s.progress.default))
end

quarry.runJob = function(resume)
    if resume == nil then
        resume = false
    end

    local job = getJob()
    term.clear()
    term.setCursorPos(1, 1)
    if resume then
        print(string.format("Resume Quarry: %d x %d (%d)", job.left, job.forward, job.levels))
    else
        print(string.format("Quarry: %d x %d (%d)", job.left, job.forward, job.levels))
    end

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

return quarry
