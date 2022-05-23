local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local ui = require("am.ui")
local e = require("am.event")
local core = require("am.core")
local h = require("am.progress.helpers")

local QuarryWrapper = require("am.progress.quarry")
local CollectWrapper = require("am.progress.collect")
local ColoniesWrapper = require("am.progress.colonies")

local p = {}
---@type table<string, am.progress.ProgressWrapper>
local WRAPPERS = {}
local TABS = nil

---@param src am.net.src
---@param tabbed boolean
local function createFrame(src, tabbed)
    if not tabbed then
        return ui.Frame(ui.a.Anchor(1, 1), {
            id=string.format("progressFrame.%d", src.id),
            fillHorizontal=true,
            fillVertical=true,
            border=0,
            backgroundColor=colors.black,
            textColor=colors.white,
        })
    end

    if TABS == nil then
        TABS = ui.TabbedFrame(ui.a.Anchor(1, 1), {
            id="progressFrame",
            fillHorizontal=true,
            fillVertical=true,
            border=0,
            backgroundColor=colors.black,
            textColor=colors.white,
            primaryTabId=tostring(src.id),
            showTabs=true,
            tabFillColor=colors.gray,
            tabTextColor=colors.black,
            activeTabFillColor=colors.black,
            activeTabTextColor=colors.yellow,
            tabPadTop=1,
            tabPadBottom=0
        })
        ---@cast TABS am.ui.TabbedFrame

        return TABS.tabs[1]
    end

    return TABS:createTab(tostring(src.id))
end

---@param src am.net.src
---@param event? am.e.ProgressEvent
---@param output? cc.output
---@param tabbed? boolean
---@return am.progress.ProgressWrapper?, boolean
local function getWrapper(src, event, output, tabbed)
    v.expect(1, src, "table")
    v.expect(2, output, "table", "nil")
    v.expect(3, event, "table", "nil")
    v.expect(4, tabbed, "boolean", "nil")
    local create = output ~= nil and event ~= nil
    if output ~= nil then
        ui.h.requireOutput(output)
    end
    if tabbed == nil then
        tabbed = false
    end

    local wrapper = WRAPPERS[src.id]
    local created = false
    if create then
        ---@cast output cc.output
        ---@cast event am.e.ProgressEvent
        if wrapper ~= nil then
            local wrapperOutput = wrapper.output
            if ui.h.isFrameScreen(wrapperOutput) then
                wrapperOutput = ui.h.getFrameScreen(wrapperOutput).output
            end
            if not wrapper.names[event.name] or not ui.h.isSameScreen(wrapperOutput, output) then
                WRAPPERS[src.id] = nil
                wrapper = nil
            end
        end
        if wrapper == nil then
            if (
                event.name == e.c.Event.Progress.quarry or
                event.name == e.c.Event.Progress.collect or
                event.name == e.c.Event.Progress.tree or
                event.name == e.c.Event.Colonies.status_poll
            ) then
                local frame = createFrame(src, tabbed)
                local frameOutput = output
                if tabbed then
                    frameOutput = TABS:makeScreen(output)
                end
                if event.name == e.c.Event.Progress.quarry then
                    wrapper = QuarryWrapper(src, event, frameOutput, frame)
                    ---@cast wrapper am.progress.ProgressWrapper
                elseif event.name == e.c.Event.Progress.collect or event.name == e.c.Event.Progress.tree then
                    wrapper = CollectWrapper(src, event, frameOutput, frame)
                    ---@cast wrapper am.progress.ProgressWrapper
                elseif event.name == e.c.Event.Colonies.status_poll then
                    ---@cast event am.e.ColonyStatusPollEvent
                    wrapper = ColoniesWrapper(src, event.status.id, frameOutput, frame)
                    ---@cast wrapper am.progress.ColoniesWrapper
                    wrapper.progress.status = event.status
                end
            end

            if wrapper ~= nil then
                wrapper:createUI()
                WRAPPERS[src.id] = wrapper
                if TABS ~= nil then
                    TABS:setActive(output, #TABS.tabs)
                    if #TABS.tabs == 1 then
                        output.clear()
                        TABS:render(output)
                    end
                end
            end
            created = wrapper ~= nil
        end
    end

    return wrapper, created
end

---@param output cc.output
---@return am.net.src
local function getSrcFromOutput(output)
    for id, wrapper in pairs(WRAPPERS) do
        local wrapperOutput = wrapper.output
        if ui.h.isFrameScreen(wrapperOutput) then
            wrapperOutput = ui.h.getFrameScreen(wrapperOutput).output
        end

        if ui.h.isSameScreen(output, wrapperOutput) then
            return {id=id}
        end
    end
    return nil
end

---@param src am.net.src
---@param pos am.p.TurtlePosition
local function updatePosition(src, pos)
    v.expect(1, src, "table")
    v.expect(2, pos, "table")

    local wrapper = getWrapper(src)
    if wrapper ~= nil then
        wrapper:updatePosition(src, pos)
    end
end

---@param src am.net.src
---@param status string
local function updateStatus(src, status)
    v.expect(1, src, "table")
    v.expect(2, status, "string")

    local wrapper = getWrapper(src)
    if wrapper ~= nil then
        wrapper:updateStatus(src, status)
    end
end

---@param src am.net.src
---@param event am.e.ProgressEvent
---@param output? cc.output
---@param tabbed? boolean
local function printProgress(src, event, output, tabbed)
    v.expect(1, src, "table")
    v.expect(2, event, "table")
    v.expect(3, output, "table", "nil")
    v.expect(4, tabbed, "boolean", "nil")
    if output == nil then
        output = term
    else
        ui.h.requireOutput(output)
    end
    if tabbed == nil then
        tabbed = false
    end

    local wrapper, created = getWrapper(src, event, output, tabbed)
    if wrapper ~= nil and not created then
        wrapper:update(src, event)
    end
end

---@param event string Event name
---@param args table
local function handleAll(event, args)
    if TABS ~= nil then
        TABS:handle(term, event, table.unpack(args))
    else
        for _, wrapper in pairs(WRAPPERS) do
            wrapper:handle(e.getComputer(), event, args)
        end
    end
end

---@param src am.net.src
---@param event string Event name
---@param args table
local function handle(src, event, args)
    local newSrc = nil
    if ui.c.l.Events.Always[event] then
        handleAll(event, args)
        return
    elseif ui.c.l.Events.UI[event] then
        local parts = core.split(args[1].objId, ".")
        if parts[1] == "progressFrame" then
            newSrc = {
                id=tonumber(parts[2])
            }
        end
    elseif ui.c.l.Events.Terminal[event] then
        newSrc = getSrcFromOutput(term)
    elseif ui.c.l.Events.Monitor[event] then
        newSrc = getSrcFromOutput(peripheral.wrap(args[1]))
    elseif event == e.c.Event.Pathfind.position then
        updatePosition(src, args[1].position)
        return
    end

    if newSrc ~= nil then
        src = newSrc
    end

    if TABS ~= nil then
        TABS:handle(term, event, table.unpack(args))
    else
        local wrapper, _ = getWrapper(src)
        if wrapper ~= nil then
            wrapper:handle(src, event, args)
        end
    end
end

p.updateStatus = updateStatus
p.updatePosition = updatePosition
p.print = printProgress
p.handle = handle
p.itemStrings = h.itemStrings

return p
