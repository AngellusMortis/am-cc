local v = require("cc.expect")
local pp = require("cc.pretty")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

local pathfind = require("pathfind")

local function printUsage(op)
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    local usage = " <pos|nodes|returnNodes|save|saveReturn|reset|go|goVert|turn|turnLeft|turnRight|goTo|goToPos> [args] ..."

    if op == "pos" then
        usage = " pos"
    elseif op == "nodes" then
        usage = " nodes"
    elseif op == "returnNodes" then
        usage = " returnNodes"
    elseif op == "save" then
        usage = " save"
    elseif op == "saveReturn" then
        usage = " saveReturn"
    elseif op == "reset" then
        usage = " reset"
    elseif op == "go" then
        usage = " go <count>"
    elseif op == "goVert" then
        usage = " goVert <count>"
    elseif op == "turn" then
        usage = " turn <dir>"
    elseif op == "turnLeft" then
        usage = " turnLeft"
    elseif op == "turnRight" then
        usage = " turnRight"
    elseif op == "goTo" then
        usage = " goTo <origin|return|node|returnNode>"
    elseif op == "goToPos" then
        usage = " goToPos [x] [z] [y] [dir]"
    end

    print("Usage: " .. programName .. usage)
end

local function main(op, arg1, arg2, arg3, arg4)
    op = string.lower(op)

    if op == "pos" then
        pp.pretty_print(pathfind.getPosition())
    elseif op == "nodes" then
        pp.pretty_print(pathfind.getNodes())
    elseif op == "returnnodes" then
        pp.pretty_print(pathfind.getReturnNodes())
    elseif op == "save" then
        pp.pretty_print(pathfind.addNode())
    elseif op == "savereturn" then
        pp.pretty_print(pathfind.addReturnNode())
    elseif op == "reset" then
        pathfind.resetPosition()
    elseif op == "go" or op == "govert" then
        if arg1 == nil then
            arg1 = 1
        end

        local count = tonumber(arg1)
        if op == "go" then
            pp.pretty_print(pathfind.go(count))
        else
            pp.pretty_print(pathfind.goVert(count))
        end
        pp.pretty_print(success)
    elseif op == "turn" then
        if arg1 == nil then
            arg1 = 1
        end

        local dir = pathfind.dirFromString(arg1)
        pp.pretty_print(pathfind.turnTo(dir))
    elseif op == "turnleft" then
        pp.pretty_print(pathfind.turnLeft())
    elseif op == "turnright" then
        pp.pretty_print(pathfind.turnRight())
    elseif op == "goto" then
        arg1 = string.lower(arg1)
        if arg1 == "origin" then
            pp.pretty_print(pathfind.goToOrigin())
        elseif arg1 == "return" then
            pp.pretty_print(pathfind.goToReturn())
        elseif arg1 == "node" then
            pp.pretty_print({pathfind.goToPreviousNode()})
        elseif arg1 == "returnnode" then
            pp.pretty_print({pathfind.goToPreviousReturnNode()})
        else
            printUsage(op)
        end
    elseif op == "gotopos" then
        if arg1 == nil then
            arg1 = 0
        end
        if arg2 == nil then
            arg2 = 0
        end
        if arg3 == nil then
            arg3 = 0
        end

        local x = tonumber(arg1)
        local z = tonumber(arg2)
        local y = tonumber(arg3)
        local dir = pathfind.dirFromString(arg4)
        pp.pretty_print(pathfind.goTo(x, z, y, dir))
    else
        printUsage(op)
    end
end

main(arg[1], arg[2], arg[3], arg[4], arg[5])
