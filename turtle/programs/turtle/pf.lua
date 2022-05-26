local v = require("cc.expect")
local pp = require("cc.pretty")

require(settings.get("ghu.base") .. "core/apis/ghu")

local log = require("am.log")
local core = require("am.core")
local pf = require("am.pathfind")

---@param op string
local function printUsage(op)
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    local usage = " <action> [args] ..."
    local printActions = false

    if op == "pos" then
        usage = " pos"
    elseif op == "nodes" then
        usage = " nodes <isReturn>"
    elseif op == "save" then
        usage = " save <isReturn>"
    elseif op == "reset" then
        usage = " reset"
    elseif op == "turn" then
        usage = " turn <left|right>"
    elseif op == "turnTo" then
        usage = " turnTo <dir>"
    elseif op == "go" then
        usage = " go <count>"
    elseif op == "goUp" then
        usage = " goUp <count>"
    elseif op == "goTo" then
        usage = " goTo <origin|return|node|returnNode>"
    elseif op == "goToPos" then
        usage = " goToPos [x] [z] [y] [dir]"
    else
        printActions = true
    end

    print("Usage: " .. programName .. usage)
    if printActions then
        print("Actions:")
        print("pos, nodes, save, reset, turn, turnTo, go, goUp, goTo, goToPos")
    end
end

---@param op string
---@param arg1 string
---@param arg2 string
---@param arg3 string
---@param arg4 string
local function main(op, arg1, arg2, arg3, arg4)
    log.s.print.set(true)
    if op ~= nil then
        op = string.lower(op)
    end

    if op == "pos" then
        log.debug("pf pos")
        log.info(pf.getPos())
    elseif op == "nodes" or op == "save" then
        if arg1 == nil then
            arg1 = false
        end
        local isReturn = core.strBool(arg1)
        v.expect(2, isReturn, "boolean")

        log.debug(string.format("pf %s %s", op, isReturn))
        if op == "save" then
            log.info(pf.addNode(nil, isReturn))
            return
        end

        if isReturn then
            log.info(pf.getReturnNodes())
        else
            log.info(pf.getNodes())
        end
    elseif op == "reset" then
        log.debug("pf reset")
        pf.resetPosition()
    elseif op == "go" or op == "goup" then
        if arg1 == nil then
            arg1 = 1
        end

        local count = tonumber(arg1)
        local success
        log.debug(string.format("pf %s %d", op, count))
        if op == "go" then
            success = pf.goHorizontal(count)
        else
            success = pf.goVertical(count)
        end
        log.info(success)
    elseif op == "turnto" then
        if arg1 == nil then
            arg1 = "front"
        end
        string.lower(arg1)

        log.debug(string.format("pf turnTo %s", arg1))
        local dir = pf.dirFromString(arg1, pf.c.DirType.Turn)
        log.info(pf.turnTo(dir))
    elseif op == "turn" then
        arg1 = string.lower(arg1)
        if arg1 == "left" then
            log.debug("pf turn left")
            log.info(pf.turnLeft())
        elseif arg1 == "right" then
            log.debug("pf turn right")
            log.info(pf.turnRight())
        else
            printUsage(op)
        end
    elseif op == "goto" then
        arg1 = string.lower(arg1)
        if arg1 == "origin" then
            log.debug("pf goto origin")
            log.info(pf.goToOrigin())
        elseif arg1 == "return" then
            log.debug("pf goto return")
            log.info(pf.goToReturn())
        elseif arg1 == "node" then
            log.debug("pf goto node")
            log.info({pf.goToPreviousNode(false)})
        elseif arg1 == "returnnode" then
            log.debug("pf goto returnnode")
            log.info({pf.goToPreviousNode(true)})
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
        local dir = pf.dirFromString(arg4)
        log.debug(string.format("pf gotopos %d %d %d %s", x, z, y, dir))
        log.info(pf.goTo(x, z, y, dir))
    else
        printUsage(op)
    end
end

main(arg[1], arg[2], arg[3], arg[4], arg[5])
