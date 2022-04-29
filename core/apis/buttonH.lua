--------------------Buttonh----------------------------
----------------------MENU/PANEL API-------------------
--------------------by 9551 DEV!--------------------
---Copyright (c) 2021-2022 9551------------9551#0001---
---using this code in your project is fine!------------
---as long as you dont claim you made it---------------
---im cool with it, feel free to include---------------
---in your projects!   discord: 9551#0001--------------
---you dont have to but giving credits is nice :)------
-------------------------------------------------------
-------------------------------------------------------
--*!   pastebin get LTDZZZEJ button

--*functions usages
--*API(ins, cord1, cord2, length, height)
--*timetouch(timeout,monitor)
--*touch()
--*button(monitor, ins, cord1, cord2, text)
--*counter(monitor, ins, cc, cord1, cord2, cv, max, min, col)
--*fill(monitor, pos1, pos2, length, height)
--*switch(monitor, ccins, pos1, pos2, col1, col2, col3, text)
--*switchn(monitor, cc, ins, pos1, pos2, col1, col2, col3, text, text2)
--*bundle(side, color, state)
--*signal(side, ins, col)
--*sliderVer/Hor(monitor, ins, cc, pos1, pos2, length, color1, textCol)
--*local function menu(monitor, ins, cc, x, y, textcol, switchcol, text, returns1, more, returns2)  (returns menuout)
--*bar(monitor, pos1, pos2, length, height, ins, max, color1, color2, color3, printval, hor, text, format, rect, thicc)
--*timeswitch(monitor, ins, cc, pos1, pos2, change, start, col1, col2, col3, repeats)
--*render(monitor,text,x,y,textcol,backCol)
--*menudata()
--*frame(monitor, pos1, pos2, length, height, color3, color1, thicc)
--*db allows you to get stored data from all functions that use stored data!
--*how to use db:  in your function for example switch you do   b.switch("db",<data>) data is the storing position you want to get data of

--base API this API is made for detecting clicks in an area
local monitor = {}
local terminal = {}
local expect = require("cc.expect").expect
function monitor.API(ins, cord1, cord2, length, height)
    expect(1, ins, "table")
    expect(2, cord1, "number")
    expect(3, cord2, "number")
    expect(4, length, "number")
    expect(5, height, "number")
    if ins == true then
        ins = {os.pullEvent("monitor_touch")}
    end
    if ins[3] >= cord1 and ins[3] <= cord1 + length - 1 then
        if ins[4] >= cord2 and ins[4] <= cord2 + height - 1 then
            return true
        else
            return false
        end
    end
end

function monitor.touch()
    local dats = {os.pullEvent("monitor_touch")}
    return dats
end

function monitor.timetouch(timeout, mon)
    expect(1, timeout, "number")
    expect(2, mon, "string")
    local timer = os.startTimer(timeout)
    while true do
        local event = {os.pullEvent()}
        if (event[1] == "timer") and (event[2] == timer) then
            if mon == nil then
                local mon = "timeout"
            end
            return {"timeout", mon, 1000, 1000}
        elseif (event[1] == "monitor_touch") and (event[2] == mon) then
            return {event[1], event[2], event[3], event[4]}
        end
    end
end

-------------------------------------------------------------------------------------------------

function monitor.button(mon, ins, cord1, cord2, text)
    expect(1, mon, "string")
    expect(2, ins, "table")
    expect(3, cord1, "number")
    expect(4, cord2, "number")
    expect(5, text, "string")
    if ins[2] == mon then
        if ins ~= nil then
            local m = peripheral.wrap(mon)
            local x = monitor.API(ins, cord1, cord2, string.len(text), 1)
            m.setCursorPos(cord1, cord2)
            m.write(text)
            return x
        end
    end
end

function monitor.counter(mon, ins, cc, cord1, cord2, cv, max, min, col)
    if mon == "db" then
        if data == nil then
            return nil
        else
            return data[ins]
        end
    end
    if mon == "setdb" then
        if data == nil then
            return "no data to edit"
        else
            data[ins] = cc
            return ("value changed too " .. type(cc))
        end
    end
    expect(1, mon, "string")
    expect(2, ins, "table")
    expect(3, cc, "number")
    expect(4, cord1, "number")
    expect(5, cord2, "number")
    expect(6, cv, "number")
    expect(7, max, "number")
    expect(8, min, "number")
    expect(9, col, "string")
    if ins[2] == mon then
        if ins ~= nil then
            local m = peripheral.wrap(mon)
            if data == nil then
                data = {}
                for is = 0, 1000 do
                    data[is] = 0
                end
            end
            m.setCursorPos(cord1, cord2)
            m.write("\24" .. " " .. data[cc])
            m.setCursorPos(cord1, cord2 + 1)
            m.write("\25")
            if monitor.API(ins, cord1, cord2, 1, 1) == true then
                if data[cc] < max then
                    data[cc] = data[cc] + cv
                    m.setCursorPos(cord1, cord2)
                    m.setTextColor(colors.green)
                    m.write("\24" .. " " .. data[cc] .. " ")
                    m.setCursorPos(cord1, cord2 + 1)
                    m.setTextColor(colors.red)
                    m.write("\25")
                    m.setTextColor(colors[col])
                    return data[cc]
                end
            end
        end
        if monitor.API(ins, cord1, cord2 + 1, 1, 1) == true then
            if data[cc] > min then
                data[cc] = data[cc] - cv
                m.setCursorPos(cord1, cord2)
                m.setTextColor(colors.green)
                m.write("\24" .. " " .. data[cc] .. " ")
                m.setCursorPos(cord1, cord2 + 1)
                m.setTextColor(colors.red)
                m.write("\25")
                m.setTextColor(colors[col])
                return data[cc]
            end
        end
    end
end

function monitor.fill(mon, pos1, pos2, length, height)
    expect(1, mon, "string")
    expect(2, pos1, "number")
    expect(3, pos2, "number")
    expect(4, length, "number")
    expect(5, height, "number")
    local m = peripheral.wrap(mon)
    for x = 0, height - 1 do
        m.setCursorPos(pos1, pos2 + x)
        m.write(string.rep(" ", length))
    end
end

function monitor.switch(mon, cc, ins, pos1, pos2, col1, col2, col3, text)
    if mon == "db" then
        if data1 == nil then
            return nil
        else
            return data1[cc]
        end
    end
    if mon == "setdb" then
        if data1 == nil then
            return "no data to edit"
        else
            data1[cc] = ins
            return ("value changed too " .. type(ins))
        end
    end
    expect(1, mon, "string")
    expect(2, cc, "number")
    expect(3, ins, "table")
    expect(4, pos1, "number")
    expect(5, pos2, "number")
    expect(6, col1, "string")
    expect(7, col2, "string")
    expect(8, col3, "string")
    expect(9, text, "string")
    if ins[2] == mon then
        if ins ~= nil then
            local re = string.len(text)
            local m = peripheral.wrap(mon)
            if data1 == nil then
                data1 = {}
                for is = 0, 1000 do
                    data1[is] = false
                end
            end
            local function ff()
                data1[cc] = not data1[cc]
            end
            if monitor.API(ins, pos1, pos2, string.len(text), 1) == true then
                ff()
            end
            local oldcol1 = m.getTextColor()
            local oldcol2 = m.getBackgroundColor()
            if data1[cc] == true then
                m.setBackgroundColor(colors[col2])
            else
                m.setBackgroundColor(colors[col1])
            end
            m.setCursorPos(pos1, pos2)
            m.setTextColor(colors[col3])
            m.write(text)
            m.setTextColor(oldcol1)
            m.setBackgroundColor(oldcol2)
            return (data1[cc])
        end
    end
end

function monitor.switchn(mon, cc, ins, pos1, pos2, col1, col2, col3, text, text2)
    if mon == "db" then
        if data2 == nil then
            return nil
        else
            return data2[cc]
        end
    end
    if mon == "setdb" then
        if data2 == nil then
            return "no data to edit"
        else
            data2[cc] = ins
            return ("value changed too " .. type(ins))
        end
    end
    expect(1, mon, "string")
    expect(2, cc, "number")
    expect(3, ins, "table")
    expect(4, pos1, "number")
    expect(5, pos2, "number")
    expect(6, col1, "string")
    expect(7, col2, "string")
    expect(8, col3, "string")
    expect(9, text, "string")
    expect(10, text2, "string")

    if ins[2] == mon then
        if ins ~= nil then
            local re = string.len(text)
            if string.len(text) ~= string.len(text2) then
                if string.len(text) > string.len(text2) then
                    re = string.len(text)
                else
                    re = string.len(text2)
                end
            end
            local m = peripheral.wrap(mon)
            if data2 == nil then
                data2 = {}
                for is = 0, 1000 do
                    data2[is] = false
                end
            end
            local function ff()
                data2[cc] = not data2[cc]
            end
            if monitor.API(ins, pos1, pos2, re, 1) == true then
                ff()
            end
            local oldcol1 = m.getTextColor()
            local oldcol2 = m.getBackgroundColor()
            if data2[cc] == true then
                m.setCursorPos(pos1, pos2)
                if string.len(text) ~= string.len(text2) then
                    m.write(string.rep(" ", re))
                end
                m.setBackgroundColor(colors[col2])
                m.setCursorPos(pos1, pos2)
                m.setTextColor(colors[col3])
                m.write(text2)
            else
                m.setCursorPos(pos1, pos2)
                if string.len(text) ~= string.len(text2) then
                    m.write(string.rep(" ", re))
                end
                m.setBackgroundColor(colors[col1])
                m.setCursorPos(pos1, pos2)
                m.setTextColor(colors[col3])
                m.write(text)
            end
            m.setTextColor(oldcol1)
            m.setBackgroundColor(oldcol2)
            return (data2[cc])
        end
    end
end
-- bundle cable APIs for using main API with bundled cables
function monitor.bundle(side, color, state)
    expect(1, side, "string")
    expect(2, color, "number")
    expect(3, state, "boolean")
    if state == true then
        rs.setBundledOutput(side, colors.combine(rs.getBundledOutput(side), color))
    elseif state == false then
        rs.setBundledOutput(side, colors.subtract(rs.getBundledOutput(side), color))
    end
end

function monitor.signal(side, ins, col, func)
    expect(1, side, "string")
    expect(2, ins, "boolean", "string")
    expect(3, col, "number")
    expect(4, func, "boolean")
    if ins == "clear" then
        rs.setBundledOutput(side, 0)
    else
        if func == true then
            if ins == "on" then
                ins = true
            end
            if ins == "nil" then
                ins = false
            end
        end
        if ins ~= nil then
            if ins == true then
                bundle(side, col, true)
            elseif ins == false then
                bundle(side, col, false)
            end
        end
    end
end
-------------------------------------------------------------------------------------------------

function monitor.sliderHor(mon, ins, cc, pos1, pos2, length, color1, textCol)
    if mon == "db" then
        if data3 == nil then
            return nil
        else
            return data3[ins]
        end
    end
    if mon == "setdb" then
        if data3 == nil then
            return "no data to edit"
        else
            data3[ins] = cc
            return ("value changed too " .. type(cc))
        end
    end
    expect(1, mon, "string")
    expect(2, ins, "table")
    expect(3, cc, "number")
    expect(4, pos1, "number")
    expect(5, pos2, "number")
    expect(6, length, "number")
    expect(7, color1, "string")
    expect(8, textCol, "string")
    if ins[2] == mon then
        if ins ~= nil then
            m = peripheral.wrap(mon)
            local oldcol1 = m.getBackgroundColor()
            local oldcol2 = m.getTextColor()
            m.setBackgroundColor(colors[color1])
            m.setTextColor(colors[textCol])
            m.setCursorPos(pos1, pos2)
            for i = 0, length do
                m.write("-")
                m.setCursorPos(pos1 + i, pos2)
            end
            if data3 == nil then
                data3 = {}
                for is = 0, 1000 do
                    data3[is] = 0
                end
            end
            local cp = (ins[3])
            if (ins[4] == pos2) and (ins[3] >= pos1) and (ins[3] <= (pos1 + length) - 1) then
                m.setCursorPos(cp, pos2)
                data3[cc] = cp
                m.write("|")
            else
                m.setCursorPos(data3[cc], pos2)
                m.write("|")
            end
            m.setBackgroundColor(oldcol1)
            m.setTextColor(oldcol2)
            if data3[cc] - pos1 >= 0 then
                return (data3[cc] - pos1)
            elseif data3[cc] - pos1 < 0 then
                return 0
            end
        end
    end
end

function monitor.sliderVer(mon, ins, cc, pos1, pos2, length, color1, textCol)
    if mon == "db" then
        if data10 == nil then
            return nil
        else
            return data10[ins]
        end
    end
    if mon == "setdb" then
        if data10 == nil then
            return "no data to edit"
        else
            data10[ins] = cc
            return ("value changed too " .. type(cc))
        end
    end
    expect(1, mon, "string")
    expect(2, ins, "table")
    expect(3, cc, "number")
    expect(4, pos1, "number")
    expect(5, pos2, "number")
    expect(6, length, "number")
    expect(7, color1, "string")
    expect(8, textCol, "string")
    if ins[2] == mon then
        if ins ~= nil then
            m = peripheral.wrap(mon)
            local oldcol1 = m.getBackgroundColor()
            local oldcol2 = m.getTextColor()
            m.setBackgroundColor(colors[color1])
            m.setTextColor(colors[textCol])
            m.setCursorPos(pos1, pos2)
            for i = 0, length do
                m.write("\124")
                m.setCursorPos(pos1, pos2 - i)
            end
            if data10 == nil then
                data10 = {}
                for is = 0, 1000 do
                    data10[is] = 0
                end
            end
            local cp = ins[4]
            if (ins[3] == pos1) and (ins[4] <= pos2) and (ins[4] >= (pos2 - length) + 1) then
                m.setCursorPos(pos1, cp)
                data10[cc] = cp
                m.write("\xad")
            else
                m.setCursorPos(pos1, data10[cc])
                m.write("\xad")
            end
            m.setBackgroundColor(oldcol1)
            m.setTextColor(oldcol2)
            if data10[cc] - pos1 >= 0 then
                return (data10[cc] - pos1)
            elseif data10[cc] - pos1 < 0 then
                return 0
            end
        end
    end
end

function monitor.render(mon, text, x, y, textcol, backCol)
    expect(1, mon, "string")
    expect(2, text, "string")
    expect(3, x, "number")
    expect(4, y, "number")
    expect(5, textcol, "string")
    expect(6, backCol, "string", "number")
    local m = peripheral.wrap(mon)
    local oldcol1 = m.getBackgroundColor()
    local oldcol2 = m.getTextColor()
    local cur = {m.getCursorPos()}
    m.setTextColor(colors[textcol])
    if type(backCol) == "string" then
        m.setBackgroundColor(colors[backCol])
    elseif type(backCol) == "number" then
        m.setBackgroundColor(backCol)
    end
    m.setCursorPos(x, y)
    m.write(text)
    m.setBackgroundColor(oldcol1)
    m.setTextColor(oldcol2)
    m.setCursorPos(cur[1], cur[2])
end

function monitor.menu(mon, ins, cc, x, y, textcol, switchcol, text, returns1, more, returns2)
    expect(1, mon, "string")
    expect(2, ins, "table")
    expect(3, cc, "number")
    expect(4, x, "number")
    expect(5, y, "number")
    expect(6, textcol, "string")
    expect(7, switchcol, "string")
    expect(8, text, "string")
    expect(9, returns1, "string", "number", "boolean", "nil")
    expect(10, more, "boolean")
    expect(11, returns2, "string", "number", "boolean", "nil")
    if ins[2] == mon then
        if thisIsUseless == nil then
            for i = 0, 1000 do
                thisIsUseless = {}
                thisIsUseless[i] = false
            end
        end
        if not thisIsUseless[cc] then
            if textcol2 ~= nil then
                monitor.render(mon, text, x, y, textcol, oldcol2)
            end
        end
        if ins ~= nil then
            local m = peripheral.wrap(mon)
            local oldcol1 = m.getTextColor()
            local oldcol2 = m.getBackgroundColor()
            local l = string.len(text)
            if ins[1] ~= "timeout" then
                if data4 == nil then
                    data4 = {}
                    for is = 0, 1000 do
                        data4[is] = false
                    end
                end
                if data5 == nil then
                    data5 = {}
                    for is = 0, 1000 do
                        data5[is] = false
                    end
                end
                if data6 == nil then
                    data6 = {}
                    for is = 0, 1000 do
                        data6[is] = false
                    end
                end
                if monitor.API(ins, x, y, l, 1) == true then
                    data4[cc] = text
                    data5[cc] = x
                    data6[cc] = y
                    local function menus()
                        for i = 1, 500 do
                            if data4[i] ~= false then
                                m.setBackgroundColor(oldcol2)
                                m.setCursorPos(data5[i], data6[i])
                                m.setTextColor(colors[textcol])
                                m.write(data4[i])
                            end
                        end
                        local i = 0
                    end
                    menus()
                    m.setCursorPos(data5[cc], data6[cc])
                    m.setBackgroundColor(colors[switchcol])
                    m.setTextColor(colors[textcol])
                    m.write(text)
                    m.setTextColor(oldcol1)
                    m.setBackgroundColor(oldcol2)
                    menuout = text
                    if returns1 == nil then
                        return menuout
                    else
                        if (more == nil) or (more == false) then
                            menuout = returns1
                            return menuout
                        else
                            menuout = {
                                returns1,
                                returns2
                            }
                            if menuout == nil then
                                return 0
                            end
                            return menuout
                        end
                    end
                end
            end
        end
    end
    thisIsUseless[cc] = true
    if more == true then
        if menuout == nil then
            menuout = {returns1, "nil"}
        end
    end
end

function monitor.menudata()
    if menuout ~= nil then
        return menuout
    else
        return "no output"
    end
end

function monitor.timeswitch(mon, ins, cc, pos1, pos2, change, start, col1, col2, col3, repeats)
    if mon == "db" then
        if data7 == nil then
            return nil
        else
            return data7[ins]
        end
    end
    if mon == "setdb" then
        if data7 == nil then
            return "no data to edit"
        else
            data7[ins] = cc
            return ("value changed too " .. type(cc))
        end
    end
    expect(1, mon, "string")
    expect(2, ins, "table")
    expect(3, cc, "number")
    expect(4, pos1, "number")
    expect(5, pos2, "number")
    expect(6, change, "number")
    expect(7, start, "number")
    expect(8, col1, "string")
    expect(9, col2, "string")
    expect(10, col3, "string")
    expect(11, repeats, "boolean")
    if ins[2] == mon then
        if ins ~= nil then
            local m = peripheral.wrap(mon)
            local oldcol1 = m.getTextColor()
            local oldcol2 = m.getBackgroundColor()
            m.setBackgroundColor(colors[col2])
            m.setTextColor(colors[col1])
            if data7 == nil then
                data7 = {}
                for is = 0, 1000 do
                    data7[is] = false
                end
            end
            if data8 == nil then
                data8 = {}
                for is = 0, 1000 do
                    data8[is] = false
                end
            end
            if data8[cc] == false then
                data8[cc] = start
                m.setCursorPos(pos1 + 6, pos2)
                m.write(data8[cc])
            end
            m.setCursorPos(pos1, pos2)
            m.write("start")
            if monitor.API(ins, pos1, pos2, 4, 1) == true then
                data7[cc] = true
            end
            if data7[cc] == true then
                if data8[cc] > 0 then
                    repeat
                        timeOut = data8[cc]
                        m.setBackgroundColor(colors[col3])
                        data8[cc] = data8[cc] - change
                        m.setCursorPos(pos1 + 6, pos2)
                        sleep(1)
                        m.write(data8[cc])
                    until data8[cc] == 0
                    return "ended"
                end
            end
            if repeats == true then
                data8[cc] = start
            end
            m.setBackgroundColor(colors[col2])
            m.setCursorPos(pos1 + 6, pos2)
            m.write(data8[cc])
            m.setTextColor(oldcol1)
            m.setBackgroundColor(oldcol2)
        end
    end
end

function monitor.bar(
    mon,
    pos1,
    pos2,
    length,
    height,
    ins,
    max,
    color1,
    color2,
    color3,
    printval,
    hor,
    text,
    format,
    rect,
    thicc)
    expect(1, mon, "string")
    expect(2, pos1, "number")
    expect(3, pos2, "number")
    expect(4, length, "number")
    expect(5, height, "number")
    expect(6, ins, "number")
    expect(7, max, "number")
    expect(8, color1, "string")
    expect(9, color2, "string")
    expect(10, color3, "string")
    expect(11, printval, "boolean")
    expect(12, hor, "boolean")
    expect(13, text, "string")
    expect(14, format, "boolean")
    expect(15, rect, "boolean")
    expect(16, thicc, "boolean")
    if (ins == nil) or (ins < 0) then
        ins = 0
    end
    if format == nil then
        local format = false
    end
    if ins ~= nil then
        local m = peripheral.wrap(mon)
        oldcol = m.getBackgroundColor()
        oldcol1 = m.getTextColor()
        m.setTextColor(colors[color3])
        local function reprint()
            m.setBackgroundColor(colors[color1])
            monitor.fill(mon, pos1 - 1, pos2 - height, length, height * 2)
            m.setBackgroundColor(oldcol)
            xm = m.getBackgroundColor()
            xb = m.getTextColor()
            m.setTextColor(xm)
            m.setBackgroundColor(xb)
            m.setCursorPos(pos1 - 1, pos2 - height)
            if thicc then
                m.setBackgroundColor(colors[color3])
            end
            if thicc then
                m.write(string.rep("\x83", length + 1)) --\143
                m.setTextColor(xb)
                m.setBackgroundColor(xm)
            else
                m.write("\159" .. string.rep("\143", length - 1)) --\x83
                m.setTextColor(xb)
                m.setBackgroundColor(xm)
                m.write("\144")
            end
            if thicc then
                m.setBackgroundColor(colors[color3])
            end
            m.setCursorPos(pos1 - 1, pos2 + height)
            if thicc then
                m.write(string.rep("\x8c", length + 1)) --\131
            else
                m.write("\130" .. string.rep("\131", length - 1) .. "\129") --\x8c
            end
            for i = 0, (height * 2) - 2 do
                if not thicc then
                    m.setTextColor(xm)
                    m.setBackgroundColor(xb)
                end
                m.setCursorPos(pos1 - 1, (pos2 + i) - (height) + 1)
                if thicc then
                    m.setBackgroundColor(colors[color3])
                end
                m.write("\x95")
                m.setCursorPos((pos1 - 2) + (length + 1), (pos2 + i) - (height) + 1)
                if not thicc then
                    m.setTextColor(xb)
                    m.setBackgroundColor(xm)
                end
                m.write("\x95")
            end
        end
        if rect ~= false then
            reprint()
        else
            monitor.fill(mon, pos1 - 1, pos2 - height, length, height * 2)
        end
        local drawLength = ins / max * length
        local drawHeights = ins / max * height
        local drawHeight = math.ceil(drawHeights)
        local moveval = (drawHeight * 2) - 2
        local z = pos2 + height
        m.setBackgroundColor(colors[color2])
        if (hor == false) or (hor == nil) then
            monitor.fill(mon, pos1, (pos2 - height) + 1, drawLength - 1, (height * 2) - 1)
        else
            monitor.fill(mon, pos1, (z - 1) - moveval, length - 1, moveval + 1)
        end
        if printval == true then
            m.setCursorPos(pos1 + 1, pos2)
            m.setTextColor(colors[color3])
            local fillTo = (ins / max) * length + pos1
            for i = 1, #text do
                local c = text:sub(i, i)
                local x, y = m.getCursorPos()
                if x <= fillTo then
                    m.setBackgroundColor(colors[color2])
                else
                    m.setBackgroundColor(colors[color1])
                end
                m.write(c)
            end
            -- m.setCursorPos(pos1, pos2)
            -- m.setTextColor(colors[color3])
            -- if hor == true then
            --     if format then
            --         if ins >= max / 2 then
            --             m.setBackgroundColor(colors[color2])
            --         else
            --             m.setBackgroundColor(colors[color1])
            --         end
            --     else
            --         if ins >= (max / 2) - (max / height) then
            --             m.setBackgroundColor(colors[color2])
            --         else
            --             m.setBackgroundColor(colors[color1])
            --         end
            --     end
            -- elseif hor == false then
            --     m.setCursorPos(pos1, pos2)
            --     m.setTextColor(colors[color3])
            --     if hor == true then
            --         if ins >= 1 then
            --             m.setBackgroundColor(colors[color2])
            --         else
            --             m.setBackgroundColor(colors[color1])
            --         end
            --     end
            -- end
            -- if format then
            --     m.write(ins .. "/" .. max)
            --     m.setCursorPos(pos1, pos2 + 1)
            --     m.write(text)
            -- else
            --     m.write(ins .. "/" .. max .. " " .. text)
            -- end
            m.setBackgroundColor(oldcol)
            m.setTextColor(oldcol1)
        end
        m.setTextColor(oldcol1)
        m.setBackgroundColor(oldcol)
    end
end

function monitor.frame(mon, pos1, pos2, length, height, color3, color1, thicc)
    expect(1, mon, "string")
    expect(2, pos1, "number")
    expect(3, pos2, "number")
    expect(4, length, "number")
    expect(5, height, "number")
    expect(6, color3, "string")
    expect(7, color1, "string")
    expect(8, thicc, "boolean", "nil")
    local m = peripheral.wrap(mon)
    local oldcol = m.getBackgroundColor()
    local oldcol1 = m.getTextColor()
    m.setBackgroundColor(colors[color1])
    monitor.fill(mon, pos1 - 1, pos2 - height, length, height * 2)
    m.setBackgroundColor(oldcol)
    xm = m.getBackgroundColor()
    xb = m.getTextColor()
    m.setTextColor(xm)
    m.setBackgroundColor(xb)
    m.setCursorPos(pos1 - 1, pos2 - height)
    if thicc then
        m.setBackgroundColor(colors[color3])
        m.setTextColor(oldcol)
        m.write(string.rep("\x83", length + 1)) --\143
        m.setTextColor(xb)
        m.setBackgroundColor(xm)
    else
        m.setTextColor(oldcol)
        m.setBackgroundColor(colors[color3])
        m.write("\159" .. string.rep("\143", length - 1)) --\x83
        m.setTextColor(colors[color3])
        m.setBackgroundColor(oldcol)
        m.write("\144")
    end
    m.setCursorPos(pos1 - 1, pos2 + height)
    if thicc then
        m.setBackgroundColor(oldcol)
        m.setTextColor(colors[color3])
        m.write(string.rep("\x8f", length + 1)) --\131
        m.setBackgroundColor(colors[color1])
        m.setTextColor(colors[color3])
    else
        m.write("\130" .. string.rep("\131", length - 1) .. "\129") --\x8c
    end
    for i = 0, (height * 2) - 2 do
        if not thicc then
            m.setTextColor(xm)
            m.setBackgroundColor(xb)
        end
        m.setCursorPos(pos1 - 1, (pos2 + i) - (height) + 1)
        if thicc then
            m.setBackgroundColor(colors[color3])
        end
        m.setBackgroundColor(colors[color3])
        m.write("\x95")
        m.setCursorPos((pos1 - 2) + (length + 1), (pos2 + i) - (height) + 1)
        if not thicc then
            m.setTextColor(xb)
            m.setBackgroundColor(xm)
        end
        m.setTextColor(colors[color3])
        m.write("\x95")
    end
    m.setBackgroundColor(oldcol)
    m.setTextColor(oldcol1)
end

--*functions usages
--*API(ins, cord1, cord2, length, height)
--*timetouch(timeout)
--*touch()
--*button(lr,ins, cord1, cord2, text)
--*counter(lr, ins, cc, cord1, cord2, cv, max, min, col)
--*fill(pos1, pos2, length, height)
--*switch(lr, ccins, pos1, pos2, col1, col2, col3, text)
--*switchn(lr, cc, ins, pos1, pos2, col1, col2, col3, text, text2)
--*bundle(side, color, state)
--*signal(side, ins, col)
--*sliderVer/Hor(lr, ins, cc, pos1, pos2, length, color1, textCol)
--*local function menu(lr, ins, cc, x, y, textcol, switchcol, text, returns1, more, returns2)  (returns menuout)
--*bar(pos1, pos2, length, height, ins, max, color1, color2, color3, printval, hor, text, format, rect, thicc)
--*timeswitch(lr, ins, cc, pos1, pos2, change, start, col1, col2, col3, repeats)
--*render(text,x,y,textcol,backCol)
--*menudata()
--*frame(pos1, pos2, length, height, color3, color1, thicc)
--*db allows you to get stored data from all functions that use stored data!
--*how to use db:  in your function for example switch you do   b.switch("db",<data>) data is the storing position you want to get data of

--base API this API is made for detecting clicks in an area
function terminal.API(ins, cord1, cord2, length, height)
    expect(1, ins, "table")
    expect(2, cord1, "number")
    expect(3, cord2, "number")
    expect(4, length, "number")
    expect(5, height, "number")
    if ins == true then
        ins = {os.pullEvent("mouse_click")}
    end
    if ins[3] >= cord1 and ins[3] <= cord1 + length - 1 then
        if ins[4] >= cord2 and ins[4] <= cord2 + height - 1 then
            return true
        else
            return false
        end
    end
end

function terminal.touch()
    local dats = {os.pullEvent("mouse_click")}
    return dats
end

function terminal.timetouch(timeout)
    expect(1, timeout, "number")
    local timer = os.startTimer(timeout)
    while true do
        local event = {os.pullEvent()}
        if (event[1] == "timer") and (event[2] == timer) then
            return {"timeout", "tout", 1000, 1000}
        elseif (event[1] == "mouse_click") then
            return {event[1], event[2], event[3], event[4]}
        end
    end
end

-------------------------------------------------------------------------------------------------

function terminal.button(lr, ins, cord1, cord2, text)
    expect(1, lr, "number")
    expect(2, ins, "table")
    expect(3, cord1, "number")
    expect(4, cord2, "number")
    expect(5, text, "string")
    if ins[2] == lr or ins[2] == "tout" then
        if ins ~= nil then
            local x = terminal.API(ins, cord1, cord2, string.len(text), 1)
            term.setCursorPos(cord1, cord2)
            term.write(text)
            return x
        end
    end
end

function terminal.counter(lr, ins, cc, cord1, cord2, cv, max, min, col)
    if lr == "db" then
        if data == nil then
            return nil
        else
            return data[ins]
        end
    end
    if lr == "setdb" then
        if data == nil then
            return "no data to edit"
        else
            data[ins] = cc
            return ("value changed too " .. type(cc))
        end
    end
    expect(1, lr, "number")
    expect(2, ins, "table")
    expect(3, cc, "number")
    expect(4, cord1, "number")
    expect(5, cord2, "number")
    expect(6, cv, "number")
    expect(7, max, "number")
    expect(8, min, "number")
    expect(9, col, "string")
    if ins[2] == lr or ins[2] == "tout" then
        if ins ~= nil then
            if data == nil then
                data = {}
                for is = 0, 1000 do
                    data[is] = 0
                end
            end
            term.setCursorPos(cord1, cord2)
            term.write("\24" .. " " .. data[cc])
            term.setCursorPos(cord1, cord2 + 1)
            term.write("\25")
            if terminal.API(ins, cord1, cord2, 1, 1) == true then
                if data[cc] < max then
                    data[cc] = data[cc] + cv
                    term.setCursorPos(cord1, cord2)
                    term.setTextColor(colors.green)
                    term.write("\24" .. " " .. data[cc] .. " ")
                    term.setCursorPos(cord1, cord2 + 1)
                    term.setTextColor(colors.red)
                    term.write("\25")
                    term.setTextColor(colors[col])
                    return data[cc]
                end
            end
        end
        if terminal.API(ins, cord1, cord2 + 1, 1, 1) == true then
            if data[cc] > min then
                data[cc] = data[cc] - cv
                term.setCursorPos(cord1, cord2)
                term.setTextColor(colors.green)
                term.write("\24" .. " " .. data[cc] .. " ")
                term.setCursorPos(cord1, cord2 + 1)
                term.setTextColor(colors.red)
                term.write("\25")
                term.setTextColor(colors[col])
                return data[cc]
            end
        end
    end
end

function terminal.fill(pos1, pos2, length, height)
    expect(1, pos1, "number")
    expect(2, pos2, "number")
    expect(3, length, "number")
    expect(4, height, "number")
    for x = 0, height - 1 do
        term.setCursorPos(pos1, pos2 + x)
        term.write(string.rep(" ", length))
    end
end

function terminal.switch(lr, cc, ins, pos1, pos2, col1, col2, col3, text)
    if lr == "db" then
        if data1 == nil then
            return nil
        else
            return data1[cc]
        end
    end
    if lr == "setdb" then
        if data1 == nil then
            return "no data to edit"
        else
            data1[cc] = ins
            return ("value changed too " .. type(ins))
        end
    end
    expect(1, lr, "number")
    expect(2, cc, "number")
    expect(3, ins, "table")
    expect(4, pos1, "number")
    expect(5, pos2, "number")
    expect(6, col1, "string")
    expect(7, col2, "string")
    expect(8, col3, "string")
    expect(9, text, "string")
    if ins[2] == lr or ins[2] == "tout" then
        if ins ~= nil then
            local re = string.len(text)
            if data1 == nil then
                data1 = {}
                for is = 0, 1000 do
                    data1[is] = false
                end
            end
            local function ff()
                data1[cc] = not data1[cc]
            end
            if terminal.API(ins, pos1, pos2, string.len(text), 1) == true then
                ff()
            end
            local oldcol1 = term.getTextColor()
            local oldcol2 = term.getBackgroundColor()
            if data1[cc] == true then
                term.setBackgroundColor(colors[col2])
            else
                term.setBackgroundColor(colors[col1])
            end
            term.setCursorPos(pos1, pos2)
            term.setTextColor(colors[col3])
            term.write(text)
            term.setTextColor(oldcol1)
            term.setBackgroundColor(oldcol2)
            return (data1[cc])
        end
    end
end

function terminal.switchn(lr, cc, ins, pos1, pos2, col1, col2, col3, text, text2)
    if lr == "db" then
        if data2 == nil then
            return nil
        else
            return data2[cc]
        end
    end
    if lr == "setdb" then
        if data2 == nil then
            return "no data to edit"
        else
            data2[cc] = ins
            return ("value changed too " .. type(ins))
        end
    end
    expect(1, lr, "number")
    expect(2, cc, "number")
    expect(3, ins, "table")
    expect(4, pos1, "number")
    expect(5, pos2, "number")
    expect(6, col1, "string")
    expect(7, col2, "string")
    expect(8, col3, "string")
    expect(9, text, "string")
    expect(10, text2, "string")
    if ins[2] == lr or ins[2] == "tout" then
        if ins ~= nil then
            local re = string.len(text)
            if string.len(text) ~= string.len(text2) then
                if string.len(text) > string.len(text2) then
                    re = string.len(text)
                else
                    re = string.len(text2)
                end
            end
            if data2 == nil then
                data2 = {}
                for is = 0, 1000 do
                    data2[is] = false
                end
            end
            local function ff()
                data2[cc] = not data2[cc]
            end
            if terminal.API(ins, pos1, pos2, re, 1) == true then
                ff()
            end
            local oldcol1 = term.getTextColor()
            local oldcol2 = term.getBackgroundColor()
            if data2[cc] == true then
                term.setCursorPos(pos1, pos2)
                if string.len(text) ~= string.len(text2) then
                    term.write(string.rep(" ", re))
                end
                term.setBackgroundColor(colors[col2])
                term.setCursorPos(pos1, pos2)
                term.setTextColor(colors[col3])
                term.write(text2)
            else
                term.setCursorPos(pos1, pos2)
                if string.len(text) ~= string.len(text2) then
                    term.write(string.rep(" ", re))
                end
                term.setBackgroundColor(colors[col1])
                term.setCursorPos(pos1, pos2)
                term.setTextColor(colors[col3])
                term.write(text)
            end
            term.setTextColor(oldcol1)
            term.setBackgroundColor(oldcol2)
            return (data2[cc])
        end
    end
end
-- bundle cable APIs for using main API with bundled cables
function terminal.bundle(side, color, state)
    expect(1, side, "string")
    expect(2, color, "number")
    expect(3, state, "boolean")
    if (type(side) == "string") and (type(color) == "number") and (type(state) == "boolean") then
        if state == true then
            rs.setBundledOutput(side, colors.combine(rs.getBundledOutput(side), color))
        elseif state == false then
            rs.setBundledOutput(side, colors.subtract(rs.getBundledOutput(side), color))
        end
    else
        error("please use like this:\nbundle(side:string,colors.(color),state:boolean)")
    end
end

function terminal.signal(side, ins, col, func)
    expect(1, side, "string")
    expect(2, ins, "boolean", "string")
    expect(3, col, "number")
    expect(4, func, "boolean")
    if ins == "clear" then
        rs.setBundledOutput(side, 0)
    else
        if func == true then
            if ins == "on" then
                ins = true
            end
            if ins == "nil" then
                ins = false
            end
        end
        if ins ~= nil then
            if ins == true then
                bundle(side, col, true)
            elseif ins == false then
                bundle(side, col, false)
            end
        end
    end
end
-------------------------------------------------------------------------------------------------

function terminal.sliderHor(lr, ins, cc, pos1, pos2, length, color1, textCol)
    if lr == "db" then
        if data3 == nil then
            return nil
        else
            return data3[ins]
        end
    end
    if lr == "setdb" then
        if data3 == nil then
            return "no data to edit"
        else
            data3[ins] = cc
            return ("value changed too " .. type(cc))
        end
    end
    expect(1, lr, "number")
    expect(2, ins, "table")
    expect(3, cc, "number")
    expect(4, pos1, "number")
    expect(5, pos2, "number")
    expect(6, length, "number")
    expect(7, color1, "string")
    expect(8, textCol, "string")
    if ins[2] == lr or ins[2] == "tout" then
        if ins ~= nil then
            local oldcol1 = term.getBackgroundColor()
            local oldcol2 = term.getTextColor()
            term.setBackgroundColor(colors[color1])
            term.setTextColor(colors[textCol])
            term.setCursorPos(pos1, pos2)
            for i = 0, length do
                term.write("-")
                term.setCursorPos(pos1 + i, pos2)
            end
            if data3 == nil then
                data3 = {}
                for is = 0, 1000 do
                    data3[is] = 0
                end
            end
            local cp = (ins[3])
            if (ins[4] == pos2) and (ins[3] >= pos1) and (ins[3] <= (pos1 + length) - 1) then
                term.setCursorPos(cp, pos2)
                data3[cc] = cp
                term.write("|")
            else
                term.setCursorPos(data3[cc], pos2)
                term.write("|")
            end
            term.setBackgroundColor(oldcol1)
            term.setTextColor(oldcol2)
            if data3[cc] - pos1 >= 0 then
                return (data3[cc] - pos1)
            elseif data3[cc] - pos1 < 0 then
                return 0
            end
        end
    end
end

function terminal.sliderVer(lr, ins, cc, pos1, pos2, length, color1, textCol)
    if lr == "db" then
        if data10 == nil then
            return nil
        else
            return data10[ins]
        end
    end
    if lr == "setdb" then
        if data10 == nil then
            return "no data to edit"
        else
            data10[ins] = cc
            return ("value changed too " .. type(cc))
        end
    end
    expect(1, lr, "number")
    expect(2, ins, "table")
    expect(3, cc, "number")
    expect(4, pos1, "number")
    expect(5, pos2, "number")
    expect(6, length, "number")
    expect(7, color1, "string")
    expect(8, textCol, "string")
    if ins[2] == lr or ins[2] == "tout" then
        if ins ~= nil then
            local oldcol1 = term.getBackgroundColor()
            local oldcol2 = term.getTextColor()
            term.setBackgroundColor(colors[color1])
            term.setTextColor(colors[textCol])
            term.setCursorPos(pos1, pos2)
            for i = 0, length do
                term.write("\124")
                term.setCursorPos(pos1, pos2 - i)
            end
            if data10 == nil then
                data10 = {}
                for is = 0, 1000 do
                    data10[is] = 0
                end
            end
            local cp = ins[4]
            if (ins[3] == pos1) and (ins[4] <= pos2) and (ins[4] >= (pos2 - length) + 1) then
                term.setCursorPos(pos1, cp)
                data10[cc] = cp
                term.write("\xad")
            else
                term.setCursorPos(pos1, data10[cc])
                term.write("\xad")
            end
            term.setBackgroundColor(oldcol1)
            term.setTextColor(oldcol2)
            if data10[cc] - pos1 >= 0 then
                return (data10[cc] - pos1)
            elseif data10[cc] - pos1 < 0 then
                return 0
            end
        end
    end
end

function terminal.render(text, x, y, textcol, backCol)
    expect(1, text, "string")
    expect(2, x, "number")
    expect(3, y, "number")
    expect(4, textcol, "string")
    expect(5, backCol, "string", "number")
    local oldcol1 = term.getBackgroundColor()
    local oldcol2 = term.getTextColor()
    local cur = {term.getCursorPos()}
    term.setTextColor(colors[textcol])
    if type(backCol) == "string" then
        term.setBackgroundColor(colors[backCol])
    elseif type(backCol) == "number" then
        term.setBackgroundColor(backCol)
    end
    term.setCursorPos(x, y)
    term.write(text)
    term.setBackgroundColor(oldcol1)
    term.setTextColor(oldcol2)
    term.setCursorPos(cur[1], cur[2])
end

function terminal.menu(lr, ins, cc, x, y, textcol, switchcol, text, returns1, more, returns2)
    expect(1, lr, "number")
    expect(2, ins, "table")
    expect(3, cc, "number")
    expect(4, x, "number")
    expect(5, y, "number")
    expect(6, textcol, "string")
    expect(7, switchcol, "string")
    expect(8, text, "string")
    expect(9, returns1, "string", "number", "boolean", "nil")
    expect(10, more, "boolean")
    expect(11, returns2, "string", "number", "boolean", "nil")
    if ins[2] == lr or ins[2] == "tout" then
        if thisIsUseless == nil then
            for i = 0, 1000 do
                thisIsUseless = {}
                thisIsUseless[i] = false
            end
        end
        if not thisIsUseless[cc] then
            terminal.render(text, x, y, textcol, oldcol2)
        end
        if ins ~= nil then
            local oldcol1 = term.getTextColor()
            local oldcol2 = term.getBackgroundColor()
            local l = string.len(text)
            if ins[1] ~= "timeout" then
                if data4 == nil then
                    data4 = {}
                    for is = 0, 1000 do
                        data4[is] = false
                    end
                end
                if data5 == nil then
                    data5 = {}
                    for is = 0, 1000 do
                        data5[is] = false
                    end
                end
                if data6 == nil then
                    data6 = {}
                    for is = 0, 1000 do
                        data6[is] = false
                    end
                end
                if terminal.API(ins, x, y, l, 1) == true then
                    data4[cc] = text
                    data5[cc] = x
                    data6[cc] = y
                    local function menus()
                        for i = 1, 500 do
                            if data4[i] ~= false then
                                term.setBackgroundColor(oldcol2)
                                term.setCursorPos(data5[i], data6[i])
                                term.setTextColor(colors[textcol])
                                term.write(data4[i])
                            end
                        end
                        local i = 0
                    end
                    menus()
                    term.setCursorPos(data5[cc], data6[cc])
                    term.setBackgroundColor(colors[switchcol])
                    term.setTextColor(colors[textcol])
                    term.write(text)
                    term.setTextColor(oldcol1)
                    term.setBackgroundColor(oldcol2)
                    menuout = text
                    if returns1 == nil then
                        return menuout
                    else
                        if (more == nil) or (more == false) then
                            menuout = returns1
                            return menuout
                        else
                            menuout = {
                                returns1,
                                returns2
                            }
                            if menuout == nil then
                                return 0
                            end
                            return menuout
                        end
                    end
                end
            end
        end
    end
    thisIsUseless[cc] = true
    if more == true then
        if menuout == nil then
            menuout = {returns1, "nil"}
        end
    end
end

function terminal.menudata()
    if menuout ~= nil then
        return menuout
    else
        return "no output"
    end
end

function terminal.timeswitch(lr, ins, cc, pos1, pos2, change, start, col1, col2, col3, repeats)
    if lr == "db" then
        if data7 == nil then
            return nil
        else
            return data7[ins]
        end
    end
    if lr == "setdb" then
        if data7 == nil then
            return "no data to edit"
        else
            data7[ins] = cc
            return ("value changed too " .. type(cc))
        end
    end
    expect(1, lr, "number")
    expect(2, ins, "table")
    expect(3, cc, "number")
    expect(4, pos1, "number")
    expect(5, pos2, "number")
    expect(6, change, "number")
    expect(7, start, "number")
    expect(8, col1, "string")
    expect(9, col2, "string")
    expect(10, col3, "string")
    expect(11, repeats, "boolean")
    if ins[2] == lr or ins[2] == "tout" then
        if ins ~= nil then
            local oldcol1 = term.getTextColor()
            local oldcol2 = term.getBackgroundColor()
            term.setBackgroundColor(colors[col2])
            term.setTextColor(colors[col1])
            if data7 == nil then
                data7 = {}
                for is = 0, 1000 do
                    data7[is] = false
                end
            end
            if data8 == nil then
                data8 = {}
                for is = 0, 1000 do
                    data8[is] = false
                end
            end
            if data8[cc] == false then
                data8[cc] = start
                term.setCursorPos(pos1 + 6, pos2)
                term.write(data8[cc])
            end
            term.setCursorPos(pos1, pos2)
            term.write("start")
            if terminal.API(ins, pos1, pos2, 4, 1) == true then
                data7[cc] = true
            end
            if data7[cc] == true then
                if data8[cc] > 0 then
                    repeat
                        timeOut = data8[cc]
                        term.setBackgroundColor(colors[col3])
                        data8[cc] = data8[cc] - change
                        term.setCursorPos(pos1 + 6, pos2)
                        sleep(1)
                        term.write(data8[cc])
                    until data8[cc] == 0
                    return "ended"
                end
            end
            if repeats == true then
                data8[cc] = start
            end
            term.setBackgroundColor(colors[col2])
            term.setCursorPos(pos1 + 6, pos2)
            term.write(data8[cc])
            term.setTextColor(oldcol1)
            term.setBackgroundColor(oldcol2)
        end
    end
end

function terminal.bar(
    pos1,
    pos2,
    length,
    height,
    ins,
    max,
    color1,
    color2,
    color3,
    printval,
    hor,
    text,
    format,
    rect,
    thicc)
    expect(1, pos1, "number")
    expect(2, pos2, "number")
    expect(3, length, "number")
    expect(4, height, "number")
    expect(5, ins, "number")
    expect(6, max, "number")
    expect(7, color1, "string")
    expect(8, color2, "string")
    expect(9, color3, "string")
    expect(10, printval, "boolean")
    expect(11, hor, "boolean")
    expect(12, text, "string")
    expect(13, format, "boolean")
    expect(14, rect, "boolean")
    expect(15, thicc, "boolean")
    if (ins == nil) or (ins < 0) then
        ins = 0
    end
    if format == nil then
        local format = false
    end
    if ins ~= nil then
        oldcol = term.getBackgroundColor()
        oldcol1 = term.getTextColor()
        term.setTextColor(colors[color3])
        local function reprint()
            term.setBackgroundColor(colors[color1])
            terminal.fill(pos1 - 1, pos2 - height, length, height * 2)
            term.setBackgroundColor(oldcol)
            xm = term.getBackgroundColor()
            xb = term.getTextColor()
            term.setTextColor(xm)
            term.setBackgroundColor(xb)
            term.setCursorPos(pos1 - 1, pos2 - height)
            if thicc then
                term.setBackgroundColor(colors[color3])
            end
            if thicc then
                term.write(string.rep("\x83", length + 1)) --\143
                term.setTextColor(xb)
                term.setBackgroundColor(xm)
            else
                term.write("\159" .. string.rep("\143", length - 1)) --\x83
                term.setTextColor(xb)
                term.setBackgroundColor(xm)
                term.write("\144")
            end
            if thicc then
                term.setBackgroundColor(colors[color3])
            end
            term.setCursorPos(pos1 - 1, pos2 + height)
            if thicc then
                term.write(string.rep("\x8c", length + 1)) --\131
            else
                term.write("\130" .. string.rep("\131", length - 1) .. "\129") --\x8c
            end
            for i = 0, (height * 2) - 2 do
                if not thicc then
                    term.setTextColor(xm)
                    term.setBackgroundColor(xb)
                end
                term.setCursorPos(pos1 - 1, (pos2 + i) - (height) + 1)
                if thicc then
                    term.setBackgroundColor(colors[color3])
                end
                term.write("\x95")
                term.setCursorPos((pos1 - 2) + (length + 1), (pos2 + i) - (height) + 1)
                if not thicc then
                    term.setTextColor(xb)
                    term.setBackgroundColor(xm)
                end
                term.write("\x95")
            end
        end
        if rect ~= false then
            reprint()
        else
            terminal.fill(pos1 - 1, pos2 - height, length, height * 2)
        end
        local drawLength = ins / max * length
        local drawHeights = ins / max * height
        local drawHeight = math.ceil(drawHeights)
        local moveval = (drawHeight * 2) - 2
        local z = pos2 + height
        term.setBackgroundColor(colors[color2])
        if (hor == false) or (hor == nil) then
            terminal.fill(pos1, (pos2 - height) + 1, drawLength - 1, (height * 2) - 1)
        else
            terminal.fill(pos1, (z - 1) - moveval, length - 1, moveval + 1)
        end
        if printval == true then
            term.setCursorPos(pos1 + 1, pos2)
            term.setTextColor(colors[color3])
            local fillTo = (ins / max) * length + pos1
            for i = 1, #text do
                local c = text:sub(i, i)
                local x, y = term.getCursorPos()
                if x <= fillTo then
                    term.setBackgroundColor(colors[color2])
                else
                    term.setBackgroundColor(colors[color1])
                end
                term.write(c)
            end
            -- term.setCursorPos(pos1, pos2)
            -- term.setTextColor(colors[color3])
            -- if hor == true then
            --     if format then
            --         if ins >= max / 2 then
            --             term.setBackgroundColor(colors[color2])
            --         else
            --             term.setBackgroundColor(colors[color1])
            --         end
            --     else
            --         if ins >= (max / 2) - (max / height) then
            --             term.setBackgroundColor(colors[color2])
            --         else
            --             term.setBackgroundColor(colors[color1])
            --         end
            --     end
            -- elseif hor == false then
            --     term.setCursorPos(pos1, pos2)
            --     term.setTextColor(colors[color3])
            --     if hor == true then
            --         if ins >= 1 then
            --             term.setBackgroundColor(colors[color2])
            --         else
            --             term.setBackgroundColor(colors[color1])
            --         end
            --     end
            -- end
            -- if format then
            --     term.write(ins .. "/" .. max)
            --     term.setCursorPos(pos1, pos2 + 1)
            --     term.write(text)
            -- else
            --     term.write(ins .. "/" .. max .. " " .. text)
            -- end
            term.setBackgroundColor(oldcol)
            term.setTextColor(oldcol1)
        end
        term.setTextColor(oldcol1)
        term.setBackgroundColor(oldcol)
    end
end

function terminal.frame(pos1, pos2, length, height, color3, color1, thicc)
    expect(1, pos1, "number")
    expect(2, pos2, "number")
    expect(3, length, "number")
    expect(4, height, "number")
    expect(5, color3, "string")
    expect(6, color1, "string")
    expect(7, thicc, "boolean","nil")
    local oldcol = term.getBackgroundColor()
    local oldcol1 = term.getTextColor()
    term.setBackgroundColor(colors[color1])
    terminal.fill(pos1 - 1, pos2 - height, length, height * 2)
    term.setBackgroundColor(oldcol)
    xm = term.getBackgroundColor()
    xb = term.getTextColor()
    term.setTextColor(xm)
    term.setBackgroundColor(xb)
    term.setCursorPos(pos1 - 1, pos2 - height)
    if thicc then
        term.setBackgroundColor(colors[color3])
        term.setTextColor(oldcol)
        term.write(string.rep("\x83", length + 1)) --\143
        term.setTextColor(xb)
        term.setBackgroundColor(xm)
    else
        term.setTextColor(oldcol)
        term.setBackgroundColor(colors[color3])
        term.write("\159" .. string.rep("\143", length - 1)) --\x83
        term.setTextColor(colors[color3])
        term.setBackgroundColor(oldcol)
        term.write("\144")
    end
    term.setCursorPos(pos1 - 1, pos2 + height)
    if thicc then
        term.setBackgroundColor(oldcol)
        term.setTextColor(colors[color3])
        term.write(string.rep("\x8f", length + 1)) --\131
        term.setBackgroundColor(colors[color1])
        term.setTextColor(colors[color3])
    else
        term.write("\130" .. string.rep("\131", length - 1) .. "\129") --\x8c
    end
    for i = 0, (height * 2) - 2 do
        if not thicc then
            term.setTextColor(xm)
            term.setBackgroundColor(xb)
        end
        term.setCursorPos(pos1 - 1, (pos2 + i) - (height) + 1)
        if thicc then
            term.setBackgroundColor(colors[color3])
        end
        term.setBackgroundColor(colors[color3])
        term.write("\x95")
        term.setCursorPos((pos1 - 2) + (length + 1), (pos2 + i) - (height) + 1)
        if not thicc then
            term.setTextColor(xb)
            term.setBackgroundColor(xm)
        end
        term.setTextColor(colors[color3])
        term.write("\x95")
    end
    term.setBackgroundColor(oldcol)
    term.setTextColor(oldcol1)
end

return {
    monitor = monitor,
    terminal = terminal
}
