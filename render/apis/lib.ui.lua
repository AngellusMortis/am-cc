local v = require("cc.expect")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

local textLib = require("lib.text")

local ui = {}
ui.c = {}

local colorNames = {}
for name, number in pairs(colors) do
    colorNames[number] = name
end

ui.isTerm = function(output)
    v.expect(1, output, "table")

    return output.redirect ~= nil
end

local function handleEvent(uiObj, event, output)
    local isGui = false
    if uiObj.output ~= nil then
        isGui = true
        output = uiObj.output
    end
    v.expect(3, output, "table")

    if not ui.isTerm(output) then
        if event[2] ~= peripheral.getName(output) then
            return
        end
    end

    if event[1] == "term_resize" or event[1] == "monitor_resize" then
        uiObj.render(output)
        return
    end

    if isGui then
        for _, subObj in pairs(uiObj.items) do
            subObj.handle(event, output)
        end
        return
    end

    local handler = nil
    local args = {}
    -- click/touch events
    if event[1] == "mouse_click" or event[1] == "mouse_up" or event[1] == "monitor_touch" then
        if event[1] == "mouse_click" then
            args = {clickType=event[2], x=event[3], y=event[4]}
            if event[2] == 1 then
                handler = uiObj.onClick or uiObj.onActivate
            elseif event[2] == 2 then
                handler = uiObj.onRightClick or uiObj.onActivate
            else
                handler = uiObj.onMiddleClick or uiObj.onActivate
            end
        elseif event[1] == "mouse_up" then
            args = {clickType = event[2], x=event[3], y=event[4]}
            if event[2] == 1 then
                handler = uiObj.onMouseUp or uiObj.onDeactivate
            elseif event[2] == 2 then
                handler = uiObj.onMouseRightUp or uiObj.onDeactivate
            else
                handler = uiObj.onMouseMiddleUp or uiObj.onDeactivate
            end
        elseif event[1] == "monitor_touch" then
            args = {clickType = nil, x=event[3], y=event[4]}
            handler = uiObj.onTouch or uiObj.onActivate
        end

        if handler ~= nil then
            if uiObj.within == nil then
                handler = nil
            else
                if not uiObj.within(args.x, args.y, output) then
                    handler = nil
                end
            end
        end
    end

    if handler ~= nil then
        handler(uiObj, output, args)
    end
end

local function addToGui(guiObj, uiObj, id)
    if id == nil then
        id = "ui" .. tostring(guiObj.idAuto)
        guiObj.idAuto = guiObj.idAuto + 1
    end

    v.expect(2, uiObj, "table")
    v.expect(3, id, "string")
    if uiObj.render == nil then
        error("Not a valid UI obj")
    end

    guiObj.items[id] = uiObj
end

local function removeFromGui(guiObj, id)
    v.expect(2, id, "string")

    if guiObj.items[id] == nil then
        error(id .. " not in GUI object")
    end

    table.remove(guiObj.items, id)
end

local function resetGui(guiObj)
    guiObj.items = {}
end

local function renderGui(guiObj)
    local _, height = guiObj.output.getSize()

    guiObj.output.clear()
    guiObj.output.setCursorPos(1, 1)
    guiObj.output.setCursorBlink(false)
    guiObj.output.setTextColor(colors.white)

    for _, uiObj in pairs(guiObj.items) do
        uiObj.render(guiObj.output)
    end

    guiObj.output.setCursorPos(1, height)
end

ui.GUI = function(output)
    if output == nil then
        output = term
    end

    local guiObj = {
        items = {},
        idAuto = 1,
        output = output,
        visible = true
    }
    guiObj.add = function(uiObj, id)
        addToGui(guiObj, uiObj, id)
    end
    guiObj.remove = function(id)
        removeFromGui(guiObj, id)
    end
    guiObj.reset = function()
        resetGui(guiObj)
    end
    guiObj.render = function()
        renderGui(guiObj)
    end
    guiObj.handle = function(event)
        handleEvent(guiObj, event)
    end

    return guiObj
end

-- #region Text
ui.a = {}

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
    local actualMsg, _ = textLib.getTextColor(msg)

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
    if textObj.visible then
        output.write(msg)
    else
        output.write(string.rep(" ", #msg))
    end

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

    local textObj = {text=msg, anchor=anchor, color=color, background=background, visible=true}
    textObj.render = function(output)
        renderText(textObj, output)
    end
    textObj.handle = function(event, output)
        handleEvent(textObj, event, output)
    end

    return textObj
end
-- #endregion

-- #region Rectangle
local function validateRect(rectObj, output)
    local width, height = output.getSize()

    v.field(rectObj, "border", "number")
    v.range(rectObj.border, 0, 3)

    if rectObj.border > 0 then
        v.range(height, 3)
    end

    v.field(rectObj, "x", "number")
    v.range(rectObj.x, 1, width - 2)

    v.field(rectObj, "y", "number")
    if rectObj.border == 0 then
        v.range(rectObj.y, 1, height)
    else
        v.range(rectObj.y, 1, height - 2)
    end

    v.field(rectObj, "height", "number")
    if rectObj.border == 0 then
        v.range(rectObj.height, 1, height)
    else
        v.range(rectObj.height, 1, height - 2)
    end

    v.field(rectObj, "length", "number", "nil")
    if rectObj.length ~= nil then
        v.range(rectObj.length, 3, width)
    end

    if rectObj.backgroundColor ~= nil then
        v.field(rectObj, "backgroundColor", "number")
        v.range(rectObj.backgroundColor, 1)
    end
    if rectObj.fillColor ~= nil then
        v.field(rectObj, "fillColor", "number")
        v.range(rectObj.fillColor, 1)
    end
    v.field(rectObj, "borderColor", "number")
    v.range(rectObj.borderColor, 1)
    if rectObj.textColor ~= nil then
        v.field(rectObj, "textColor", "number")
        v.range(rectObj.textColor, 1)
    end
end

local function renderBorder1(rectObj, output, length, backgroundColor)
    local borderColor = rectObj.getBorderColor(output) or backgroundColor

    -- top
    output.setCursorPos(rectObj.x, rectObj.y)
    output.setTextColor(backgroundColor)
    output.setBackgroundColor(borderColor)
    output.write("\159" .. string.rep("\143", length - 2))
    output.setTextColor(borderColor)
    output.setBackgroundColor(backgroundColor)
    output.write("\144")

    for i = 1, rectObj.height, 1 do
        -- left border
        output.setCursorPos(rectObj.x, rectObj.y + i)
        output.setTextColor(backgroundColor)
        output.setBackgroundColor(borderColor)
        output.write("\x95")

        -- right border
        output.setCursorPos(rectObj.x + length - 1, rectObj.y + i)
        output.setTextColor(borderColor)
        output.setBackgroundColor(backgroundColor)
        output.write("\x95")
    end

    -- bottom border
    output.setCursorPos(rectObj.x, rectObj.y + rectObj.height + 1)
    output.setTextColor(borderColor)
    output.setBackgroundColor(backgroundColor)
    output.write("\130" .. string.rep("\131", length - 2) .. "\129")
end

local function renderBorder2(rectObj, output, length, backgroundColor)
    local borderColor = rectObj.getBorderColor(output) or backgroundColor

    -- top
    output.setCursorPos(rectObj.x, rectObj.y)
    output.setTextColor(backgroundColor)
    output.setBackgroundColor(borderColor)
    output.write(string.rep("\x83", length + 1))

    for i = 1, rectObj.height, 1 do
        -- left border
        output.setCursorPos(rectObj.x, rectObj.y + 1)
        output.setTextColor(backgroundColor)
        output.setBackgroundColor(borderColor)
        output.write(" ")

        -- right border
        output.setCursorPos(rectObj.x + length - 1, rectObj.y + 1)
        output.setTextColor(backgroundColor)
        output.setBackgroundColor(borderColor)
        output.write(" ")
    end

    -- bottom border
    output.setCursorPos(rectObj.x, rectObj.y + rectObj.height + 1)
    output.setTextColor(borderColor)
    output.setBackgroundColor(backgroundColor)
    output.write(string.rep("\143", length + 1))
end

local function renderBorder3(rectObj, output, length)
    local borderColor = rectObj.getBorderColor(output) or backgroundColor
    output.setBackgroundColor(borderColor)

    -- top
    output.setCursorPos(rectObj.x, rectObj.y)
    output.setBackgroundColor(borderColor)
    output.write(string.rep(" ", length + 1))

    for i = 1, rectObj.height, 1 do
        -- left border
        output.setCursorPos(rectObj.x, rectObj.y + i)
        output.write(" ")

        -- right border
        output.setCursorPos(rectObj.x + length - 1, rectObj.y + i)
        output.write(" ")
    end

    -- bottom border
    output.setCursorPos(rectObj.x, rectObj.y + rectObj.height + 1)
    output.write(string.rep(" ", length + 1))
end

local function renderBox(
    output, startX, startY,
    length, height,
    label,
    textColor, backgroundColor
)
    v.expect(1, output, "table")
    v.expect(2, startX, "number")
    v.expect(3, startY, "number")
    v.expect(4, length, "number")
    v.expect(5, height, "number")
    v.expect(6, label, "string", "nil")
    v.expect(7, textColor, "number")
    v.expect(8, backgroundColor, "number")

    if label == nil then
        label = ""
    else
        label = " " .. label
    end

    local textY = math.ceil(height / 2) - 1
    for x = 0, length - 1, 1 do
        for y = 0, height - 1, 1 do
            output.setCursorPos(startX + x, startY + y)
            output.setTextColor(textColor)
            output.setBackgroundColor(backgroundColor)
            if x < #label and y == textY then
                output.write(label:sub(x + 1, x + 1))
            else
                output.write(" ")
            end
        end
    end
end

local function renderRect(rectObj, output)
    if output == nil then
        output = term
    end
    validateRect(rectObj, output)

    local width, height = output.getSize()
    local oldX, oldY = output.getCursorPos()
    local oldColor = output.getTextColor()
    local oldBackground = output.getBackgroundColor()
    local backgroundColor = rectObj.backgroundColor
    local fillColor = rectObj.getFillColor(output)
    local textColor = rectObj.textColor
    if backgroundColor == nil or not rectObj.visible then
        backgroundColor = oldBackground
    end
    if fillColor == nil or not rectObj.visible then
        fillColor = oldBackground
    end
    if textColor == nil or not rectObj.visible then
        textColor = oldColor
    end

    local length = rectObj.length
    if length == nil then
        length = width
    end

    local startOffset = 1
    local boxLength = length - 2

    if rectObj.border == 0 then
        startOffset = 0
        boxLength = length
    elseif rectObj.border == 1 then
        renderBorder1(rectObj, output, length, backgroundColor)
    elseif rectObj.border == 2 then
        renderBorder2(rectObj, output, length, backgroundColor)
    else
        renderBorder3(rectObj, output, length)
    end
    renderBox(output, rectObj.x + startOffset, rectObj.y + startOffset, boxLength, rectObj.height, rectObj.getLabel(), textColor, fillColor)

    output.setCursorPos(oldX, oldY)
    output.setTextColor(oldColor)
    output.setBackgroundColor(oldBackground)
end

local function withinRect(rectObj, x, y, output)
    if output == nil then
        output = term
    end
    validateRect(rectObj, output)

    if not rectObj.visible then
        return false
    end

    local width, height = output.getSize()
    if x < rectObj.x or y < rectObj.y then
        return false
    end

    local length = rectObj.length
    if rectObj.length == nil then
        length = width
    end

    return x <= (rectObj.x + length) and y <= (rectObj.y + rectObj.height)
end

ui.Rect = function(x, y, length, height, label)
    v.expect(1, x, "number")
    v.expect(2, y, "number")
    v.expect(3, length, "number", "nil")
    v.expect(4, height, "number")
    v.expect(5, label, "string", "nil")

    local rectObj = {
        x=x,
        y=y,
        height=height,
        length=length,
        backgroundColor=nil,
        borderColor=colors.gray,
        fillColor=nil,
        textColor=nil,
        border=1,
        label=label,
        visible=true
    }
    rectObj.render = function(output)
        renderRect(rectObj, output)
    end
    rectObj.getLabel = function(output)
        return rectObj.label
    end
    rectObj.getFillColor = function(output)
        if rectObj.fillColor == nil or not rectObj.visible then
            return output.getBackgroundColor()
        end
        return rectObj.fillColor
    end
    rectObj.getBorderColor = function(output)
        if rectObj.borderColor == nil or not rectObj.visible then
            return output.getBackgroundColor()
        end
        return rectObj.borderColor
    end
    rectObj.getLabel = function(output)
        if not rectObj.visible then
            return nil
        end
        return rectObj.label
    end
    rectObj.within = function(x, y, output)
        return withinRect(rectObj, x, y, output)
    end
    rectObj.handle = function(event, output)
        handleEvent(rectObj, event, output)
    end

    return rectObj
end
-- #endregion



local function validateBar(barObj, output)
    v.field(barObj, "current", "number")
    v.range(barObj.current, 0)

    v.field(barObj, "total", "number")
    v.range(barObj.total, math.floor(barObj.current))

    v.field(barObj, "progressColor", "number")
    v.range(barObj.progressColor, 1)

    v.field(barObj, "showPercent", "boolean")
    v.field(barObj, "showProgress", "boolean")
end

local function getBarLabel(barObj)
    local label = ""
    local current = math.min(barObj.current, barObj.total)
    local percent = current / barObj.total

    if barObj.label ~= nil then
        label = label .. barObj.label
    end
    if barObj.showPercent then
        label = label .. string.format(" %d%%", percent * 100)
    end
    if barObj.showProgress then
        label = label .. string.format(" [%d/%d]", current, barObj.total)
    end

    if label == "" then
        return nil
    end
    return label
end

local function renderBar(barObj, output)
    if output == nil then
        output = term
    end

    local width, height = output.getSize()
    local oldX, oldY = output.getCursorPos()
    local oldColor = output.getTextColor()
    local oldBackground = output.getBackgroundColor()

    renderRect(barObj, output)
    if not barObj.visible then
        return
    end

    local startOffset = 0
    local length = barObj.length
    local progressColor = barObj.progressColor
    local textColor = barObj.textColor

    if textColor == nil then
        textColor = oldColor
    end
    if length == nil then
        length = width
    end
    if barObj.border > 0 then
        length = length - 2
        startOffset = startOffset + 1
    end

    local current = math.min(barObj.current, barObj.total)
    local percent = current / barObj.total
    local fillTo = math.floor(percent * length)

    renderBox(
        output,
        barObj.x + startOffset, barObj.y + startOffset,
        fillTo, barObj.height,
        barObj.getLabel(),
        textColor, progressColor
    )

    output.setCursorPos(oldX, oldY)
    output.setTextColor(oldColor)
    output.setBackgroundColor(oldBackground)
end

ui.Bar = function(y, label)
    v.expect(1, y, "number")
    v.expect(2, label, "string", "nil")

    local barObj = ui.Rect(1, y, nil, 1, label)
    barObj.fillColor = colors.lightGray
    barObj.textColor = colors.white
    barObj.current=0
    barObj.total=1
    barObj.progressColor=colors.green
    barObj.showProgress=true
    barObj.showPercent=true
    barObj.render = function(output)
        renderBar(barObj, output)
    end
    barObj.getLabel = function(output)
        return getBarLabel(barObj)
    end

    return barObj
end

ui.Button = function(x, y, length, height, label)
    v.expect(1, x, "number")
    v.expect(2, y, "number")
    v.expect(3, length, "number", "nil")
    v.expect(4, height, "number")
    v.expect(5, label, "string", "nil")

    local buttonObj = ui.Rect(x, y, length, height, label)
    buttonObj.active = false
    buttonObj.onClick = function(_, output, data)
        buttonObj.active = true

        if buttonObj.onActivate ~= nil then
            buttonObj.onActivate(buttonObj, output, data)
        end

        buttonObj.render(output)
    end
    buttonObj.onMouseUp = function(_, output, data)
        buttonObj.active = false

        if buttonObj.onDeactivate ~= nil then
            buttonObj.onDeactivate(buttonObj, output, data)
        end

        buttonObj.render(output)
    end
    buttonObj.getFillColor = function(output)
        if buttonObj.active then
            return buttonObj.borderColor
        end
        return buttonObj.fillColor
    end
    buttonObj.getBorderColor = function(output)
        if not buttonObj.visible then
            return output.getBackgroundColor()
        end

        if buttonObj.active then
            return buttonObj.fillColor
        end
        return buttonObj.borderColor
    end

    return buttonObj
end

return ui
