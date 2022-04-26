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

local progress = { total = 0, level = 0 }

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
    local progressOneLevel = 1 / state.levels
    pathfind.turnTo(pathfind.c.FORWARD)

    progress.level = 0
    print(string.format(
        ".Start level %d of %d (%d%%, %d%%)",
        state.completed + 1, state.levels,
        progress.level * 100, progress.total * 100
    ))
    local pos = pathfind.getPosition()
    if pos.x == 0 and pos.z == 0 then
        turtleCore.digForward()
    end
    if state.completed > 0 then
        turtleCore.digDown(state.completed + pos.y)
    end

    for row = 1, state.left, 1 do
        progress.level = (row - 1) / state.left
        progress.total = state.completed / state.levels + progressOneLevel * progress.level

        print(string.format(
            "..Start row %d of %d (%d%%, %d%%)",
            row, state.left,
            progress.level * 100, progress.total * 100
        ))
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
        progress.level = row / state.left
        progress.total = state.completed / state.levels + progressOneLevel * progress.level
    end
    print(string.format(
        "..Return to start (%d%%, %d%%)",
        progress.level * 100, progress.total * 100
    ))
    if not pathfind.goTo(0, 1) then
        error("Could not return to start")
    end
    state.completed = state.completed + 1
    progress.level = 1
    progress.total = state.completed / state.levels
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
