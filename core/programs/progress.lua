local v = require("cc.expect")

local ghu = require(settings.get("ghu.base") .. "core/apis/ghu")
ghu.initModulePaths()

local eventLib = require("eventLib")

local function getWiredModems()
    return { peripheral.find("modem", function(name, modem)
        return not modem.isWireless()
    end) }
end
local function getMonitor(name)
    v.expect(1, name, "string")
    local modems = getWiredModems()

    for i = 1, #modems, 1 do
        if modems[i].hasTypeRemote(name, "monitor") then
            return peripheral.wrap(name)
        end
    end

    error(string.format("Could not find montior at %s", name))
end

local function main(name, output)
    if output == nil then
        output = term
    else
        output = getMonitor(output)
    end
    v.expect(1, name, "string")
    v.expect(2, output, "table")

    eventLib.initNetwork()
    if not eventLib.online then
        error("Could not find modem")
    end

    output.clear()
    output.setCursorPos(1, 1)
    output.write("Waiting for event...")

    while true do
        local id, data = rednet.receive()
        if data.name == name then
            eventLib.printProgress(data.event, data.name, output)
        end
    end
end

main(arg[1], arg[2])
