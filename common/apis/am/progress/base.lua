local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local BaseObject = require("am.ui.base").BaseObject

---@class am.progress.ProgressWrapper:am.ui.b.BaseObject
---@field src am.net.src
---@field progress am.e.ProgressEvent
---@field output cc.output
---@field frame am.ui.Frame
---@field names table<string, boolean>
local ProgressWrapper = BaseObject:extend("am.progress.ProgressWrapper")
---@param src am.net.src
---@param progress am.e.ProgressEvent
---@param output cc.output
---@param frame am.ui.Frame
function ProgressWrapper:init(src, progress, output, frame)
    v.expect(1, src, "table")
    v.expect(2, progress, "table")
    v.expect(3, output, "table")
    v.expect(4, frame, "table")
    ProgressWrapper.super.init(self)

    self.src = src
    self.progress = progress
    self.frame = frame
    self.output = output
    self.names = {}
    return self
end

function ProgressWrapper:getBaseId()
    return self.frame.id .. ".i"
end

function ProgressWrapper:render()
    if self.frame.visible then
        local fs = self.frame:makeScreen(self.output)
        fs.clear()
        self.frame:render(self.output)
    end
end

function ProgressWrapper:createUI()
    self:update(self.src, self.progress)
    self:render()
end

---@param src am.net.src
---@param event am.e.ProgressEvent
function ProgressWrapper:update(src, event)
    self.progress = event
end

---@param src am.net.src
---@param pos am.p.TurtlePosition
function ProgressWrapper:updatePosition(src, pos)
end

---@param src am.net.src
---@param status string
function ProgressWrapper:updateStatus(src, status)
end

---@param src am.net.src
---@param event string Event name
---@param args table
function ProgressWrapper:handle(src, event, args)
end

return ProgressWrapper
