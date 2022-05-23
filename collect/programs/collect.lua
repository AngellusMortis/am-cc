local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local c = require("am.collect")
local pc = require("am.peripheral")

local function main(from, to, interval)
    v.expect(1, from, "string")
    v.expect(2, to, "string")
    v.expect(3, interval, "number", "nil")

    local allInventories = pc.getInventoryLookup()
    if not allInventories[from] then
        error("Invalid from inventory")
    end
    if not allInventories[to] then
        error("Invalid to inventory")
    end

    if interval ~= nil then
        v.range(interval, 1)
    end

    c.s.job.set(c.CollectJob(from, to, interval))
    c.collect()
end

main(arg[1], arg[2], arg[3])
