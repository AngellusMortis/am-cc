local completion = require("cc.shell.completion")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

local shellBase = string.sub(ghu.base .. "AngellusMortis/am-cc/turtle/", 2)

shell.setCompletionFunction(
    shellBase .. "programs/turtle/tc.lua",
    completion.build(
        { completion.choice, { "empty", "refuel ", "dig ", "digUp ", "digDown " }, false}
    )
)

local directions = { "left", "right", "forward", "back" }
local compGoTo = function(shell, text, previous)
    if previous[2] ~= "goTo" and previous[2] ~= "turn" then
        return nil
    end

    if previous[2] == "turn" then
        return completion.choice(shell, text, previous, directions, false)
    end

    return completion.choice(shell, text, previous, { "origin", "return", "node", "returnNode" }, false)
end
shell.setCompletionFunction(
    shellBase .. "programs/turtle/pf.lua",
    completion.build(
        { completion.choice, { "pos", "nodes ", "returnNodes", "save", "saveReturn", "reset", "go ", "goVert ", "turn ", "goTo ", "goToPos " }, false},
        compGoTo,
        nil,
        nil,
        { completion.choice, directions, false}
    )
)
