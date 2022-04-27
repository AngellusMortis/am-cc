local v = require("cc.expect")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

local log = require("log").log
local pathfind = require("pathfind")
local eventLib = require("eventLib")

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

turtleCore.error = function(msg)
    v.expect(1, msg, "string")

    log(string.format("%s. Retrying...", msg))
    eventLib.b.turtleError(msg)
end

turtleCore.emptyInventory = function()
    eventLib.b.turtleEmpty()
    log("Returning to origin...")
    while not pathfind.goToOrigin() do
        turtleCore.error("Cannot Return to Origin")
        sleep(5)
    end

    pathfind.turnTo(pathfind.c.LEFT)
    log("Emptying inventory...")
    for i = 1, 16, 1 do
        if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            while not turtle.drop() do
                turtleCore.error("Failed to Insert Item")
                sleep(5)
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
        turtleCore.error("Cannot Return to Return")
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
    eventLib.b.turtleRefuel(count, empty)
    if turtleCore.hasRequiredFuel(count) then
        return
    end

    if empty then
        turtleCore.emptyInventory()
    end
    local needed = count - turtle.getFuelLevel()
    log(string.format("Refueling (%d)...", count))
    while not turtleCore.refuel(count) do
        turtleCore.error(string.format("Need %d More Fuel", needed))
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
    eventLib.b.turtleDigForward(count)

    for i = 1, count, 1 do
        if turtle.detect() then
            if not turtleCore.hasRoom() then
                turtleCore.emptyInventoryAndReturn()
            end
            while not turtle.dig() do
                turtleCore.error("Cannot Dig Block")
                sleep(1)
            end
        end
        while not pathfind.forward() do
            turtleCore.error("Cannot Move")
            sleep(1)
        end
    end
end

turtleCore.digDown = function(count)
    if count == nil then
        count = 1
    end
    v.expect(1, count, "number")
    eventLib.b.turtleDigDown(count)

    for i = 1, count, 1 do
        if turtle.detect() then
            if not turtleCore.hasRoom() then
                turtleCore.emptyInventoryAndReturn()
            end
            while not turtle.digDown() do
                turtleCore.error("Cannot Dig Block Down")
                sleep(1)
            end
        end
        while not pathfind.down() do
            turtleCore.error("Cannot Move Down")
            sleep(1)
        end
    end
end

turtleCore.digUp = function(count)
    if count == nil then
        count = 1
    end
    v.expect(1, count, "number")
    eventLib.b.turtleDigUp(count)

    for i = 1, count, 1 do
        if turtle.detect() then
            if not turtleCore.hasRoom() then
                turtleCore.emptyInventoryAndReturn()
            end
            while not turtle.digUp() do
                turtleCore.error("Cannot Dig Block Up")
                sleep(1)
            end
        end
        while not pathfind.up() do
            turtleCore.error("Cannot Move Up")
            sleep(1)
        end
    end
end

return turtleCore
