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
    local op = string.lower(previous[2])
    if op ~= "goto" and op ~= "turn" then
        return nil
    end

    if op == "turn" then
        return completion.choice(shell, text, previous, directions, false)
    end

    return completion.choice(shell, text, previous, { "origin", "return", "node", "returnNode" }, false)
end
shell.setCompletionFunction(
    shellBase .. "programs/turtle/pf.lua",
    completion.build(
        { completion.choice, { "pos", "nodes ", "returnnodes", "save", "savereturn", "reset", "go ", "govert ", "turn ", "turnleft", "turnright", "goto ", "gotopos " }, false},
        compGoTo,
        nil,
        nil,
        { completion.choice, directions, false}
    )
)
