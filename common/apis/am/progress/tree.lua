local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local BaseObject = require("am.ui.base").BaseObject

local ui = require("am.ui")
local e = require("am.event")
local log = require("am.log")
local h = require("am.progress.helpers")

local ProgressWrapper = require("am.progress.base")

---@class am.progress.TreeWrapper:am.progress.ProgressWrapper
---@field progress am.e.TreeProgressEvent
---@field completed boolean
---@field paused boolean
local TreeWrapper = ProgressWrapper:extend("am.progress.TreeWrapper")
function TreeWrapper:init(src, progress, output)
    TreeWrapper.super.init(self, src, progress, output)

    self.paused = false
    self.names[progress.name] = true
    return self
end

function TreeWrapper:createUI()
    local baseId = self.screen.id
    local wrapper = self

    local startY = 2
    local nameText = ui.Text(ui.a.Top(), "", {id=baseId .. ".nameText"})
    local _, height = self.screen.output.getSize()
    if height <= 12 then
        startY = 1
        nameText.visible = false
    end

    if _G.RUN_PROGRESS and ui.h.isTerm(self.screen.output) then
        local closeButton = ui.Button(ui.a.TopRight(), "x", {id=baseId .. ".closeButton", fillColor=colors.red, border=0})
        closeButton:addActivateHandler(function()
            _G.RUN_PROGRESS = false
        end)
        self.screen:add(closeButton)
    end

    self.screen:add(nameText)
    self.screen:add(ui.Text(ui.a.Center(startY), "", {id=baseId .. ".titleText"}))

    -- rate text
    self.screen:add(ui.Text(ui.a.Center(startY + 2), "", {id=baseId .. ".rateText"}))

    -- status text
    self.screen:add(ui.Text(ui.a.Center(startY + 4), "", {id=baseId .. ".statusText"}))

    --- halt button
    local haltButton = ui.Button(ui.a.Center(startY + 5, ui.c.Offset.Left, 1), "\x8f", {
        id=baseId .. ".haltButton", fillColor=colors.red
    })
    haltButton:addActivateHandler(function()
        log.info(string.format("Halting %s...", self.src.label))
        e.TurtleRequestHaltEvent(self.src.id):send()
    end)
    self.screen:add(haltButton)

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
    self.screen:add(pauseButton)

    self.screen:add(ui.Text(ui.a.Bottom(), "", {id=baseId .. ".posText"}))
    TreeWrapper.super.createUI(self)
end

---@param event am.e.QuarryProgressEvent
function TreeWrapper:update(event)
    local width, height = self.screen.output.getSize()

    local baseId = self.screen.id
    self.progress = event

    -- top section
    local nameText = self.screen:get(baseId .. ".nameText")
    ---@cast nameText am.ui.BoundText
    local titleText = self.screen:get(baseId .. ".titleText")
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
        nameText.obj.visible = true
    end

    local extra = ""
    titleText.obj.anchor.y = startY
    if #self.progress.trees > 0 then
        extra = string.format(" (%d)", #self.progress.trees)
    end
    titleText:update(string.format("Tree%s", extra))

    local rateText = self.screen:get(baseId .. ".rateText")
    ---@cast rateText am.ui.BoundText
    local statusText = self.screen:get(baseId .. ".statusText")
    ---@cast statusText am.ui.BoundText
    local posText = self.screen:get(baseId .. ".posText")
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
    local baseId = self.screen.id
    local statusText = self.screen:get(baseId .. ".statusText")
    ---@cast statusText am.ui.BoundText

    statusText:update(status)
end

---@param event string Event name
---@param args table
function TreeWrapper:handle(event, args)
    local baseId = self.screen.id
    if event == e.c.Event.Progress.quarry then
        self:update(args[1])
    else
        local haltButton = self.screen:get(baseId .. ".haltButton")
        ---@cast haltButton am.ui.BoundButton
        local pauseButton = self.screen:get(baseId .. ".pauseButton")
        ---@cast pauseButton am.ui.BoundButton

        if event == e.c.Event.Turtle.paused then
            self.paused = true
            self.completed = false
            pauseButton.obj.fillColor = colors.green
            pauseButton:updateLabel("\x10")
            self.screen:render()
        elseif event == e.c.Event.Turtle.started then
            self.paused = false
            self.completed = false

            haltButton.obj.visible = true
            haltButton:updateLabel("\x8f")
            pauseButton.obj.visible = true
            pauseButton.obj.fillColor = colors.yellow
            pauseButton:updateLabel("\x95\x95")
            self.screen:render()
        elseif event == e.c.Event.Turtle.exited then
            self.completed = true
            self.paused = false
            haltButton.obj.visible = false
            pauseButton.obj.visible = false
            self.screen:render()
        else
            self.screen:handle({event, table.unpack(args)})
        end
    end
end

return TreeWrapper
