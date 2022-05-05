local completion = require("cc.shell.completion")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
local shellBase = string.sub(ghu.p.ext .. "AngellusMortis/am-cc/turtle/programs/turtle/", 2)

shell.setCompletionFunction(
    shellBase .. "tc.lua",
    completion.build(
        { completion.choice, { "empty", "refuel ", "dig ", "digUp ", "digDown " }, false}
    )
)

local turnDirections = { "left", "right", "front", "back" }
local compGoTo = function(shell, text, previous)
    local op = string.lower(previous[2])
    if op ~= "goto" and op ~= "turn" and op ~= "turnto" and op ~= "nodes" and op ~= "save" then
        return nil
    end

    if op == "nodes" or op == "save" then
        return completion.choice(shell, text, previous, { "true", "false" }, false)
    end

    if op == "turn" then
        return completion.choice(shell, text, previous, { "left", "right" }, false)
    end

    if op == "turnto" then
        return completion.choice(shell, text, previous, turnDirections, false)
    end

    return completion.choice(shell, text, previous, { "origin", "return", "node", "returnnode" }, false)
end
shell.setCompletionFunction(
    shellBase .. "pf.lua",
    completion.build(
        { completion.choice, { "pos", "nodes ", "save ", "reset", "turn ", "turnto ", "go ", "goup ", "goto ", "gotopos " }, false},
        compGoTo,
        nil,
        nil,
        { completion.choice, turnDirections, false}
    )
)
