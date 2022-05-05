local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local tc = require("am.turtle")

local function printUsage(op)
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    local usage = " <action> [count]"
    local printActions = false

    if op == "empty" then
        usage = " empty"
    elseif op == "refuel" then
        usage = " refuel <count>"
    elseif op == "dig" then
        usage = " dig <count>"
    elseif op == "digUp" then
        usage = " digUp <count>"
    elseif op == "digDown" then
        usage = " digDown <count>"
    else
        printActions = true
    end

    print("Usage: " .. programName .. usage)
    if printActions then
        print("Actions:")
        print("empty, refuel, dig, digUp, digDown")
    end
end

local function main(op, count)
    if count == nil then
        count = 1
    else
        count = tonumber(count)
    end

    if op == "empty" then
        tc.emptyInventory()
    elseif op == "refuel" then
        local current = turtle.getFuelLevel()
        if current == "unlimited" then
            print("Fuel disabled")
            return
        end

        if current == turtle.getFuelLimit() then
            print("At limit")
            return
        end

        tc.refuel(current + count)
    elseif op == "dig" then
        tc.digForward(count)
    elseif op == "digUp" then
        tc.digUp(count)
    elseif op == "digDown" then
        tc.digDown(count)
    else
        printUsage(op)
    end
end

main(arg[1], arg[2])
