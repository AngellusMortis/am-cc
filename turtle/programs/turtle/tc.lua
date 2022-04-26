local v = require("cc.expect")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

local turtleCore = require("turtleCore")

local function printUsage(op)
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    local usage = " <empty|refuel|dig|digUp|digDown> [count]"

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
    end

    print("Usage: " .. programName .. usage)
end

local function main(op, count)
    if count == nil then
        count = 1
    else
        count = tonumber(count)
    end

    if op == "empty" then
        turtleCore.emptyInventory()
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

        turtleCore.goRefuel(current + count, false)
    elseif op == "dig" then
        turtleCore.digForward(count)
    elseif op == "digUp" then
        turtleCore.digUp(count)
    elseif op == "digDown" then
        turtleCore.digDown(count)
    else
        printUsage(op)
    end
end

main(arg[1], arg[2])
