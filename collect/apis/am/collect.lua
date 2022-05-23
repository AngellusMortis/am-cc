local v = require("cc.expect")

local BaseObject = require("am.ui.base").BaseObject

local core = require("am.core")
local log = require("am.log")
local e = require("am.event")
local pc = require("am.peripheral")
local p = require("am.progress")

local c = {}

---@class am.c.CollectJob:am.ui.b.BaseObject
---@field from string
---@field to string
---@field interval number
local CollectJob = BaseObject:extend("am.c.CollectJob")
c.CollectJob = CollectJob
---@param from string
---@param to string
---@param interval? number
function CollectJob:init(from, to, interval)
    v.expect(1, from, "string")
    v.expect(2, to, "string")
    v.expect(3, interval, "number", "nil")

    self.from = from
    self.to = to
    self.interval = interval or 60

    return self
end

local s = {}
s.job = {
    name = "collect.job",
    default = nil,
}
c.s = core.makeSettingWrapper(s)

local CURRENT = e.c.RunType.Running
local RUN_EVENT_LOOP = true
---@type table<number, table<string, cc.item>>
---@type am.collect_rate[]
local RATE_TIMER = nil
local UPDATE_RATE = 300
local CURRENT_STATUS = ""

local function sendEvent()
    e.CollectProgressEvent(CURRENT_STATUS, pc.getRates()):send()
end

---@param msg string
local function setStatus(msg)
    CURRENT_STATUS = msg
    sendEvent()
end

---@return cc.inventory, cc.inventory
local function getInventories()
    local job = c.s.job.get()
    local from = peripheral.wrap(job.from)
    ---@cast from cc.inventory|nil
    if from == nil then
        error("Could not locate from inventory")
    end
    local to = peripheral.wrap(job.to)
    ---@cast to cc.inventory|nil
    if to == nil then
        error("Could not locate to inventory")
    end

    return from, to
end

local function runLoop()
    pc.setStartTime()
    e.TurtleStartedEvent():send()

    local job = c.s.job.get()
    local from, _ = getInventories()
    while CURRENT == e.c.RunType.Running or CURRENT == e.c.RunType.Paused do
        setStatus("")
        local sleepTime = 5
        local pingTime = 10
        if CURRENT == e.c.RunType.Running then
            local items = {}
            ---@cast items cc.item[]
            for slot, item in pairs(from.list()) do
                item = from.getItemDetail(slot)
                ---@cast item cc.item
                if not pc.pullItem(job.from, job.to, item.count, nil, slot) then
                    e.ErrorEvent("Could not move item"):send()
                    break
                end
                items[#items + 1] = item
            end
            if #items > 0 then
                pc.addItems(items)
                sendEvent()
                sleepTime = job.interval
                pingTime = 10
            end
        end

        local startState = CURRENT
        while sleepTime > 0 and CURRENT == startState do
            sleepTime = sleepTime - 0.5
            pingTime = pingTime - 0.5
            if pingTime <= 0 then
                e.PingEvent():send()
                pingTime = 10
            end
            sleep(0.5)
        end

        if startState == e.c.RunType.Running and CURRENT == e.c.RunType.Paused then
            e.TurtlePausedEvent():send()
        end
    end

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
                sendEvent()
                RATE_TIMER = os.startTimer(UPDATE_RATE)
            end
        elseif event == e.c.Event.Common.error then
            setStatus(string.format("error:%s", args[1].error))
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
        elseif event == e.c.Event.Progress.collect then
            p.print(e.getComputer(), args[1])
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

local function collect()
    log.s.print.set(false)
    parallel.waitForAll(runLoop, eventLoop, netEventLoop)
    log.s.print.set(true)
    c.s.job.set(nil)
    term.clear()
end

c.CollectJob = CollectJob
c.collect = collect

return c
