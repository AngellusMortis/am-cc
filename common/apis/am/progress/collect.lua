require(settings.get("ghu.base") .. "core/apis/ghu")

local ui = require("am.ui")
local e = require("am.event")
local log = require("am.log")
local h = require("am.helpers")

local ProgressWrapper = require("am.progress.base")

---@class am.progress.CollectWrapper:am.progress.ProgressWrapper
---@field src_map table<number, am.net.src>
---@field progress table<number, am.e.CollectProgressEvent>
---@field completed boolean
---@field paused boolean
---@field position am.p.TurtlePosition|nil
local CollectWrapper = ProgressWrapper:extend("am.progress.CollectWrapper")
---@param src am.net.src
---@param progress am.e.CollectProgressEvent
---@param output cc.output
---@param frame am.ui.Frame
function CollectWrapper:init(src, progress, output, frame)
    CollectWrapper.super.init(self, src, {[src.id]=progress}, output, frame)

    self.src_map = {[src.id] = src}
    self.position = nil
    self.paused = false
    self.names = {
        [e.c.Event.Progress.collect] = true,
        [e.c.Event.Progress.tree] = true,
    }
    return self
end


---@return am.e.CollectProgressEvent, number
function CollectWrapper:getEvent()
    local count = 0
    local event = nil
    for _, progressEvent in pairs(self.progress) do
        count = count + 1
        event = progressEvent
    end

    return event, count
end

---@param event? am.e.CollectProgressEvent
---@param count? number
---@return boolean
function CollectWrapper:isTree(event, count)
    if count == nil then
        event, count = self:getEvent()
    end
    ---@cast event am.e.CollectProgressEvent
    return count == 1 and event ~= nil and event.name == e.c.Event.Progress.tree
end

---@return string
function CollectWrapper:getTitle()
    local event, count = self:getEvent()
    if self:isTree(event, count) then
        ---@cast event am.e.TreeProgressEvent
        local extra = ""
        if #event.trees > 0 then
            extra = string.format(" (%d)", #event.trees)
        end
        return string.format("Tree%s", extra)
    end

    return "Collect"
end

---@class am.progress_status
---@field label string
---@field status string

---@return string
function CollectWrapper:getStatus()
    for _, event in pairs(self.progress) do
        return event.status
    end

    return ""
end

---@return string[]
function CollectWrapper:getItems()
    local items = {}
    ---@cast items table<string, am.collect_rate>

    for _, event in pairs(self.progress) do
        for _, rate in ipairs(event.rates) do
            if items[rate.item.name] == nil then
                items[rate.item.name] = rate
            else
                local existingRate = items[rate.item.name]
                existingRate.rate = existingRate.rate + rate.rate
                items[rate.item.name] = existingRate
            end
        end
    end

    local itemList = {}
    ---@cast itemList am.collect_rate[]
    for _, item in pairs(items) do
        itemList[#itemList + 1] = item
    end
    h.sortItemsByCount(itemList, false)

    local rates = {}
    for _, item in ipairs(itemList) do
        local rate = h.metricString(item.rate)
        rates[#rates + 1] = string.format("%5s %s/min", rate, item.item.displayName)
    end
    return rates
end

function CollectWrapper:createUI()
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

    local event = self:getEvent()
    self:update(self.src, event)
    self:render()
end

---@param src am.net.src
---@param event? am.e.ColoniesEvent
---@param force? boolean
function CollectWrapper:update(src, event, force)
    if event ~= nil then
        self.progress[src.id] = event
    end

    if not self.frame.visible and not force then
        return
    end

    local _, height = self.output.getSize()

    local baseId = self:getBaseId()
    self.src_map[src.id] = src

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

    titleText.obj.anchor.y = startY
    titleText:update(self:getTitle())

    local redraw = false
    local rateText = self.frame:get(baseId .. ".rateText", self.output)
    ---@cast rateText am.ui.BoundText
    local statusText = self.frame:get(baseId .. ".statusText", self.output)
    ---@cast statusText am.ui.BoundText

    rateText.obj.anchor.y = startY + 2
    local items = self:getItems()
    rateText:update(items)

    local itemCount = #items
    if itemCount == 0 then
        itemCount = 1
    end
    local itemEndY = startY + itemCount
    if statusText.obj.anchor.y ~= itemEndY + 3 then
        redraw = true
    end
    statusText.obj.anchor.y = itemEndY + 3
    statusText:update(self:getStatus())

    local haltButton = self.frame:get(baseId .. ".haltButton", self.output)
    ---@cast haltButton am.ui.BoundButton
    local pauseButton = self.frame:get(baseId .. ".pauseButton", self.output)
    ---@cast pauseButton am.ui.BoundButton
    haltButton.obj.anchor.y = itemEndY + 4
    pauseButton.obj.anchor.y = itemEndY + 4

    local progressEvent, count = self:getEvent()
    if self:isTree(progressEvent, count) then
        ---@cast progressEvent am.e.TreeProgressEvent
        self:updatePosition(src, progressEvent.pos)
    else
        self:updatePosition(src, nil)
    end

    if redraw then
        self:render()
    end
end

---@param src am.net.src
---@param pos? am.p.TurtlePosition
function ProgressWrapper:updatePosition(src, pos)
    self.position = pos
    local baseId = self:getBaseId()
    local posText = self.frame:get(baseId .. ".posText", self.output)
    ---@cast posText am.ui.BoundText

    if pos == nil then
        posText.visible = false
        posText:update("")
        return
    end

    local width, _ = self.output.getSize()
    local posFmt = "pos (%d, %d) e: %d, d: %d"
    if width < 30 then
        posFmt = "(%d,%d) e:%d, d:%d"
    end
    posText:update(string.format(
        posFmt, pos.v.x, pos.v.z, pos.v.y, pos.dir
    ))
end

---@param src am.net.src
---@param status string
function CollectWrapper:updateStatus(src, status)
    local baseId = self:getBaseId()
    local statusText = self.frame:get(baseId .. ".statusText", self.output)
    ---@cast statusText am.ui.BoundText

    statusText:update(status)
end

---@param src am.net.src
---@param event string Event name
---@param args table
function CollectWrapper:handle(src, event, args)
    local baseId = self:getBaseId()
    local wrapper = self
    if event == e.c.Event.Progress.quarry then
        self:update(src, args[1])
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

return CollectWrapper
