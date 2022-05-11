local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local BaseObject = require("am.ui.base").BaseObject
local ui = require("am.ui")

local e = require("am.event")
local log = require("am.log")

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

---@param tabs am.ui.BoundTabbedFrame
function ColoniesWrapper:createMainTab(tabs)
    local baseId = self.screen.id
    local tab = tabs:getTab(1)
    local rightOffset = 3
    local rowOffset = 1
    tab:add(ui.Text(ui.a.Left(rowOffset), "Raid"))
    tab:add(ui.Text(ui.a.Right(rowOffset, rightOffset), "", {id=baseId .. ".raid"}))
    rowOffset = rowOffset + 1

    tab:add(ui.Text(ui.a.Left(rowOffset), "Happiness"))
    tab:add(ui.Text(ui.a.Right(rowOffset, rightOffset), "", {id=baseId .. ".happiness"}))
    rowOffset = rowOffset + 1

    tab:add(ui.Text(ui.a.Left(rowOffset), "Citizens"))
    tab:add(ui.Text(ui.a.Right(rowOffset, rightOffset), "/", {id=baseId .. ".citizens"}))
    local citizensTabButton = ui.Button(ui.a.Right(rowOffset), "\x17", {
        id=baseId .. ".citizenTabButton",
        fillColor=colors.blue,
        textColor=colors.white,
        border=0
    })
    citizensTabButton:addActivateHandler(function()
        tabs:setActive(2)
    end)
    tab:add(citizensTabButton)
    rowOffset = rowOffset + 1

    tab:add(ui.Text(ui.a.Left(rowOffset), "Graves"))
    tab:add(ui.Text(ui.a.Right(rowOffset, rightOffset), "", {id=baseId .. ".graves"}))
    rowOffset = rowOffset + 1

    tab:add(ui.Text(ui.a.Left(rowOffset), "Contructions"))
    tab:add(ui.Text(ui.a.Right(rowOffset, rightOffset), "", {id=baseId .. ".contructions"}))
    rowOffset = rowOffset + 1

    tab:add(ui.Text(ui.a.Left(rowOffset), "Requests"))
    local requestsTabButton = ui.Button(ui.a.Right(rowOffset), "\x17", {
        id=baseId .. ".requestsTabButton",
        fillColor=colors.blue,
        textColor=colors.white,
        border=0
    })
    requestsTabButton:addActivateHandler(function()
        tabs:setActive(3)
    end)
    tab:add(requestsTabButton)
    tab:add(ui.Text(ui.a.Right(rowOffset, rightOffset), "", {id=baseId .. ".requests"}))
    rowOffset = rowOffset + 1

    tab:add(ui.Text(ui.a.Left(rowOffset), "Buildings"))
    tab:add(ui.Text(ui.a.Right(rowOffset, rightOffset), "", {id=baseId .. ".buildings"}))
    local buildingsTabButton = ui.Button(ui.a.Right(rowOffset), "\x17", {
        id=baseId .. ".buildingsTabButton",
        fillColor=colors.red,
        textColor=colors.white,
        border=0
    })
    buildingsTabButton:addActivateHandler(function()
        tabs:setActive(4)
    end)
    tab:add(buildingsTabButton)
    rowOffset = rowOffset + 1

    tab:add(ui.Text(ui.a.Left(rowOffset), "Visitors"))
    tab:add(ui.Text(ui.a.Right(rowOffset, rightOffset), "", {id=baseId .. ".visitors"}))
    local visitorsTabButton = ui.Button(ui.a.Right(rowOffset), "\x17", {
        id=baseId .. ".visitorsTabButton",
        fillColor=colors.green,
        textColor=colors.white,
        border=0
    })
    visitorsTabButton:addActivateHandler(function()
        tabs:setActive(5)
    end)
    tab:add(visitorsTabButton)
    rowOffset = rowOffset + 1

    tab:add(ui.Text(ui.a.Left(rowOffset), "Players"))
    local playersTabButton = ui.Button(ui.a.Right(rowOffset), "\x17", {
        id=baseId .. ".playersTabButton",
        fillColor=colors.blue,
        textColor=colors.white,
        border=0
    })
    playersTabButton:addActivateHandler(function()
        tabs:setActive(6)
    end)
    tab:add(playersTabButton)
    tab:add(ui.Text(ui.a.Right(rowOffset, rightOffset), "", {id=baseId .. ".players"}))
end

---@param tabs am.ui.BoundTabbedFrame
---@param height number
function ColoniesWrapper:createCitizensTab(tabs, height)
    local baseId = self.screen.id
    local tab = tabs:createTab("citizens")
    tab:add(ui.Text(ui.a.TopLeft(), "Citizens"))
    local closeButton = ui.Button(ui.a.TopRight(), "x", {id=baseId .. ".citizenCloseButton", fillColor=colors.red, border=0})
    closeButton:addActivateHandler(function()
        tabs:setActive(1)
    end)
    tab:add(closeButton)
    local citizenListFrame = ui.Frame(ui.a.Anchor(1, 2), {
        id=baseId .. ".citizenListFrame",
        fillColor=colors.lightGray,
        textColor=colors.black,
        fillHorizontal=true,
        scrollBar=true,
        height=height-1,
        border=0,
        padTop=1,
        padLeft=1,
    })
    citizenListFrame:add(ui.Text(ui.a.TopLeft(), "", {id=baseId .. ".citizenList"}))
    tab:add(citizenListFrame)
end

---@param tabs am.ui.BoundTabbedFrame
---@param height number
function ColoniesWrapper:createRequestsTab(tabs, height)
    local baseId = self.screen.id
    local tab = tabs:createTab("requests")
    tab:add(ui.Text(ui.a.TopLeft(), "Requests"))
    local closeButton = ui.Button(ui.a.TopRight(), "x", {id=baseId .. ".requestCloseButton", fillColor=colors.red, border=0})
    closeButton:addActivateHandler(function()
        tabs:setActive(1)
    end)
    tab:add(closeButton)
    local requestListFrame = ui.Frame(ui.a.Anchor(1, 2), {
        id=baseId .. ".requestListFrame",
        fillColor=colors.lightGray,
        textColor=colors.black,
        fillHorizontal=true,
        scrollBar=true,
        height=height-1,
        border=0,
        padTop=1,
        padLeft=1,
    })
    requestListFrame:add(ui.Text(ui.a.TopLeft(), "", {id=baseId .. ".requestList"}))
    tab:add(requestListFrame)
end

---@param tabs am.ui.BoundTabbedFrame
---@param height number
function ColoniesWrapper:createBuildingsTab(tabs, height)
    local baseId = self.screen.id
    local tab = tabs:createTab("buildings")
    tab:add(ui.Text(ui.a.TopLeft(), "Buildings"))
    local closeButton = ui.Button(ui.a.TopRight(), "x", {id=baseId .. ".buildingCloseButton", fillColor=colors.red, border=0})
    closeButton:addActivateHandler(function()
        tabs:setActive(1)
    end)
    tab:add(closeButton)
    local buildingListFrame = ui.Frame(ui.a.Anchor(1, 2), {
        id=baseId .. ".buildingListFrame",
        fillColor=colors.lightGray,
        textColor=colors.black,
        fillHorizontal=true,
        scrollBar=true,
        height=height-1,
        border=0,
        padTop=1,
        padLeft=1,
    })
    buildingListFrame:add(ui.Text(ui.a.TopLeft(), "", {id=baseId .. ".buildingList"}))
    tab:add(buildingListFrame)
end

---@param tabs am.ui.BoundTabbedFrame
---@param height number
function ColoniesWrapper:createVisitorsTab(tabs, height)
    local baseId = self.screen.id
    local tab = tabs:createTab("visitors")
    tab:add(ui.Text(ui.a.TopLeft(), "Visitors"))
    local closeButton = ui.Button(ui.a.TopRight(), "x", {id=baseId .. ".visitorCloseButton", fillColor=colors.red, border=0})
    closeButton:addActivateHandler(function()
        tabs:setActive(1)
    end)
    tab:add(closeButton)
    local visitorListFrame = ui.Frame(ui.a.Anchor(1, 2), {
        id=baseId .. ".visitorListFrame",
        fillColor=colors.lightGray,
        textColor=colors.black,
        fillHorizontal=true,
        scrollBar=true,
        height=height-1,
        border=0,
        padTop=1,
        padLeft=1,
    })
    visitorListFrame:add(ui.Text(ui.a.TopLeft(), "", {id=baseId .. ".visitorList"}))
    tab:add(visitorListFrame)
end

---@param tabs am.ui.BoundTabbedFrame
---@param height number
function ColoniesWrapper:createPlayersTab(tabs, height)
    local baseId = self.screen.id
    local tab = tabs:createTab("players")
    tab:add(ui.Text(ui.a.TopLeft(), "Players"))
    local closeButton = ui.Button(ui.a.TopRight(), "x", {id=baseId .. ".playerCloseButton", fillColor=colors.red, border=0})
    closeButton:addActivateHandler(function()
        tabs:setActive(1)
    end)
    tab:add(closeButton)
    local playerListFrame = ui.Frame(ui.a.Anchor(1, 2), {
        id=baseId .. ".playerListFrame",
        fillColor=colors.lightGray,
        textColor=colors.black,
        fillHorizontal=true,
        scrollBar=true,
        height=height-1,
        border=0,
        padTop=1,
        padLeft=1,
    })
    playerListFrame:add(ui.Text(ui.a.TopLeft(), "", {id=baseId .. ".playerList"}))
    tab:add(playerListFrame)
end

function ColoniesWrapper:createUI()
    local baseId = self.screen.id
    local _, height = self.screen.output.getSize()
    local tabHeight = height - 2

    self.screen:add(ui.Text(ui.a.Top(), "", {id=baseId .. ".titleText"}))

    if _G.RUN_PROGRESS and ui.h.isTerm(self.screen.output) then
        local closeButton = ui.Button(ui.a.TopRight(), "x", {id=baseId .. ".closeButton", fillColor=colors.red, border=0})
        closeButton:addActivateHandler(function()
            _G.RUN_PROGRESS = false
        end)
        self.screen:add(closeButton)
    end

    local tabs = ui.TabbedFrame(ui.a.Anchor(1, 3), {
        id=baseId .. ".tabsBase",
        fillColor=colors.black,
        textColor=colors.white,
        border=0,
        fillVertical=true,
        fillHorizontal=true
    })
    local boundTabs = tabs:bind(self.screen.output)

    self:createMainTab(boundTabs)
    self:createCitizensTab(boundTabs, tabHeight)
    self:createRequestsTab(boundTabs, tabHeight)
    self:createBuildingsTab(boundTabs, tabHeight)
    self:createVisitorsTab(boundTabs, tabHeight)
    self:createPlayersTab(boundTabs, tabHeight)
    boundTabs:setActive(1)

    self.screen:add(tabs)
    ColoniesWrapper.super.createUI(self)
end

---@param tabs am.ui.BoundTabbedFrame
function ColoniesWrapper:updateMainTab(tabs)
    local status = self.progress.status
    ---@cast status cc.colony
    local baseId = self.screen.id

    local tab = tabs:getTab(1)
    ---@cast tab am.ui.BoundFrame

    local raidStatus = tab:get(baseId .. ".raid")
    ---@cast raidStatus am.ui.BoundText
    if status.raid then
        raidStatus.obj.textColor = colors.red
        raidStatus:update("Yes")
    else
        raidStatus.obj.textColor = colors.green
        raidStatus:update("No")
    end

    local happiness = tab:get(baseId .. ".happiness")
    ---@cast happiness am.ui.BoundText
    if status.happiness < 5 then
        happiness.obj.textColor = colors.red
    elseif status.happiness < 8 then
        happiness.obj.textColor = colors.yellow
    else
        happiness.obj.textColor = colors.green
    end
    happiness:update(string.format("%d/10", self.progress.status.happiness))


    local citizens = tab:get(baseId .. ".citizens")
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

    local graves = tab:get(baseId .. ".graves")
    ---@cast graves am.ui.BoundText
    if status.graves > 0 then
        graves.obj.textColor = colors.red
    else
        graves.obj.textColor = colors.green
    end
    graves:update(tostring(status.graves))

    local contructions = tab:get(baseId .. ".contructions")
    ---@cast contructions am.ui.BoundText
    contructions:update(tostring(status.constructionCount))

    local requests = tab:get(baseId .. ".requests")
    ---@cast requests am.ui.BoundText
    if #status.requests > 0 then
        requests.obj.textColor = colors.yellow
    else
        requests.obj.textColor = colors.green
    end
    requests:update(tostring(#status.requests))

    local buildings = tab:get(baseId .. ".buildings")
    ---@cast buildings am.ui.BoundText
    buildings:update(tostring(#status.buildings))

    local visitors = tab:get(baseId .. ".visitors")
    ---@cast visitors am.ui.BoundText
    visitors:update(tostring(status.visitorCount))

    local players = tab:get(baseId .. ".players")
    ---@cast players am.ui.BoundText
    players:update(tostring(#status.players))
end

---@param tabs am.ui.BoundTabbedFrame
---@param height number
function ColoniesWrapper:updateCitizensTab(tabs, height)
    local status = self.progress.status
    ---@cast status cc.colony
    local baseId = self.screen.id

    local tab = tabs:getTab(2)
    ---@cast tab am.ui.BoundFrame

    local citizenListFrame = tab:get(baseId .. ".citizenListFrame")
    ---@cast citizenListFrame am.ui.BoundFrame
    local newHeight = math.max(height - 1, status.citizenCount)
    if citizenListFrame.obj.height ~= newHeight then
        citizenListFrame.obj.height = newHeight
        citizenListFrame:render()
    end

    local citizenList = tab:get(baseId .. ".citizenList")
    ---@cast citizenList am.ui.BoundText
    local citizenText = {}
    for _, citizen in pairs(status.citizens) do
        local job = "Unemployed"
        if citizen.work ~= nil then
            job = string.gsub(citizen.work.type, "^%l", string.upper)
        end
        citizenText[#citizenText + 1] = string.format("%s %s", job, citizen.name)
    end
    table.sort(citizenText)
    citizenList:update(citizenText)
end

---@param tabs am.ui.BoundTabbedFrame
---@param height number
function ColoniesWrapper:updateRequestsTab(tabs, height)
    local status = self.progress.status
    ---@cast status cc.colony
    local baseId = self.screen.id

    local tab = tabs:getTab(3)
    ---@cast tab am.ui.BoundFrame

    local requestListFrame = tab:get(baseId .. ".requestListFrame")
    ---@cast requestListFrame am.ui.BoundFrame
    local newHeight = math.max(height - 1, #status.requests)
    if requestListFrame.obj.height ~= newHeight then
        requestListFrame.obj.height = newHeight
        requestListFrame:render()
    end

    local requestList = tab:get(baseId .. ".requestList")
    ---@cast requestList am.ui.BoundText
    local requestText = {}
    for _, request in pairs(status.requests) do
        requestText[#requestText + 1] = request.desc
    end
    table.sort(requestText)
    requestList:update(requestText)
end

---@param tabs am.ui.BoundTabbedFrame
---@param height number
function ColoniesWrapper:updateBuildingsTab(tabs, height)
    local status = self.progress.status
    ---@cast status cc.colony
    local baseId = self.screen.id

    local tab = tabs:getTab(4)
    ---@cast tab am.ui.BoundFrame

    local buildingListFrame = tab:get(baseId .. ".buildingListFrame")
    ---@cast buildingListFrame am.ui.BoundFrame
    local newHeight = math.max(height - 1, #status.buildings)
    if buildingListFrame.obj.height ~= newHeight then
        buildingListFrame.obj.height = newHeight
        buildingListFrame:render()
    end

    local buildingList = tab:get(baseId .. ".buildingList")
    ---@cast buildingList am.ui.BoundText
    local buildingText = {}
    for _, building in pairs(status.buildings) do
        local buildingType = string.gsub(building.type, "^%l", string.upper)
        buildingText[#buildingText + 1] = string.format("L%d %s", building.level, buildingType)
    end
    table.sort(buildingText)
    buildingList:update(buildingText)
end

---@param tabs am.ui.BoundTabbedFrame
---@param height number
function ColoniesWrapper:updateVisitorsTab(tabs, height)
    local status = self.progress.status
    ---@cast status cc.colony
    local baseId = self.screen.id

    local tab = tabs:getTab(5)
    ---@cast tab am.ui.BoundFrame

    local visitorListFrame = tab:get(baseId .. ".visitorListFrame")
    ---@cast visitorListFrame am.ui.BoundFrame
    local newHeight = math.max(height - 1, status.visitorCount)
    if visitorListFrame.obj.height ~= newHeight then
        visitorListFrame.obj.height = newHeight
        visitorListFrame:render()
    end

    local visitorList = tab:get(baseId .. ".visitorList")
    ---@cast visitorList am.ui.BoundText
    local visitorText = {}
    for _, visitor in pairs(status.visitors) do
        visitorText[#visitorText + 1] = visitor.name
    end
    table.sort(visitorText)
    visitorList:update(visitorText)
end

---@param tabs am.ui.BoundTabbedFrame
---@param height number
function ColoniesWrapper:updatePlayersTab(tabs, height)
    local status = self.progress.status
    ---@cast status cc.colony
    local baseId = self.screen.id

    local tab = tabs:getTab(6)
    ---@cast tab am.ui.BoundFrame

    local playerListFrame = tab:get(baseId .. ".playerListFrame")
    ---@cast playerListFrame am.ui.BoundFrame
    local newHeight = math.max(height - 1, #status.players)
    if playerListFrame.obj.height ~= newHeight then
        playerListFrame.obj.height = newHeight
        playerListFrame:render()
    end

    local playerList = tab:get(baseId .. ".playerList")
    ---@cast playerList am.ui.BoundText
    local playerText = {}
    for _, player in pairs(status.players) do
        playerText[#playerText + 1] = string.format("%s %s", player.rank, player.name)
    end
    table.sort(playerText)
    playerList:update(playerText)
end

---@param event am.e.ColoniesEvent
function ColoniesWrapper:update(event)
    local _, height = self.screen.output.getSize()

    if event.name == e.c.Event.Colonies.status_poll then
        ---@cast event am.e.ColoniesScanEvent
        self.progress.status = event.status
    end

    local titleText = self.screen:get(self.screen.id .. ".titleText")
    ---@cast titleText am.ui.BoundText
    titleText:update(self.progress.status.name)

    local tabs = self.screen:get(self.screen.id .. ".tabsBase")
    ---@cast tabs am.ui.BoundTabbedFrame

    self:updateMainTab(tabs)
    self:updateCitizensTab(tabs, height)
    self:updateRequestsTab(tabs, height)
    self:updateBuildingsTab(tabs, height)
    self:updateVisitorsTab(tabs, height)
    self:updatePlayersTab(tabs, height)
end

---@param event string Event name
---@param args table
function ColoniesWrapper:handle(event, args)
    if event == e.c.Event.Colonies.status_poll then
        self:update(args[1])
    else
        self.screen:handle({event, table.unpack(args)})
    end
end

return ColoniesWrapper
