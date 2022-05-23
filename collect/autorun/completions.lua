local completion = require("cc.shell.completion")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
local shellBase = string.sub(ghu.p.ext .. "AngellusMortis/am-cc/collect/programs/", 2)

local pc = require("am.peripheral")

shell.setCompletionFunction(
    shellBase .. "collect.lua",
    completion.build(
        { completion.choice, pc.getInventoryNames(), true},
        { completion.choice, pc.getInventoryNames(), true},
        nil
    )
)
