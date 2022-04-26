local v = require("cc.expect")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

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
    print("Returning to origin...")
    sleep(5)
    while not pathfind.goToOrigin() do
        print("Could not return to origin. Retrying...")
        sleep(5)
    end

    pathfind.turnTo(pathfind.c.LEFT)
    print("Emptying inventory...")
    for i = 1, 16, 1 do
        if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            while not turtle.drop() do
                print("Destination inventory full. Retrying...")
            end
        end
    end
    pathfind.turnTo(pathfind.c.FORWARD)
    turtle.select(1)
end

turtleCore.emptyInventoryAndReturn = function()
    sleep(5)
    turtleCore.emptyInventory()
    print("Returning...")
    sleep(5)
    while not pathfind.goToReturn() do
        print("Could not go back to return. Retrying...")
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

    if turtleCore.hasRequiredFuel(count) then
        return
    end

    if empty then
        turtleCore.emptyInventory()
    end
    local needed = count - turtle.getFuelLevel()
    print(string.format("Refueling (%d)...", count))
    while not turtleCore.refuel(count) do
        print(string.format("Waiting for %d fuel...", needed))
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
