local completion = require("cc.shell.completion")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

local shellBase = string.sub(ghu.base .. "AngellusMortis/am-cc/mine/", 2)

shell.setCompletionFunction(
    shellBase .. "programs/turtle/quarry.lua",
    completion.build(
        nil,
        nil,
        nil,
        nil,
        nil,
        nil,
        { completion.choice, { "left", "right", "forward", "back" }, true},
        { completion.choice, { "true", "false" }, false}
    )
)
