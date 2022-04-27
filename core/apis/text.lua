local v = require("cc.expect")
local pp = require("cc.pretty")

local text = {}

text.center = function(msg, output)
    if output == nil then
        output = term
    end
    v.expect(1, msg, "string")

    local width, _ = output.getSize()
    local _, y = output.getCursorPos()
    local x = (width - #msg) / 2

    output.setCursorPos(x, y)
    output.write(msg)
end

return text
