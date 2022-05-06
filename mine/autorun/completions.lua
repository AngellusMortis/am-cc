local completion = require("cc.shell.completion")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
local shellBase = string.sub(ghu.p.ext .. "AngellusMortis/am-cc/mine/programs/turtle/", 2)

shell.setCompletionFunction(
    shellBase .. "quarry.lua",
    completion.build(
        nil,
        nil,
        nil,
        { completion.choice, { "true", "false" }, true},
        nil,
        nil,
        nil,
        { completion.choice, { "left", "right", "forward", "back" }, true},
        { completion.choice, { "true", "false" }, false}
    )
)
