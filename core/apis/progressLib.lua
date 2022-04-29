local v = require("cc.expect")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

local ui = require("ui")
local text = require("text")

local progressLib = {}
local uiGroups = {}

local function getUIGroup(output, name, create)
    if create == nil then
        create = true
    end
    v.expect(1, output, "table")
    v.expect(2, name, "string")
    v.expect(3, create, "boolean")

    local namespace = "term"
    if not ui.isTerm(output) then
        namespace = peripheral.getName(output)
    end

    local groupName = namespace
    if name ~= nil then
        groupName = namespace .. "_" .. name
    end

    local created = false
    local group = uiGroups[groupName]
    if group == nil and create then
        group = ui.Group()
        created = true
        uiGroups[groupName] = group
    end

    return group, created
end

progressLib.updateStatus = function(output, name, status)
    v.expect(1, output, "table")
    if name ~= nil then
        v.expect(2, name, "string")
    end
    v.expect(3, status, "string")

    uiGroup, _ = getUIGroup(output, name, false)
    if uiGroup ~= nil then
        uiGroup.items.statusText.text = status
        uiGroup.render(output)
    end
end

local initQuarryUi = function(uiGroup, name)
    uiGroup.reset()

    local titleY = 1
    if name ~= nil then
        uiGroup.add(ui.Text("", ui.a.Center(1)), "nameText")
        titleY = 2
    end
    uiGroup.add(ui.Text("", ui.a.Center(titleY)), "titleText")
    uiGroup.add(ui.Bar(4), "totalBar")
    uiGroup.add(ui.Bar(6), "lineBar")
    uiGroup.add(ui.Text("", ui.a.Center(8)), "statusText")
    uiGroup.add(ui.Text("", ui.a.Bottom()), "curPosText")
end

local updateQuarryUi = function(uiGroup, output, job, progress, pos, name, isOnline)
    local width, height = output.getSize()
    local titleY = 1
    if name ~= nil then
        local nameStatus = name
        if isOnline then
            nameStatus = "info:" .. name
        end
        uiGroup.items.nameText.text = nameStatus
    end
    uiGroup.items.titleText.text = string.format(
        "Quarry: %d x %d (%d)", job.left, job.forward, job.levels
    )

    local currentLevel = math.min(progress.completedLevels + 1, job.levels)
    uiGroup.items.totalBar.label = string.format(
        "Total %d%% [%d/%d]", progress.total * 100, currentLevel, job.levels
    )
    uiGroup.items.totalBar.current = progress.total

    uiGroup.items.lineBar.label = string.format(
        "Level %d%% [%d/%d]", progress.level * 100, progress.currentRow, job.left
    )
    uiGroup.items.lineBar.current = progress.level

    uiGroup.items.statusText.text = progress.status
    local posFmt = "pos (%d, %d) e: %d, d: %d"
    if width < 30 then
        posFmt = "(%d,%d) e:%d, d:%d"
    end
    uiGroup.items.curPosText.text = string.format(posFmt, pos.x, pos.z, pos.y, pos.dir)

    -- render(output, 2, 9, "X", "white", "red")
    -- render(output, width-1, 9, "=", "white", "blue")
end

progressLib.quarry = function(output, job, progress, pos, name, isOnline)
    if type(output) ~= "table" then
        isOnline = name
        name = pos
        pos = progress
        progress = job
        job = output
        output = term
    end

    v.expect(1, output, "table")
    v.expect(2, job, "table")
    v.expect(3, progress, "table")
    v.expect(4, pos, "table")
    if name ~= nil then
        v.expect(5, name, "string")
    end
    if isOnline == nil then
        isOnline = false
    end
    v.expect(6, isOnline, "boolean")

    local namespace = "term"
    if not ui.isTerm(output) then
        namespace = peripheral.getName(output)
    end
    local uiGroup, created = getUIGroup(output, name)

    local width, height = output.getSize()
    if created then
        initQuarryUi(uiGroup, name)
    end
    updateQuarryUi(uiGroup, output, job, progress, pos, name, isOnline)

    uiGroup.render(output)
end

return progressLib
