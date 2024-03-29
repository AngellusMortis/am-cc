local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local pf = require("am.pathfind")
local core = require("am.core")
local tc = require("am.turtle")
local log = require("am.log")
local e = require("am.event")
local h = require("am.helpers")
local p = require("am.progress")
local pc = require("am.peripheral")

local tree = {}

local d = {}
d.trees = {
    name = "trees",
    default = {},
    type = "table"
}
d.status = {
    name = "status",
    default = "",
    type = "string"
}
d.canResume = {
    name = "canResume",
    default = false,
    type = "boolean"
}
tree.d = core.makeDataWrapper(d, "tree")

local CURRENT = e.c.RunType.Running
local RUN_EVENT_LOOP = true
local IS_RESUME = false
local PREVIOUS_STATUS = nil
---@type table<number, table<string, cc.item>>
---@type am.collect_rate[]
local UPDATE_RATE = 300
local RATE_TIMER = nil


---@class am.t.tree_location
---@field start am.p.TurtlePosition
---@field width number

---@return boolean
local function isTree()
    local success, data = turtle.inspect()
    return success and (data.tags["minecraft:saplings"] or data.tags["minecraft:logs"])
end

---@param pos? am.p.TurtlePosition
local function fireProgressEvent(pos)
    v.expect(1, pos, "table", "nil")
    if pos ~= nil then
        h.requirePosition(1, pos)
    end

    if pos == nil then
        pos = pf.getPos()
    end
    e.TreeProgressEvent(pos, tree.d.trees.get(), tree.d.status.get(), pc.getRates()):send()
end

---@param msg string
local function setStatus(msg)
    tree.d.status.set(msg)
    fireProgressEvent()
end


local function discoverTrees()
    tree.d.trees.set({})
    log.info("Discovering trees...")
    setStatus("Discover Trees")

    local trees = {}
    ---@cast trees am.t.tree_location[]
    local current = nil
    ---@cast current am.t.tree_location|nil
    log.info(".Discover left")
    setStatus("Discover Left Trees")
    while pf.forward() do
        pf.turnLeft()
        if isTree() then
            if current == nil then
                current = {
                    width = 1,
                    start = pf.getPos()
                }
            else
                current.width = current.width + 1
            end
        elseif current ~= nil then
            trees[#trees + 1] = current
            log.info(string.format("..Found tree width %d", current.width))
            current = nil
        end
        pf.turnRight()
    end

    if current ~= nil then
        trees[#trees + 1] = current
        log.info(string.format("..Found tree width %d", current.width))
        current = nil
    end

    pf.turnTo(pf.c.Turtle.Direction.Back)
    log.info(".Discover right")
    setStatus("Discover Right Trees")
    while not pf.atOrigin() and pf.forward() do
        pf.turnLeft()
        if isTree() then
            if current == nil then
                current = {
                    width = 1,
                    start = pf.getPos()
                }
            else
                current.width = current.width + 1
            end
        elseif current ~= nil then
            trees[#trees + 1] = current
            log.info(string.format("..Found tree width %d", current.width))
            current = nil
        end
        pf.turnRight()
    end

    if current ~= nil then
        trees[#trees + 1] = current
        log.info(string.format("..Found tree width %d", current.width))
        current = nil
    end

    log.info(string.format("Discovered %d trees", #trees))
    setStatus(string.format("Discovered %d Trees", #trees))
    tree.d.trees.set(trees)
    pf.goToOrigin()
end

---@param isFirst boolean
---@param width number
---@return boolean
local function harvestLevel(isFirst, width)
    local startDigFunc = tc.digUp
    if isFirst then
        startDigFunc = tc.dig
    end
    if width == 1 then
        startDigFunc()
        local success, data = turtle.inspectUp()
        return success and data.tags["minecraft:logs"]
    end

    local rows = 0
    startDigFunc()
    local success, data = turtle.inspectUp()
    local moreTree = success and data.tags["minecraft:logs"]
    while rows < width do
        for i = 2, width, 1 do
            tc.dig()
            success, data = turtle.inspectUp()
            moreTree = moreTree or (success and data.tags["minecraft:logs"])
        end
        rows = rows + 1

        if rows < width then
            local turnFunc = pf.turnRight
            if rows % 2 == 0 then
                turnFunc = pf.turnLeft
            end
            turnFunc()
            tc.dig()
            success, data = turtle.inspectUp()
            moreTree = moreTree or (success and data.tags["minecraft:logs"])
            turnFunc()
        end
    end
    pf.turnRight()
    return moreTree
end

---@param width number
local function replant(width)
    if width == 1 then
        tc.fillDown()
        return
    end

    local rows = 0
    while rows < width do
        for i = 1, width, 1 do
            tc.fillDown()
            if i < width then
                pf.forward()
            end
        end
        rows = rows + 1

        if rows < width then
            local turnFunc = pf.turnRight
            if rows % 2 == 0 then
                turnFunc = pf.turnLeft
            end
            turnFunc()
            pf.forward()
            turnFunc()
        end
    end
end

---@param index number
---@param loc am.t.tree_location
local function harvestTree(index, loc)
    setStatus(string.format("Harvest %d: (%d, %d)", index, loc.start.v.x, loc.start.v.z))
    log.info(string.format(".Harvest %d: (%d, %d)", index, loc.start.v.x, loc.start.v.z))
    while not pf.goTo(loc.start.v.x, loc.start.v.z, loc.start.v.y, loc.start.dir, true) do
        tc.error("Cannot go to tree")
        sleep(5)
    end

    local success, data = turtle.inspect()
    while not success or not data.tags["minecraft:logs"] do
        setStatus(string.format("Wait Grow %d: (%d, %d)", index, loc.start.v.x, loc.start.v.z))
        log.info(".Wait Grow %d: (%d, %d)")
        sleep(5)
        if CURRENT ~= e.c.RunType.Running then
            return
        end
        success, data = turtle.inspect()
    end

    setStatus(string.format("Harvest %d: (%d, %d)", index, loc.start.v.x, loc.start.v.z))
    local isFirst = true
    while harvestLevel(isFirst, loc.width) do
        isFirst = false
    end
    local pos = pf.getPos()
    setStatus(string.format("Replant %d: (%d, %d)", index, loc.start.v.x, loc.start.v.z))
    log.info(string.format(".Replant %d: (%d, %d)", index, loc.start.v.x, loc.start.v.z))
    pf.goTo(pos.v.x, pos.v.z, 1)
    replant(loc.width)
    pf.goTo(loc.start.v.x, loc.start.v.z, loc.start.v.y)
end

local function treeLoop()
    START_TIME = os.clock()
    e.TurtleStartedEvent():send()
    if IS_RESUME then
        pf.goToOrigin()
    else
        pf.resetPosition()
        pf.resetNodes()
        discoverTrees()
    end
    if pf.atOrigin() then
        tc.discoverChests()
        tc.emptyInventory()
    end

    tree.d.canResume.set(true)
    local trees = tree.d.trees.get()
    log.info(string.format("Harvesting %d trees...", #trees))
    while CURRENT == e.c.RunType.Running or CURRENT == e.c.RunType.Paused do
        if CURRENT == e.c.RunType.Running then
            tc.refuel(175 * #trees)
            for index, treeLoc in ipairs(trees) do
                harvestTree(index, treeLoc)
                if CURRENT ~= e.c.RunType.Running then
                    break
                end
            end
            pf.goTo(0, 0, 0, nil, true)
            tc.emptyInventory()

            if CURRENT == e.c.RunType.Paused then
                tc.emptyInventory()
                e.TurtlePausedEvent():send()
            end
        else
            sleep(5)
        end
    end
    tree.d.canResume.set(false)

    pf.goToOrigin()
    tc.emptyInventory()
    e.TurtleExitEvent(true):send()
    sleep(5)
    RUN_EVENT_LOOP = false
end

local function eventLoop()
    RATE_TIMER = os.startTimer(UPDATE_RATE)
    while RUN_EVENT_LOOP do
        -- timeout timer
        local timer = os.startTimer(3)
        local event, args = core.cleanEventArgs(os.pullEvent())

        if event == "timer" then
            if args[1] == RATE_TIMER then
                pc.calculateRates()
                fireProgressEvent()
                RATE_TIMER = os.startTimer(UPDATE_RATE)
            end
        elseif event == e.c.Event.Pathfind.position then
            local pos = pf.TurtlePosition.deserialize(nil, args[1].position)
            p.updatePosition(e.getComputer(), pos)
        elseif event == e.c.Event.Pathfind.go_to then
            local eventObj = args[1]
            ---@cast eventObj am.e.PathfindGoToEvent
            if eventObj.gotoType == e.c.Turtle.GoTo.Return then
                if eventObj.success == nil then
                    setStatus("Resuming")
                end
            end
        elseif event == e.c.Event.Progress.tree then
            p.print(e.getComputer(), args[1])
        elseif event == e.c.Event.Turtle.empty then
            setStatus("Emptying Inventory")
            if args[1].completed then
                pc.addItems(args[1].items)
                fireProgressEvent()
            end
        elseif event == e.c.Event.Turtle.exited then
            setStatus("error:Stopped")
            CURRENT = e.c.RunType.Halted
        elseif event == e.c.Event.Turtle.request_pause then
            CURRENT = e.c.RunType.Paused
            log.info("Pausing...")
        elseif event == e.c.Event.Turtle.request_halt then
            CURRENT = e.c.RunType.Halted
            log.info("Halting...")
        elseif event == e.c.Event.Turtle.request_continue then
            CURRENT = e.c.RunType.Running
            log.info("Unpausing...")
            e.TurtleStartedEvent():send()
        elseif event == e.c.Event.Turtle.paused then
            setStatus("warning:Paused")
        elseif event == e.c.Event.Turtle.fetch_fill then
            setStatus("Getting Fill Block")
        elseif event == e.c.Event.Turtle.refuel then
            setStatus("Refueling")
        elseif event == e.c.Event.Turtle.error then
            PREVIOUS_STATUS = tree.d.status.get()
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
                CURRENT = e.c.RunType.Halted
                log.info("Halting...")
            elseif data.name == e.c.Event.Turtle.request_pause and data.event.id == id then
                CURRENT = e.c.RunType.Paused
                log.info("Pausing...")
            elseif data.name == e.c.Event.Turtle.request_continue and data.event.id == id then
                CURRENT = e.c.RunType.Running
                log.info("Unpausing...")
                e.TurtleStartedEvent():send()
            end
        end
    end
end

---@param resume? boolean
local function harvestTrees(resume)
    if resume == nil then
        resume = false
    end
    IS_RESUME = resume

    log.s.print.set(false)
    parallel.waitForAll(treeLoop, eventLoop, netEventLoop)
    log.s.print.set(true)
    term.clear()
end

tree.harvestTrees = harvestTrees

return tree
