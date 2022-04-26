local basePath = settings.get("ghu.base")
local ghu = require(basePath .. "core/apis/ghu")
ghu.initModulePaths()
local turtleCore = require("turtleCore")
local quarry = require("quarryLib")

local function main()
    if quarry.canResume() then
        turtleCore.emptyInventory()
        quarry.runJob(true)
    end
end

main()
