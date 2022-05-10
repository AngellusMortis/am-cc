---@return boolean
local function isRunning()
    local count = 0
    for i = 1, multishell.getCount(), 1 do
        if multishell.getTitle(i) == "progress" then
            count = count + 1
            if count > 0 then
                return true
            end
        end
    end
    return false
end

if not isRunning() then
    shell.run("bg progress")
end
