local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local BaseObject = require("am.ui.base").BaseObject

local ui = require("am.ui")
local e = require("am.event")
local log = require("log")
local core = require("am.core")

local p = {}
local wrappers = {}

---@class am.progress.ProgressWrapper:am.ui.b.BaseObject
---@field src table
---@field progress am.e.ProgressEvent
---@field screen am.ui.Screen
local ProgressWrapper = BaseObject:extend("am.progress.ProgressWrapper")
function ProgressWrapper:init(src, progress, output)
    v.expect(1, src, "table")
    v.expect(2, progress, "table")
    v.expect(3, output, "table")
    ProgressWrapper.super.init(self)

    self.src = src
    self.screen = self:createUI(output)
    self:update(progress)
    self.screen:render()
    return self
end

---@param output cc.output
---@return am.ui.Screen
function ProgressWrapper:createUI(output)
    return ui.Screen(output)
end

---@param event am.e.ProgressEvent
function ProgressWrapper:update(event)
    self.progress = event
end

---@param event string Event name
---@param args table
function ProgressWrapper:handle(event, args)
end

---@class am.progress.QuarryWrapper:am.progress.ProgressWrapper
---@field progress am.e.QuarryProgressEvent
local QuarryWrapper = ProgressWrapper:extend("am.progress.QuarryWrapper")
function QuarryWrapper:init(src, progress, output)
    ProgressWrapper.super.init(self, src, progress, output)

    self.paused = false
    return self
end

---@param output cc.output
---@return am.ui.Screen
function QuarryWrapper:createUI(output)
    local screen = ui.Screen(output)
    local titleY = 1

    local wrapper = self

    local haltButton = ui.Button(ui.a.Center(10, ui.c.Offset.Left), "Stop", {id="haltButton", fillColor=colors.red})
    haltButton:addActivateHandler(function()
        log.info(string.format("Halting %s...", self.src.name))
        e.TurtleRequestHaltEvent(self.src.id):send()
    end)

    local pauseButton = ui.Button(ui.a.Center(10, ui.c.Offset.Right), "Pause", {id="pauseButton", fillColor=colors.yellow})
    pauseButton:addActivateHandler(function()
        if wrapper.paused then
            log.info(string.format("Continuing %s...", self.src.name))
            e.TurtleRequestContinueEvent(self.src.id):send()
        else
            log.info(string.format("Pausing %s...", self.src.name))
            e.TurtleRequestPauseEvent(self.src.id):send()
        end
    end)

    if self.src.name ~= nil then
        screen:add(ui.Text(ui.a.Top(), "", "nameText"))
        titleY = 2
    end
    screen:add(ui.Text(ui.a.Center(titleY), "", "titleText"))
    screen:add(ui.ProgressBar(ui.a.Center(3), {
        id="totalBar", label="Total", displayTotal=self.progress.job.levels, fillColor=colors.lightGray
    }))
    screen:add(ui.ProgressBar(ui.a.Center(6), {
        id="levelBar", label="Level", total=self.progress.job.left, fillColor=colors.lightGray
    }))
    screen:add(ui.Text(ui.a.Center(9), "", {id="statusText"}))
    screen:add(haltButton)
    screen:add(pauseButton)
    screen:add(ui.Text(ui.a.Bottom(), "", {id="posText"}))
    return screen
end

---@param event am.e.QuarryProgressEvent
function QuarryWrapper:update(event)
    local width, _ = self.screen.output.getSize()

    self.progress = event
    if self.src.name ~= nil then
        local nameText = self.screen:get("nameText")
        if nameText ~= nil then
            ---@cast nameText am.ui.BoundText
            local nameStatus = self.src.name
            if e.online then
                nameStatus = "info:" .. nameStatus
            end
            nameText:update(nameStatus)
        end
    end
    local titleText = self.screen:get("titleText")
    ---@cast titleText am.ui.BoundText
    local totalBar = self.screen:get("totalBar")
    ---@cast totalBar am.ui.BoundProgressBar
    local levelBar = self.screen:get("levelBar")
    ---@cast levelBar am.ui.BoundProgressBar
    local statusText = self.screen:get("statusText")
    ---@cast statusText am.ui.BoundText
    local posText = self.screen:get("posText")
    ---@cast posText am.ui.BoundText

    titleText:update(string.format(
        "Quarry: %d x %d (%d)", self.progress.job.left, self.progress.job.forward, self.progress.job.levels
    ))
    totalBar:update(self.progress.progress.current)
    levelBar:update(self.progress.progress.completedRows)
    statusText:update(self.progress.progress.status)
    local posFmt = "pos (%d, %d) e: %d, d: %d"
    if width < 30 then
        posFmt = "(%d,%d) e:%d, d:%d"
    end
    posText:update(string.format(
        posFmt, self.progress.pos.v.x, self.progress.pos.v.z, self.progress.pos.v.y, self.progress.pos.v.dir
    ))
end

---@param event string Event name
---@param args table
function QuarryWrapper:handle(event, args)
    if event == e.c.Event.Progress.quarry then
        self:update(args[1])
    elseif event == e.c.Event.Turtle.paused then
        self.paused = true
        local pauseButton = self.screen:get("pauseButton")
        ---@cast pauseButton am.ui.BoundButton
        pauseButton.obj.fillColor = colors.green
        pauseButton:updateLabel("Go")
    elseif event == e.c.Event.Turtle.started then
        self.paused = false
        local haltButton = self.screen:get("haltButton")
        ---@cast haltButton am.ui.BoundButton
        local pauseButton = self.screen:get("pauseButton")
        ---@cast pauseButton am.ui.BoundButton

        haltButton.obj.visible = true
        haltButton:updateLabel("Stop")
        pauseButton.obj.visible = true
        pauseButton.obj.fillColor = colors.yellow
        pauseButton:updateLabel("Pause")
    elseif event == e.c.Event.Turtle.exited then
        local haltButton = self.screen:get("haltButton")
        ---@cast haltButton am.ui.BoundButton
        local pauseButton = self.screen:get("pauseButton")
        ---@cast pauseButton am.ui.BoundButton

        haltButton.obj.visible = false
        haltButton:updateLabel("")
        pauseButton.obj.visible = false
        pauseButton:updateLabel("")
    else
        self.screen:handle({event, unpack(args)})
    end
end

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

    local wrapper = wrappers[src.id]
    local created = false
    if create then
        ---@cast output cc.output
        ---@cast event am.e.ProgressEvent
        if wrapper.event.name ~= event.name or not ui.h.isSameScreen(wrapper.screen, output) then
            wrappers[src.id] = nil
            wrapper = nil
        end
        if wrapper == nil then
            created = true
            if event.name == e.c.Event.Progress.quarry then
                wrapper = QuarryWrapper(src, event, output)
                wrappers[src.id] = wrapper
            end
        end
    end

    return wrapper, created
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

---@param src am.net.src
---@param event string Event name
---@param args table
local function handle(src, event, args)
    local wrapper = getWrapper(src)
    if wrapper ~= nil then
        wrapper:handle(event, args)
    end
end

p.print = printProgress
p.handle = handle

return p
