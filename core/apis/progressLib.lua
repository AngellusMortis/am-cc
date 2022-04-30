local v = require("cc.expect")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

local l.ui = require("lib.ui")
local log = require("log")

local progressLib = {}
local GUI = {}

local function getGui(output, name, create)
    if create == nil then
        create = true
    end
    v.expect(1, output, "table")
    v.expect(2, name, "string")
    v.expect(3, create, "boolean")

    local namespace = "term"
    if not l.ui.isTerm(output) then
        namespace = peripheral.getName(output)
    end

    local guiName = namespace
    if name ~= nil then
        guiName = namespace .. "_" .. name
    end

    local created = false
    local gui = GUI[guiName]
    if gui == nil and create then
        gui = l.ui.GUI(output)
        created = true
        GUI[guiName] = gui
    end

    return gui, created
end

progressLib.handleEvent = function(event, name)
    for _, gui in pairs(GUI) do
        if name == nil or gui.name == name then
            gui.handle(event)
        end
    end
end

progressLib.updateStatus = function(output, name, status)
    v.expect(1, output, "table")
    if name ~= nil then
        v.expect(2, name, "string")
    end
    v.expect(3, status, "string")

    gui, _ = getGui(output, name, false)
    if gui ~= nil then
        gui.items.statusText.text = status
        gui.render()
    end
end

local initQuarryUi = function(gui, job, name)
    gui.reset()

    local width, _ = gui.output.getSize()
    local center = math.floor(width / 2)
    local titleY = 1
    if name ~= nil then
        gui.add(l.ui.Text("", l.ui.a.Center(1)), "nameText")
        titleY = 2
    end
    gui.isPaused = false
    gui.name = name

    gui.add(l.ui.Text("", l.ui.a.Center(titleY)), "titleText")
    gui.add(l.ui.Bar(3, "Total"), "totalBar")
    gui.items.totalBar.showProgress = false
    gui.items.totalBar.showPercent = false
    gui.add(l.ui.Bar(6, "Level"), "lineBar")
    gui.items.lineBar.total = job.left
    gui.add(l.ui.Text("", l.ui.a.Center(9)), "statusText")
    gui.add(l.ui.Button(center - 7, 10, 8, 1, "Stop"), "buttonHalt")
    gui.items.buttonHalt.fillColor = colors.red
    gui.items.buttonHalt.onActivate = function(_, output, data)
        log.log(string.format("Halting %s...", gui.name))
        require("eventLib").b.turtleRequestHalt(gui.name)
    end
    gui.add(l.ui.Button(center + 2, 10, 9, 1, "Pause"), "buttonPause")
    gui.items.buttonPause.fillColor = colors.yellow
    gui.items.buttonPause.onActivate = function(_, output, data)
        if gui.isPaused then
            log.log(string.format("Continuing %s...", gui.name))
            require("eventLib").b.turtleRequestContinue(gui.name)
        else
            log.log(string.format("Pausing %s...", gui.name))
            require("eventLib").b.turtleRequestPause(gui.name)
        end
    end
    gui.add(l.ui.Text("", l.ui.a.Bottom()), "curPosText")

    origHandle = gui.handle
    gui.handle = function(event)
        local eventLib = require("eventLib")
        if event[1] == eventLib.e.turtle and event[2] == eventLib.e.turtle_paused then
            gui.isPaused = true
            gui.items.buttonPause.fillColor = colors.green
            gui.items.buttonPause.label = "Go"
            gui.render()
        elseif event[1] == eventLib.e.turtle and event[2] == eventLib.e.turtle_started then
            gui.isPaused = false
            gui.items.buttonHalt.visible = true
            gui.items.buttonPause.visible = true
            gui.items.buttonPause.fillColor = colors.yellow
            gui.items.buttonPause.label = "Pause"
            gui.render()
        elseif event[1] == eventLib.e.turtle and (event[2] == eventLib.e.turtle_completed or event[2] == eventLib.e.turtle_halted) then
            gui.items.buttonHalt.visible = false
            gui.items.buttonPause.visible = false
        else
            origHandle(event)
        end
    end
end

local updateQuarryUi = function(gui, output, job, progress, pos, name, isOnline)
    local width, height = output.getSize()
    local titleY = 1
    if name ~= nil then
        local nameStatus = name
        if isOnline then
            nameStatus = "info:" .. name
        end
        gui.items.nameText.text = nameStatus
    end
    gui.items.titleText.text = string.format(
        "Quarry: %d x %d (%d)", job.left, job.forward, job.levels
    )

    gui.items.totalBar.label = string.format(
        "Total %d%% [%d/%d]", progress.totalPercent * 100, progress.completedLevels, job.levels
    )
    gui.items.totalBar.current = progress.totalPercent
    gui.items.lineBar.current = progress.completedRows

    gui.items.statusText.text = progress.status
    local posFmt = "pos (%d, %d) e: %d, d: %d"
    if width < 30 then
        posFmt = "(%d,%d) e:%d, d:%d"
    end
    gui.items.curPosText.text = string.format(posFmt, pos.x, pos.z, pos.y, pos.dir)
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
    if not l.ui.isTerm(output) then
        namespace = peripheral.getName(output)
    end
    local gui, created = getGui(output, name)

    local width, height = output.getSize()
    if created then
        initQuarryUi(gui, job, name)
    end
    updateQuarryUi(gui, output, job, progress, pos, name, isOnline)

    gui.render()
end

return progressLib
