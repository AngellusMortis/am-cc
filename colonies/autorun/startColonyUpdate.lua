require(settings.get("ghu.base") .. "core/apis/ghu")

local colonies = require("am.colonies")

---@return boolean
local function isRunning()
    local count = 0
    for i = 1, multishell.getCount(), 1 do
        if multishell.getTitle(i) == "colonyUpdate" then
            count = count + 1
            if count > 0 then
                return true
            end
        end
    end
    return false
end

if colonies.canResume() and not isRunning() then
    shell.run("bg colonyUpdate")
    multishell.setFocus(2)
end
