local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local BaseObject = require("am.ui.base").BaseObject

local core = require("am.core")
local log = require("am.log")
local e = require("am.event")
local h = require("am.helpers")
local p = require("am.progress")
local pf = require("am.pathfind")
local tc = require("am.turtle")

local q = {}

---@class am.q.QuarryJob:am.ui.b.BaseObject
---@field left number|nil
---@field forward number|nil
---@field levels number
---@field walls boolean
---@field refuelTarget number
---@field refuelLevel number
---@field percentPerLevel number
local QuarryJob = BaseObject:extend("am.q.QuarryJob")
q.QuarryJob = QuarryJob
function QuarryJob:init(left, forward, levels, walls, restore)
    v.expect(1, left, "number", "nil")
    v.expect(2, forward, "number", "nil")
    v.expect(3, levels, "number")
    v.expect(4, walls, "boolean")
    v.expect(5, restore, "boolean", "nil")
    if left ~= nil then
        v.range(left, 1)
    end
    if forward ~= nil then
        v.range(forward, 1)
    end
    QuarryJob.super.init(self)
    if left == nil or forward == nil then
        restore = true
    end
    if restore == nil then
        restore = false
    end

    self.left = left
    self.forward = forward
    self.levels = levels
    self.walls = walls
    self.refuelTarget = 320
    self.refuelLevel = 1
    self.percentPerLevel = 1
    if not restore then
        self:calculateExtra()
    end
    return self
end

---@class am.q.ReadyQuarryJob:am.q.QuarryJob
---@field left number
---@field forward number
local ReadyQuarryJob = QuarryJob:extend("am.q.ReadyQuarryJob")
q.ReadyQuarryJob = ReadyQuarryJob

function QuarryJob:calculateExtra()
    local fuelPerLevel = self.left * self.forward + (self.left * 2) + (self.forward * 2)
    local requiredFuel = fuelPerLevel
    local refuelLevel = self.levels
    if turtle.getFuelLimit() == "unlimited" then
        requiredFuel = fuelPerLevel * self.levels
    else
        refuelLevel = 1
        while refuelLevel < self.levels and (requiredFuel + fuelPerLevel) < turtle.getFuelLimit() do
            requiredFuel = requiredFuel + fuelPerLevel
            refuelLevel = refuelLevel + 1
        end
    end

    self.refuelTarget = requiredFuel
    self.refuelLevel = refuelLevel
    self.percentPerLevel = 1 / self.levels
end

---@param raw table
---@return am.q.QuarryJob
function QuarryJob:deserialize(raw)
    local job = QuarryJob(raw.left, raw.forward, raw.levels, raw.walls, true)
    job.refuelTarget = raw.refuelTarget
    job.refuelLevel = raw.refuelLevel
    job.percentPerLevel = raw.percentPerLevel

    return job
end

---@class am.q.QuarryProgress:am.ui.b.BaseObject
---@field current number
---@field levelCurrent number
---@field completedLevels number
---@field completedRows number
---@field finished boolean
---@field status string
---@field hitBedrock boolean
---@field items table<string, cc.item>
local QuarryProgress = BaseObject:extend("am.q.QuarryProgress")
q.QuarryProgress = QuarryProgress
function QuarryProgress:init(
    current, levelCurrent, completedLevels, completedRows, finished, status
)
    v.expect(1, current, "number")
    v.expect(2, levelCurrent, "number")
    v.expect(3, completedLevels, "number")
    v.expect(4, completedRows, "number")
    v.expect(5, finished, "boolean")
    v.expect(6, status, "string")
    v.range(current, 0)
    v.range(levelCurrent, 0)
    v.range(completedLevels, 0)
    v.range(completedRows, 0)
    QuarryJob.super.init(self)

    self.current = current
    self.levelCurrent = levelCurrent
    self.completedLevels = completedLevels
    self.completedRows = completedRows
    self.finished = finished
    self.status = status
    self.hitBedrock = false
    self.items = {}
    return self
end

---@param raw table
---@return am.q.QuarryProgress
function QuarryProgress:deserialize(raw)
    local progress = QuarryProgress(
        raw.current,
        raw.levelCurrent,
        raw.completedLevels,
        raw.completedRows,
        raw.finished,
        raw.status
    )
    if raw.hitBedrock ~= nil then
        progress.hitBedrock = raw.hitBedrock
    end
    if raw.items ~= nil then
        progress.items = raw.items
    end
    return progress
end

local s = {}
s.job = {
    name = "quarry.job",
    default = QuarryJob(16, 16, 1, true),
    type = "table"
}
s.progress = {
    name = "quarry.progress",
    default = QuarryProgress(0, 0, 0, 0, true, ""),
    type = "table"
}
s.autoResume = {
    name = "quarry.autoResume",
    default = true,
    type = "boolean"
}
s.offsetPos = {
    name = "quarry.offsetPos",
    default = false,
}
q.s = core.makeSettingWrapper(s)
q.s.job.get = function()
    return QuarryJob.deserialize(nil, settings.get(q.s.job.name))
end
q.s.progress.get = function()
    return QuarryProgress.deserialize(nil, settings.get(q.s.progress.name))
end
q.s.offsetPos.get = function()
    local raw = settings.get(q.s.offsetPos.name)
    if raw then
        raw = pf.TurtlePosition.deserialize(nil, settings.get(q.s.offsetPos.name))
    end
    return raw
end

local START_POS = pf.TurtlePosition(vector.new(0, 0, 1), e.c.Turtle.Direction.Front)
---@type table<string, number>
local RunType = {
    Running = 1,
    Completed = 2,
    Paused = 3,
    Halted = 4
}

local CURRENT = RunType.Running
local RUN_EVENT_LOOP = true
local PREVIOUS_STATUS = nil

---@param pos? am.p.TurtlePosition
local function fireProgressEvent(pos, progress)
    v.expect(1, pos, "table", "nil")
    v.expect(2, progress, "table", "nil")
    if pos ~= nil then
        h.requirePosition(1, pos)
    end

    if pos == nil then
        pos = pf.s.position.get()
    end
    if progress == nil then
        progress = q.s.progress.get()
    end
    e.QuarryProgressEvent(pos, q.s.job.get(), progress):send()
end

---@param progress am.q.QuarryProgress
local function setProgress(progress)
    v.expect(1, progress, "table")
    if not BaseObject.has(progress, "am.q.QuarryProgress") then
        error("Not progress obj")
    end

    q.s.progress.set(progress)
    fireProgressEvent(nil, progress)
end

---@param status string
local function setStatus(status)
    v.expect(1, status, "string")

    local progress = q.s.progress.get()
    progress.status = status
    setProgress(progress)
end

---@param event am.e.TurtleEmptyEvent
local function addItems(event)
    local progress = q.s.progress.get()
    for _, item in ipairs(event.items) do
        if progress.items[item.name] == nil then
            progress.items[item.name] = item
        else
            local curItem = progress.items[item.name]
            curItem.count = curItem.count + item.count
            progress.items[item.name] = curItem
        end
    end
    setProgress(progress)
end

---@param rowNum number
local function startRow(rowNum)
    v.expect(1, rowNum, "number")
    v.range(rowNum, 1)

    local progress = q.s.progress.get()
    local job = q.s.job.get()
    ---@cast job am.q.ReadyQuarryJob

    progress.completedRows = rowNum - 1
    progress.levelCurrent = progress.completedRows / job.left
    progress.current = progress.completedLevels / job.levels + job.percentPerLevel * progress.levelCurrent
    progress.status = string.format("Digging Row %d", rowNum)
    setProgress(progress)

    log.info(string.format(
        "..Start row %d of %d (%d%%, %d%%)",
        rowNum, job.left,
        progress.levelCurrent * 100, progress.current * 100
    ))
end

local function completeRow()
    local progress = q.s.progress.get()
    local job = q.s.job.get()
    ---@cast job am.q.ReadyQuarryJob

    progress.completedRows = progress.completedRows + 1
    progress.levelCurrent = progress.completedRows / job.left
    progress.current = progress.completedLevels / job.levels + job.percentPerLevel * progress.levelCurrent
    progress.status = string.format("Completed Row %d", progress.completedRows)
    setProgress(progress)
end

local function startLevel()
    local progress = q.s.progress.get()
    local job = q.s.job.get()
    ---@cast job am.q.ReadyQuarryJob

    progress.levelCurrent = 0
    progress.status = string.format("Starting Level %d", progress.completedLevels + 1)
    setProgress(progress)

    log.info(string.format(
        ".Start level %d of %d (%d%%, %d%%)",
        progress.completedLevels + 1, job.levels,
        progress.levelCurrent * 100, progress.current * 100
    ))
end

local function completeLevel()
    local progress = q.s.progress.get()
    local job = q.s.job.get()
    ---@cast job am.q.ReadyQuarryJob

    progress.completedLevels = progress.completedLevels + 1
    progress.completedRows = 0
    progress.levelCurrent = 1
    progress.current = progress.completedLevels / job.levels
    progress.status = string.format("Completing Level %d", progress.completedLevels - 1)
    setProgress(progress)
end

local function finishJob()
    local progress = q.s.progress.get()
    progress.finished = true
    progress.status = "Finishing Job"
    setProgress(progress)
    log.info("Finishing Quarry...")

    sleep(5)
    RUN_EVENT_LOOP = false
    log.info("Items Mined:")
    local items = p.itemStrings(progress.items)
    for _, item in ipairs(items) do
        log.info(item)
    end
end

local function goToOffset()
    local offset = q.s.offsetPos.get()
    if offset then
        setStatus("Going to Offset")
        while not pf.goTo(offset.v.x, offset.v.z, offset.v.y, offset.dir) do
            tc.error("Cannot Goto Offset")
            sleep(3)
        end
        pf.addNode()
    end
end

---@param count? number
---@param walls? boolean
---@param fillLeft? boolean
---@param fillRight? boolean
---@param isLast? boolean
---@return boolean
local function digAndFill(count, walls, fillLeft, fillRight, isLast)
    v.expect(1, count, "number", "nil")
    v.expect(2, walls, "boolean", "nil")
    v.expect(3, fillLeft, "boolean", "nil")
    v.expect(4, fillRight, "boolean", "nil")
    v.expect(5, isLast, "boolean", "nil")
    if count == nil then
        count = 1
    end
    if walls == nil then
        walls = true
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

    for i = 1, count, 1 do
        local wasBlock = turtle.detect()
        if not tc.dig() then
            return false
        end
        if not turtle.detectDown() and ((isLast and walls) or tc.isSourceBlockDown()) then
            tc.fillDown(true)
        end
        if walls then
            if fillLeft then
                pf.turnLeft()
                tc.fill(true)
                pf.turnRight()
            end
            if fillRight then
                pf.turnRight()
                tc.fill(true)
                pf.turnLeft()
            end
        end
        if CURRENT ~= RunType.Running then
            return true
        end
    end
    return true
end

local function resetNodes()
    local offset = q.s.offsetPos.get()
    pf.resetNodes()
    if offset then
        pf.addNode(offset)
    end
    pf.addNode(START_POS)
end

---@param rowNum number
---@param isLast boolean
---@return boolean
local function resumeLevel(rowNum, isLast)
    setStatus(string.format("Returning to Row %d", rowNum))
    log.info(string.format("..Resume start: %s", log.format(START_POS)))
    local job = q.s.job.get()
    ---@cast job am.q.ReadyQuarryJob
    local rotated = false
    local leftMod = -1
    local forwardMod = 1
    if START_POS.dir == e.c.Turtle.Direction.Right then
        rotated = true
        leftMod = 1
        forwardMod = 1
    elseif START_POS.dir == e.c.Turtle.Direction.Back then
        leftMod = 1
        forwardMod = -1
    elseif START_POS.dir == e.c.Turtle.Direction.Left then
        rotated = true
        leftMod = -1
        forwardMod = -1
    end

    local currentX = START_POS.v.x
    local currentZ = START_POS.v.z

    local isEven = rowNum % 2 == 0
    if not isEven then
        local forwardCount = forwardMod * (job.forward - 1)
        log.info(string.format("..Resume: forward %d", job.forward - 1))
        if rotated then
            currentX = START_POS.v.x + forwardCount
        else
            currentZ = START_POS.v.z + forwardCount
        end
        pf.goTo(currentX, currentZ)
    end

    local leftCount = leftMod * (rowNum - 1)
    log.info(string.format("..Resume: left %d", rowNum - 1))
    if rotated then
        pf.goTo(currentX, currentZ + leftCount, nil, START_POS.dir)
    else
        pf.goTo(currentX + leftCount, currentZ, nil, START_POS.dir)
    end

    pf.turnLeft()
    log.info(string.format("..Resume: dig", rowNum - 1))
    if not digAndFill(1, job.walls, isEven, not isEven, isLast) then
        return false
    end
    if isEven then
        log.info("..Resume: turn right")
        pf.turnRight()
    else
        log.info("..Resume: turn left")
        pf.turnLeft()
    end
    return true
end

---@param firstLevel boolean
---@param lastLevel boolean
---@return boolean
local function digLevel(firstLevel, lastLevel)
    local job = q.s.job.get()
    ---@cast job am.q.ReadyQuarryJob
    local walls = not firstLevel and job.walls
    pf.turnTo(START_POS.dir)

    startLevel()
    local pos = pf.s.position.get()
    if pos.v.x == 0 and pos.v.z == 0 and pos.v.y == 0 then
        goToOffset()
        if not digAndFill(1, walls, job.left == 1, true) then
            return false
        end
        if CURRENT ~= RunType.Running then
            return true
        end
        pos = pf.s.position.get()
        START_POS = core.copy(pos)
    end

    local progress = q.s.progress.get()
    local levelsDown = pos.v.y - START_POS.v.y
    if progress.completedLevels > 0 then
        for i = 1, progress.completedLevels + levelsDown, 1 do
            if not tc.digDown() then
                return false
            end
        end
    end

    if walls then
        pf.turnRight()
        tc.fill(true)
        if not firstLevel then
            pf.turnRight()
            tc.fill(true)
            pf.turnLeft()
        end
        pf.turnLeft()
        if lastLevel then
            tc.fillDown(true)
        end
    end

    if progress.completedRows > 0 then
        if not resumeLevel(progress.completedRows, lastLevel) then
            return false
        end
    end

    for row = progress.completedRows + 1, job.left, 1 do
        resetNodes()
        local isEvenRow = row % 2 == 0
        local isLastRow = row == job.left

        startRow(row)
        local fillLeft = isLastRow and not isEvenRow
        local fillRight = row == 1 or (isLastRow and isEvenRow)
        if not digAndFill(job.forward - 1, walls, fillLeft, fillRight, lastLevel) then
            return false
        end
        if CURRENT ~= RunType.Running then
            return true
        end

        -- fill end block
        if walls then
            tc.fill(true)
        end
        if row < job.left then
            if isEvenRow then
                pf.turnRight()
            else
                pf.turnLeft()
            end
            if not digAndFill(1, walls, isEvenRow, not isEvenRow) then
                return false
            end
            if CURRENT ~= RunType.Running then
                return true
            end
            if (row + 1) == job.left and walls then
                tc.fill(true)
            end
            if isEvenRow then
                pf.turnRight()
            else
                pf.turnLeft()
            end

            if lastLevel and walls then
                tc.fillDown(true)
            end
        end
        completeRow()

        if CURRENT ~= RunType.Running then
            return true
        end
    end

    progress = q.s.progress.get()
    log.info(string.format(
        "..Return to start (%d%%, %d%%)",
        job.percentPerLevel * 100, progress.current * 100
    ))
    while not pf.goTo(START_POS.v.x, START_POS.v.z, nil, START_POS.dir) do
        tc.error("Cannot Return to Start")
        sleep(3)
    end
    completeLevel()
    return true
end

---@param x number
---@param z number
---@param y number
---@param dir number
local function setOffset(x, z, y, dir)
    v.expect(1, x, "number")
    v.expect(2, y, "number")
    v.expect(3, z, "number")
    v.expect(4, dir, "number")
    v.range(dir, 1, 4)

    q.s.offsetPos.set(pf.TurtlePosition(vector.new(x, y, z), dir))
end

local function clearOffset()
    s.offsetPos.set(false)
end

---@return boolean
local function canResume()
    return q.s.autoResume.get() and not q.s.progress.get().finished
end

---@param left? number
---@param forward? number
---@param levels number
---@param walls boolean
local function setJob(left, forward, levels, walls)
    v.expect(1, left, "number", "nil")
    v.expect(2, forward, "number", "nil")
    v.expect(3, levels, "number")
    if left ~= nil then
        v.range(left, 1)
    end
    if forward ~= nil then
        v.range(forward, 1)
    end
    v.range(levels, 1)

    local job = QuarryJob(left, forward, levels, walls)
    q.s.job.set(job)

    local progress = core.copy(q.s.progress.default)
    progress.finished = false
    setProgress(progress)
end

---@return number, number
local function discoverBoundary()
    log.info("Discovering Boundary")
    setStatus("Discovering Boundary")
    tc.refuel(500) -- allow discover of a 64x64 size boundary
    local startingOffset = q.s.offsetPos.get()
    goToOffset()
    setStatus("Discovering Boundary")
    tc.dig()
    pf.turnRight()
    if not turtle.detect() then
        while pf.forward() do end
        pf.turnLeft()
        while pf.forward() do end
        pf.turnRight()
        tc.dig()
        pf.turnRight()
        pf.turnRight()
        local pos = pf.s.position.get()
        q.setOffset(pos.v.x, pos.v.z, pos.v.y, pos.dir)
        log.info(string.format("Setting new offset: %s", log.format(pos)))
        setStatus(string.format("Set Offset: (%d, %d)", pos.v.x, pos.v.z))
        pf.forward()
        pf.turnRight()
    end
    local forward = 1
    local left = 1
    pf.turnLeft()
    while pf.forward() do
        forward = forward + 1
    end
    pf.turnLeft()
    while pf.forward() do
        left = left + 1
        local pos = pf.s.position.get()
        if pos.v.x == 0 and pos.v.z == 1 then
            break
        end
    end
    log.info(string.format("Discovered Boundary: %d %d", left, forward))
    setStatus(string.format("Discovered: %dx%d", left, forward))
    pf.resetNodes()
    if startingOffset then
        pf.addNode(startingOffset)
    end
    pf.goToOrigin()
    pf.resetNodes()
    return left, forward
end

local function runLoop()
    local job = q.s.job.get()
    if job.left == nil or job.forward == nil then
        local left, forward = discoverBoundary()
        setJob(left, forward, job.levels, job.walls)
        job = q.s.job.get()
        completeLevel()
        pf.resetNodes()
        pf.resetNodes(true)
    end
    ---@cast job am.q.ReadyQuarryJob

    e.TurtleStartedEvent():send()
    local pos = pf.s.position.get()
    if pos.v.x == 0 and pos.v.y == 0 and pos.v.z == 0 and pos.dir ==  e.c.Turtle.Direction.Front then
        tc.discoverChests()
    end
    tc.emptyInventory()
    local progress = q.s.progress.get()
    local hitBedrock = false
    while progress.completedLevels < job.levels and (CURRENT == RunType.Running or CURRENT == RunType.Paused) do
        if CURRENT == RunType.Running then
            if progress.completedLevels % job.refuelLevel == 0 then
               tc.refuel(job.refuelTarget, progress.completedLevels ~= 0)
            end
            if not digLevel(progress.completedLevels == 0, (progress.completedLevels + 1) == job.levels) then
                hitBedrock = true
                break
            end
            progress = q.s.progress.get()

            if CURRENT == RunType.Paused then
                tc.emptyInventory()
                e.TurtlePausedEvent():send()
            end
        else
            sleep(5)
        end
    end
    if hitBedrock then
        progress = q.s.progress.get()
        q.s.job.set(QuarryJob(job.left, job.forward, progress.completedLevels + 1, job.walls))
        completeLevel()
        progress = q.s.progress.get()
        progress.hitBedrock = true
        progress.status = "Hit Bedrock"
        setProgress(progress)
    end
    tc.emptyInventory()
    if CURRENT == RunType.Halted then
        e.TurtleExitEvent(false):send()
        sleep(3)
        CURRENT = RunType.Completed
    else
        e.TurtleExitEvent(true):send()
    end
    finishJob()
end

local function eventLoop()
    while RUN_EVENT_LOOP do
        -- timeout timer
        local timer = os.startTimer(3)
        local event, args = core.cleanEventArgs(os.pullEvent())

        if event == e.c.Event.Pathfind.position then
            local pos = pf.TurtlePosition.deserialize(nil, args[1].position)
            fireProgressEvent(pos)
        elseif event == e.c.Event.Pathfind.go_to then
            local eventObj = args[1]
            ---@cast eventObj am.e.PathfindGoToEvent
            if eventObj.gotoType == e.c.Turtle.GoTo.Return then
                if eventObj.success == nil then
                    setStatus("Resuming")
                else
                    local progress = q.s.progress.get()
                    local job = q.s.job.get()
                    ---@cast job am.q.ReadyQuarryJob
                    if progress.completedRows == job.left then
                        setStatus(string.format("Completed Row %d", progress.completedRows))
                    else
                        setStatus(string.format("Digging Row %d", progress.completedRows + 1))
                    end
                end
            end
        elseif event == e.c.Event.Progress then
            p.print(e.getComputer(), args[1])
        elseif event == e.c.Event.Turtle.empty then
            setStatus("Emptying Inventory")
            if args[1].completed then
                addItems(args[1])
            end
        elseif event == e.c.Event.Turtle.exited then
            if args[1].completed then
                setStatus("success:Completed")
                CURRENT = RunType.Completed
            else
                setStatus("error:Stopped")
                CURRENT = RunType.Halted
            end
        elseif event == e.c.Event.Turtle.request_pause then
            CURRENT = RunType.Paused
            log.info("Pausing...")
        elseif event == e.c.Event.Turtle.request_halt then
            CURRENT = RunType.Halted
            log.info("Halting...")
        elseif event == e.c.Event.Turtle.request_continue then
            CURRENT = RunType.Running
            log.info("Unpausing...")
            e.TurtleStartedEvent():send()
        elseif event == e.c.Event.Turtle.paused then
            setStatus("warning:Paused")
        elseif event == e.c.Event.Turtle.fetch_fill then
            setStatus("Getting Fill Block")
        elseif event == e.c.Event.Turtle.refuel then
            setStatus("Refueling")
        elseif event == e.c.Event.Turtle.error then
            local progress = q.s.progress.get()
            PREVIOUS_STATUS = progress.status
            setStatus(string.format("error:%s", args[1].error))
        elseif event == e.c.Event.Turtle.error_clear then
            if PREVIOUS_STATUS ~= nil then
                setStatus(PREVIOUS_STATUS)
                PREVIOUS_STATUS = nil
            end
        end
        p.handle(e.getComputer(), event, args)
        os.cancelTimer(timer)
    end
end

local function netEventLoop()
    e.initNetwork()
    if not e.online then
        return
    end

    while RUN_EVENT_LOOP do
        local data = e.receive()
        if data ~= nil then
            ---@cast data am.turtle_request
            local id = os.getComputerID()
            if data.name == e.c.Event.Turtle.request_halt and data.event.id == id then
                CURRENT = RunType.Halted
                log.info("Halting...")
            elseif data.name == e.c.Event.Turtle.request_pause and data.event.id == id then
                CURRENT = RunType.Paused
                log.info("Pausing...")
            elseif data.name == e.c.Event.Turtle.request_continue and data.event.id == id then
                CURRENT = RunType.Running
                log.info("Unpausing...")
                e.TurtleStartedEvent():send()
            end
        end
    end
end

---@param resume? boolean
local function runJob(resume)
    v.expect(1, resume, "boolean", "nil")
    if resume == nil then
        resume = false
    end

    e.initNetwork()
    local job = q.s.job.get()
    term.clear()
    term.setCursorPos(1, 1)
    if not log.s.print.get() then
        p.print(e.getComputer(), e.QuarryProgressEvent(
            pf.s.position.get(),
            job,
            q.s.progress.get()
        ))
    end
    local extra = ""
    if job.left ~= nil and job.forward ~= nil then
        extra = string.format(": %d x %d (%d)", job.left, job.forward, job.levels)
    end
    if resume then
        log.info(string.format("Resume Quarry%s", extra))
        setStatus("Resuming")
    else
        log.info(string.format("Quarry%s", extra))
    end

    parallel.waitForAll(runLoop, eventLoop, netEventLoop)
    term.setCursorBlink(true)
    if not log.s.print.get() then
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.clear()
        term.setCursorPos(1, 1)
    end
    log.s.print.set(true)
end

q.setOffset = setOffset
q.clearOffset = clearOffset
q.canResume = canResume
q.setJob = setJob
q.runJob = runJob

return q
