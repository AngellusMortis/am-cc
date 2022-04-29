local v = require("cc.expect")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

local b = require("buttonH")
local text = require("text")

local ui = {}

local colorNames = {}
for name, number in pairs(colors) do
    colorNames[number] = name
end

ui.isTerm = function(output)
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

ui.Group = function()
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

local function renderBar(barObj, output)
    if output == nil then
        output = term
    end

    local width, _ = output.getSize()
    local label = ""
    if barObj.label ~= nil then
        label = barObj.label
    end
    local length = width - 1
    if barObj.length ~= nil then
        length = barObj.length
    end
    local x = barObj.x + 1

    local oldX, oldY = output.getCursorPos()
    local oldColor = output.getTextColor()
    local oldBackground = output.getBackgroundColor()
    if ui.isTerm(output) then
        b.terminal.bar(
            x, barObj.y, length, barObj.height,
            barObj.current, barObj.total,
            colorNames[barObj.background], colorNames[barObj.fill], colorNames[barObj.border],
            label ~= "", false, label, false, true, false
        )
    else
        b.monitor.bar(
            peripheral.getName(output),
            x, barObj.y, length, barObj.height,
            barObj.current, barObj.total,
            colorNames[barObj.background], colorNames[barObj.fill], colorNames[barObj.border],
            label ~= "", false, label, false, true, false
        )
    end
    output.setCursorPos(oldX, oldY)
    output.setTextColor(oldColor)
    output.setBackgroundColor(oldBackground)
end

ui.Bar = function(y, label)
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
        background=colors.lightGray,
        fill=colors.green,
        border=colors.gray,
    }
    barObj.render = function(output)
        renderBar(barObj, output)
    end

    return barObj
end

ui.a = {}

local function centerAnchor(anchorObj, output, msg)
    v.expect(2, output, "table")
    v.expect(3, msg, "string")

    local width, _ = output.getSize()
    local actualMsg, _ = text.getTextColor(msg)

    return {x=(width - #actualMsg) / 2, y=anchorObj.y}
end

local function bottomAnchor(anchorObj, subAnchor, output, msg)
    v.expect(2, output, "table")

    local _, height = output.getSize()
    anchorObj.y = height

    return subAnchor(anchorObj, output, msg)
end

ui.a.Center = function(y)
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

ui.a.Bottom = function()
    local anchorObj = {y=1}
    anchorObj.getPos = function(output, msg)
        return bottomAnchor(anchorObj, centerAnchor, output, msg)
    end

    return anchorObj
end

ui.a.Top = function()
    local anchorObj = {y=1}
    anchorObj.getPos = function(output, msg)
        return centerAnchor(anchorObj, output, msg)
    end

    return anchorObj
end

ui.a.Left = function(y)
    v.expect(1, y, "number")

    local anchorObj = {y=y}
    anchorObj.getPos = function(output, msg)
        return leftAnchor(anchorObj, output, msg)
    end

    return anchorObj
end

ui.a.TopLeft = function()
    local anchorObj = {y=1}
    anchorObj.getPos = function(output, msg)
        return leftAnchor(anchorObj, output, msg)
    end

    return anchorObj
end

ui.a.BottomLeft = function()
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
    local actualMsg, _ = text.getTextColor(msg)

    return {x=(width - #actualMsg), y=anchorObj.y}
end

ui.a.Right = function(y)
    v.expect(1, y, "number")

    local anchorObj = {y=y}
    anchorObj.getPos = function(output, msg)
        return rightAnchor(anchorObj, output, msg)
    end

    return anchorObj
end

ui.a.TopRight = function()
    local anchorObj = {y=1}
    anchorObj.getPos = function(output, msg)
        return rightAnchor(anchorObj, output, msg)
    end

    return anchorObj
end

ui.a.BottomRight = function()
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

ui.a.Absolute = function(x, y)
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
    local msg, color = text.getTextColor(textObj.text)
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

ui.Text = function(msg, anchor, color, background)
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
