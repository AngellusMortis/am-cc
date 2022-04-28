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
local chestTags = {
    "forge:chests",
    "forge:barrels",
}
-- any block matching the following rules are already included
-- * has tag `forge:ores`
-- * name contains `_ore`
-- * name contains `raw_` and `_block`
local extraOreBlock = {
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

    for _, tag in ipairs(chestTags) do
        if data.tags[tag] ~= nil then
            return true
        end
    end
    return false
end

local isSourceBlockDir = function(moveDir)
    local success = false
    local data = nil
    if moveDir == moveDirForward then
        if not turtle.detect() then
            success, data = turtle.inspect()
        end
    elseif moveDir == moveDirDown then
        if not turtle.detectDown() then
            success, data = turtle.inspectDown()
        end
    elseif not turtle.detectUp() then
        success, data = turtle.inspectUp()
    end
    if not success then
        return false
    end
    return success and data.state.level == 0
end

turtleCore.isSourceBlock = function()
    return isSourceBlockDir(moveDirForward)
end

turtleCore.isSourceBlockDown = function()
    return isSourceBlockDir(moveDirDown)
end

turtleCore.isSourceBlockUp = function()
    return isSourceBlockDir(moveDirUp)
end

local isOreBlockDir = function(moveDir)
    local success = false
    local data = nil
    if moveDir == moveDirForward then
        success, data = turtle.inspect()
    elseif moveDir == moveDirDown then
        success, data = turtle.inspectDown()
    elseif not turtle.detectUp() then
        success, data = turtle.inspectUp()
    end
    if not success then
        return false
    elseif data.tags["forge:ores"] ~= nil or string.find(data.name, "_ore") then
        return true
    elseif string.find(data.name, "raw_") and string.find(data.name, "_block") then
        return true
    else
        for _, name in ipairs(extraOreBlock) do
            if name == data.name then
                return true
            end
        end
    end

    return false
end

turtleCore.isOreBlock = function()
    return isOreBlockDir(moveDirForward)
end

turtleCore.isOreBlockDown = function()
    return isOreBlockDir(moveDirDown)
end

turtleCore.isOreBlockUp = function()
    return isOreBlockDir(moveDirUp)
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
    for i = 2, 16, 1 do
        if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            turtleCore.insert(nil, nil, "Missing Drop Chest")
        end
    end

    eventLib.b.turtleGetFill()
    turtle.select(1)
    pathfind.turnTo(pathfind.c.RIGHT)
    turtleCore.pull(turtle.getItemSpace(), "Failed to Pull Fill Block", "Missing Fill Chest")

    pathfind.turnTo(pathfind.c.FORWARD)
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
    turtle.select(2)
    while count > turtle.getFuelLevel() do
        turtleCore.pullUp(nil, string.format("Need %d More Fuel", needed), chestMsg)
        turtle.refuel()
        needed = count - turtle.getFuelLevel()
    end
    turtle.dropUp()
    turtle.select(1)
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

local function fillDir(moveDir, replaceOre)
    if replaceOre == nil then
        replaceOre = false
    end
    turtle.select(1)
    if turtle.getItemCount() == 0 then
        print("Slot count:", turtle.getItemCount())
        turtleCore.emptyInventoryAndReturn()
    end

    if replaceOre and isOreBlockDir(moveDir) then
        digDir(moveDir)
    end
    placeDir(moveDir)
end

turtleCore.fillForward = function(replaceOre)
    fillDir(moveDirForward, replaceOre)
end

turtleCore.fillDown = function(replaceOre)
    fillDir(moveDirDown, replaceOre)
end

turtleCore.fillUp = function(replaceOre)
    fillDir(moveDirUp, replaceOre)
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
            elseif isSourceBlockDir(moveDir) then
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
