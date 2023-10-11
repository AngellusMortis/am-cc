-- ComputerCraft does not have a way to persist module loaders
-- So importing the core updater library will automatically initialize the module loaders if needed
require(settings.get("ghu.base") .. "core/apis/ghu")

local core = require("am.core")
local ui = require("am.ui")
local stargate = peripheral.find("basic_interface")
local monitor = peripheral.find("monitor")
local log = require("am.log")

if stargate == nil then
    error("Could not find Stargate Basic Interface")
end
if monitor == nil then
    error("Could not find Stargate Dialing Monitor")
end

_G.RUNNING = false
_G.CAN_DIAL = false

---@class sg.address
---@field id string
---@field name string
---@field address number[]

---@type table<string, sg.address>
local selectedAddresses = {}
---@type number[]|nil
local toDial = nil

local s = {}
s.allGates = {
    name = "sg.allGates",
    default = {},
    type = "table"
}
s = core.makeSettingWrapper(s)

local terminal = ui.Screen(term, {textColor=colors.white, backgroundColor=colors.black})
local dialer = ui.Screen(monitor, {textColor=colors.white, backgroundColor=colors.black})

local function canDial()
    return _G.CAN_DIAL
end


local function isRunning()
    return _G.RUNNING
end

---@param address_num number[]
local function getAddressInfo(address_num)
    local addresses = s.allGates.get()
    for _, address in pairs(addresses) do
        if #address_num == #(address.address) then
            local match = true
            for index, symbol in ipairs(address.address) do
                if symbol ~= address_num[index] then
                    match = false
                    break
                end
            end
            if match then
                return address
            end
        end
    end

    local name = "-"
    for _, symbol in ipairs(address_num) do
        name = name .. tostring(symbol) .. "-"
    end
    return {
        id="unknown",
        name=name,
        address=address
    }
end

---@param running boolean
local function setRunning(running)
    _G.RUNNING = running
    if not running then
        _G.CAN_DIAL = false
    end
end

---@param text string
local function setStatus(text)
    local termStatus = terminal:get("termStatus")
    if termStatus ~= nil then
        termStatus:update(text)
    end

    local dialStatus = dialer:get("dialStatus")
    if dialStatus ~= nil then
        dialStatus:update(text)
    end
end

---@param text string
---@param progress number|nil
local function setProgress(text, progress)
    local termProgress = terminal:get("termProgress")
    local requireFullRender = false

    if termProgress ~= nil then
        if progress == nil then
            termProgress.obj.baseLabel = ""
            termProgress.obj.visible = false
            termProgress:update(0)
            terminal:render()
        else
            termProgress.obj.baseLabel = text
            termProgress.obj.visible = true
            termProgress:update(progress)
            terminal:render()
        end
    end

    local dialProgress = dialer:get("dialProgress")
    if dialProgress ~= nil then
        if progress == nil then
            dialProgress.obj.baseLabel = ""
            dialProgress.obj.visible = false
            dialProgress:update(0)
            dialer:render()
        else
            dialProgress.obj.baseLabel = text
            dialProgress.obj.visible = true
            dialProgress:update(progress)
            dialer:render()
        end
    end
end

---@param chevron number
local function gotoChevron(chevron)
    stargate.rotateClockwise(chevron)
    while not stargate.isCurrentSymbol(chevron) do
        sleep(1)
    end
end

local function resetStargate(wait)
    if wait == nil then
        wait = 1
    end

    _G.CAN_DIAL = false
    toDial = nil
    setStatus("Resetting Stargate")
    setProgress("")
    stargate.disconnectStargate()
    if not stargate.isCurrentSymbol(0) then
        stargate.rotateClockwise(-1)
        if wait > 0 then
            sleep(wait)
        end
        gotoChevron(0)
    end
    setStatus("Idle")
    log.debug("idle")
    _G.CAN_DIAL = true
end

---@param chevron number
local function encodeChevron(chevron)
    if not canDial() then
        return
    end

    gotoChevron(chevron)
    stargate.raiseChevron()
    sleep(0.5)
    stargate.lowerChevron()
end

---@param address sg.address
local function dialAddress(address)
    local current = 0
    local total = #address.address + 1
    local label = "Dial: " .. address.name

    log.debug("dial address: " .. address.name)
    setStatus("Dialing")
    setProgress(label, 1)
    stargate.disconnectStargate()
    stargate.rotateClockwise(-1)
    sleep(3)
    if not canDial() then
        return
    end

    for _, chevron in ipairs(address.address) do
        if canDial() then
            encodeChevron(chevron)
            current = current + 1
            setProgress(label, math.floor(current / total * 100))
        end
    end
    if canDial() then
        encodeChevron(0)
        setProgress(label, 100)
    end
end

---@param button am.ui.Button
---@param output table
---@param event am.ui.e.ButtonActivateEvent
local function dialButtonHandler(button, output, event)
    local address = selectedAddresses[button.id]
    if address == nil then
        log.debug("No dial (" .. button.id .. ")")
    elseif toDial ~= nil then
        log.debug("Dial already in progress")
    else
        toDial = address
        button.fillColor = colors.lightGray
        button.disabled = true
    end
end

local function showAutoDialer()
    local dialFrame = terminal:get("dialFrame")
    if dialFrame ~= nil then
        dialFrame:setVisible(true)
    end

    local manualFrame = terminal:get("manualFrame")
    if manualFrame ~= nil then
        manualFrame:setVisible(false)
    end
    terminal:render()
end


local function showManualDialer()
    local dialFrame = terminal:get("dialFrame")
    if dialFrame ~= nil then
        dialFrame:setVisible(false)
    end

    local manualFrame = terminal:get("manualFrame")
    if manualFrame ~= nil then
        manualFrame:setVisible(true)
    end
    terminal:render()
end

---@param frame am.ui.Frame
local function setupDialFrame(frame)
    local width, height = terminal.output.getSize()

    local addressFrame = ui.Frame(ui.a.TopLeft(), {
        id="termAddress",
        width=width - 10,
        height=height - 7,
        backgroundColor=colors.black,
        fillColor=colors.lightGray,
        fillHorizontal=false,
        scrollBar=true,
        padLeft=1,
        padTop=1,
    })
    frame:add(addressFrame)

    local dialButton = ui.Button(ui.a.BottomLeft(), "Dial", {
        id="termDial",
        disabled=true,
        fillColor=colors.lightGray,
        width=width - 10,
        backgroundColor=colors.black,
    })
    dialButton:addActivateHandler(dialButtonHandler)
    frame:add(dialButton)

    local exitButton = ui.Button(ui.a.BottomRight(), "Exit", {
        fillColor=colors.red,
        backgroundColor=colors.black,
    })
    exitButton:addActivateHandler(function()
        setRunning(false)
    end)
    frame:add(exitButton)

    local resetButton = ui.Button(ui.a.Right(height-9), "Reset", {
        fillColor=colors.yellow,
        backgroundColor=colors.black,
        textColor=colors.black,
    })
    resetButton:addActivateHandler(function()
        resetStargate()
    end)
    frame:add(resetButton)

    local manualButton = ui.Button(ui.a.Right(height-12), "Manual", {
        id="manualButton",
        fillColor=colors.blue,
        backgroundColor=colors.black,
        textColor=colors.black,
    })
    manualButton:addActivateHandler(function()
        showManualDialer()
    end)
    frame:add(manualButton)
end

---@param frame am.ui.Frame
local function setupManualDialFrame(frame)
    local width, height = terminal.output.getSize()

    local autoButton = ui.Button(ui.a.BottomRight(), "Auto", {
        id="autoButton",
        fillColor=colors.blue,
        backgroundColor=colors.black,
        textColor=colors.black,
    })
    autoButton:addActivateHandler(function()
        showAutoDialer()
    end)
    frame:add(autoButton)
end

---@param screen am.ui.Screen
local function setupTerminal(screen)
    local width, height = screen.output.getSize()

    screen:add(ui.Text(ui.a.Top(), "Stargate Control", {textColor=colors.cyan}))
    screen:add(ui.Text(ui.a.Center(3), "", {id="termStatus", textColor=colors.white}))
    local progressBar = ui.ProgressBar(ui.a.Left(4), {
        id="termProgress",
        label="",
        textColor=colors.white,
        border=0,
        showProgress=false,
        showCount=false,
        showPercent=true,
    })
    progressBar.visible = false
    screen:add(progressBar)

    local dialFrame = ui.Frame(ui.a.Left(5), {
        id="dialFrame",
        width=width,
        height=height - 4,
        backgroundColor=colors.black,
        fillColor=colors.black,
        border=0,
        fillHorizontal=true,
        scrollBar=false,
        padLeft=0,
        padTop=0,
    })
    screen:add(dialFrame)
    setupDialFrame(dialFrame)

    local manualFrame = ui.Frame(ui.a.Left(5), {
        id="manualFrame",
        width=width,
        height=height - 4,
        backgroundColor=colors.black,
        fillColor=colors.black,
        border=0,
        fillHorizontal=true,
        scrollBar=false,
        padLeft=0,
        padTop=0,
    })
    screen:add(manualFrame)
    setupManualDialFrame(manualFrame)
    manualFrame:setVisible(false)
end

---@param screen am.ui.Screen
local function setupDialer(screen)
    local width, height = screen.output.getSize()

    screen:add(ui.Text(ui.a.Top(), "Stargate Dialer", {textColor=colors.cyan}))
    screen:add(ui.Text(ui.a.Center(3), "", {id="dialStatus", textColor=colors.white}))
    local progressBar = ui.ProgressBar(ui.a.Left(4), {
        id="dialProgress",
        label="",
        textColor=colors.white,
        border=0,
        showProgress=false,
        showCount=false,
        showPercent=true,
    })
    progressBar.visible = false
    screen:add(progressBar)

    local addressFrame = ui.Frame(ui.a.Left(5), {
        id="dialAddress",
        width=width,
        height=height - 7,
        backgroundColor=colors.black,
        fillColor=colors.lightGray,
        fillHorizontal=false,
        scrollBar=true,
        padLeft=1,
        padTop=1,
    })
    screen:add(addressFrame)

    local dialButton = ui.Button(ui.a.BottomLeft(), "Dial", {
        id="dialDial",
        disabled=true,
        fillColor=colors.lightGray,
        width=width,
        backgroundColor=colors.black,
    })
    dialButton:addActivateHandler(dialButtonHandler)
    screen:add(dialButton)
end

---@param item1 sg.address
---@param item2 sg.address
local function sortAddress(item1, item2)
    return item1.name:lower() < item2.name:lower()
end

---@param addressList sg.address[]
---@param frame am.ui.BoundFrame
local function updateAddressesForFrame(addressList, frame)
    ---@type table<string, boolean>
    local usedIds = {}

    for index, address in ipairs(addressList) do
        local width = frame:getWidth()
        local label = "  " .. address.name .. string.rep(" ", width - address.name:len() - 2)
        local textId = frame.obj.id .. address.id
        local boundText = frame:get(textId)
        ---@cast text am.ui.BoundText|nil
        local text

        if (boundText == nil) then
            text = ui.Text(ui.a.Left(index), label, {
                id=textId, width=frame:getWidth()
            })
            frame.obj:add(text)
        else
            text = boundText.obj
            text.anchor = ui.a.Left(index)
        end
        ---@cast text am.ui.Text

        text.label = label
        text.backgroundColor = colors.lightGray
        text.textColor = colors.black
        text.visible = true
        usedIds[label] = true
    end

    for _, item in pairs(frame.obj.i) do
        ---@cast item am.ui.Text
        if usedIds[item.label] == nil then
            item.visible = false
        end
    end
end

local function updateAddresses()
    ---@type table<string, sg.address>
    local addresses = s.allGates.get()

    ---@type sg.address[]
    local addressList = {}
    for _, address in pairs(addresses) do
        addressList[#addressList+1] = address
    end
    table.sort(addressList, sortAddress)

    updateAddressesForFrame(addressList, terminal:get("termAddress"))
    terminal:render()
    updateAddressesForFrame(addressList, dialer:get("dialAddress"))
    dialer:render()
end

---@param name string
---@param address number[]
local function setAddress(id, name, address)
    ---@type table<string, sg.address>
    local addresses = s.allGates.get()
    addresses[id] = {
        id=id,
        name=name,
        address=address
    }
    s.allGates.set(addresses)
    updateAddresses()
end

---@param id string
local function removeAddress(id)
    ---@type table<string, sg.address>
    local addresses = s.allGates.get()
    addresses[id] = nil
    s.allGates.set(addresses)
    updateAddresses()
end

local function setupUI()
    setupTerminal(terminal)
    setupDialer(dialer)

    terminal:render()
    dialer:render()
end

---@param frame am.ui.BoundFrame
---@param button am.ui.BoundButton
---@param row number
local function handleClickEvent(frame, button, row)
    log.debug("click (" .. frame.obj.id .."): " .. row)
    log.debug(button.obj.id)
    local width = frame:getWidth()
    local addresses = s.allGates.get()
    ---@type sg.address[]
    local addressList = {}
    for _, address in pairs(addresses) do
        addressList[#addressList+1] = address
    end
    table.sort(addressList, sortAddress)

    local address = addressList[row]
    if address == nil or toDial ~= nil or not canDial() then
        button.obj.fillColor = colors.lightGray
        button.obj.disabled = true
    else
        button.obj.fillColor = colors.green
        button.obj.disabled = false
    end

    if address == nil then
        selectedAddresses[button.obj.id] = nil
        return
    end

    selectedAddresses[button.obj.id] = address
    for _, item in pairs(frame.obj.i) do
        ---@cast item am.ui.Text
        local label = "  " .. address.name .. string.rep(" ", width - address.name:len() - 2)
        if item.label == label then
            item.backgroundColor = colors.black
            item.textColor = colors.green
        else
            item.backgroundColor = colors.lightGray
            item.textColor = colors.black
        end
    end
end

---@param event string
---@param args table
local function handleEvent(event, args)
    if event:find("^stargate_") then
        log.debug({event, args})
        if event == "stargate_chevron_engaged" then
            setStatus("Chevron " .. args[1] .. " Engaged: " .. args[2])
        elseif event == "stargate_outgoing_wormhole" then
            address = getAddressInfo(args[1])
            setStatus("Outgoing: " .. address.name)
            setProgress("")
        elseif event == "stargate_incoming_wormhole" then
            address = getAddressInfo(args[1])
            setStatus("Incoming: " .. address.name)
            setProgress("")
            _G.CAN_DIAL = false
        elseif event == "stargate_disconnected" then
            setProgress("")
            setStatus("Idle")
            _G.CAN_DIAL = true
        end
    elseif event == "terminate" then
        setRunning(false)
    else
        terminal:handle(event, table.unpack(args))
        dialer:handle(event, table.unpack(args))
        if event == "ui.frame_click" and args[1].objId == "termAddress" then
            handleClickEvent(terminal:get("termAddress"), terminal:get("termDial"), args[1].y)
            terminal:render()
        elseif event == "ui.frame_touch" and args[1].objId == "dialAddress" then
            handleClickEvent(dialer:get("dialAddress"), dialer:get("dialDial"), args[1].y)
            dialer:render()
        end
    end
end

local function eventLoop()
    while isRunning() do
        local event, args = core.cleanEventArgs(os.pullEventRaw())
        handleEvent(event, args)
    end
end

local function dialLoop()
    resetStargate()

    while isRunning() do
        if toDial ~= nil then
            dialAddress(toDial)
            toDial = nil
        end
        sleep(1)
    end
end

local function main()
    setRunning(true)

    log.s.print.set(false)
    setupUI()
    updateAddresses()
    parallel.waitForAll(eventLoop, dialLoop)
    resetStargate(0)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.white)
end

main()
