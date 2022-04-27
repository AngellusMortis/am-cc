local v = require("cc.expect")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

local log = require("log")
local pathfind = require("pathfind")
local quarry = require("quarryLib")

local function main(left, forward, levels, pretty)
    if left == nil then
        left = 16
    end
    if forward == nil then
        forward = left
    end
    if levels == nil then
        levels = 1
    end
    if pretty == nil then
        pretty = true
    else
        pretty = ghu.strBool(pretty)
    end
    v.expect(4, pretty, "boolean")

    log.setPrint(not pretty)
    pathfind.resetPosition()
    quarry.setJob(tonumber(left), tonumber(forward), tonumber(levels))
    quarry.runJob()
end

main(arg[1], arg[2], arg[3], arg[4])
