local v = require("cc.expect")
local pp = require("cc.pretty")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

local log = require("log")
local eventLib = require("eventLib")
local progressLib = require("progressLib")
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
        totalPercent = 0, levelPercent = 0,
        completedLevels = 0, completedRows = 0,
        finished = true, status = "",
    },
    type = "table"
}
quarry.s.autoResume = {
    name = "quarry.autoResume",
    default = true,
    type = "boolean"
}
quarry.s.offsetPos = {
    name = "quarry.offsetPos",
    default = false,
}

settings.define(quarry.s.job.name, quarry.s.job)
settings.define(quarry.s.progress.name, quarry.s.progress)
settings.define(quarry.s.autoResume.name, quarry.s.autoResume)
settings.define(quarry.s.offsetPos.name, quarry.s.offsetPos)

local startPos = {x=0, y=0, z=1, dir=pathfind.c.FORWARD}

r = {}
r.running = 1
r.completed = 2
r.paused = 3
r.halted = 4

local runType = r.running

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

    progress.completedRows = rowNum - 1
    progress.levelPercent = progress.completedRows / job.left
    progress.totalPercent = progress.completedLevels / job.levels + job.levelProgress * progress.levelPercent
    progress.status = string.format("Digging Row %d", rowNum)
    setProgress(progress)

    log.log(string.format(
        "..Start row %d of %d (%d%%, %d%%)",
        rowNum, job.left,
        progress.levelPercent * 100, progress.totalPercent * 100
    ))
end

local function completeRow()
    local progress = getProgress()
    local job = getJob()

    progress.completedRows = progress.completedRows + 1
    progress.levelPercent = progress.completedRows / job.left
    progress.totalPercent = progress.completedLevels / job.levels + job.levelProgress * progress.levelPercent
    progress.status = string.format("Completed Row %d", progress.completedRows)
    setProgress(progress)
end

local function startLevel()
    local progress = getProgress()
    local job = getJob()

    progress.levelPercent = 0
    progress.status = string.format("Starting Level %d", progress.completedLevels + 1)
    setProgress(progress)

    log.log(string.format(
        ".Start level %d of %d (%d%%, %d%%)",
        progress.completedLevels + 1, job.levels,
        progress.levelPercent * 100, progress.totalPercent * 100
    ))
end

local function completeLevel()
    local progress = getProgress()
    local job = getJob()

    progress.completedLevels = progress.completedLevels + 1
    progress.completedRows = 0
    progress.levelPercent = 1
    progress.totalPercent = progress.completedLevels / job.levels
    progress.status = string.format("Completing Level %d", progress.completedLevels - 1)
    setProgress(progress)
end

local function finishJob()
    local progress = getProgress()
    progress.finished = true
    progress.status = "Finishing Job"
    setProgress(progress)
end

local function goToOffset()
    local offset = settings.get(quarry.s.offsetPos.name)
    if offset then
        setStatus("Going to Offset")
        while not pathfind.goTo(offset.x, offset.z, offset.y, offset.dir) do
            turtleCore.error("Cannot Goto Offset")
            sleep(3)
        end
        pathfind.addNode()
    end
end

local function digAndFill(count, fillLeft, fillRight, isLast)
    if count == nil then
        count = 1
    end
    if fillLeft == nil then
        fillLeft = false
    end
    if fillRight == nil then
        fillRight = false
    end
    if isLast == nil then
        isLast = false
    end
    v.expect(1, count, "number")
    v.expect(2, fillLeft, "boolean")
    v.expect(3, fillRight, "boolean")
    v.expect(4, isLast, "boolean")

    for i = 1, count, 1 do
        turtleCore.digForward()
        if not turtle.detectDown() and (isLast or turtleCore.isSourceBlockDown()) then
            turtleCore.fillDown(true)
        end
        if fillLeft then
            pathfind.turnLeft()
            turtleCore.fillForward(true)
            pathfind.turnRight()
        end
        if fillRight then
            pathfind.turnRight()
            turtleCore.fillForward(true)
            pathfind.turnLeft()
        end
        if runType ~= r.running then
            return
        end
    end
end

local function resetNodes()
    v.expect(1, startPos, "table")

    local offset = settings.get(quarry.s.offsetPos.name)

    pathfind.resetNodes()
    if offset then
        pathfind.addNode(offset)
    end
    pathfind.addNode(startPos)
end

local function resumeLevel(rowNum, isLast)
    setStatus(string.format("Returning to Row %d", rowNum))
    log.log(string.format("..Resume start: %s", pp.render(pp.pretty(startPos))))
    local job = getJob()
    local rotated = false
    local leftMod = -1
    local forwardMod = 1
    if startPos.dir == pathfind.c.RIGHT then
        rotated = true
        leftMod = 1
        forwardMod = 1
    elseif startPos.dir == pathfind.c.BACK then
        leftMod = 1
        forwardMod = -1
    elseif startPos.dir == pathfind.c.LEFT then
        rotated = true
        leftMod = -1
        forwardMod = -1
    end

    local currentX = startPos.x
    local currentZ = startPos.z

    local isEven = rowNum % 2 == 0
    if not isEven then
        local forwardCount = forwardMod * (job.forward - 1)
        log.log(string.format("..Resume: forward %d", job.forward - 1))
        if rotated then
            currentX = startPos.x + forwardCount
        else
            currentZ = startPos.z + forwardCount
        end
        pathfind.goTo(currentX, currentZ)
    end

    local leftCount = leftMod * (rowNum - 1)
    log.log(string.format("..Resume: left %d", rowNum - 1))
    if rotated then
        pathfind.goTo(currentX, currentZ + leftCount, nil, startPos.dir)
    else
        pathfind.goTo(currentX + leftCount, currentZ, nil, startPos.dir)
    end

    pathfind.turnLeft()
    log.log(string.format("..Resume: dig", rowNum - 1))
    digAndFill(1, isEven, not isEven, isLast)
    if isEven then
        log.log("..Resume: turn right")
        pathfind.turnRight()
    else
        log.log("..Resume: turn left")
        pathfind.turnLeft()
    end
end

local function digLevel(firstLevel, lastLevel)
    local job = getJob()
    local progressOneLevel = 1 / job.levels
    pathfind.turnTo(startPos.dir)

    startLevel()
    local pos = pathfind.getPosition()
    if pos.x == 0 and pos.z == 0 and pos.y == 0 then
        goToOffset()
        digAndFill(1, job.left == 1, true)
        if runType ~= r.running then
            return
        end
        pos = pathfind.getPosition()
    end
    startPos = ghu.copy(pos)
    resetNodes()

    local progress = getProgress()
    local levelsDown = pos.y - startPos.y
    if progress.completedLevels > 0 then
        turtleCore.digDown(progress.completedLevels + levelsDown)
    end

    pathfind.turnRight()
    turtleCore.fillForward(true)
    if not firstLevel then
        pathfind.turnRight()
        turtleCore.fillForward(true)
        pathfind.turnLeft()
    end
    pathfind.turnLeft()
    if lastLevel then
        turtleCore.fillDown(true)
    end

    if progress.completedRows > 0 then
        resumeLevel(progress.completedRows, lastLevel)
    end

    for row = progress.completedRows + 1, job.left, 1 do
        local isEvenRow = row % 2 == 0
        local isLastRow = row == job.left

        startRow(row)
        local fillLeft = isLastRow and not isEvenRow
        local fillRight = row == 1 or (isLastRow and isEvenRow)
        digAndFill(job.forward - 1, fillLeft, fillRight, lastLevel)
        if runType ~= r.running then
            return
        end

        -- fill end block
        turtleCore.fillForward(true)
        if row < job.left then
            if isEvenRow then
                pathfind.turnRight()
            else
                pathfind.turnLeft()
            end
            digAndFill(1, isEvenRow, not isEvenRow)
            if runType ~= r.running then
                return
            end
            if (row + 1) == job.left then
                turtleCore.fillForward(true)
            end
            if isEvenRow then
                pathfind.turnRight()
            else
                pathfind.turnLeft()
            end

            if lastLevel then
                turtleCore.fillDown(true)
            end
        end
        completeRow()

        if runType ~= r.running then
            return
        end
    end

    progress = getProgress()
    log.log(string.format(
        "..Return to start (%d%%, %d%%)",
        progress.levelPercent * 100, progress.totalPercent * 100
    ))
    while not pathfind.goTo(startPos.x, startPos.z, nil, startPos.dir) do
        turtleCore.error("Cannot Return to Start")
        sleep(3)
    end
    completeLevel()
end

quarry.setOffset = function(x, z, y, dir)
    v.expect(1, x, "number")
    v.expect(2, y, "number")
    v.expect(3, z, "number")
    v.expect(4, dir, "number")
    v.range(dir, 1, 4)

    settings.set(quarry.s.offsetPos.name, {x=x, y=y, z=z, dir=dir})
    settings.save()
end

quarry.clearOffset = function()
    settings.set(quarry.s.offsetPos.name, false)
    settings.save()
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

    eventLib.b.turtleStarted()
    turtleCore.emptyInventory()
    local progress = getProgress()
    while progress.completedLevels < job.levels and (runType == r.running or runType == r.paused) do
        if runType == r.running then
            if progress.completedLevels % job.refuelLevel == 0 then
               turtleCore.goRefuel(job.refuelTarget, progress.completedLevels ~= 0)
            end
            digLevel(progress.completedLevels == 0, (progress.completedLevels + 1) == job.levels)
            progress = getProgress()

            if runType == r.paused then
                turtleCore.emptyInventory()
                eventLib.b.turtlePaused()
            end
        else
            sleep(5)
        end
    end
    finishJob()
    turtleCore.emptyInventory()
    if runType == r.halted then
        eventLib.b.turtleHalted()
        sleep(3)
        runType = r.completed
    else
        eventLib.b.turtleCompleted()
    end
end

local eventLoop = function()
    while runType ~= r.completed do
        -- timeout timer
        local timer = os.startTimer(3)
        local data = {os.pullEvent()}
        local event = data[1]
        local subEvent = data[2]

        if event == eventLib.e.turtle then
            if subEvent == eventLib.e.turtle_empty then
                setStatus("Emptying Inventory")
            elseif subEvent == eventLib.e.turtle_completed then
                setStatus("success:Completed")
                runType = r.completed
            elseif subEvent == eventLib.e.turtle_requestPause then
                runType = r.paused
                log.log("Pausing...")
            elseif subEvent == eventLib.e.turtle_requestHalt then
                runType = r.halted
                log.log("Halting...")
            elseif subEvent == eventLib.e.turtle_requestContinue then
                runType = r.running
                log.log("Unpausing...")
                eventLib.b.turtleStarted()
            elseif subEvent == eventLib.e.turtle_halted then
                setStatus("error:Stopped")
            elseif subEvent == eventLib.e.turtle_paused then
                setStatus("warning:Paused")
            elseif subEvent == eventLib.e.turtle_getFill then
                setStatus("Getting Fill Block")
            elseif subEvent == eventLib.e.turtle_refuel then
                setStatus("Refueling")
            elseif subEvent == eventLib.e.turtle_error then
                setStatus(string.format("error:%s", data[3]))
            end
        elseif event == eventLib.e.pathfind then
            if subEvent == eventLib.e.pathfind_pos then
                fireProgressEvent(data[3])
            elseif subEvent == eventLib.e.pathfind_goToReturn then
                if data[5] == nil then
                    setStatus("Resuming")
                else
                    local progress = getProgress()
                    local job = getJob()
                    if progress.completedRows == job.left then
                        setStatus(string.format("Completed Row %d", progress.completedRows))
                    else
                        setStatus(string.format("Digging Row %d", progress.completedRows + 1))
                    end
                end
            end
        elseif event == eventLib.e.progress then
            if not settings.get(log.s.print.name) then
                eventLib.printProgress(data)
            end
        end
        progressLib.handleEvent(data)
        os.cancelTimer(timer)
    end
end

local netEventLoop = function()
    if not eventLib.online then
        return
    end

    while runType ~= r.completed do
        local id, data = rednet.receive(nil, 3)
        if data ~= nil and data.type == eventLib.e.type then
            if data.event[1] == eventLib.e.turtle then
                if data.event[2] == eventLib.e.turtle_requestHalt and data.event[3] == eventLib.getName() then
                    runType = r.halted
                    log.log("Halting...")
                elseif data.event[2] == eventLib.e.turtle_requestPause and data.event[3] == eventLib.getName() then
                    runType = r.paused
                    log.log("Pausing...")
                elseif data.event[2] == eventLib.e.turtle_requestContinue and data.event[3] == eventLib.getName() then
                    runType = r.running
                    log.log("Unpausing...")
                    eventLib.b.turtleStarted()
                end
            end
        end
    end
end

quarry.runJob = function(resume)
    if resume == nil then
        resume = false
    end
    v.expect(1, resume, "boolean")

    eventLib.initNetwork()
    local job = getJob()
    term.clear()
    term.setCursorPos(1, 1)
    if resume then
        log.log(string.format("Resume Quarry: %d x %d (%d)", job.left, job.forward, job.levels))
        setStatus("Resuming")
        if not settings.get(log.s.print.name) then
            progressLib.quarry(term, job, getProgress(), pathfind.getPosition(), eventLib.getName(), eventLib.online)
        end
    else
        log.log(string.format("Quarry: %d x %d (%d)", job.left, job.forward, job.levels))
    end

    parallel.waitForAll(runLoop, eventLoop, netEventLoop)
    term.setCursorBlink(true)
    log.setPrint(true)
end

return quarry
