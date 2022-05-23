require(settings.get("ghu.base") .. "core/apis/ghu")

local c = require("am.collect")

if c.s.job.get() ~= nil then
    c.collect()
end
