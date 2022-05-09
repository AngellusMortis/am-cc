local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local BaseObject = require("am.ui.base").BaseObject

local ui = require("am.ui")

---@class am.progress.ProgressWrapper:am.ui.b.BaseObject
---@field src am.net.src
---@field progress am.e.ProgressEvent
---@field screen am.ui.Screen
local ProgressWrapper = BaseObject:extend("am.progress.ProgressWrapper")
function ProgressWrapper:init(src, progress, output)
    v.expect(1, src, "table")
    v.expect(2, progress, "table")
    v.expect(3, output, "table")
    ProgressWrapper.super.init(self)

    self.src = src
    self.progress = progress
    self.screen = ui.Screen(output, {id="screen." .. src.id, backgroundColor=colors.black, textColor=colors.white})
    return self
end

function ProgressWrapper:createUI()
    self:update(self.progress)
    self.screen:render()
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
