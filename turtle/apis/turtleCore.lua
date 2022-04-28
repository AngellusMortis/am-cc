local v = require("cc.expect")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

local log = require("log").log
local pathfind = require("pathfind")
local eventLib = require("eventLib")

local turtleCore = {}
local moveDirForward = 1
local moveDirDown = 2
local moveDirUp = 3

local fillBlocks = {
    "minecraft:cobblestone",
    "minecraft:dirt",
    "minecraft:andesite",
    "minecraft:diorite",
    "minecraft:granite",
}

local function dirStr(moveDir)
    v.expect(1, moveDir, "number")
    v.range(moveDir, 1, 3)

    if moveDir == moveDirForward then
        return ""
    elseif moveDir == moveDirDown then
        return " Down"
    else
        return " Up"
    end
end

local function isSourceBlock(data)
    return data[1] and data[2].state.level == 0
end

local function isFillBlock(block)
    sleep(1)
    if block == nil then
        return false
    end
    for _, blockName in ipairs(fillBlocks) do
        if blockName == block.name then
            return true
        end
    end
    return false
end

local function selectFill()
    while true do
        for i = 1, 16, 1 do
            if isFillBlock(turtle.getItemDetail(i)) then
                turtle.select(i)
                return
            end
        end
        turtleCore.error("Need Fill Block")
        sleep(5)
    end
end

local function digDir(moveDir)
    v.expect(1, moveDir, "number")
    v.range(moveDir, 1, 3)

    if moveDir == moveDirForward then
        return turtle.dig()
    elseif moveDir == moveDirDown then
        return turtle.digDown()
    else
        return turtle.digUp()
    end
end

local function placeDir(moveDir)
    v.expect(1, moveDir, "number")
    v.range(moveDir, 1, 3)

    if moveDir == moveDirForward then
        return turtle.place()
    elseif moveDir == moveDirDown then
        return turtle.placeDown()
    else
        return turtle.placeUp()
    end
end

local function dropDir(moveDir, count)
    v.expect(1, moveDir, "number")
    if count ~= nil then
        v.expect(2, count, "number")
    end
    v.range(moveDir, 1, 3)

    if moveDir == moveDirForward then
        return turtle.drop(count)
    elseif moveDir == moveDirDown then
        return turtle.dropDown(count)
    else
        return turtle.dropUp(count)
    end
end

local function suckDir(moveDir, count)
    v.expect(1, moveDir, "number")
    if count ~= nil then
        v.expect(2, count, "number")
    end
    v.range(moveDir, 1, 3)

    if moveDir == moveDirForward then
        return turtle.suck(count)
    elseif moveDir == moveDirDown then
        return turtle.suckDown(count)
    else
        return turtle.suckUp(count)
    end
end

local function digEventDir(moveDir, count)
    if count == nil then
        count = 1
    end
    v.expect(1, moveDir, "number")
    v.expect(2, count, "number")
    v.range(moveDir, 1, 3)

    if moveDir == moveDirForward then
        eventLib.b.turtleDigForward(count)
    elseif moveDir == moveDirDown then
        eventLib.b.turtleDigDown(count)
    else
        eventLib.b.turtleDigUp(count)
    end
end

local function detectDir(moveDir)
    v.expect(1, moveDir, "number")

    if moveDir == moveDirForward then
        return turtle.detect()
    elseif moveDir == moveDirDown then
        return turtle.detectDown()
    else
        return turtle.detectUp()
    end
end

local function inspectDir(moveDir)
    v.expect(1, moveDir, "number")

    if moveDir == moveDirForward then
        return turtle.inspect()
    elseif moveDir == moveDirDown then
        return turtle.inspectDown()
    else
        return turtle.inspectUp()
    end
end

local function goDir(moveDir)
    v.expect(1, moveDir, "number")

    if moveDir == moveDirForward then
        return pathfind.forward()
    elseif moveDir == moveDirDown then
        return pathfind.down()
    else
        return pathfind.up()
    end
end

local function isChestDir(moveDir)
    local success, data = inspectDir(moveDir)
    if not success then
        return false
    end

    return data.tags["forge:chests"]
end

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
    local chestMsg = "Missing Refuel Chest Above"
    while count > turtle.getFuelLevel() do
        turtleCore.pullUp(nil, string.format("Need %d More Fuel", needed), chestMsg)
        turtle.refuel()

        needed = count - turtle.getFuelLevel()
    end
    turtle.dropUp()
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

local function fillDir(moveDir)
    selectFill()
    placeDir(moveDir)
    turtle.select(1)
end

turtleCore.fillForward = function()
    fillDir(moveDirForward)
end

turtleCore.fillDown = function()
    fillDir(moveDirDown)
end

turtleCore.fillUp = function()
    fillDir(moveDirUp)
end

local function digMoveDir(moveDir, count)
    if count == nil then
        count = 1
    end
    v.expect(1, moveDir, "number")
    v.expect(2, count, "number")
    v.range(moveDir, 1, 3)

    digEventDir(moveDir, count)
    local hasFilled = false
    for i = 1, count, 1 do
        success = false
        while not success do
            local error = false
            if detectDir(moveDir) then
                if not turtleCore.hasRoom() then
                    error = true
                    turtleCore.emptyInventoryAndReturn()
                end
                if not error and isChestDir(moveDir) then
                    error = true
                    turtleCore.error("Cannot Dig Chest" .. dirStr(moveDir))
                    sleep(5)
                end
                if not error and not digDir(moveDir) then
                    error = true
                    turtleCore.error("Cannot Dig Block" .. dirStr(moveDir))
                    sleep(1)
                end

                if not error and hasFilled then
                    error = true
                    sleep(1)
                end
            elseif isSourceBlock({inspectDir(moveDir)}) then
                error = true
                if hasFilled then
                    turtleCore.error("Cannot Remove Source Block" .. dirStr(moveDir))
                    sleep(3)
                else
                    hasFilled = true
                    fillDir(moveDir)
                end
            end
            if not error and not goDir(moveDir) then
                error = true
                turtleCore.error("Cannot Move" .. dirStr(moveDir))
                sleep(1)
            end

            if not error then
                success = true
            end
        end
    end
end

turtleCore.digForward = function(count)
    digMoveDir(moveDirForward, count)
end

turtleCore.digDown = function(count)
    digMoveDir(moveDirDown, count)
end

turtleCore.digUp = function(count)
    digMoveDir(moveDirUp, count)
end

local function insertDir(moveDir, count, msg, chestMsg)
    if msg == nil then
        msg = "Failed to Insert Item" .. dirStr(moveDir)
    end
    if chestMsg == nil then
        chestMsg = "No Chest For Insert" .. dirStr(moveDir)
    end

    while not isChestDir(moveDir) do
        turtleCore.error(chestMsg)
        sleep(5)
    end

    while not dropDir(moveDir, count) do
        turtleCore.error(msg)
        sleep(5)
    end
end

turtleCore.insert = function(count, msg, chestMsg)
    insertDir(moveDirForward, count, msg, chestMsg)
end

turtleCore.insertDown = function(count, msg, chestMsg)
    insertDir(moveDirDown, count, msg, chestMsg)
end

turtleCore.insertUp = function(count, msg, chestMsg)
    insertDir(moveDirUp, count, msg, chestMsg)
end

local function pullDir(moveDir, count, msg, chestMsg)
    if msg == nil then
        msg = "Failed to Pull Item" .. dirStr(moveDir)
    end
    if chestMsg == nil then
        chestMsg = "No Chest For Pull" .. dirStr(moveDir)
    end

    while not isChestDir(moveDir) do
        turtleCore.error(chestMsg)
        sleep(5)
    end

    while not suckDir(moveDir, count) do
        turtleCore.error(msg)
        sleep(5)
    end
end

turtleCore.pull = function(count, msg, chestMsg)
    pullDir(moveDirForward, count, msg, chestMsg)
end

turtleCore.pullDown = function(count, msg, chestMsg)
    pullDir(moveDirDown, count, msg, chestMsg)
end

turtleCore.pullUp = function(count, msg, chestMsg)
    pullDir(moveDirUp, count, msg, chestMsg)
end

return turtleCore
