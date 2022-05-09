local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local BaseObject = require("am.ui.base").BaseObject
local object = require("ext.object")

local log = require("am.log")
local e = require("am.event")

local ProgressWrapper = require("am.progress.base")

---@class am.progress.ColonyProgress:am.ui.b.BaseObject
---@field id number
---@field status cc.colony|nil
local ColonyProgress = BaseObject:extend("am.progress.ColonyProgress")
function ColonyProgress:init(id)
    ColonyProgress.super.init(self)

    self.id = id
    self.status = nil
    return self
end

---@class am.progress.ColoniesWrapper:am.progress.ProgressWrapper
---@field progress am.progress.ColonyProgress
local ColoniesWrapper = ProgressWrapper:extend("am.progress.QuarryWrapper")
function ColoniesWrapper:init(src, id, output)
    ColoniesWrapper.super.init(self, src, ColonyProgress(id), output)
    self.names = {
        [e.c.Event.Colonies.status_poll] = true,
    }
    return self
end

function ColoniesWrapper:createUI()


    ColoniesWrapper.super.createUI(self)
end

---@param event am.e.ColoniesEvent
function ColoniesWrapper:update(event)
    if event.name == e.c.Event.Colonies.status_poll then
        ---@cast event am.e.ColoniesScanEvent
        self.progress.status = event.status
    end
end

---@param status string
function ColoniesWrapper:updateStatus(status)

end

---@param event string Event name
---@param args table
function ColoniesWrapper:handle(event, args)

end

return ColoniesWrapper
