local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local log = require("am.log")
local pf = require("am.pathfind")
local e = require("am.event")
local h = require("am.helpers")
local core = require("am.core")

local tc = {}
---@type table<string, string>
--- any block considered a fuel for when discovering fuel chest
local fuels = {
    ["minecraft:coal"] = true,
    ["minecraft:coal_block"] = true,
    ["minecraft:charcoal"] = true,
    ["quark:charcoal_block"] = true,
    ["mekanism:block_charcoal"] = true,
    ["minecraft:lava_bucket"] = true,
}
-- any block matching the following rules are already included
-- * has tag `forge:ores`
-- * name contains `_ore`
-- * name contains `raw_` and `_block`
---@type table<string, string>
local extraOreBlock = {
}

local d = {}
d.chestMap = {
    name = "chestMap",
    default = {
        fuel = "top",
        fill = "right",
        dump = "left",
    },
    type = "table"
}
tc.d = core.makeDataWrapper(d, "tc")

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

---@return table[]
local function getInventories()
    local names = peripheral.getNames()
    local inventories = {}
    for _, name in ipairs(names) do
        local p = peripheral.wrap(name)
        if peripheral.hasType(p, "inventory") then
            inventories[#inventories + 1] = p
        end
    end
    return inventories
end

---@return string|nil
local function getLocalName()
    local modem = peripheral.find("modem", function(_, p) return not p.isWireless() end)
    if modem == nil then
        return nil
    end
    return modem.getNameLocal()
end

local function discoverChests()
    local dumpChest = nil
    local fillChest = nil
    local fuelChest = nil
    while dumpChest == nil or fillChest == nil or fuelChest == nil do
        local inventories = getInventories()
        for _, i in ipairs(inventories) do
            local items = i.list()
            ---@cast items cc.item_simple[]
            local hasItems = false
            local hasFuel = false
            for _, item in pairs(items) do
                hasItems = true
                if fuels[item.name] then
                    hasFuel = true
                    fuelChest = peripheral.getName(i)
                end
                break
            end
            if not hasFuel then
                if hasItems then
                    fillChest = peripheral.getName(i)
                else
                    dumpChest = peripheral.getName(i)
                end
            end
        end

        local found = true
        if dumpChest == nil then
            found = false
            turtleError("No Dump Chest")
        elseif fillChest == nil then
            found = false
            turtleError("No Fill Chest")
        elseif fuelChest == nil then
            found = false
            turtleError("No Fuel Chest")
        end

        if not found then
            sleep(5)
        end
    end

    tc.d.chestMap.set({
        fuel = fuelChest,
        fill = fillChest,
        dump = dumpChest,
    })
end

---@param chestType "fuel"|"fill"|"dump"
---@param count? number
---@return boolean
local function pushItem(chestType, count)
    v.expect(2, count, "number", "nil")
    if count ~= nil then
        v.range(count, 0, 64)
    end
    if count == 0 then
        return
    end

    local success = false
    local chestName = tc.d.chestMap.get()[chestType]
    if chestName == "top" then
        success = turtle.dropUp(count)
    elseif chestName == "bottom" then
        success = turtle.dropDown(count)
    elseif chestName == "left" then
        pf.turnTo(e.c.Turtle.Direction.Left)
        success = turtle.drop(count)
    elseif chestName == "right" then
        pf.turnTo(e.c.Turtle.Direction.Right)
        success = turtle.drop(count)
    else
        pf.turnTo(e.c.Turtle.Direction.Front)
        local chest = peripheral.wrap(chestName)
        local fromSlot = turtle.getSelectedSlot()

        local toSlot = nil
        local items = chest.list()
        for i = 1, chest.size(), 1 do
            if items[i] == nil then
                toSlot = i
                break
            end
        end
        if toSlot ~= nil then
            success = pcall(function () chest.pullItems(getLocalName(), fromSlot, count, toSlot) end)
        end
    end
    return success
end

---@param chestType "fuel"|"fill"|"dump"
---@param count? number
---@param msg? string
local function pushChestType(chestType, count, msg)
    if count == nil then
        count = 1
    end
    v.expect(2, count, "number")

    if msg == nil then
        msg = string.format("Failed to Push Item (%s)", chestType)
    end

    while not pushItem(chestType, count) do
        turtleError(msg)
        sleep(5)
    end
end

---@param chestType "fuel"|"fill"|"dump"
---@param count? number
---@return boolean
local function pullItem(chestType, count)
    v.expect(2, count, "number", "nil")
    if count ~= nil then
        v.range(count, 0, 64)
    end
    if count == 0 then
        return
    end

    local success = false
    local chestName = tc.d.chestMap.get()[chestType]
    if chestName == "top" then
        success = turtle.suckUp(count)
    elseif chestName == "bottom" then
        success = turtle.suckDown(count)
    elseif chestName == "left" then
        pf.turnTo(e.c.Turtle.Direction.Left)
        success = turtle.suck(count)
    elseif chestName == "right" then
        pf.turnTo(e.c.Turtle.Direction.Right)
        success = turtle.suck(count)
    else
        pf.turnTo(e.c.Turtle.Direction.Front)
        local toSlot = turtle.getSelectedSlot()

        local chest = peripheral.wrap(chestName)
        local fromSlot = nil
        for key, _ in pairs(chest.list()) do
            fromSlot = key
            break
        end
        if fromSlot ~= nil then
            success = pcall(function () chest.pushItems(getLocalName(), fromSlot, count, toSlot) end)
        end
    end
    return success
end

---@param chestType "fuel"|"fill"|"dump"
---@param count? number
---@param msg? string
local function pullChestType(chestType, count, msg)
    if count == nil then
        count = 1
    end
    v.expect(2, count, "number")

    if msg == nil then
        msg = string.format("Failed to Pull Item (%s)", chestType)
    end

    while not pullItem(chestType, count) do
        turtleError(msg)
        sleep(5)
    end
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
        oldItem.count = -oldItem.count
        return oldItem
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
    if newItem.count == 0 then
        return nil
    end
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

---@param doFill boolean
local function emptyInventoryBase(doFill)
    local event = e.TurtleEmptyEvent(false, nil)
    event:send()
    if not pf.atOrigin() then
        log.info("Returning to origin...")
        while not pf.goToOrigin() do
            turtleError("Cannot Return to Origin")
            sleep(5)
        end
    end
    pf.turnTo(e.c.Turtle.Direction.Front)

    log.info("Emptying inventory...")
    local startSlot = 1
    if doFill then
        startSlot = 2
    end
    local items = getInventory()
    for i = startSlot, 16, 1 do
        local dumpCount = turtle.getItemCount(i)
        if dumpCount > 0 then
            turtle.select(i)
            pushChestType("dump", dumpCount)
        end
    end
    local newItems = getInventoryDiff(items)
    local placed = {}
    ---@cast placed cc.item[]
    for _, item in pairs(newItems) do
        if item ~= nil and item.count < 0 then
            item.count = math.abs(item.count)
            placed[#placed + 1] = item
        end
    end
    event.completed = true
    event.items = placed
    event:send()

    if doFill then
        event = e.TurtleFetchFillEvent(false, nil)
        event:send()
        items = getInventory()
        turtle.select(1)
        local neededFill = turtle.getItemSpace()
        if neededFill > 0 then
            pullChestType("fill", neededFill)
        end

        newItems = getInventoryDiff(items)
        for _, item in ipairs(newItems) do
            if item ~= nil and item.count > 0 then
                event.completed = true
                event.item = item
                event:send()
            end
        end
    end
    pf.turnTo(e.c.Turtle.Direction.Front)
end

---@param doReturn? boolean
---@param doFill? boolean
local function emptyInventory(doReturn, doFill)
    v.expect(1, doReturn, "boolean", "nil")
    v.expect(2, doFill, "boolean", "nil")
    if doReturn == nil then
        doReturn = false
    end
    if doFill == nil then
        doFill = true
    end

    emptyInventoryBase(doFill)
    local pos = pf.getPos()
    if doReturn and h.isOrigin(pos) then
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
    local pullCount = nil
    turtle.select(2)
    while count > currentLevel do
        pullChestType("fuel", pullCount or 1, string.format("Need %d More Fuel", needed))
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
    local dumpCount = turtle.getItemCount(2)
    if dumpCount > 0 then
        pushChestType("fuel", dumpCount)
    end
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
    local pos = pf.getPos()
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
local function isPerherialDir(moveDir)
    v.expect(1, moveDir, "number")
    v.range(moveDir, -1, 1)

    local dir = "top"
    if moveDir == e.c.Turtle.Direction.Front then
        dir = "front"
    elseif moveDir == e.c.Turtle.Direction.Down then
        dir = "bottom"
    end
    local perh = peripheral.wrap(dir)
    return perh ~= nil
end

---@return boolean
local function isPerherial()
    return isPerherialDir(e.c.Turtle.Direction.Front)
end

---@return boolean
local function isPerherialDown()
    return isPerherialDir(e.c.Turtle.Direction.Down)
end

---@return boolean
local function isPerherialUp()
    return isPerherialDir(e.c.Turtle.Direction.Up)
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
---@return boolean
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
        local success = false
        local hadError = false
        while not success do
            local wasError = false
            if detectDir(moveDir) then
                if not hasRoom() then
                    wasError = true
                    hadError = true
                    emptyInventory(true)
                end
                if not wasError and isPerherialDir(moveDir) then
                    wasError = true
                    hadError = true
                    turtleError("Ignored Block" .. dirStr(moveDir))
                    sleep(5)
                end
                if not wasError and not digDir(moveDir) then
                    local inspectSuccess, data = inspectDir(moveDir)
                    if inspectSuccess and data.name == "minecraft:bedrock" then
                        return false
                    end
                    wasError = true
                    hadError = true
                    turtleError("Cannot Dig Block" .. dirStr(moveDir))
                    sleep(1)
                end

                if not wasError and hasFilled then
                    wasError = true
                    hadError = true
                    sleep(1)
                end
            elseif isSourceBlockDir(moveDir) then
                wasError = true
                hadError = true
                if hasFilled then
                    turtleError("Infinite Source" .. dirStr(moveDir))
                    sleep(3)
                else
                    hasFilled = true
                    fillDir(moveDir)
                end
            end
            if not wasError and not goDir(moveDir) then
                wasError = true
                hadError = true
                turtleError("Cannot Move" .. dirStr(moveDir))
                sleep(1)
            end

            if not wasError then
                success = true
            end
        end
        if hadError then
            e.TurtleErrorClearEvent():send()
        end
    end
    digEventDir(moveDir, count, true)
    return true
end

---@param count? number
---@return boolean
local function dig(count)
    return digMoveDir(e.c.Turtle.Direction.Front, count)
end

---@param count? number
---@return boolean
local function digDown(count)
    return digMoveDir(e.c.Turtle.Direction.Down, count)
end

---@param count? number
---@return boolean
local function digUp(count)
    return digMoveDir(e.c.Turtle.Direction.Up, count)
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

    while not isPerherialDir(moveDir) do
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

    while not isPerherialDir(moveDir) do
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

tc.discoverChests = discoverChests
tc.error = turtleError
tc.hasRequiredFuel = hasRequiredFuel
tc.emptySlots = emptySlots
tc.hasRoom = hasRoom
tc.emptyInventory = emptyInventory
tc.refuel = refuel
tc.isPerherial = isPerherial
tc.isPerherialDown = isPerherialDown
tc.isPerherialUp = isPerherialUp
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
