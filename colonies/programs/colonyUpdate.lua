require(settings.get("ghu.base") .. "core/apis/ghu")

local log = require("am.log")
local colonies = require("am.colonies")

local RUN = true


local function statusLoop()
    while RUN do
        log.info("Polling colony status...")
        colonies.pollColony()
        log.info("Completed polling colony status")
        sleep(30)
    end
end

local function warehouseLoop()
    while RUN do
        sleep(10)
        log.info("Emptying warehouse inventory...")
        colonies.emptyWarehouse()
        log.info("Completed empty warehouse")
        sleep(20)
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

    parallel.waitForAll(statusLoop, warehouseLoop)
end

main(arg[1], arg[2])
