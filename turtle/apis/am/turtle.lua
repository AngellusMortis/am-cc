local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local log = require("am.log")
local pf = require("am.pathfind")
local e = require("am.event")
local h = require("am.helpers")

local tc = {}
---@type table<string, string>
local chestTags = {
    "forge:chests",
    "forge:barrels",
}
-- any block matching the following rules are already included
-- * has tag `forge:ores`
-- * name contains `_ore`
-- * name contains `raw_` and `_block`
---@type table<string, string>
local extraOreBlock = {
}

---@param moveDir number
---@param count? number
---@param completed boolean
local function digEventDir(moveDir, count, completed)
    v.expect(1, moveDir, "number")
    v.expect(2, count, "number", "nil")
    v.expect(3, completed, "boolean")
    v.range(moveDir, -1, 1)
    if count == nil then
        count = 1
    end

    e.TurtleDigEvent(completed, moveDir, count):send()
end

---@param msg string
local function turtleError(msg)
    v.expect(1, msg, "string")

    log.info(string.format("%s. Retrying...", msg))
    e.TurtleErrorEvent(msg):send()
end

---@return cc.item|nil[]
local function getInventory()
    local items = {}
    for i = 1, 16, 1 do
        items[i] = turtle.getItemDetail(i, true)
    end
    return items
end

---@param oldItem cc.item?
---@param newItem cc.item?
---@return cc.item|nil
local function getItemDiff(oldItem, newItem)
    if oldItem == nil and newItem == nil then
        return nil
    end
    if oldItem ~= nil and newItem == nil then
        return nil
    end
    if oldItem == nil and newItem ~= nil then
        return newItem
    end
    ---@cast oldItem cc.item
    ---@cast newItem cc.item

    if oldItem.name ~= newItem.name then
        return newItem
    end
    newItem.count = oldItem.count - newItem.count
    return newItem
end

---@param startingItems cc.item|nil[]
---@return cc.item|nil[]
local function getInventoryDiff(startingItems)
    local diffItems = {}
    for i = 1, 16, 1 do
        local item = turtle.getItemDetail(i)
        diffItems[i] = getItemDiff(startingItems[i], item)
    end
    return diffItems
end

---@param count number
---@return boolean
local function hasRequiredFuel(count)
    v.expect(1, count, "number")
    v.range(count, 1)

    local level = turtle.getFuelLevel()
    if level == "unlimited" then
        return true
    end

    return level > count
end

---@return number
local function emptySlots()
    local emptyCount = 0
    for i = 1, 16, 1 do
        if turtle.getItemCount(i) == 0 then
            emptyCount = emptyCount + 1
        end
    end
    return emptyCount
end

---@return boolean
local function hasRoom()
    -- leave buffer of 4 slots for any possible drops
    return emptySlots() >= 4
end

local function emptyInventoryBase()
    local event = e.TurtleEmptyEvent(false, nil)
    event:send()
    log.info("Returning to origin...")
    while not pf.goToOrigin() do
        turtleError("Cannot Return to Origin")
        sleep(5)
    end

    pf.turnTo(e.c.Turtle.Direction.Left)
    log.info("Emptying inventory...")
    local items = getInventory()
    for i = 2, 16, 1 do
        if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            tc.insert(nil, nil, "Missing Drop Chest")
        end
    end
    local newItems = getInventoryDiff(items)
    local placed = {}
    for _, item in ipairs(newItems) do
        if item ~= nil and item.count < 0 then
            item.count = math.abs(item.count)
            placed[#placed + 1] = placed
        end
    end
    event.completed = true
    event.items = placed
    event:send()

    event = e.TurtleFetchFillEvent(false, nil)
    event:send()
    items = getInventory()
    turtle.select(1)
    pf.turnTo(e.c.Turtle.Direction.Right)
    tc.pull(turtle.getItemSpace(), "Failed to Pull Fill Block", "Missing Fill Chest")

    pf.turnTo(e.c.Turtle.Direction.Front)
    newItems = getInventoryDiff(items)
    for _, item in ipairs(newItems) do
        if item ~= nil and item.count > 0 then
            event.completed = true
            event.item = item
            event:send()
        end
    end
end

---@param doReturn? boolean
local function emptyInventory(doReturn)
    v.expect(1, doReturn, "boolean", "nil")
    if doReturn == nil then
        doReturn = false
    end

    emptyInventoryBase()
    local pos = pf.s.position.get()
    if doReturn and not h.isOrigin(pos) then
        log.info("Returning...")
        while not pf.goToReturn() do
            turtleError("Cannot Return to Return")
            sleep(5)
        end
    end
end

---@param count number
---@return boolean
local function refuelBase(count)
    v.expect(1, count, "number")
    v.range(count, 1)

    local currentLevel = turtle.getFuelLevel()
    local needed = count - currentLevel
    local chestMsg = "Missing Refuel Chest Above"
    local pullCount = nil
    turtle.select(2)
    while count > currentLevel do
        tc.pullUp(pullCount, string.format("Need %d More Fuel", needed), chestMsg)
        turtle.refuel()
        if pullCount == nil then
            local fuelPer = turtle.getFuelLevel() - currentLevel
            pullCount = math.ceil(needed / fuelPer)
            if pullCount < 1 then
                pullCount = nil
            elseif pullCount > 64 then
                pullCount = 64
            end
        end
        currentLevel = turtle.getFuelLevel()
        needed = count - currentLevel
    end
    turtle.dropUp()
    turtle.select(1)
    return true
end

---@param count number
---@param empty? boolean
local function refuel(count, empty)
    v.expect(1, count, "number")
    v.expect(2, empty, "boolean", "nil")
    if empty == nil then
        empty = false
    end
    v.range(count, 1)

    if hasRequiredFuel(count) then
        return
    end
    local startingLevel = turtle.getFuelLevel()
    local event = e.TurtleRefuelEvent(false, count, startingLevel)
    event:send()

    if empty then
        emptyInventory()
        event:send()
    end
    local pos = pf.s.position.get()
    if not h.isOrigin(pos) then
        log.info("Returning...")
        while not pf.goToOrigin() do
            turtleError("Cannot Return to Origin")
            sleep(5)
        end
    end
    log.info(string.format("Refueling (%d)...", count))
    refuelBase(count)
    event.completed = true
    event.newLevel = turtle.getFuelLevel()
    event:send()
end

---@param moveDir number
---@return string
local function dirStr(moveDir)
    v.expect(1, moveDir, "number")
    v.range(moveDir, -1, 1)

    if moveDir == e.c.Turtle.Direction.Front then
        return ""
    elseif moveDir == e.c.Turtle.Direction.Down then
        return " Down"
    else
        return " Up"
    end
end

---@param moveDir number
---@return boolean, string|nil
local function digDir(moveDir)
    v.expect(1, moveDir, "number")
    v.range(moveDir, -1, 1)

    if moveDir == e.c.Turtle.Direction.Front then
        return turtle.dig()
    elseif moveDir == e.c.Turtle.Direction.Down then
        return turtle.digDown()
    else
        return turtle.digUp()
    end
end

---@param moveDir number
---@return boolean, string|nil
local function placeDir(moveDir)
    v.expect(1, moveDir, "number")
    v.range(moveDir, -1, 1)

    if moveDir == e.c.Turtle.Direction.Front then
        return turtle.place()
    elseif moveDir == e.c.Turtle.Direction.Down then
        return turtle.placeDown()
    else
        return turtle.placeUp()
    end
end

---@param moveDir number
---@param count? number
---@return boolean, string|nil
local function dropDir(moveDir, count)
    v.expect(1, moveDir, "number")
    v.expect(2, count, "number", "nil")
    v.range(moveDir, -1, 1)

    if moveDir == e.c.Turtle.Direction.Front then
        return turtle.drop(count)
    elseif moveDir == e.c.Turtle.Direction.Down then
        return turtle.dropDown(count)
    else
        return turtle.dropUp(count)
    end
end

---@param moveDir number
---@param count? number
---@return boolean, string|nil
local function suckDir(moveDir, count)
    v.expect(1, moveDir, "number")
    v.expect(2, count, "number", "nil")
    v.range(moveDir, -1, 1)

    if moveDir == e.c.Turtle.Direction.Front then
        return turtle.suck(count)
    elseif moveDir == e.c.Turtle.Direction.Down then
        return turtle.suckDown(count)
    else
        return turtle.suckUp(count)
    end
end

---@param moveDir number
---@return boolean
local function detectDir(moveDir)
    v.expect(1, moveDir, "number")
    v.range(moveDir, -1, 1)

    if moveDir == e.c.Turtle.Direction.Front then
        return turtle.detect()
    elseif moveDir == e.c.Turtle.Direction.Down then
        return turtle.detectDown()
    else
        return turtle.detectUp()
    end
end

---@param moveDir number
---@return boolean, cc.block|string
local function inspectDir(moveDir)
    v.expect(1, moveDir, "number")
    v.range(moveDir, -1, 1)

    if moveDir == e.c.Turtle.Direction.Front then
        return turtle.inspect()
    elseif moveDir == e.c.Turtle.Direction.Down then
        return turtle.inspectDown()
    else
        return turtle.inspectUp()
    end
end

---@param moveDir number
---@return boolean
local function goDir(moveDir)
    v.expect(1, moveDir, "number")
    v.range(moveDir, -1, 1)

    if moveDir == e.c.Turtle.Direction.Front then
        return pf.forward()
    elseif moveDir == e.c.Turtle.Direction.Down then
        return pf.down()
    else
        return pf.up()
    end
end

---@param moveDir number
---@return boolean
local function isChestDir(moveDir)
    v.expect(1, moveDir, "number")
    v.range(moveDir, -1, 1)

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

---@return boolean
local function isChest()
    return isChestDir(e.c.Turtle.Direction.Front)
end

---@return boolean
local function isChestDown()
    return isChestDir(e.c.Turtle.Direction.Down)
end

---@return boolean
local function isChestUp()
    return isChestDir(e.c.Turtle.Direction.Up)
end

---@param moveDir number
---@return boolean
local function isSourceBlockDir(moveDir)
    v.expect(1, moveDir, "number")
    v.range(moveDir, -1, 1)

    local success = false
    local data = nil
    if not detectDir(moveDir) then
        success, data = inspectDir(moveDir)
    end
    if not success then
        return false
    end
    return success and data.state.level == 0
end

---@return boolean
local function isSourceBlock()
    return isSourceBlockDir(e.c.Turtle.Direction.Front)
end

---@return boolean
local function isSourceBlockDown()
    return isSourceBlockDir(e.c.Turtle.Direction.Down)
end

---@return boolean
local function isSourceBlockUp()
    return isSourceBlockDir(e.c.Turtle.Direction.Up)
end

---@param moveDir number
---@return boolean
local function isOreBlockDir(moveDir)
    local success, data = inspectDir(moveDir)
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

---@return boolean
local function isOreBlock()
    return isOreBlockDir(e.c.Turtle.Direction.Front)
end

---@return boolean
local function isOreBlockDown()
    return isOreBlockDir(e.c.Turtle.Direction.Down)
end

---@return boolean
local function isOreBlockUp()
    return isOreBlockDir(e.c.Turtle.Direction.Up)
end

---@param moveDir number
---@param replaceOre? boolean
local function fillDir(moveDir, replaceOre)
    v.expect(1, moveDir, "number")
    v.expect(2, replaceOre, "boolean", "nil")
    v.range(moveDir, -1, 1)

    if replaceOre == nil then
        replaceOre = false
    end
    turtle.select(1)
    if turtle.getItemCount() == 0 then
        emptyInventory(true)
    end

    if replaceOre and isOreBlockDir(moveDir) then
        digDir(moveDir)
    end
    placeDir(moveDir)
end

---@param replaceOre? boolean
local function fill(replaceOre)
    fillDir(e.c.Turtle.Direction.Front, replaceOre)
end

---@param replaceOre? boolean
local function fillDown(replaceOre)
    fillDir(e.c.Turtle.Direction.Down, replaceOre)
end

---@param replaceOre? boolean
local function fillUp(replaceOre)
    fillDir(e.c.Turtle.Direction.Up, replaceOre)
end

---@param moveDir number
---@param count? number
local function digMoveDir(moveDir, count)
    if count == nil then
        count = 1
    end
    v.expect(1, moveDir, "number")
    v.expect(2, count, "number")
    v.range(moveDir, -1, 1)

    digEventDir(moveDir, count, false)
    local hasFilled = false
    for i = 1, count, 1 do
        success = false
        while not success do
            local error = false
            if detectDir(moveDir) then
                if not hasRoom() then
                    error = true
                    emptyInventory(true)
                end
                if not error and isChestDir(moveDir) then
                    error = true
                    turtleError("Cannot Dig Chest" .. dirStr(moveDir))
                    sleep(5)
                end
                if not error and not digDir(moveDir) then
                    error = true
                    turtleError("Cannot Dig Block" .. dirStr(moveDir))
                    sleep(1)
                end

                if not error and hasFilled then
                    error = true
                    sleep(1)
                end
            elseif isSourceBlockDir(moveDir) then
                error = true
                if hasFilled then
                    turtleError("Cannot Remove Source Block" .. dirStr(moveDir))
                    sleep(3)
                else
                    hasFilled = true
                    fillDir(moveDir)
                end
            end
            if not error and not goDir(moveDir) then
                error = true
                turtleError("Cannot Move" .. dirStr(moveDir))
                sleep(1)
            end

            if not error then
                success = true
            end
        end
    end
    digEventDir(moveDir, count, true)
end

---@param count? number
local function dig(count)
    digMoveDir(e.c.Turtle.Direction.Front, count)
end

---@param count? number
local function digDown(count)
    digMoveDir(e.c.Turtle.Direction.Down, count)
end

---@param count? number
local function digUp(count)
    digMoveDir(e.c.Turtle.Direction.Up, count)
end

---@param moveDir number
---@param count? number
---@param msg? string
---@param chestMsg? string
local function insertDir(moveDir, count, msg, chestMsg)
    v.expect(1, moveDir, "number")
    v.expect(2, count, "number", "nil")
    v.range(moveDir, -1, 1)

    if msg == nil then
        msg = "Failed to Insert Item" .. dirStr(moveDir)
    end
    if chestMsg == nil then
        chestMsg = "No Chest For Insert" .. dirStr(moveDir)
    end

    while not isChestDir(moveDir) do
        turtleError(chestMsg)
        sleep(5)
    end

    while not dropDir(moveDir, count) do
        turtleError(msg)
        sleep(5)
    end
end

---@param count? number
---@param msg? string
---@param chestMsg? string
local function insert(count, msg, chestMsg)
    insertDir(e.c.Turtle.Direction.Front, count, msg, chestMsg)
end

---@param count? number
---@param msg? string
---@param chestMsg? string
local function insertDown(count, msg, chestMsg)
    insertDir(e.c.Turtle.Direction.Down, count, msg, chestMsg)
end

---@param count? number
---@param msg? string
---@param chestMsg? string
local function insertUp(count, msg, chestMsg)
    insertDir(e.c.Turtle.Direction.Up, count, msg, chestMsg)
end

---@param moveDir number
---@param count? number
---@param msg? string
---@param chestMsg? string
local function pullDir(moveDir, count, msg, chestMsg)
    if count == nil then
        count = 1
    end
    v.expect(1, moveDir, "number")
    v.expect(2, count, "number")
    v.range(moveDir, -1, 1)

    if msg == nil then
        msg = "Failed to Pull Item" .. dirStr(moveDir)
    end
    if chestMsg == nil then
        chestMsg = "No Chest For Pull" .. dirStr(moveDir)
    end

    while not isChestDir(moveDir) do
        turtleError(chestMsg)
        sleep(5)
    end

    while not suckDir(moveDir, count) do
        turtleError(msg)
        sleep(5)
    end
end

---@param count? number
---@param msg? string
---@param chestMsg? string
local function pull(count, msg, chestMsg)
    return pullDir(e.c.Turtle.Direction.Front, count, msg, chestMsg)
end

---@param count? number
---@param msg? string
---@param chestMsg? string
local function pullDown(count, msg, chestMsg)
    return pullDir(e.c.Turtle.Direction.Down, count, msg, chestMsg)
end

---@param count? number
---@param msg? string
---@param chestMsg? string
local function pullUp(count, msg, chestMsg)
    return pullDir(e.c.Turtle.Direction.Up, count, msg, chestMsg)
end

tc.error = turtleError
tc.hasRequiredFuel = hasRequiredFuel
tc.emptySlots = emptySlots
tc.hasRoom = hasRoom
tc.emptyInventory = emptyInventory
tc.refuel = refuel
tc.isChest = isChest
tc.isChestDown = isChestDown
tc.isChestUp = isChestUp
tc.isSourceBlock = isSourceBlock
tc.isSourceBlockDown = isSourceBlockDown
tc.isSourceBlockUp = isSourceBlockUp
tc.isOreBlock = isOreBlock
tc.isOreBlockDown = isOreBlockDown
tc.isOreBlockUp = isOreBlockUp
tc.fill = fill
tc.fillDown = fillDown
tc.fillUp = fillUp
tc.dig = dig
tc.digDown = digDown
tc.digUp = digUp
tc.insert = insert
tc.insertDown = insertDown
tc.insertUp = insertUp
tc.pull = pull
tc.pullDown = pullDown
tc.pullUp = pullUp

return tc
