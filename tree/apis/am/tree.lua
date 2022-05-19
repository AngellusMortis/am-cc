local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local ui = require("am.ui")
local e = require("am.event")
local log = require("am.log")

local ProgressWrapper = require("am.progress.base")

---@class am.progress.TreeWrapper:am.progress.ProgressWrapper
---@field progress am.e.TreeProgressEvent
---@field completed boolean
---@field paused boolean
local TreeWrapper = ProgressWrapper:extend("am.progress.TreeWrapper")
---@param src am.net.src
---@param progress am.e.ProgressEvent
---@param output cc.output
---@param frame am.ui.Frame
function TreeWrapper:init(src, progress, output, frame)
    TreeWrapper.super.init(self, src, progress, output, frame)

    self.paused = false
    self.names[progress.name] = true
    return self
end

function TreeWrapper:createUI()
    local baseId = self:getBaseId()
    local wrapper = self

    local startY = 2
    local nameText = ui.Text(ui.a.Top(), "", {id=baseId .. ".nameText"})
    local _, height = self.output.getSize()
    if height <= 12 then
        startY = 1
        nameText.visible = false
    end

    if _G.PROGRESS_SHOW_CLOSE then
        local closeButton = ui.Button(ui.a.TopRight(), "x", {id=baseId .. ".closeButton", fillColor=colors.red, border=0})
        closeButton:addActivateHandler(function()
            _G.RUN_PROGRESS = false
        end)
        self.frame:add(closeButton)
    end

    self.frame:add(nameText)
    self.frame:add(ui.Text(ui.a.Center(startY), "", {id=baseId .. ".titleText"}))

    -- rate text
    self.frame:add(ui.Text(ui.a.Center(startY + 2), "", {id=baseId .. ".rateText"}))

    -- status text
    self.frame:add(ui.Text(ui.a.Center(startY + 4), "", {id=baseId .. ".statusText"}))

    --- halt button
    local haltButton = ui.Button(ui.a.Center(startY + 5, ui.c.Offset.Left, 1), "\x8f", {
        id=baseId .. ".haltButton", fillColor=colors.red
    })
    haltButton:addActivateHandler(function()
        log.info(string.format("Halting %s...", self.src.label))
        e.TurtleRequestHaltEvent(self.src.id):send()
    end)
    self.frame:add(haltButton)

    --- pause button
    local pauseButton = ui.Button(ui.a.Center(startY + 5, ui.c.Offset.Right, 1), "\x95\x95", {
        id=baseId .. ".pauseButton", fillColor=colors.yellow
    })
    pauseButton:addActivateHandler(function()
        if wrapper.paused then
            log.info(string.format("Continuing %s...", self.src.label))
            e.TurtleRequestContinueEvent(self.src.id):send()
        else
            log.info(string.format("Pausing %s...", self.src.label))
            e.TurtleRequestPauseEvent(self.src.id):send()
        end
    end)
    self.frame:add(pauseButton)

    self.frame:add(ui.Text(ui.a.Bottom(), "", {id=baseId .. ".posText"}))
    TreeWrapper.super.createUI(self)
end

---@param event am.e.QuarryProgressEvent
function TreeWrapper:update(event)
    local width, height = self.output.getSize()

    local baseId = self:getBaseId()
    self.progress = event

    -- top section
    local nameText = self.frame:get(baseId .. ".nameText", self.output)
    ---@cast nameText am.ui.BoundText
    local titleText = self.frame:get(baseId .. ".titleText", self.output)
    ---@cast titleText am.ui.BoundText

    if self.src.label ~= nil then
        local nameStatus = self.src.label
        if e.online then
            nameStatus = "info:" .. nameStatus
        end
        nameText:update(nameStatus)
    end

    local startY = 1
    if height <= 12 then
        nameText.obj.visible = false
    else
        startY = 2
        nameText.obj.visible = self.frame.visible
    end

    local extra = ""
    titleText.obj.anchor.y = startY
    if #self.progress.trees > 0 then
        extra = string.format(" (%d)", #self.progress.trees)
    end
    titleText:update(string.format("Tree%s", extra))

    local rateText = self.frame:get(baseId .. ".rateText", self.output)
    ---@cast rateText am.ui.BoundText
    local statusText = self.frame:get(baseId .. ".statusText", self.output)
    ---@cast statusText am.ui.BoundText
    local posText = self.frame:get(baseId .. ".posText", self.output)
    ---@cast posText am.ui.BoundText

    rateText.obj.anchor.y = startY + 2
    rateText:update(string.format("%.1f log/min", self.progress.rate))

    statusText.obj.anchor.y = startY + 4
    statusText:update(self.progress.status)
    local posFmt = "pos (%d, %d) e: %d, d: %d"
    if width < 30 then
        posFmt = "(%d,%d) e:%d, d:%d"
    end
    posText:update(string.format(
        posFmt, self.progress.pos.v.x, self.progress.pos.v.z, self.progress.pos.v.y, self.progress.pos.dir
    ))
end

---@param status string
function TreeWrapper:updateStatus(status)
    local baseId = self:getBaseId()
    local statusText = self.frame:get(baseId .. ".statusText", self.output)
    ---@cast statusText am.ui.BoundText

    statusText:update(status)
end

---@param event string Event name
---@param args table
function TreeWrapper:handle(event, args)
    local baseId = self:getBaseId()
    local wrapper = self
    if event == e.c.Event.Progress.quarry then
        self:update(args[1])
    else
        local haltButton = self.frame:get(baseId .. ".haltButton", self.output)
        ---@cast haltButton am.ui.BoundButton
        local pauseButton = self.frame:get(baseId .. ".pauseButton", self.output)
        ---@cast pauseButton am.ui.BoundButton

        if event == e.c.Event.Turtle.paused then
            self.paused = true
            self.completed = false
            pauseButton.obj.fillColor = colors.green
            pauseButton:updateLabel("\x10")
            self:render()
        elseif event == e.c.Event.Turtle.started then
            self.paused = false
            self.completed = false

            haltButton.obj.visible = wrapper.frame.visible
            haltButton:updateLabel("\x8f")
            pauseButton.obj.visible = wrapper.frame.visible
            pauseButton.obj.fillColor = colors.yellow
            pauseButton:updateLabel("\x95\x95")
            self:render()
        elseif event == e.c.Event.Turtle.exited then
            self.completed = true
            self.paused = false
            haltButton.obj.visible = false
            pauseButton.obj.visible = false
            self:render()
        else
            self.frame:handle(self.output, {event, table.unpack(args)})
        end
    end
end

return TreeWrapper
