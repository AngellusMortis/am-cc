require(settings.get("ghu.base") .. "core/apis/ghu")

local log = require("am.log")
local colonies = require("am.colonies")
local p = require("am.progress")
local e = require("am.event")
local core = require("am.core")

_G.RUN_PROGRESS = true
_G.PROGRESS_SHOW_CLOSE = true

local RUN_EVENT_LOOP = true
local STATUS_TEXT = ""
local STATUS = nil

---@param msg string
local function setStatus(msg)
    STATUS_TEXT = msg
    if STATUS ~= nil then
        e.ColonyStatusPollEvent(STATUS, STATUS_TEXT):send()
    end
end

---@param ping? boolean
local function incrementalSleep(sleepTime, ping)
    if ping == nil then
        ping = false
    end

    local pingTime = 10
    while sleepTime > 0 and _G.RUN_PROGRESS do
        sleepTime = sleepTime - 0.5
        pingTime = pingTime - 0.5
        if pingTime <= 0 then
            if ping then
                e.PingEvent():send()
            end
            pingTime = 10
        end
        sleep(0.5)
    end
end

local function statusLoop()
    while _G.RUN_PROGRESS do
        log.info("Polling colony status...")
        setStatus("Poll Colony")
        STATUS = colonies.pollColony()
        e.ColonyStatusPollEvent(STATUS, STATUS_TEXT):send()
        log.info("Completed polling colony status")
        setStatus("")
        incrementalSleep(30, true)
    end

    setStatus("error:Stopped")
    sleep(2)
    RUN_EVENT_LOOP = false
end

local function warehouseLoop()
    incrementalSleep(3)
    while _G.RUN_PROGRESS do
        setStatus("Scan Warehouse")
        log.info("Emptying warehouse inventory...")
        colonies.emptyWarehouse()
        log.info("Completed empty warehouse")
        setStatus("")
        incrementalSleep(60)
    end
end

local function requestLoop()
    -- incrementalSleep(10)
    while _G.RUN_PROGRESS do
        setStatus("Fulfill Requests")
        log.info("Fulfilling requests...")
        colonies.fulfillRequests()
        log.info("Completed fulfilling requests")
        setStatus("")
        incrementalSleep(10)
    end
end

local function eventLoop()
    while RUN_EVENT_LOOP do
        -- timeout timer
        local timer = os.startTimer(3)
        local event, args = core.cleanEventArgs(os.pullEvent())

        if event == e.c.Event.Colonies.status_poll or event == e.c.Event.Colonies.warehouse_poll then
            p.print(e.getComputer(), args[1])
        end

        p.handle(e.getComputer(), event, args)
        os.cancelTimer(timer)
    end
end

---@param importChest? string
local function main(importChest)
    if importChest ~= nil then
        if peripheral.wrap(importChest) == nil then
            error("Invalid import chest")
        end
        colonies.s.importChest.set(importChest)
    end

    if not colonies.canResume() then
        error("Missing transfer or import chest")
    end

    log.s.print.set(false)
    parallel.waitForAll(statusLoop, warehouseLoop, eventLoop, requestLoop)
    log.s.print.set(true)
    term.clear()
end

main(arg[1])
