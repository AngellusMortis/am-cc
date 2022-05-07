local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local log = require("am.log")
local e = require("am.event")
local ui = require("am.ui")
local p = require("am.progress")
local core = require("am.core")

local s = {}
s.outputMap = {
    name = "progress.outputMap",
    default = {},
    type = "table"
}
s.timeout = {
    name = "progress.timeout",
    default = 30,
    type = "number"
}
s = core.makeSettingWrapper(s)

local AUTO_DISCOVER = true
local MIN_SIZE = {width=13, height=7}
local BASE_SIZE = {width=25, height=13}
local TIMEOUT_MAP = {}
local DATA = {}

---@return table<string, cc.output>
local function getAllMonitors()
    local monitors = {}
    for _, name in ipairs(peripheral.getNames()) do
        if peripheral.getType(name) == "monitor" then
            local monitor = peripheral.wrap(name)
            monitor.clear()
            monitor.setCursorPos(1, 1)
            monitor.setTextScale(1.0)
            local width, height = monitor.getSize()
            if width > MIN_SIZE.width and height > MIN_SIZE.height then
                if width < BASE_SIZE.width or height < BASE_SIZE.height then
                    monitor.setTextScale(0.5)
                elseif width >= (BASE_SIZE.width * 5) and height >= (BASE_SIZE.height * 5) then
                    monitor.setTextScale(5.0)
                elseif width >= (BASE_SIZE.width * 4) and height >= (BASE_SIZE.height * 4) then
                    monitor.setTextScale(4.0)
                elseif width >= (BASE_SIZE.width * 3) and height >= (BASE_SIZE.height * 3) then
                    monitor.setTextScale(3.0)
                elseif width >= (BASE_SIZE.width * 2) and height >= (BASE_SIZE.height * 2) then
                    monitor.setTextScale(2.0)
                end
                monitors[name] = monitor
            end
        end
    end

    return monitors
end

---@return cc.output, string
local function getMonitor(outputName)
    if outputName == nil or outputName == "term" then
        return term, "term"
    end
    v.expect(1, outputName, "string")
    local monitors = getAllMonitors()
    local output = monitors[outputName]

    if output == nil then
        error(string.format("Could not find montior at %s", outputName))
    end
    return output, outputName
end

---@param outputMap table<number, cc.output>
local function saveOutputMap(outputMap)
    v.expect(1, outputMap, "table")
    local outputNameMap = {}
    for id, output in pairs(outputMap) do
        local outputName = peripheral.getName(output)
        outputNameMap[id] = outputName
    end
    s.outputMap.set(outputNameMap)
end

---@param src am.net.src
---@param outputName string
local function addOutput(src, outputName)
    v.expect(1, src, "table")
    v.expect(2, outputName, "string")

    local outputNameMap = s.outputMap.get()
    outputNameMap[src.id] = outputName
    s.outputMap.set(outputNameMap)

    local name = src.label or src.id
    log.info(string.format("Adding %s as output for %s...", outputName, name))
end

---@return table<number, cc.output>, table<string, number>
local function getOutputMap()
    local outputNameMap = s.outputMap.get()
    local outputMap = {}
    local computerMap = {}

    for id, outputName in pairs(outputNameMap) do
        local output = getMonitor(outputName)
        if output ~= nil then
            outputMap[id] = output
            computerMap[outputName] = id
        end
    end

    saveOutputMap(outputMap)
    return outputMap, computerMap
end

---@param src am.net.src
---@param autoDiscovery? boolean
---@return cc.output|nil
local function getDisplay(src, autoDiscovery)
    v.expect(1, src, "table")
    v.expect(2, autoDiscovery, "boolean", "nil")
    if autoDiscovery == nil then
        autoDiscovery = AUTO_DISCOVER
    end

    if DATA.outputMap == nil or DATA.computerMap == nil then
        DATA.outputMap, DATA.computerMap = getOutputMap()
    end

    local output = DATA.outputMap[src.id]
    if output == nil and src.label ~= nil then
        output = DATA.outputMap[string.lower(src.label)]
    end
    if output ~= nil or not autoDiscovery then
        return output
    end

    local count = 0
    ---@diagnostic disable-next-line: redefined-local
    for outputName, output in pairs(getAllMonitors()) do
        count = count + 1
        local existing = DATA.computerMap[outputName]
        if existing == nil then
            addOutput(src, outputName)
            DATA.outputMap[src.id] = output
            DATA.computerMap[outputName] = src.id
            return output
        end
    end

    if count == 0 then
        return term
    end

    return nil
end

---@param computerMap table<string, number>
local function initTerm(computerMap)
    if computerMap["term"] ~= nil then
        log.s.print.set(false)
    else
        log.s.print.set(true)
        term.clear()
        term.setCursorPos(1, 1)
        term.setTextColor(colors.white)
    end
end

local function eventLoop()
    while true do
        local event, args = core.cleanEventArgs(os.pullEvent())
        p.handle(e.getComputer(), event, args)
    end
end

local function netEventLoop()
    while true do
        local id, data = rednet.receive()
        if data ~= nil and data.type == e.type then
            ---@cast data am.net
            local output = nil
            if e.c.Lookup.Progress[data.name] then
                output = getDisplay(data.src)
                if output ~= nil then
                    p.print(data.src, data.event, output)
                    if TIMEOUT_MAP[data.src.id] ~= -1 then
                        TIMEOUT_MAP[data.src.id] = os.clock() + settings.get(s.timeout.name)
                    end
                end
            end
            if output == nil then
                output = getDisplay(data.src, false)
            end
            if output ~= nil then
                if data.event.name == e.c.Event.Turtle.turtle_started then
                    TIMEOUT_MAP[data.src.id] = os.clock() + settings.get(s.timeout.name)
                elseif data.event.name == e.c.Event.Turtle.turtle_paused or data.event.name == e.c.Event.Turtle.turtle_exited then
                    TIMEOUT_MAP[data.src.id] = -1
                end
                p.handle(data.src, data.event.name, {data.event})
            end
        end
    end
end

local function heartbeat()
    while true do
        sleep(1)
        local now = os.clock()
        for id, timeout in pairs(TIMEOUT_MAP) do
            if timeout~= -1 and now > timeout then
                local output = getDisplay({id=id})
                if output ~= nil then
                    p.updateStatus({id=id}, "error:Progress Timeout")
                end
            end
        end
    end
end

local function main(name, outputName)
    local outputMap = {}
    local computerMap = {}
    if name ~= nil then
        local outputObj
        outputObj, outputName = getMonitor(outputName)
        v.expect(1, name, "string")
        v.expect(2, outputObj, "table")

        name = string.lower(name)
        AUTO_DISCOVER = false
        outputMap[name] = outputObj
        computerMap[outputName] = name
    else
        outputMap, computerMap = getOutputMap()
    end

    initTerm(computerMap)
    e.initNetwork()
    if not e.online then
        error("Could not find modem")
    end

    for id, output in pairs(outputMap) do
        outputName = "term"
        if not ui.h.isTerm(output) then
            outputName = peripheral.getName(output)
        end
        log.info(string.format("Using %s output for %s", outputName, name))

        output.clear()
        output.setCursorPos(1, 1)
        output.setTextColor(colors.white)
        output.write(string.format("Wait for %s...", name))
        output.setCursorPos(1, 2)
    end

    log.info("Listening for progress events...")
    DATA = {outputMap=outputMap, computerMap=computerMap}
    parallel.waitForAny(eventLoop, netEventLoop, heartbeat)
end

main(arg[1], arg[2])