local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local log = require("am.log")
local colonies = require("am.colonies")

local function statusLoop()
    while true do
        log.info("Polling colony status...")
        colonies.pollColony()
        log.info("Completed polling colony status")
        sleep(30)
    end
end

statusLoop()
