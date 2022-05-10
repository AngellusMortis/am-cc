local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local BaseObject = require("am.ui.base").BaseObject
local ui = require("am.ui")

local e = require("am.event")

local ProgressWrapper = require("am.progress.base")

---@class am.progress.ColonyProgress:am.ui.b.BaseObject
---@field id number
---@field status cc.colony|nil
local ColonyProgress = BaseObject:extend("am.progress.ColonyProgress")
function ColonyProgress:init(id)
    ColonyProgress.super.init(self)

    self.id = id
    self.status = nil
    return self
end

---@class am.progress.ColoniesWrapper:am.progress.ProgressWrapper
---@field progress am.progress.ColonyProgress
local ColoniesWrapper = ProgressWrapper:extend("am.progress.QuarryWrapper")
function ColoniesWrapper:init(src, id, output)
    ColoniesWrapper.super.init(self, src, ColonyProgress(id), output)
    self.names = {
        [e.c.Event.Colonies.status_poll] = true,
    }
    return self
end

function ColoniesWrapper:createUI()
    local baseId = self.screen.id
    self.screen:add(ui.Text(ui.a.Top(), "", {id=baseId .. ".titleText"}))

    local tabs = ui.TabbedFrame(ui.a.Anchor(1, 3), {
        id=baseId .. ".tabsBase",
        fillColor=colors.black,
        border=0,
        fillVertical=true,
        fillHorizontal=true
    })

    local mainTab = tabs.tabs[1]
    local rightOffset = 2
    local rowOffset = 1
    mainTab:add(ui.Text(ui.a.Left(rowOffset), "Raid"))
    mainTab:add(ui.Text(ui.a.Right(rowOffset, rightOffset), "", {id=baseId .. ".raid"}))
    rowOffset = rowOffset + 1

    mainTab:add(ui.Text(ui.a.Left(rowOffset), "Happiness"))
    mainTab:add(ui.Text(ui.a.Right(rowOffset, rightOffset), "", {id=baseId .. ".happiness"}))
    rowOffset = rowOffset + 1

    mainTab:add(ui.Text(ui.a.Left(rowOffset), "Citizens"))
    mainTab:add(ui.Text(ui.a.Right(rowOffset, rightOffset), "/", {id=baseId .. ".citizens"}))
    rowOffset = rowOffset + 1

    mainTab:add(ui.Text(ui.a.Left(rowOffset), "Graves"))
    mainTab:add(ui.Text(ui.a.Right(rowOffset, rightOffset), "", {id=baseId .. ".graves"}))
    rowOffset = rowOffset + 1

    mainTab:add(ui.Text(ui.a.Left(rowOffset), "Contructions"))
    mainTab:add(ui.Text(ui.a.Right(rowOffset, rightOffset), "", {id=baseId .. ".contructions"}))
    rowOffset = rowOffset + 1

    mainTab:add(ui.Text(ui.a.Left(rowOffset), "Requests"))
    mainTab:add(ui.Text(ui.a.Right(rowOffset, rightOffset), "", {id=baseId .. ".requests"}))
    rowOffset = rowOffset + 1

    mainTab:add(ui.Text(ui.a.Left(rowOffset), "Buildings"))
    mainTab:add(ui.Text(ui.a.Right(rowOffset, rightOffset), "", {id=baseId .. ".buildings"}))
    rowOffset = rowOffset + 1

    mainTab:add(ui.Text(ui.a.Left(rowOffset), "Visitors"))
    mainTab:add(ui.Text(ui.a.Right(rowOffset, rightOffset), "", {id=baseId .. ".visitors"}))
    rowOffset = rowOffset + 1

    mainTab:add(ui.Text(ui.a.Left(rowOffset), "Players"))
    mainTab:add(ui.Text(ui.a.Right(rowOffset, rightOffset), "", {id=baseId .. ".players"}))

    self.screen:add(tabs)
    ColoniesWrapper.super.createUI(self)
end

---@param event am.e.ColoniesEvent
function ColoniesWrapper:update(event)
    if event.name == e.c.Event.Colonies.status_poll then
        ---@cast event am.e.ColoniesScanEvent
        self.progress.status = event.status
    end

    local status = self.progress.status
    ---@cast status cc.colony
    local baseId = self.screen.id
    local titleText = self.screen:get(baseId .. ".titleText")
    ---@cast titleText am.ui.BoundText

    titleText:update(status.name)

    local tabs = self.screen:get(baseId .. ".tabsBase")
    ---@cast tabs am.ui.BoundTabbedFrame

    local mainTab = tabs:getTab(1)
    ---@cast mainTab am.ui.BoundFrame

    local raidStatus = mainTab:get(baseId .. ".raid")
    ---@cast raidStatus am.ui.BoundText
    if status.raid then
        raidStatus.obj.textColor = colors.red
        raidStatus:update("Yes")
    else
        raidStatus.obj.textColor = colors.green
        raidStatus:update("No")
    end

    local happiness = mainTab:get(baseId .. ".happiness")
    ---@cast happiness am.ui.BoundText
    if status.happiness < 5 then
        happiness.obj.textColor = colors.red
    elseif status.happiness < 8 then
        happiness.obj.textColor = colors.yellow
    else
        happiness.obj.textColor = colors.green
    end
    happiness:update(string.format("%d/10", self.progress.status.happiness))


    local citizens = mainTab:get(baseId .. ".citizens")
    ---@cast citizens am.ui.BoundText
    local tavernPeople = status.tavernCount * 4
    local maxHoused = status.maxCitizens - tavernPeople
    if status.citizenCount == maxHoused then
        citizens.obj.textColor = colors.green
    elseif status.citizenCount > status.maxCitizens then
        citizens.obj.textColor = colors.red
    else
        citizens.obj.textColor = colors.yellow
    end
    citizens:update(string.format("%d/%d", status.citizenCount, status.maxCitizens))

    local graves = mainTab:get(baseId .. ".graves")
    ---@cast graves am.ui.BoundText
    if status.graves > 0 then
        graves.obj.textColor = colors.red
    else
        graves.obj.textColor = colors.green
    end
    graves:update(tostring(status.graves))

    local contructions = mainTab:get(baseId .. ".contructions")
    ---@cast contructions am.ui.BoundText
    contructions:update(tostring(status.constructionCount))

    local requests = mainTab:get(baseId .. ".requests")
    ---@cast requests am.ui.BoundText
    if #status.requests > 0 then
        requests.obj.textColor = colors.yellow
    else
        requests.obj.textColor = colors.green
    end
    requests:update(tostring(#status.requests))

    local buildings = mainTab:get(baseId .. ".buildings")
    ---@cast buildings am.ui.BoundText
    buildings:update(tostring(#status.buildings))

    local visitors = mainTab:get(baseId .. ".visitors")
    ---@cast visitors am.ui.BoundText
    visitors:update(tostring(status.visitorCount))

    local players = mainTab:get(baseId .. ".players")
    ---@cast players am.ui.BoundText
    players:update(tostring(#status.players))
end

---@param status string
function ColoniesWrapper:updateStatus(status)

end

---@param event string Event name
---@param args table
function ColoniesWrapper:handle(event, args)
    self.screen:handle({event, table.unpack(args)})
end

return ColoniesWrapper
