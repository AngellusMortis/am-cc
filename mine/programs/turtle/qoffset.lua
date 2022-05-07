local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local pf = require("am.pathfind")
local q = require("am.quarry")
local log = require("am.log")

---@param x? string
---@param z? string
---@param y? string
---@param dir? string
local function main(x, z, y, dir)
    v.expect(1, x, "string", "nil")
    v.expect(2, z, "string", "nil")
    v.expect(3, y, "string", "nil")
    v.expect(4, dir, "string", "nil")
    if x == nil and z == nil and y == nil and dir == nil then
    elseif x == "clear" then
        q.clearOffset()
    else
        q.setOffset(
            tonumber(x),
            tonumber(z),
            tonumber(y),
            pf.dirFromString(dir, pf.c.DirType.Turn)
        )
    end
    local offset = q.s.offsetPos.get()
    if offset then
        log.info(string.format("Quarry Offset: %s", log.format(offset)))
    else
        log.info("No quarry offset")
    end
end

main(arg[1], arg[2], arg[3], arg[4])
