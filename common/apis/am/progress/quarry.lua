local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local ui = require("am.ui")
local e = require("am.event")
local log = require("am.log")
local h = require("am.progress.helpers")

local ProgressWrapper = require("am.progress.base")

---@class am.progress.QuarryWrapper:am.progress.ProgressWrapper
---@field progress am.e.QuarryProgressEvent
---@field completed boolean
---@field paused boolean
local QuarryWrapper = ProgressWrapper:extend("am.progress.QuarryWrapper")
---@param src am.net.src
---@param progress am.e.ProgressEvent
---@param output cc.output
---@param frame am.ui.Frame
function QuarryWrapper:init(src, progress, output, frame)
    QuarryWrapper.super.init(self, src, progress, output, frame)

    self.completed = false
    self.paused = false
    self.names[progress.name] = true
    return self
end

---@param mainFrame am.ui.TabbedFrame
function QuarryWrapper:createProgressFrame(mainFrame)
    local wrapper = self
    local progressFrame = mainFrame.tabs[1]
    local baseId = self:getBaseId()

    --- items button
    local itemsButton = ui.Button(ui.a.Center(8), "\x17", {
        id=baseId .. ".itemsButton", fillColor=colors.blue
    })
    itemsButton:addActivateHandler(function()
        mainFrame:setActive(wrapper.output, 2)
        local haltButton = progressFrame:get(baseId .. ".haltButton", wrapper.output)
        ---@cast haltButton am.ui.Button
        local pauseButton = progressFrame:get(baseId .. ".pauseButton", wrapper.output)
        ---@cast pauseButton am.ui.Button
        if wrapper.completed then
            haltButton.visible = false
            pauseButton.visible = false
        end
    end)
    progressFrame:add(itemsButton)

    --- total bar
    progressFrame:add(ui.ProgressBar(ui.a.TopLeft(), {
        id=baseId .. ".totalBar", label="Total", displayTotal=self.progress.job.levels, fillColor=colors.lightGray
    }))

    --- level bar
    progressFrame:add(ui.ProgressBar(ui.a.Left(4), {
        id=baseId .. ".levelBar", label="Level", total=1, fillColor=colors.lightGray
    }))

    -- status text
    progressFrame:add(ui.Text(ui.a.Center(7), "", {id=baseId .. ".statusText"}))

    --- halt button
    local haltButton = ui.Button(ui.a.Center(8, ui.c.Offset.Left, 2), "\x8f", {
        id=baseId .. ".haltButton", fillColor=colors.red
    })
    haltButton:addActivateHandler(function()
        log.info(string.format("Halting %s...", self.src.label))
        e.TurtleRequestHaltEvent(self.src.id):send()
    end)
    progressFrame:add(haltButton)

    --- pause button
    local pauseButton = ui.Button(ui.a.Center(8, ui.c.Offset.Right, 2), "\x95\x95", {
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
    progressFrame:add(pauseButton)

    --- position text
    progressFrame:add(ui.Text(ui.a.Bottom(), "", {id=baseId .. ".posText"}))
    progressFrame:setVisible(true)
end

---@param mainFrame am.ui.TabbedFrame
---@param height number
function QuarryWrapper:createItemsFrame(mainFrame, height)
    local wrapper = self
    local baseId = self:getBaseId()
    local itemsFrame = mainFrame:createTab("items")
    itemsFrame.fillHorizontal = true
    itemsFrame.fillVertical = true
    itemsFrame.border = 0
    itemsFrame.fillColor = colors.black
    itemsFrame.textColor = colors.white

    --- title
    itemsFrame:add(ui.Text(ui.a.TopLeft(), "Mined Items", {id=baseId .. ".itemsTitle"}))

    --- close button
    local closeItemsButton = ui.Button(ui.a.TopRight(), "x", {
        id=baseId .. ".closeItemsButton", fillColor=colors.red, border=0
    })
    closeItemsButton:addActivateHandler(function()
        mainFrame:setActive(wrapper.output, 1)
    end)
    itemsFrame:add(closeItemsButton)

    --- item list
    local itemsListFrame = ui.Frame(ui.a.Anchor(1, 2), {
        id=baseId .. ".itemsListFrame",
        fillHorizontal=true,
        border=0,
        padLeft=1,
        padTop=1,
        fillColor=colors.lightGray,
        textColor=colors.black,
        scrollBar=true,
        height=height
    })
    itemsListFrame:add(ui.Text(ui.a.TopLeft(), {}, {id=baseId .. ".itemListText"}))

    itemsFrame:add(itemsListFrame)
    itemsFrame:setVisible(false)
end

function QuarryWrapper:createUI()
    local baseId = self:getBaseId()

    local startY = 2
    local nameText = ui.Text(ui.a.Top(), "", {id=baseId .. ".nameText"})
    local _, height = self.output.getSize()
    if height <= 12 then
        startY = 1
        nameText.visible = false
    end

    if _G.RUN_PROGRESS and ui.h.isTerm(self.output) then
        local closeButton = ui.Button(ui.a.TopRight(), "x", {id=baseId .. ".closeButton", fillColor=colors.red, border=0})
        closeButton:addActivateHandler(function()
            _G.RUN_PROGRESS = false
        end)
        self.frame:add(closeButton)
    end

    self.frame:add(nameText)
    self.frame:add(ui.Text(ui.a.Center(startY), "", {id=baseId .. ".titleText"}))
    local mainFrame = ui.TabbedFrame(ui.a.Anchor(1, startY + 1), {
        id=baseId .. ".mainFrame",
        fillHorizontal=true,
        fillVertical=true,
        border=0,
        fillColor=colors.black,
        textColor=colors.white,
        primaryTabId="progress"
    })
    self:createProgressFrame(mainFrame)
    self:createItemsFrame(mainFrame, height - startY)
    mainFrame:setActive(self.output, 1)

    self.frame:add(mainFrame)
    QuarryWrapper.super.createUI(self)
end

---@param event am.e.QuarryProgressEvent
function QuarryWrapper:update(event)
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
    if self.progress.job.left ~= nil and self.progress.job.forward ~= nil then
        extra = string.format(": %d x %d (%d)", self.progress.job.left, self.progress.job.forward, self.progress.job.levels)
    end
    titleText:update(string.format("Quarry%s", extra))


    local mainFrame = self.frame:get(baseId .. ".mainFrame", self.output)
    ---@cast mainFrame am.ui.BoundTabbedFrame

    -- progress tab
    local progressFrame = mainFrame:getTab(1)
    ---@cast progressFrame am.ui.BoundFrame

    local totalBar = progressFrame:get(baseId .. ".totalBar")
    ---@cast totalBar am.ui.BoundProgressBar
    local levelBar = progressFrame:get(baseId .. ".levelBar")
    ---@cast levelBar am.ui.BoundProgressBar
    local statusText = progressFrame:get(baseId .. ".statusText")
    ---@cast statusText am.ui.BoundText
    local posText = progressFrame:get(baseId .. ".posText")
    ---@cast posText am.ui.BoundText

    totalBar.obj.displayTotal = self.progress.job.levels
    totalBar:update(self.progress.progress.current * 100)
    if self.progress.progress.hitBedrock then
        totalBar:updateLabel("Total (Bedrock)")
    else
        totalBar:updateLabel("Total")
    end
    if self.progress.job.left ~= nil then
        levelBar.obj.total = self.progress.job.left
    end
    levelBar:update(self.progress.progress.completedRows)
    statusText:update(self.progress.progress.status)
    local posFmt = "pos (%d, %d) e: %d, d: %d"
    if width < 30 then
        posFmt = "(%d,%d) e:%d, d:%d"
    end
    posText:update(string.format(
        posFmt, self.progress.pos.v.x, self.progress.pos.v.z, self.progress.pos.v.y, self.progress.pos.dir
    ))
    progressFrame.obj.anchor.y = startY + 1

    -- items tab
    local itemsFrame = mainFrame:getTab(2)
    ---@cast itemsFrame am.ui.BoundFrame
    itemsFrame.obj.anchor.y = startY + 1

    local itemsListFrame = itemsFrame:get(baseId .. ".itemsListFrame")
    ---@cast itemsListFrame am.ui.BoundFrame
    local listText = itemsFrame:get(baseId .. ".itemListText")
    ---@cast listText am.ui.BoundText

    local minListHeight = height - startY
    local items = h.itemStrings(self.progress.progress.items)
    itemsListFrame.obj.height = math.max(minListHeight, #items + 2)
    listText:update(items)
end

---@param status string
function QuarryWrapper:updateStatus(status)
    local baseId = self:getBaseId()
    local statusText = self.frame:get(baseId .. ".statusText", self.output)
    ---@cast statusText am.ui.BoundText

    statusText:update(status)
end

---@param event string Event name
---@param args table
function QuarryWrapper:handle(event, args)
    local baseId = self:getBaseId()
    if event == e.c.Event.Progress.quarry then
        self:update(args[1])
    else
        local mainFrame = self.frame:get(baseId .. ".mainFrame", self.output)
        ---@cast mainFrame am.ui.BoundTabbedFrame
        local progressActive = mainFrame.obj.active == 1
        local progressFrame = mainFrame:getTab(1)
        ---@cast progressFrame am.ui.BoundFrame
        local haltButton = progressFrame:get(baseId .. ".haltButton")
        ---@cast haltButton am.ui.BoundButton
        local pauseButton = progressFrame:get(baseId .. ".pauseButton")
        ---@cast pauseButton am.ui.BoundButton

        if event == e.c.Event.Turtle.paused then
            self.paused = true
            self.completed = false
            pauseButton.obj.fillColor = colors.green
            pauseButton:updateLabel("\x10")
            if progressActive then
                mainFrame:render()
            end
        elseif event == e.c.Event.Turtle.started then
            self.paused = false
            self.completed = false

            haltButton.obj.visible = progressActive and true or false
            haltButton:updateLabel("\x8f")
            pauseButton.obj.visible = progressActive and true or false
            pauseButton.obj.fillColor = colors.yellow
            pauseButton:updateLabel("\x95\x95")
            if progressActive then
                mainFrame:render()
            end
        elseif event == e.c.Event.Turtle.exited then
            self.completed = true
            self.paused = false
            haltButton.obj.visible = false
            pauseButton.obj.visible = false
            if progressActive then
                mainFrame:render()
            end
        else
            self.frame:handle(self.output, {event, table.unpack(args)})
        end
    end
end

return QuarryWrapper
