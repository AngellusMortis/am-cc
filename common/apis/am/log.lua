local v = require("cc.expect")
local pp = require("cc.pretty")

require(settings.get("ghu.base") .. "core/apis/ghu")
local core = require("am.core")

local l = {}

local s = {}
s.file = {
    name = "log.file",
    default = nil
}
s.print = {
    name = "log.print",
    default = true,
    type = "boolean"
}
l.s = core.makeSettingWrapper(s)

---@param msg any
---@param pretty? boolean
---@param fileOnly? boolean
local function log(msg, pretty, fileOnly)
    v.expect(2, pretty, "boolean", "nil")
    v.expect(3, fileOnly, "boolean", "nil")
    if pretty == nil then
        if type(msg) == "string" then
            pretty = false
        else
            pretty = true
        end
    end
    if fileOnly == nil then
        fileOnly = false
    end

    if pretty then
        msg = pp.pretty(msg)
    end

    local logFilePath = l.s.file.get()
    if logFilePath ~= nil then
        local logFile = fs.open(logFilePath, "a")
        if pretty then
            logFile.writeLine(pp.render(msg))
        else
            logFile.writeLine(msg)
        end
    end

    if not l.s.print.get() then
        return
    end

    if pretty then
        pp.print(pp.group(pp.print(msg)))
    else
        print(msg)
    end
end

---@param msg any
---@param pretty? boolean
local function info(msg, pretty)
    log(msg, pretty, false)
end

---@param msg any
---@param pretty? boolean
local function debug(msg, pretty)
    log(msg, pretty, true)
end

l.info = info
l.debug = debug

return l
