require(settings.get("ghu.base") .. "core/apis/ghu")

local BaseObject = require("am.ui.base").BaseObject
local ui = require("am.ui")
local h = require("am.progress.helpers")
local core = require("am.core")

local e = require("am.event")

local ProgressWrapper = require("am.progress.base")

---@class am.progress.ColonyProgress:am.ui.b.BaseObject
---@field id number
---@field status cc.colony|nil
---@field warehouse am.e.ColonyWarehousePollEvent|nil
---@field text string
local ColonyProgress = BaseObject:extend("am.progress.ColonyProgress")
function ColonyProgress:init(id)
    ColonyProgress.super.init(self)

    self.id = id
    self.status = nil
    self.warehouse = nil
    self.text = ""
    return self
end

---@class am.progress.ColoniesWrapper:am.progress.ProgressWrapper
---@field progress am.progress.ColonyProgress
local ColoniesWrapper = ProgressWrapper:extend("am.progress.QuarryWrapper")
---@param src am.net.src
---@param id number
---@param output cc.output
---@param frame am.ui.Frame
function ColoniesWrapper:init(src, id, output, frame)
    ColoniesWrapper.super.init(self, src, ColonyProgress(id), output, frame)
    self.names = {
        [e.c.Event.Colonies.status_poll] = true,
        [e.c.Event.Colonies.warehouse_poll] = true,
    }
    self:resetNeedsUpdate()
    return self
end

---@param tabs am.ui.BoundTabbedFrame
function ColoniesWrapper:createMainTab(tabs)
    local wrapper = self
    local baseId = self:getBaseId()
    local tab = tabs:getTab("main").obj
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
        local reRender = false
        if tabs.obj.tabIdMap["citizens"] == nil then
            wrapper:createCitizensTab(tabs)
            reRender = true
        end
        wrapper:updateCitizensTab(tabs)
        tabs:setActive("citizens")
        if reRender then
            wrapper:render()
        end
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
        local reRender = false
        if tabs.obj.tabIdMap["requests"] == nil then
            wrapper:createRequestsTab(tabs)
            reRender = true
        end
        wrapper:updateRequestsTab(tabs)
        tabs:setActive("requests")
        if reRender then
            wrapper:render()
        end
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
        local reRender = false
        if tabs.obj.tabIdMap["buildings"] == nil then
            wrapper:createBuildingsTab(tabs)
            reRender = true
        end
        wrapper:updateBuildingsTab(tabs)
        tabs:setActive("buildings")
        if reRender then
            wrapper:render()
        end
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
        local reRender = false
        if tabs.obj.tabIdMap["visitors"] == nil then
            wrapper:createVisitorsTab(tabs)
            reRender = true
        end
        wrapper:updateVisitorsTab(tabs)
        tabs:setActive("visitors")
        if reRender then
            wrapper:render()
        end
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
        local reRender = false
        if tabs.obj.tabIdMap["players"] == nil then
            wrapper:createPlayersTab(tabs)
            reRender = true
        end
        wrapper:updatePlayersTab(tabs)
        tabs:setActive("players")
        if reRender then
            wrapper:render()
        end
    end)
    tab:add(playersTabButton)
    tab:add(ui.Text(ui.a.Right(rowOffset, rightOffset), "", {id=baseId .. ".players"}))
    rowOffset = rowOffset + 1

    tab:add(ui.Text(ui.a.Left(rowOffset), "Warehouse"))
    local warehouseTabButton = ui.Button(ui.a.Right(rowOffset), "\x17", {
        id=baseId .. ".warehouseTabButton",
        fillColor=colors.red,
        textColor=colors.white,
        border=0
    })
    warehouseTabButton:addActivateHandler(function()
        local reRender = false
        if tabs.obj.tabIdMap["warehouse"] == nil then
            wrapper:createWarehouseTab(tabs)
            reRender = true
        end
        wrapper:updateWarehouseTab(tabs)
        tabs:setActive("warehouse")
        if reRender then
            wrapper:render()
        end
    end)
    tab:add(warehouseTabButton)
    tab:add(ui.Text(ui.a.Right(rowOffset, rightOffset), "", {id=baseId .. ".warehouse"}))
    rowOffset = rowOffset + 1

    tab:add(ui.Text(ui.a.Bottom(), "", {id=baseId .. ".statusText"}))
end

---@param tabs am.ui.BoundTabbedFrame
function ColoniesWrapper:createCitizensTab(tabs)
    local _, height = self.output.getSize()
    local baseId = self:getBaseId()
    local tab = tabs:createTab("citizens")
    tab.fillColor = colors.black
    local wrapper = self

    tab:add(ui.Text(ui.a.TopLeft(), "Citizens"))
    local closeButton = ui.Button(ui.a.TopRight(), "x", {id=baseId .. ".citizenCloseButton", fillColor=colors.red, border=0})
    closeButton:addActivateHandler(function()
        wrapper:updateMainTab(tabs)
        tabs:setActive("main")
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
function ColoniesWrapper:createRequestsTab(tabs)
    local _, height = self.output.getSize()
    local baseId = self:getBaseId()
    local tab = tabs:createTab("requests")
    local wrapper = self

    tab:add(ui.Text(ui.a.TopLeft(), "Requests"))
    local closeButton = ui.Button(ui.a.TopRight(), "x", {id=baseId .. ".requestCloseButton", fillColor=colors.red, border=0})
    closeButton:addActivateHandler(function()
        wrapper:updateMainTab(tabs)
        tabs:setActive("main")
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
function ColoniesWrapper:createBuildingsTab(tabs)
    local _, height = self.output.getSize()
    local baseId = self:getBaseId()
    local tab = tabs:createTab("buildings")
    local wrapper = self

    tab:add(ui.Text(ui.a.TopLeft(), "Buildings"))
    local closeButton = ui.Button(ui.a.TopRight(), "x", {id=baseId .. ".buildingCloseButton", fillColor=colors.red, border=0})
    closeButton:addActivateHandler(function()
        wrapper:updateMainTab(tabs)
        tabs:setActive("main")
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
function ColoniesWrapper:createVisitorsTab(tabs)
    local _, height = self.output.getSize()
    local baseId = self:getBaseId()
    local tab = tabs:createTab("visitors")
    local wrapper = self

    tab:add(ui.Text(ui.a.TopLeft(), "Visitors"))
    local closeButton = ui.Button(ui.a.TopRight(), "x", {id=baseId .. ".visitorCloseButton", fillColor=colors.red, border=0})
    closeButton:addActivateHandler(function()
        wrapper:updateMainTab(tabs)
        tabs:setActive("main")
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
function ColoniesWrapper:createPlayersTab(tabs)
    local _, height = self.output.getSize()
    local baseId = self:getBaseId()
    local tab = tabs:createTab("players")
    local wrapper = self

    tab:add(ui.Text(ui.a.TopLeft(), "Players"))
    local closeButton = ui.Button(ui.a.TopRight(), "x", {id=baseId .. ".playerCloseButton", fillColor=colors.red, border=0})
    closeButton:addActivateHandler(function()
        wrapper:updateMainTab(tabs)
        tabs:setActive("main")
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

---@param tabs am.ui.BoundTabbedFrame
function ColoniesWrapper:createWarehouseTab(tabs)
    local _, height = self.output.getSize()
    local baseId = self:getBaseId()
    local tab = tabs:createTab("warehouse")
    local wrapper = self

    tab:add(ui.Text(ui.a.TopLeft(), "Warehouse"))
    local closeButton = ui.Button(ui.a.TopRight(), "x", {id=baseId .. ".warehouseCloseButton", fillColor=colors.red, border=0})
    closeButton:addActivateHandler(function()
        wrapper:updateMainTab(tabs)
        tabs:setActive("main")
    end)
    tab:add(closeButton)
    local warehouseListFrame = ui.Frame(ui.a.Anchor(1, 2), {
        id=baseId .. ".warehouseListFrame",
        fillColor=colors.lightGray,
        textColor=colors.black,
        fillHorizontal=true,
        scrollBar=true,
        height=height-1,
        border=0,
        padTop=1,
        padLeft=1,
    })
    warehouseListFrame:add(ui.Text(ui.a.TopLeft(), "", {id=baseId .. ".warehouseList"}))
    tab:add(warehouseListFrame)
end

function ColoniesWrapper:createUI()
    local baseId = self:getBaseId()

    self.frame:add(ui.Text(ui.a.Top(), "", {id=baseId .. ".titleText"}))

    if _G.PROGRESS_SHOW_CLOSE then
        local closeButton = ui.Button(ui.a.TopRight(), "x", {id=baseId .. ".closeButton", fillColor=colors.red, border=0})
        closeButton:addActivateHandler(function()
            _G.RUN_PROGRESS = false
        end)
        self.frame:add(closeButton)
    end

    local tabs = ui.TabbedFrame(ui.a.Anchor(1, 3), {
        id=baseId .. ".tabsBase",
        fillColor=colors.black,
        textColor=colors.white,
        border=0,
        fillVertical=true,
        fillHorizontal=true
    })
    local boundTabs = tabs:bind(self.output)

    self:createMainTab(boundTabs)

    self.frame:add(tabs)
    ColoniesWrapper.super.createUI(self)
end

---@param tabs am.ui.BoundTabbedFrame
function ColoniesWrapper:updateMainTab(tabs)
    if not self.needsUpdate.main then
        return
    end

    local status = self.progress.status
    ---@cast status cc.colony
    local baseId = self:getBaseId()
    local width, _ = self.output.getSize()

    local tab = tabs:getTab("main")
    ---@cast tab am.ui.BoundFrame

    local statusText = tab:get(baseId .. ".statusText")
    ---@cast statusText am.ui.BoundText
    statusText:update(self.progress.text)

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

    local warehouse = tab:get(baseId .. ".warehouse")
    ---@cast warehouse am.ui.BoundText
    local warehouseText = "??%"
    if self.progress.warehouse ~= nil then
        local percent = self.progress.warehouse.usedSlots / self.progress.warehouse.totalSlots * 100
        if percent >= 75 then
            warehouse.obj.textColor = colors.red
        elseif percent >= 50 then
            warehouse.obj.textColor = colors.yellow
        elseif percent >= 25 then
            warehouse.obj.textColor = colors.white
        else
            warehouse.obj.textColor = colors.green
        end
        if width < 30 then
            warehouseText = string.format("%d%%", percent)
        else
            warehouseText = string.format("%d%% [%s/%s]", percent, self.progress.warehouse.usedSlots,self.progress.warehouse.totalSlots)
        end
    end
    warehouse:update(warehouseText)

    self.needsUpdate.main = false
end

---@param tabs am.ui.BoundTabbedFrame
function ColoniesWrapper:updateCitizensTab(tabs)
    if not self.needsUpdate.citizens then
        return
    end

    local _, height = self.output.getSize()
    local status = self.progress.status
    ---@cast status cc.colony
    local baseId = self:getBaseId()

    local tab = tabs:getTab("citizens")
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
        if citizen.job ~= nil then
            job = citizen.job
        end
        citizenText[#citizenText + 1] = string.format("%s %s", job, citizen.name)
    end
    table.sort(citizenText)
    citizenList:update(citizenText)

    self.needsUpdate.citizens = false
end

---@param tabs am.ui.BoundTabbedFrame
function ColoniesWrapper:updateRequestsTab(tabs)
    if not self.needsUpdate.requests then
        return
    end

    local _, height = self.output.getSize()
    local status = self.progress.status
    ---@cast status cc.colony
    local baseId = self:getBaseId()

    local tab = tabs:getTab("requests")
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
        requestText[#requestText + 1] = request.name
    end
    table.sort(requestText)
    requestList:update(requestText)

    self.needsUpdate.requests = false
end

---@param tabs am.ui.BoundTabbedFrame
function ColoniesWrapper:updateBuildingsTab(tabs)
    if not self.needsUpdate.buildings then
        return
    end

    local _, height = self.output.getSize()
    local status = self.progress.status
    ---@cast status cc.colony
    local baseId = self:getBaseId()

    local tab = tabs:getTab("buildings")
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

    self.needsUpdate.buildings = false
end

---@param tabs am.ui.BoundTabbedFrame
function ColoniesWrapper:updateVisitorsTab(tabs)
    if not self.needsUpdate.visitors then
        return
    end

    local _, height = self.output.getSize()
    local status = self.progress.status
    ---@cast status cc.colony
    local baseId = self:getBaseId()

    local tab = tabs:getTab("visitors")
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

    self.needsUpdate.visitors = false
end

---@param tabs am.ui.BoundTabbedFrame
function ColoniesWrapper:updatePlayersTab(tabs)
    if not self.needsUpdate.players then
        return
    end

    local _, height = self.output.getSize()
    local status = self.progress.status
    ---@cast status cc.colony
    local baseId = self:getBaseId()

    local tab = tabs:getTab("players")
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

    self.needsUpdate.players = false
end

---@param tabs am.ui.BoundTabbedFrame
function ColoniesWrapper:updateWarehouseTab(tabs)
    if not self.needsUpdate.warehouse then
        return
    end

    local _, height = self.output.getSize()
    local warehouse = self.progress.warehouse
    local itemCount = 0
    if warehouse ~= nil then
        itemCount = #warehouse.items
    end
    local baseId = self:getBaseId()

    local tab = tabs:getTab("warehouse")
    ---@cast tab am.ui.BoundFrame

    local warehouseListFrame = tab:get(baseId .. ".warehouseListFrame")
    ---@cast warehouseListFrame am.ui.BoundFrame
    local newHeight = math.max(height - 1, itemCount)
    if warehouseListFrame.obj.height ~= newHeight then
        warehouseListFrame.obj.height = newHeight
        warehouseListFrame:render()
    end

    local warehouseList = tab:get(baseId .. ".warehouseList")
    ---@cast warehouseList am.ui.BoundText

    local warehouseText = {}
    if warehouse ~= nil then
        warehouseText = h.itemStrings(core.copy(warehouse.items), false, true)
    end
    warehouseList:update(warehouseText)

    self.needsUpdate.players = false
end

function ColoniesWrapper:resetNeedsUpdate()
    self.needsUpdate = {
        main = true,
        citizens = true,
        requests = true,
        buildings = true,
        visitors = true,
        players = true,
        warehouse = true,
    }
end

---@param src am.net.src
---@param event? am.e.ColoniesEvent
---@param force? boolean
function ColoniesWrapper:update(src, event, force)
    local baseId = self:getBaseId()

    if event ~= nil then
        if event.name == e.c.Event.Colonies.status_poll then
        ---@cast event am.e.ColonyStatusPollEvent
        self.progress.status = event.status
        self.progress.text = event.text
        self:resetNeedsUpdate()
        elseif event.name == e.c.Event.Colonies.warehouse_poll then
            ---@cast event am.e.ColonyWarehousePollEvent
            if event.id ~= self.progress.id then
                return
            end
            self.progress.warehouse = event
            self:resetNeedsUpdate()
        end
    end

    if self.progress.status == nil then
        return
    end

    if not self.frame.visible and not force then
        return
    end

    local titleText = self.frame:get(baseId .. ".titleText", self.output)
    ---@cast titleText am.ui.BoundText
    titleText:update(self.progress.status.name)

    local tabs = self.frame:get(baseId .. ".tabsBase", self.output)
    ---@cast tabs am.ui.BoundTabbedFrame

    local activeTabId = tabs.obj.tabIndexIdMap[tabs.obj.active]
    if activeTabId == "main" then
        self:updateMainTab(tabs)
    elseif activeTabId == "citizens" then
        self:updateCitizensTab(tabs)
    elseif activeTabId == "requests" then
        self:updateRequestsTab(tabs)
    elseif activeTabId == "buildings" then
        self:updateBuildingsTab(tabs)
    elseif activeTabId == "visitors" then
        self:updateVisitorsTab(tabs)
    elseif activeTabId == "players" then
        self:updatePlayersTab(tabs)
    end
end

---@param src am.net.src
---@param status string
function ColoniesWrapper:updateStatus(src, status)
    self.progress.text = status
    local baseId = self:getBaseId()

    local statusText = self.frame:get(baseId .. ".statusText", self.output)
    ---@cast statusText am.ui.BoundText
    statusText:update(self.progress.text)
end

---@param src am.net.src
---@param event string Event name
---@param args table
function ColoniesWrapper:handle(src, event, args)
    if event == e.c.Event.Colonies.status_poll then
        self:update(src, args[1])
    else
        self.frame:handle(self.output, {event, table.unpack(args)})
    end
end

return ColoniesWrapper
