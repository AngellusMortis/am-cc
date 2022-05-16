local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local ui = require("am.ui")
local e = require("am.event")
local core = require("am.core")
local h = require("am.progress.helpers")

local QuarryWrapper = require("am.progress.quarry")
local TreeWrapper = require("am.progress.tree")
local ColoniesWrapper = require("am.progress.colonies")

local p = {}
local WRAPPERS = {}

---@param src am.net.src
---@param event? am.e.ProgressEvent
---@param output? cc.output
---@return am.progress.ProgressWrapper?, boolean
local function getWrapper(src, event, output)
    v.expect(1, src, "table")
    v.expect(2, output, "table", "nil")
    v.expect(3, event, "table", "nil")
    local create = output ~= nil and event ~= nil
    if output ~= nil then
        ui.h.requireOutput(output)
    end

    local wrapper = WRAPPERS[src.id]
    local created = false
    if create then
        ---@cast output cc.output
        ---@cast event am.e.ProgressEvent
        if wrapper ~= nil then
            if not wrapper.names[event.name] or not ui.h.isSameScreen(wrapper.screen.output, output) then
                WRAPPERS[src.id] = nil
                wrapper = nil
            end
        end
        if wrapper == nil then
            if event.name == e.c.Event.Progress.quarry then
                wrapper = QuarryWrapper(src, event, output)
                ---@cast wrapper am.progress.ProgressWrapper
                wrapper:createUI()
                WRAPPERS[src.id] = wrapper
            elseif event.name == e.c.Event.Progress.tree then
                wrapper = TreeWrapper(src, event, output)
                ---@cast wrapper am.progress.ProgressWrapper
                wrapper:createUI()
                WRAPPERS[src.id] = wrapper
            elseif event.name == e.c.Event.Colonies.status_poll then
                ---@cast event am.e.ColoniesScanEvent
                wrapper = ColoniesWrapper(src, event.status.id, output)
                ---@cast wrapper am.progress.ColoniesWrapper
                wrapper.progress.status = event.status
                wrapper:createUI()
                WRAPPERS[src.id] = wrapper
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
        if ui.h.isSameScreen(output, wrapper.screen.output) then
            return {id=id}
        end
    end
    return nil
end

---@param src am.net.src
---@param status string
local function updateStatus(src, status)
    v.expect(1, src, "table")
    v.expect(2, status, "string")

    local wrapper = getWrapper(src)
    if wrapper ~= nil then
        wrapper:updateStatus(status)
    end
end

---@param src am.net.src
---@param event am.e.ProgressEvent
---@param output? cc.output
local function printProgress(src, event, output)
    v.expect(1, src, "table")
    v.expect(2, event, "table")
    v.expect(3, output, "table", "nil")
    if output == nil then
        output = term
    else
        ui.h.requireOutput(output)
    end

    local wrapper, created = getWrapper(src, event, output)
    if wrapper ~= nil and not created then
        wrapper:update(event)
    end
end

---@param event string Event name
---@param args table
local function handleAll(event, args)
    for _, wrapper in pairs(WRAPPERS) do
        wrapper:handle(event, args)
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
        if parts[1] == "screen" then
            newSrc = {
                id=tonumber(parts[2])
            }
        end
    elseif ui.c.l.Events.Terminal[event] then
        newSrc = getSrcFromOutput(term)
    elseif ui.c.l.Events.Monitor[event] then
        newSrc = getSrcFromOutput(peripheral.wrap(args[1]))
    end

    if newSrc ~= nil then
        src = newSrc
    end

    local wrapper, _ = getWrapper(src)
    if wrapper ~= nil then
        wrapper:handle(event, args)
    end
end

p.updateStatus = updateStatus
p.print = printProgress
p.handle = handle
p.itemStrings = h.itemStrings

return p
