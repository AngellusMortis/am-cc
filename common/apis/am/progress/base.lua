local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local BaseObject = require("am.ui.base").BaseObject

local ui = require("am.ui")

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
    self.names = {}
    return self
end

function ProgressWrapper:render()
    self.frame:render(self.output)
end

function ProgressWrapper:createUI()
    self:update(self.progress)
    self:render()
end

---@param event am.e.ProgressEvent
function ProgressWrapper:update(event)
    self.progress = event
end

---@param status string
function ProgressWrapper:updateStatus(status)
end

---@param event string Event name
---@param args table
function ProgressWrapper:handle(event, args)
end

return ProgressWrapper
