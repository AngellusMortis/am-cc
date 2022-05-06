require(settings.get("ghu.base") .. "core/apis/ghu")

local q = require("am.quarry")

local function main()
    if q.canResume() then
        q.runJob(true)
    end
end

main()
