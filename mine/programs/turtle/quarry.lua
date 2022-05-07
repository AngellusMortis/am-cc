local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local core = require("am.core")
local log = require("am.log")
local pf = require("am.pathfind")
local q = require("am.quarry")

---@param walls string
---@param left string
---@param forward string
---@param levels string
---@param offsetX string
---@param offsetZ string
---@param offsetY string
---@param offsetDir string
---@param pretty string
local function main(walls, left, forward, levels, offsetX, offsetZ, offsetY, offsetDir, pretty)
    if walls == nil then
        walls = true
    else
        walls = core.strBool(walls)
    end
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
        pretty = core.strBool(pretty)
    end

    log.s.print.set(not pretty)
    pf.resetPosition()
    if offsetX ~= nil and offsetZ ~= nil and offsetY ~= nil and offsetDir ~= nil then
        q.setOffset(
            tonumber(offsetX),
            tonumber(offsetZ),
            tonumber(offsetY),
            pf.dirFromString(offsetDir, pf.c.DirType.Turn)
        )
    end
    q.setJob(tonumber(left), tonumber(forward), tonumber(levels), walls)
    q.runJob()
end

main(arg[1], arg[2], arg[3], arg[4], arg[5], arg[6], arg[7], arg[8], arg[9])
