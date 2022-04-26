local basePath = settings.get("ghu.base")
local ghu = require(basePath .. "core/apis/ghu")
ghu.initModulePaths()
local pathfind = require("pathfind")
local quarry = require("quarryLib")

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
    quarry.setJob(tonumber(left), tonumber(forward), tonumber(levels))
    quarry.runJob()
end

main(arg[1], arg[2], arg[3])
