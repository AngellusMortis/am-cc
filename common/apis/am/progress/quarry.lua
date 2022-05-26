local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local e = require("am.event")
local h = require("am.progress.helpers")
local log = require("am.log")
local ui = require("am.ui")

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
    self.needsUpdate = {
        progress = true,
        items = true,
    }
    return self
end

---@param mainFrame am.ui.TabbedFrame
function QuarryWrapper:createProgressFrame(mainFrame)
    local wrapper = self
    local progressFrame = mainFrame:getTab("progress")
    ---@cast progressFrame am.ui.Frame
    local baseId = self:getBaseId()

    --- items button
    local itemsButton = ui.Button(ui.a.Center(8), "\x17", {
        id=baseId .. ".itemsButton", fillColor=colors.blue
    })
    itemsButton:addActivateHandler(function()
        local _, height = wrapper.output.getSize()
        local startY = height <= 12 and 1 or 2
        wrapper:updateItemsTab(mainFrame:bind(wrapper.output), height - startY)
        mainFrame:setActive(wrapper.output, "items")
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
        wrapper:updateProgressTab(mainFrame:bind(wrapper.output))
        mainFrame:setActive(wrapper.output, "progress")
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

    if _G.PROGRESS_SHOW_CLOSE then
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
    mainFrame:setActive(self.output, "progress")

    self.frame:add(mainFrame)
    QuarryWrapper.super.createUI(self)
end

---@param tabs am.ui.BoundTabbedFrame
function QuarryWrapper:updateProgressTab(tabs)
    if not self.needsUpdate.progress then
        return
    end

    local baseId = self:getBaseId()
    local progressFrame = tabs:getTab("progress")
    ---@cast progressFrame am.ui.BoundFrame

    local totalBar = progressFrame:get(baseId .. ".totalBar")
    ---@cast totalBar am.ui.BoundProgressBar
    local levelBar = progressFrame:get(baseId .. ".levelBar")
    ---@cast levelBar am.ui.BoundProgressBar
    local statusText = progressFrame:get(baseId .. ".statusText")
    ---@cast statusText am.ui.BoundText

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
    self:updatePosition(self.src, self.progress.pos)

    self.needsUpdate.progress = false
end

---@param tabs am.ui.BoundTabbedFrame
---@param minListHeight number
function QuarryWrapper:updateItemsTab(tabs, minListHeight)
    if not self.needsUpdate.items then
        return
    end

    local baseId = self:getBaseId()
    local itemsFrame = tabs:getTab("items")
    ---@cast itemsFrame am.ui.BoundFrame

    local itemsListFrame = itemsFrame:get(baseId .. ".itemsListFrame")
    ---@cast itemsListFrame am.ui.BoundFrame
    local listText = itemsFrame:get(baseId .. ".itemListText")
    ---@cast listText am.ui.BoundText

    local items = h.itemStrings(self.progress.progress.items)
    itemsListFrame.obj.height = math.max(minListHeight, #items + 2)
    listText:update(items)

    self.needsUpdate.items = false
end

---@param src am.net.src
---@param event? am.e.ColoniesEvent
---@param force? boolean
function QuarryWrapper:update(src, event, force)
    if event ~= nil then
        self.progress = event
        self.needsUpdate = {
            progress = true,
            items = true,
        }
    end

    if not self.frame.visible and not force then
        return
    end

    local _, height = self.output.getSize()
    local baseId = self:getBaseId()

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


    local tabs = self.frame:get(baseId .. ".mainFrame", self.output)
    ---@cast tabs am.ui.BoundTabbedFrame
    tabs.obj.anchor.y = startY + 1

    local activeTabId = tabs.obj.tabIndexIdMap[tabs.obj.active]
    if activeTabId == "progress" then
        self:updateProgressTab(tabs)
    elseif activeTabId == "items" then
        self:updateItemsTab(tabs, height - startY)
    end
end

---@param src am.net.src
---@param pos am.p.TurtlePosition
function ProgressWrapper:updatePosition(src, pos)
    self.progress.pos = pos

    local width, _ = self.output.getSize()
    local baseId = self:getBaseId()
    local posText = self.frame:get(baseId .. ".posText", self.output)
    ---@cast posText am.ui.BoundText

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
function QuarryWrapper:updateStatus(src, status)
    self.progress.progress.status = status
    local baseId = self:getBaseId()
    local statusText = self.frame:get(baseId .. ".statusText", self.output)
    ---@cast statusText am.ui.BoundText

    statusText:update(status)
end

---@param src am.net.src
---@param event string Event name
---@param args table
function QuarryWrapper:handle(src, event, args)
    local baseId = self:getBaseId()
    if event == e.c.Event.Progress.quarry then
        self:update(src, args[1])
    else
        local mainFrame = self.frame:get(baseId .. ".mainFrame", self.output)
        ---@cast mainFrame am.ui.BoundTabbedFrame
        local progressActive = mainFrame.obj.active == 1
        local progressFrame = mainFrame:getTab("progress")
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
