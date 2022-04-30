local v = require("cc.expect")
local pp = require("cc.pretty")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")

local text = {}

text.getTextColor = function(msg)
    local parts = ghu.split(msg, ":")
    local color = nil
    if #parts == 2 then
        if string.lower(parts[1]) == "error" then
            color = colors.red
            msg = parts[2]
        elseif string.lower(parts[1]) == "warning" then
            color = colors.yellow
            msg = parts[2]
        elseif string.lower(parts[1]) == "success" then
            color = colors.green
            msg = parts[2]
        elseif string.lower(parts[1]) == "info" then
            color = colors.blue
            msg = parts[2]
        end
    end

    return msg, color
end

text.writeStatus = function(msg, output)
    if output == nil then
        output = term
    end
    v.expect(1, msg, "string")

    local parts = ghu.split(msg, ":")
    local oldColor = output.getTextColor()
    if #parts == 2 then
        if string.lower(parts[1]) == "error" then
            output.setTextColor(colors.red)
            msg = parts[2]
        elseif string.lower(parts[1]) == "warning" then
            output.setTextColor(colors.yellow)
            msg = parts[2]
        elseif string.lower(parts[1]) == "success" then
            output.setTextColor(colors.green)
            msg = parts[2]
        elseif string.lower(parts[1]) == "info" then
            output.setTextColor(colors.blue)
            msg = parts[2]
        end
    end
    output.write(msg)
    output.setTextColor(oldColor)
end

text.write = function(output, msg, x, y)
    if type(output) ~= "table" then
        y = x
        x = msg
        msg = output
        output = term
    end
    local oldX, oldY = output.getCursorPos()
    local oldColor = output.getTextColor()

    if x == nil then
        x = oldX
    end
    if y == nil then
        y = oldY
    end
    v.expect(1, output, "table")
    v.expect(2, msg, "string")
    v.expect(3, x, "number")
    v.expect(4, y, "number")

    local actualMsg, color = text.getTextColor(msg)
    output.setCursorPos(x, y)
    if color ~= nil then
        output.setTextColor(color)
    end
    output.write(actualMsg)
    output.setTextColor(oldColor)
    output.setCursorPos(oldX, oldY)
end

text.center = function(output, msg, y, clear)
    if type(output) ~= "table" then
        y = msg
        msg = output
        output = term
    end
    local oldX, oldY = output.getCursorPos()
    local oldColor = output.getTextColor()
    local width, _ = output.getSize()

    if y == nil then
        y = oldY
    end
    if clear == nil then
        clear = true
    end
    v.expect(1, output, "table")
    v.expect(2, msg, "string")
    v.expect(3, y, "number")
    v.expect(4, clear, "boolean")

    local actualMsg, color = text.getTextColor(msg)
    if clear then
        output.setCursorPos(1, y)
        output.clearLine()
        output.setCursorPos(oldX, oldY)
    end
    text.write(output, msg, (width - #actualMsg) / 2, y)
end

return text
