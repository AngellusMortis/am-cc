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

local function statusLoop()
    while _G.RUN_PROGRESS do
        log.info("Polling colony status...")
        setStatus("Poll Colony")
        STATUS = colonies.pollColony()
        e.ColonyStatusPollEvent(STATUS, STATUS_TEXT):send()
        log.info("Completed polling colony status")
        setStatus("")

        local sleepTime = 30
        local pingTime = 10
        while sleepTime > 0 and _G.RUN_PROGRESS do
            sleepTime = sleepTime - 0.5
            pingTime = pingTime - 0.5
            if pingTime <= 0 then
                e.PingEvent():send()
                pingTime = 10
            end
            sleep(0.5)
        end
    end

    setStatus("error:Stopped")
    sleep(5)
    RUN_EVENT_LOOP = false
end

local function warehouseLoop()
    while _G.RUN_PROGRESS do
        sleep(7)
        setStatus("Scan Warehouse")
        log.info("Emptying warehouse inventory...")
        colonies.emptyWarehouse()
        log.info("Completed empty warehouse")
        setStatus("")
        sleep(53)
    end
end

local function eventLoop()
    while RUN_EVENT_LOOP do
        -- timeout timer
        local timer = os.startTimer(3)
        local event, args = core.cleanEventArgs(os.pullEvent())

        if event == e.c.Event.Colonies.status_poll then
            p.print(e.getComputer(), args[1])
        end

        p.handle(e.getComputer(), event, args)
        os.cancelTimer(timer)
    end
end

---@param transferChest? string
---@param importChest? string
local function main(transferChest, importChest)
    if transferChest ~= nil then
        if peripheral.wrap(transferChest) == nil then
            error("Invalid transfer chest")
        end
        colonies.s.transferChest.set(transferChest)
    end
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
    parallel.waitForAll(statusLoop, warehouseLoop, eventLoop)
    log.s.print.set(true)
    term.clear()
end

main(arg[1], arg[2])
