local completion = require("cc.shell.completion")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
local shellBase = string.sub(ghu.p.ext .. "AngellusMortis/am-cc/tree/programs/turtle/", 2)

shell.setCompletionFunction(
    shellBase .. "tree.lua",
    completion.build(
        { completion.choice, { "true", "false" }, false}
    )
)
