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
            turtleCore.insert(nil, nil, "Missing Drop Chest")
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

    local needed = count - turtle.getFuelLevel()
    local chestMsg = "Missing Refuel Chest Below"
    while count > turtle.getFuelLevel() do
        turtleCore.pullDown(nil, string.format("Need %d More Fuel", needed), chestMsg)
        turtle.refuel()

        needed = count - turtle.getFuelLevel()
    end
    turtleCore.dropDown()
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
    turtleCore.refuel(count)
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
            while turtleCore.isChest() do
                turtleCore.error("Cannot Dig Chest")
                sleep(5)
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
            while turtleCore.isChestDown() do
                turtleCore.error("Cannot Dig Chest Down")
                sleep(5)
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
            while turtleCore.isChestUp() do
                turtleCore.error("Cannot Dig Chest Up")
                sleep(5)
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

turtleCore.isChest = function()
    local success, data = turtle.inspect()
    if not success then
        return false
    end

    return data.tags["forge:chests"]
end

turtleCore.isChestDown = function()
    local success, data = turtle.inspectDown()
    if not success then
        return false
    end

    return data.tags["forge:chests"]
end

turtleCore.isChestUp = function()
    local success, data = turtle.inspectUp()
    if not success then
        return false
    end

    return data.tags["forge:chests"]
end

turtleCore.insert = function(count, msg, chestMsg)
    if msg == nil then
        msg = "Failed to Insert Item"
    end
    if chestMsg == nil then
        chestMsg = "No Chest For Insert"
    end

    while not turtleCore.isChest() do
        turtleCore.error(chestMsg)
        sleep(5)
    end

    while not turtle.drop(count) do
        turtleCore.error(msg)
        sleep(5)
    end
end

turtleCore.insertDown = function(count, msg, chestMsg)
    if msg == nil then
        msg = "Failed to Insert Item Below"
    end
    if chestMsg == nil then
        chestMsg = "No Chest For Insert Below"
    end

    while not turtleCore.isChestDown() do
        turtleCore.error(chestMsg)
        sleep(5)
    end

    while not turtle.dropDown(count) do
        turtleCore.error(msg)
        sleep(5)
    end
end

turtleCore.insertUp = function(count, msg, chestMsg)
    if msg == nil then
        msg = "Failed to Insert Item Above"
    end
    if chestMsg == nil then
        chestMsg = "No Chest For Insert Above"
    end

    while not turtleCore.isChestUp() do
        turtleCore.error(chestMsg)
        sleep(5)
    end

    while not turtle.dropUp(count) do
        turtleCore.error(msg)
        sleep(5)
    end
end

turtleCore.pull = function(count, msg, chestMsg)
    if msg == nil then
        msg = "Failed to Pull Item"
    end
    if chestMsg == nil then
        chestMsg = "No Chest For Pull"
    end

    while not turtleCore.isChest() do
        turtleCore.error(chestMsg)
        sleep(5)
    end

    while not turtle.suck(count) do
        turtleCore.error(msg)
        sleep(5)
    end
end

turtleCore.pullDown = function(count, msg, chestMsg)
    if msg == nil then
        msg = "Failed to Pull Below"
    end
    if chestMsg == nil then
        chestMsg = "No Chest For Pull Below"
    end

    while not turtleCore.isChestDown() do
        turtleCore.error(chestMsg)
        sleep(5)
    end

    while not turtle.suckDown(count) do
        turtleCore.error(msg)
        sleep(5)
    end
end

turtleCore.pullUp = function(count, msg, chestMsg)
    if msg == nil then
        msg = "Failed to Pull Above"
    end
    if chestMsg == nil then
        chestMsg = "No Chest For Pull Above"
    end

    while not turtleCore.isChestUp() do
        turtleCore.error(chestMsg)
        sleep(5)
    end

    while not turtle.suckUp(count) do
        turtleCore.error(msg)
        sleep(5)
    end
end

return turtleCore
