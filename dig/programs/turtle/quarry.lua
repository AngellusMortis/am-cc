local basePath = settings.get("ghu.base")
local ghu = require(basePath .. "core/apis/ghu")
ghu.initModulePaths()
local pathfind = require("pathfind")
local turtleCore = require("turtleCore")

local state = {
    left = 16, forward = 16, down = 1,
    refuelTarget = 320, refuelLevel = 1,
    completed = 0
}

local function calulateRefuel()
    local fuelPerLevel = state.left * state.forward + (state.left * 2) + (state.forward * 2)
    local requiredFuel = fuelPerLevel
    local levels = state.levels
    if turtle.getFuelLimit() == "unlimited" then
        requiredFuel = fuelPerLevel * state.levels
    else
        levels = 1
        while levels < state.levels and (requiredFuel + fuelPerLevel) < turtle.getFuelLimit() do
            requiredFuel = requiredFuel + fuelPerLevel
            levels = levels + 1
        end
    end

    return requiredFuel, levels
end

local function digLevel()
    pathfind.turnTo(pathfind.c.FORWARD)

    print(string.format(".Start level %d of %d", state.completed + 1, state.levels))
    local pos = pathfind.getPosition()
    if pos.x == 0 and pos.z == 0 then
        turtleCore.digForward()
    end
    if state.completed > 0 then
        turtleCore.digDown(state.completed + pos.y)
    end

    for row = 1, state.left, 1 do
        print(string.format("..Start row %d of %d", row, state.left))
        turtleCore.digForward(state.forward - 1)

        if row < state.left then
            pathfind.turnTo(pathfind.c.LEFT)
            turtleCore.digForward()

            if row % 2 == 0 then
                pathfind.turnTo(pathfind.c.FORWARD)
            else
                pathfind.turnTo(pathfind.c.BACK)
            end
        end
    end
    print("..Return to start")
    if not pathfind.goTo(0, 1) then
        error("Could not return to start")
    end
    state.completed = state.completed + 1
end

local function main(left, forward, levels)
    if left == nil then
        left = 16
    end
    if forward == nil then
        forward = left
    end
    if levels == nil then
        levels = 1
    end

    pathfind.resetPosition()
    state.left = tonumber(left)
    state.forward = tonumber(forward)
    state.levels = tonumber(levels)
    state.completed = 0
    state.refuelTarget, state.refuelLevel = calulateRefuel()

    print(string.format("Quarry: %d x %d (%d)", state.left, state.forward, state.levels))

    turtleCore.emptyInventory()
    while state.completed < state.levels do
        if state.completed % state.refuelLevel == 0 then
            turtleCore.goRefuel(state.refuelLevel, state.completed ~= 0)
        end
        digLevel()
    end
    turtleCore.emptyInventory()
end

main(arg[1], arg[2], arg[3])
