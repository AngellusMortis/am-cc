local v = require("cc.expect")
local pp = require("cc.pretty")

local log = {}
log.s = {}
log.s.file = {
    name = "log.file",
    default = nil
}
log.s.print = {
    name = "log.print",
    default = true,
    type = "boolean"
}

settings.define(log.s.file.name, log.s.file)
settings.define(log.s.print.name, log.s.print)

log.setPrint = function(enabled)
    v.expect(1, enabled, "boolean")

    settings.set(log.s.print.name, enabled)
    settings.save()
end

log.log = function(msg, pretty)
    if pretty == nil then
        if type(msg) == "string" then
            pretty = false
        else
            pretty = true
        end
    end

    if not settings.get(log.s.print.name) then
        return
    end

    if pretty then
        pp.pretty_print(msg)
    else
        print(msg)
    end
end

return log
