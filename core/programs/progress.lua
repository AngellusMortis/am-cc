local v = require("cc.expect")
local pp = require("cc.pretty")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

local eventLib = require("eventLib")
local text = require("text")
local progressLib = require("progressLib")

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
settings.define(s.outputMap.name, s.outputMap)
settings.define(s.timeout.name, s.timeout)

local autoDiscoverDisplay = true
local terminalFree = true
local minSize = {width=13, height=7}
local baseSize = {width=25, height=13}
local timeoutMap = {}
local eventLoopData = {}

local function getAllMonitors()
    local monitors = {}
    for _, name in ipairs(peripheral.getNames()) do
        if peripheral.getType(name) == "monitor" then
            local monitor = peripheral.wrap(name)
            monitor.clear()
            monitor.setCursorPos(1, 1)
            monitor.setTextScale(1.0)
            local width, height = monitor.getSize()
            if width > minSize.width and height > minSize.height then
                if width < baseSize.width or height < baseSize.height then
                    monitor.setTextScale(0.5)
                elseif width >= (baseSize.width * 5) and height >= (baseSize.height * 5) then
                    monitor.setTextScale(5.0)
                elseif width >= (baseSize.width * 4) and height >= (baseSize.height * 4) then
                    monitor.setTextScale(4.0)
                elseif width >= (baseSize.width * 3) and height >= (baseSize.height * 3) then
                    monitor.setTextScale(3.0)
                elseif width >= (baseSize.width * 2) and height >= (baseSize.height * 2) then
                    monitor.setTextScale(2.0)
                end
                monitors[name] = monitor
            end
        end
    end

    return monitors
end

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

local function saveOutputMap(outputMap)
    v.expect(1, outputMap, "table")
    local outputNameMap = {}
    for name, output in pairs(outputMap) do
        local outputName = peripheral.getName(output)
        outputNameMap[name] = outputName
    end
    settings.set(s.outputMap.name, outputNameMap)
    settings.save()
end

local function addOutput(name, outputName)
    v.expect(1, name, "string")
    v.expect(2, outputName, "string")

    local outputNameMap = settings.get(s.outputMap.name)
    outputNameMap[name] = outputName
    settings.set(s.outputMap.name, outputNameMap)
    settings.save()

    if terminalFree then
        print(string.format("Adding %s as output for %s...", outputName, name))
    end
end

local function getOutputMap()
    local outputNameMap = settings.get(s.outputMap.name)
    local outputMap = {}
    local computerMap = {}

    for name, outputName in pairs(outputNameMap) do
        local output = getMonitor(outputName)
        if output ~= nil then
            outputMap[name] = output
            computerMap[outputName] = name
        end
    end

    saveOutputMap(outputMap)
    return outputMap, computerMap
end

local function getDisplay(name)
    v.expect(1, name, "string")
    if eventLoopData.outputMap == nil or eventLoopData.computerMap == nil then
        eventLoopData.outputMap, eventLoopData.computerMap = getOutputMap()
    end
    v.expect(2, eventLoopData.outputMap, "table")
    v.expect(3, eventLoopData.computerMap, "table")

    name = string.lower(name)
    local output = eventLoopData.outputMap[name]
    if output ~= nil or not autoDiscoverDisplay then
        return output
    end

    local count = 0
    for outputName, output in pairs(getAllMonitors()) do
        count = count + 1
        local existing = eventLoopData.computerMap[outputName]
        if existing == nil then
            addOutput(name, outputName)
            eventLoopData.outputMap[name] = output
            eventLoopData.computerMap[outputName] = name
            return output
        end
    end

    if count == 0 then
        return term
    end

    return nil
end

local function initTerm(computerMap)
    if computerMap["term"] ~= nil then
        terminalFree = false
    else
        term.clear()
        term.setCursorPos(1, 1)
        term.setTextColor(colors.white)
    end
end

local function eventLoop()
    while true do
        local id, data = rednet.receive()
        local output = getDisplay(data.name)
        if output ~= nil then
            eventLib.printProgress(data.event, data.name, output)
            timeoutMap[data.name] = os.clock() + settings.get(s.timeout.name)
        end
    end
end

local function heartbeat()
    while true do
        sleep(1)
        local now = os.clock()
        for name, timeout in pairs(timeoutMap) do
            if now > timeout then
                local output = getDisplay(name)
                if output ~= nil then
                    progressLib.updateStatus(output, name, "error:Progress Timeout")
                end
            end
        end
    end
end

local function main(name, outputName)
    local outputMap = {}
    local computerMap = {}
    if name ~= nil then
        output, outputName = getMonitor(outputName)
        v.expect(1, name, "string")
        v.expect(2, output, "table")

        name = string.lower(name)
        autoDiscoverDisplay = false
        outputMap[name] = output
        computerMap[outputName] = name
    else
        outputMap, computerMap = getOutputMap()
    end

    initTerm(computerMap)
    eventLib.initNetwork()
    if not eventLib.online then
        error("Could not find modem")
    end

    for name, output in pairs(outputMap) do
        if terminalFree then
            local outputName = peripheral.getName(output)
            print(string.format("Using %s output for %s", outputName, name))
        end
        output.clear()
        output.setCursorPos(1, 1)
        output.setTextColor(colors.white)
        output.write(string.format("Wait for %s...", name))
    end

    if terminalFree then
        print("Listening for progress events...")
    end

    eventLoopData = {outputMap=outputMap, computerMap=computerMap}
    parallel.waitForAny(eventLoop, heartbeat)
end

main(arg[1], arg[2])
