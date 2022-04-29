local v = require("cc.expect")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

local textLib = require("textLib")

local uiLib = {}
uiLib.c = {}

local colorNames = {}
for name, number in pairs(colors) do
    colorNames[number] = name
end

uiLib.isTerm = function(output)
    v.expect(1, output, "table")

    return output.redirect ~= nil
end

local function addToGroup(groupObj, uiObj, id)
    if id == nil then
        id = "ui" .. tostring(groupObj.idAuto)
        groupObj.idAuto = groupObj.idAuto + 1
    end

    v.expect(2, uiObj, "table")
    v.expect(3, id, "string")
    if uiObj.render == nil then
        error("Not a valid UI obj")
    end

    groupObj.items[id] = uiObj
end

local function removeFromGroup(groupObj, id)
    v.expect(2, id, "string")

    if groupObj.items[id] == nil then
        error(id .. " not in UI group")
    end

    table.remove(groupObj.items, id)
end

local function resetGroup(groupObj)
    groupObj.items = {}
end

local function renderGroup(groupObj, output)
    local _, height = output.getSize()

    output.clear()
    output.setCursorPos(1, 1)
    output.setCursorBlink(false)
    output.setTextColor(colors.white)

    for _, uiObj in pairs(groupObj.items) do
        uiObj.render(output)
    end

    output.setCursorPos(1, height)
end

uiLib.Group = function()
    local groupObj = {
        items = {},
        idAuto = 1
    }
    groupObj.add = function(uiObj, id)
        addToGroup(groupObj, uiObj, id)
    end
    groupObj.remove = function(id)
        removeFromGroup(groupObj, id)
    end
    groupObj.reset = function()
        resetGroup(groupObj)
    end
    groupObj.render = function(output)
        renderGroup(groupObj, output)
    end

    return groupObj
end

local function validateBar(barObj, output)
    local width, height = output.getSize()

    v.field(barObj, "border", "number")
    v.range(barObj.border, 0, 3)

    v.field(barObj, "x", "number")
    v.range(barObj.x, 1, width - 2)

    v.field(barObj, "y", "number")
    if barObj.border == 0 then
        v.range(barObj.y, 1, height)
    else
        v.range(barObj.y, 1, height - 2)
    end

    v.field(barObj, "current", "number")
    v.range(barObj.current, 0)

    v.field(barObj, "total", "number")
    v.range(barObj.total, math.floor(barObj.current))

    v.field(barObj, "label", "string", "nil")

    v.field(barObj, "height", "number")
    if barObj.border == 0 then
        v.range(barObj.height, 1, height)
    else
        v.range(barObj.height, 1, height - 2)
    end

    v.field(barObj, "length", "number", "nil")
    if barObj.length ~= nil then
        v.range(barObj.length, 3, width)
    end

    v.field(barObj, "backgroundColor", "number")
    v.range(barObj.backgroundColor, 1)
    v.field(barObj, "fillColor", "number")
    v.range(barObj.fillColor, 1)
    v.field(barObj, "borderColor", "number")
    v.range(barObj.borderColor, 1)

    v.field(barObj, "showPercent", "boolean")
    v.field(barObj, "showProgress", "boolean")
end

local function renderBorder1(barObj, output, length, oldBackground)
    -- top
    output.setCursorPos(barObj.x, barObj.y)
    output.setTextColor(oldBackground)
    output.setBackgroundColor(barObj.borderColor)
    output.write("\159" .. string.rep("\143", length - 2))
    output.setTextColor(barObj.borderColor)
    output.setBackgroundColor(oldBackground)
    output.write("\144")

    for i = 1, barObj.height, 1 do
        -- left border
        output.setCursorPos(barObj.x, barObj.y + i)
        output.setTextColor(oldBackground)
        output.setBackgroundColor(barObj.borderColor)
        output.write("\x95")

        -- right border
        output.setCursorPos(barObj.x + length - 1, barObj.y + i)
        output.setTextColor(barObj.borderColor)
        output.setBackgroundColor(oldBackground)
        output.write("\x95")
    end

    -- bottom border
    output.setCursorPos(barObj.x, barObj.y + barObj.height + 1)
    output.setTextColor(barObj.borderColor)
    output.setBackgroundColor(oldBackground)
    output.write("\130" .. string.rep("\131", length - 2) .. "\129")
end

local function renderBorder2(barObj, output, length, oldBackground)
    -- top
    output.setCursorPos(barObj.x, barObj.y)
    output.setTextColor(oldBackground)
    output.setBackgroundColor(barObj.borderColor)
    output.write(string.rep("\x83", length + 1))

    for i = 1, barObj.height, 1 do
        -- left border
        output.setCursorPos(barObj.x, barObj.y + 1)
        output.setTextColor(oldBackground)
        output.setBackgroundColor(barObj.borderColor)
        output.write(" ")

        -- right border
        output.setCursorPos(barObj.x + length - 1, barObj.y + 1)
        output.setTextColor(oldBackground)
        output.setBackgroundColor(barObj.borderColor)
        output.write(" ")
    end

    -- bottom border
    output.setCursorPos(barObj.x, barObj.y + barObj.height + 1)
    output.setTextColor(barObj.borderColor)
    output.setBackgroundColor(oldBackground)
    output.write(string.rep("\143", length + 1))
end

local function renderBorder3(barObj, output, length, oldBackground)
    output.setBackgroundColor(barObj.borderColor)

    -- top
    output.setCursorPos(barObj.x, barObj.y)
    output.setBackgroundColor(barObj.borderColor)
    output.write(string.rep(" ", length + 1))

    for i = 1, barObj.height, 1 do
        -- left border
        output.setCursorPos(barObj.x, barObj.y + i)
        output.write(" ")

        -- right border
        output.setCursorPos(barObj.x + length - 1, barObj.y + i)
        output.write(" ")
    end

    -- bottom border
    output.setCursorPos(barObj.x, barObj.y + barObj.height + 1)
    output.write(string.rep(" ", length + 1))
end

local function renderBar(barObj, output)
    if output == nil then
        output = term
    end
    validateBar(barObj, output)

    local width, height = output.getSize()
    local oldX, oldY = output.getCursorPos()
    local oldColor = output.getTextColor()
    local oldBackground = output.getBackgroundColor()

    local length = barObj.length
    if length == nil then
        length = width
    end

    local startOffset = 1
    local barLength = length - 2

    if barObj.border == 0 then
        startOffset = 0
        barLength = length
    elseif barObj.border == 1 then
        renderBorder1(barObj, output, length, oldBackground)
    elseif barObj.border == 2 then
        renderBorder2(barObj, output, length, oldBackground)
    else
        renderBorder3(barObj, output, length, oldBackground)
    end

    local current = math.min(barObj.current, barObj.total)
    local percent = current / barObj.total
    local label = " "
    if barObj.label ~= nil then
        label = label .. barObj.label
    end
    if barObj.showPercent then
        label = label .. string.format(" %d%%", percent * 100)
    end
    if barObj.showProgress then
        label = label .. string.format(" [%d/%d]", current, barObj.total)
    end
    local fillTo = percent * length
    local baseX = barObj.x + startOffset

    for x = 0, barLength - 1, 1 do
        output.setCursorPos(baseX + x, barObj.y + startOffset)
        if x < fillTo then
            output.setBackgroundColor(barObj.fillColor)
        else
            output.setBackgroundColor(barObj.backgroundColor)
        end
        output.write(" ")
    end
    for x = 0, #label, 1 do
        output.setCursorPos(baseX + x, barObj.y + startOffset)
        output.setTextColor(barObj.textColor)
        if x < fillTo then
            output.setBackgroundColor(barObj.fillColor)
        else
            output.setBackgroundColor(barObj.backgroundColor)
        end
        output.write(label:sub(x + 1, x + 1))
    end

    output.setCursorPos(oldX, oldY)
    output.setTextColor(oldColor)
    output.setBackgroundColor(oldBackground)
end

uiLib.Bar = function(y, label)
    v.expect(1, y, "number")
    v.expect(2, label, "string", "nil")

    local barObj = {
        x=1,
        y=y,
        current=0,
        total=1,
        label=label,
        height=1,
        length=nil,
        backgroundColor=colors.lightGray,
        fillColor=colors.green,
        borderColor=colors.gray,
        textColor=colors.gray,
        showProgress=true,
        showPercent=true,
        border=1,
    }
    barObj.render = function(output)
        renderBar(barObj, output)
    end

    return barObj
end

uiLib.a = {}

local function centerAnchor(anchorObj, output, msg)
    v.expect(2, output, "table")
    v.expect(3, msg, "string")

    local width, _ = output.getSize()
    local actualMsg, _ = textLib.getTextColor(msg)

    return {x=(width - #actualMsg) / 2, y=anchorObj.y}
end

local function bottomAnchor(anchorObj, subAnchor, output, msg)
    v.expect(2, output, "table")

    local _, height = output.getSize()
    anchorObj.y = height

    return subAnchor(anchorObj, output, msg)
end

uiLib.a.Center = function(y)
    v.expect(1, y, "number")

    local anchorObj = {y=y}
    anchorObj.getPos = function(output, msg)
        return centerAnchor(anchorObj, output, msg)
    end

    return anchorObj
end

local function leftAnchor(anchorObj, output, msg)
    return {x=1, y=anchorObj.y}
end

uiLib.a.Bottom = function()
    local anchorObj = {y=1}
    anchorObj.getPos = function(output, msg)
        return bottomAnchor(anchorObj, centerAnchor, output, msg)
    end

    return anchorObj
end

uiLib.a.Top = function()
    local anchorObj = {y=1}
    anchorObj.getPos = function(output, msg)
        return centerAnchor(anchorObj, output, msg)
    end

    return anchorObj
end

uiLib.a.Left = function(y)
    v.expect(1, y, "number")

    local anchorObj = {y=y}
    anchorObj.getPos = function(output, msg)
        return leftAnchor(anchorObj, output, msg)
    end

    return anchorObj
end

uiLib.a.TopLeft = function()
    local anchorObj = {y=1}
    anchorObj.getPos = function(output, msg)
        return leftAnchor(anchorObj, output, msg)
    end

    return anchorObj
end

uiLib.a.BottomLeft = function()
    local anchorObj = {y=1}
    anchorObj.getPos = function(output, msg)
        return bottomAnchor(anchorObj, leftAnchor, output, msg)
    end

    return anchorObj
end

local function rightAnchor(anchorObj, output, msg)
    v.expect(2, output, "table")
    v.expect(3, msg, "string")

    local width, _ = output.getSize()
    local actualMsg, _ = textLib.getTextColor(msg)

    return {x=(width - #actualMsg), y=anchorObj.y}
end

uiLib.a.Right = function(y)
    v.expect(1, y, "number")

    local anchorObj = {y=y}
    anchorObj.getPos = function(output, msg)
        return rightAnchor(anchorObj, output, msg)
    end

    return anchorObj
end

uiLib.a.TopRight = function()
    local anchorObj = {y=1}
    anchorObj.getPos = function(output, msg)
        return rightAnchor(anchorObj, output, msg)
    end

    return anchorObj
end

uiLib.a.BottomRight = function()
    local anchorObj = {y=1}
    anchorObj.getPos = function(output, msg)
        return bottomAnchor(anchorObj, rightAnchor, output, msg)
    end

    return anchorObj
end

local function absAnchor(anchorObj, output, msg)
    v.expect(2, output, "table")
    v.expect(3, msg, "string")

    return anchorObj
end

uiLib.a.Absolute = function(x, y)
    v.expect(1, x, "number")
    v.expect(2, y, "number")

    local anchorObj = {x=x, y=y}
    anchorObj.getPos = function(output, msg)
        return absAnchor(anchorObj, output, msg)
    end

    return anchorObj
end

local function renderText(textObj, output)
    if output == nil then
        output = term
    end

    local oldX, oldY = output.getCursorPos()
    local oldColor = output.getTextColor()
    local oldBackground = output.getBackgroundColor()

    local anchorPos = textObj.anchor.getPos(output, textObj.text)
    local msg, color = textLib.getTextColor(textObj.text)
    if textObj.color ~= nil then
        output.setTextColor(textObj.color)
    elseif color ~= nil then
        output.setTextColor(color)
    end
    if textObj.background ~= nil then
        output.setBackgroundColor(textObj.background)
    end
    output.setCursorPos(anchorPos.x, anchorPos.y)
    output.write(msg)

    output.setCursorPos(oldX, oldY)
    output.setTextColor(oldColor)
    output.setBackgroundColor(oldBackground)
end

uiLib.Text = function(msg, anchor, color, background)
    v.expect(1, msg, "string")
    v.expect(2, anchor, "table")
    if anchor.getPos == nil then
        error("Not an anchor")
    end
    if color ~= nil then
        v.expect(3, color, "number")
    end
    if background ~= nil then
        v.expect(4, background, "number")
    end

    local textObj = {text=msg, anchor=anchor, color=color, background=background}
    textObj.render = function(output)
        renderText(textObj, output)
    end

    return textObj
end

return ui
