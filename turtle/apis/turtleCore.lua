local v = require("cc.expect")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

local log = require("log").log
local pathfind = require("pathfind")

local turtleCore = {}

turtleCore.hasRequiredFuel = function(count)
    v.expect(1, count, "number")
    v.range(count, 1)

    local level = turtle.getFuelLevel()
    if level == "unlimited" then
        return true
    end

    return level > count
end

turtleCore.emptyInventory = function()
    os.queueEvent("tc_empty")
    log("Returning to origin...")
    while not pathfind.goToOrigin() do
        log("Could not return to origin. Retrying...")
        sleep(5)
    end

    pathfind.turnTo(pathfind.c.LEFT)
    log("Emptying inventory...")
    for i = 1, 16, 1 do
        if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            while not turtle.drop() do
                log("Destination inventory full. Retrying...")
            end
        end
    end
    pathfind.turnTo(pathfind.c.FORWARD)
    turtle.select(1)
end

turtleCore.emptyInventoryAndReturn = function()
    turtleCore.emptyInventory()
    log("Returning...")
    while not pathfind.goToReturn() do
        log("Could not go back to return. Retrying...")
        sleep(5)
    end
end

turtleCore.refuel = function(count)
    v.expect(1, count, "number")
    v.range(count, 1)

    while count > turtle.getFuelLevel() do
        if not turtle.suckDown() then
            return false
        end
        turtle.refuel()
    end
    turtle.dropDown()
    return true
end

turtleCore.goRefuel = function(count, empty)
    if empty == nil then
        empty = true
    end
    v.expect(1, count, "number")
    v.expect(2, empty, "boolean")
    v.range(count, 1)
    os.queueEvent("tc_refuel", count, empty)

    if turtleCore.hasRequiredFuel(count) then
        return
    end

    if empty then
        turtleCore.emptyInventory()
    end
    local needed = count - turtle.getFuelLevel()
    log(string.format("Refueling (%d)...", count))
    while not turtleCore.refuel(count) do
        log(string.format("Waiting for %d fuel...", needed))
        sleep(5)

        needed = count - turtle.getFuelLevel()
    end
end

turtleCore.emptySlots = function()
    local emptyCount = 0
    for i = 1, 16, 1 do
        if turtle.getItemCount(i) == 0 then
            emptyCount = emptyCount + 1
        end
    end
    return emptyCount
end

turtleCore.hasRoom = function()
    -- leave buffer of 4 slots for any possible drops
    return turtleCore.emptySlots() >= 4
end

turtleCore.digForward = function(count)
    if count == nil then
        count = 1
    end
    v.expect(1, count, "number")
    os.queueEvent("tc_dig", 1, count)

    for i = 1, count, 1 do
        if turtle.detect() then
            if not turtleCore.hasRoom() then
                turtleCore.emptyInventoryAndReturn()
            end
            if not turtle.dig() then
                error("Could not dig block")
            end
        end
        if not pathfind.forward() then
            error("Could not move turtle")
        end
    end
end

turtleCore.digDown = function(count)
    if count == nil then
        count = 1
    end
    v.expect(1, count, "number")
    os.queueEvent("tc_dig", 2, count)

    for i = 1, count, 1 do
        if turtle.detectDown() then
            if not turtleCore.hasRoom() then
                turtleCore.emptyInventoryAndReturn()
            end
            if not turtle.digDown() then
                error("Could not dig block")
            end
        end
        if not pathfind.down() then
            error("Could not move turtle")
        end
    end
end

turtleCore.digUp = function(count)
    if count == nil then
        count = 1
    end
    v.expect(1, count, "number")
    os.queueEvent("tc_dig", 3, count)

    for i = 1, count, 1 do
        if turtle.detectUp() then
            if not turtleCore.hasRoom() then
                turtleCore.emptyInventoryAndReturn()
            end
            if not turtle.digUp() then
                error("Could not dig block")
            end
        end
        if not pathfind.up() then
            error("Could not move turtle")
        end
    end
end

return turtleCore
