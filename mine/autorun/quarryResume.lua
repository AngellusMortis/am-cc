local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
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
