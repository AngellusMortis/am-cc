local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local BaseObject = require("am.ui.base").BaseObject

local ui = require("am.ui")
local e = require("am.event")
local log = require("am.log")
local h = require("am.progress.helpers")

local ProgressWrapper = require("am.progress.base")

---@class am.progress.QuarryWrapper:am.progress.ProgressWrapper
---@field progress am.e.QuarryProgressEvent
local QuarryWrapper = ProgressWrapper:extend("am.progress.QuarryWrapper")
function QuarryWrapper:init(src, progress, output)
    QuarryWrapper.super.init(self, src, progress, output)

    self.paused = false
    return self
end

function QuarryWrapper:createUI()
    local wrapper = self

    local baseId = self.screen.id

    local startY = 2
    local nameText = ui.Text(ui.a.Top(), "", {id=baseId .. ".nameText"})
    local width, height = self.screen.output.getSize()
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
    local progressFrame = ui.Frame(ui.a.Anchor(1, startY + 1), {
        id=baseId .. ".progressFrame",
        fillHorizontal=true,
        fillVertical=true,
        border=0,
        fillColor=colors.black,
        textColor=colors.white
    })
    self.screen:add(progressFrame)
    progressFrame:add(ui.ProgressBar(ui.a.TopLeft(), {
        id=baseId .. ".totalBar", label="Total", displayTotal=self.progress.job.levels, fillColor=colors.lightGray
    }))
    progressFrame:add(ui.ProgressBar(ui.a.Left(4), {
        id=baseId .. ".levelBar", label="Level", total=1, fillColor=colors.lightGray
    }))
    progressFrame:add(ui.Text(ui.a.Center(7), "", {id=baseId .. ".statusText"}))

    local offsetHalt = 2
    local offsetPause = 2
    if width % 2 == 0 then
        offsetHalt = 3
        offsetPause = 1
    end

    local haltButton = ui.Button(ui.a.Center(8, ui.c.Offset.Left, offsetHalt), "\x8f", {
        id=baseId .. ".haltButton", fillColor=colors.red
    })
    haltButton:addActivateHandler(function()
        log.info(string.format("Halting %s...", self.src.label))
        e.TurtleRequestHaltEvent(self.src.id):send()
    end)

    local pauseButton = ui.Button(ui.a.Center(8, ui.c.Offset.Right, offsetPause), "\x95\x95", {
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

    progressFrame:add(haltButton)
    progressFrame:add(pauseButton)
    progressFrame:add(ui.Text(ui.a.Bottom(), "", {id=baseId .. ".posText"}))

    local itemsFrame = ui.Frame(ui.a.Anchor(1, startY + 1), {
        id=baseId .. ".itemsFrame",
        fillHorizontal=true,
        fillVertical=true,
        border=0,
        fillColor=colors.black,
        textColor=colors.white
    })

    itemsFrame:add(ui.Text(ui.a.TopLeft(), "Mined Items", {id=baseId .. ".itemsTitle"}))
    local closeItemsButton = ui.Button(ui.a.TopRight(), "x", {
        id=baseId .. ".closeItemsButton", fillColor=colors.red, border=0
    })
    closeItemsButton:addActivateHandler(function()
        progressFrame:setVisible(true)
        itemsFrame:setVisible(false)
        wrapper.screen:render()
    end)
    itemsFrame:add(closeItemsButton)

    local itemsListFrame = ui.Frame(ui.a.Anchor(1, 2), {
        id=baseId .. ".itemsListFrame",
        fillHorizontal=true,
        border=0,
        padLeft=1,
        padTop=1,
        fillColor=colors.lightGray,
        textColor=colors.black,
        scrollBar=true,
        height=height - startY
    })
    itemsListFrame:add(ui.Text(ui.a.TopLeft(), {}, {id=baseId .. ".itemListText"}))

    itemsFrame:add(itemsListFrame)
    itemsFrame:setVisible(false)
    self.screen:add(itemsFrame)


    local itemsButton = ui.Button(ui.a.Center(8), "\x17", {
        id=baseId .. ".itemsButton", fillColor=colors.blue
    })
    itemsButton:addActivateHandler(function()
        itemsListFrame.currentScroll = 0
        progressFrame:setVisible(false)
        itemsFrame:setVisible(true)
        wrapper.screen:render()
    end)
    progressFrame:add(itemsButton)

    QuarryWrapper.super.createUI(self)
end

---@param event am.e.QuarryProgressEvent
function QuarryWrapper:update(event)
    local width, height = self.screen.output.getSize()

    local baseId = self.screen.id
    self.progress = event
    local progressFrame = self.screen:get(baseId .. ".progressFrame")
    ---@cast progressFrame am.ui.BoundFrame
    local itemsListFrame = self.screen:get(baseId .. ".itemsListFrame")
    ---@cast itemsListFrame am.ui.BoundFrame
    local nameText = self.screen:get(baseId .. ".nameText")
    ---@cast nameText am.ui.BoundText
    local titleText = self.screen:get(baseId .. ".titleText")
    ---@cast titleText am.ui.BoundText
    local totalBar = progressFrame:get(baseId .. ".totalBar")
    ---@cast totalBar am.ui.BoundProgressBar
    local levelBar = progressFrame:get(baseId .. ".levelBar")
    ---@cast levelBar am.ui.BoundProgressBar
    local statusText = progressFrame:get(baseId .. ".statusText")
    ---@cast statusText am.ui.BoundText
    local posText = progressFrame:get(baseId .. ".posText")
    ---@cast posText am.ui.BoundText
    local listText = itemsListFrame:get(baseId .. ".itemListText")
    ---@cast listText am.ui.BoundText

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
    titleText.obj.anchor.y = startY
    progressFrame.obj.anchor.y = startY + 1
    local minListHeight = height - startY
    local items = h.itemStrings(self.progress.progress.items)
    itemsListFrame.obj.height = math.max(minListHeight, #items + 2)
    listText:update(items)

    local extra = ""
    if self.progress.job.left ~= nil and self.progress.job.forward ~= nil then
        extra = string.format(": %d x %d (%d)", self.progress.job.left, self.progress.job.forward, self.progress.job.levels)
    end

    titleText:update(string.format("Quarry%s", extra))
    totalBar.obj.displayTotal = self.progress.job.levels
    totalBar:update(self.progress.progress.current * 100)
    if self.progress.progress.hitBedrock then
        totalBar:updateLabel("Total (Bedrock)")
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


    local itemsFrame = self.screen:get(baseId .. ".itemsFrame")
    ---@cast itemsFrame am.ui.BoundFrame
    itemsFrame.obj.anchor.y = startY + 1
end

---@param status string
function QuarryWrapper:updateStatus(status)
    local baseId = self.screen.id
    local statusText = self.screen:get(baseId .. ".statusText")
    ---@cast statusText am.ui.BoundText

    statusText:update(status)
end

---@param event string Event name
---@param args table
function QuarryWrapper:handle(event, args)
    local baseId = self.screen.id
    if event == e.c.Event.Progress.quarry then
        self:update(args[1])
    elseif event == e.c.Event.Turtle.paused then
        self.paused = true
        local pauseButton = self.screen:get(baseId .. ".pauseButton")
        ---@cast pauseButton am.ui.BoundButton
        pauseButton.obj.fillColor = colors.green
        pauseButton:updateLabel("\x10")
        self.screen:render()
    elseif event == e.c.Event.Turtle.started then
        self.paused = false
        local progressFrame = self.screen:get(baseId .. ".progressFrame")
        ---@cast progressFrame am.ui.BoundFrame
        local haltButton = progressFrame:get(baseId .. ".haltButton")
        ---@cast haltButton am.ui.BoundButton
        local pauseButton = progressFrame:get(baseId .. ".pauseButton")
        ---@cast pauseButton am.ui.BoundButton

        haltButton.obj.visible = progressFrame.obj.visible
        haltButton:updateLabel("\x8f")
        pauseButton.obj.visible = progressFrame.obj.visible
        pauseButton.obj.fillColor = colors.yellow
        pauseButton:updateLabel("\x95\x95")
        self.screen:render()
    elseif event == e.c.Event.Turtle.exited then
        local haltButton = self.screen:get(baseId .. ".haltButton")
        ---@cast haltButton am.ui.BoundButton
        local pauseButton = self.screen:get(baseId .. ".pauseButton")
        ---@cast pauseButton am.ui.BoundButton

        haltButton.obj.visible = false
        pauseButton.obj.visible = false
        self.screen:render()
    else
        self.screen:handle({event, table.unpack(args)})
    end
end
