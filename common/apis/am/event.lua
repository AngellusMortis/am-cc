local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local BaseEvent = require("am.ui").e.BaseEvent

local h = require("am.helpers")

local e = {}

local initalizedNetwork = false
e.online = false
e.type = "am.net"

---@class am.net.src
---@field id number
---@field label string

---@class am.net
---@field type "am.net"
---@field src am.net.src
---@field name string
---@field event am.e.DistributedEvent
---@field signature any

local function initNetwork()
    if initalizedNetwork then
        return
    end

    e.online = false
    local modems = { peripheral.find("modem", function(name, modem)
        return modem.isWireless()
    end) }

    if #modems > 0 then
        rednet.open(peripheral.getName(modems[1]))
        e.online = true
    end
    initalizedNetwork = true
end

---@return am.net.src
local function getComputer()
    return {
        id = os.getComputerID(),
        label = os.computerLabel()
    }
end

e.c = {}

e.c.Turtle = {}
---@type table<string, number>
e.c.Turtle.Direction = {
    Up = -1,
    Down = 0,
    Front = 1,
    Right = 2,
    Back = 3,
    Left = 4
}
e.c.Turtle.GoTo = {
    Node = 0,
    Origin = 1,
    Return = 2,
}

---@type table<string, boolean>
e.broadcastMap = {
    ["am.progress_quarry"] = true,

    ["am.pathfind_position"] = false,
    ["am.pathfind_node"] = false,
    ["am.pathfind_reset_nodes"] = false,
    ["am.pathfind_reset"] = false,
    ["am.pathfind_turn"] = false,
    ["am.pathfind_go_to"] = false,

    ["am.turtle_started"] = false,
    ["am.turtle_paused"] = false,
    ["am.turtle_exited"] = false,
    ["am.turtle_request_halt"] = false,
    ["am.turtle_request_pause"] = false,
    ["am.turtle_request_continue"] = false,
    ["am.turtle_empty"] = false,
    ["am.turtle_fetch_fill"] = false,
    ["am.turtle_refuel"] = false,
    ["am.turtle_dig"] = false,
    ["am.turtle_error"] = false,
}

e.c.Event = {}
---@type table<string, string>
e.c.Event.Progress = {
    quarry = "am.progress_quarry"
}
e.c.Event.Pathfind = {
    position = "am.pathfind_position",
    node = "am.pathfind_node",
    reset_nodes = "am.pathfind_reset_nodes",
    reset = "am.pathfind_reset",
    turn = "am.pathfind_turn",
    go_to = "am.pathfind_go_to",
}
e.c.Event.Turtle = {
    started = "am.turtle_started",
    paused = "am.turtle_paused",
    exited = "am.turtle_exited",
    request_halt = "am.turtle_request_halt",
    request_pause = "am.turtle_request_pause",
    request_continue = "am.turtle_request_continue",
    empty = "am.turtle_empty",
    fetch_fill = "am.turtle_fetch_fill",
    refuel = "am.turtle_refuel",
    dig = "am.turtle_dig",
    error = "am.turtle_error"
}

---@class am.e.DistributedEvent:am.ui.e.BaseEvent
local DistributedEvent = BaseEvent:extend("am.e.DistributedEvent")
e.DistributedEvent = DistributedEvent
function DistributedEvent:init(name)
    v.expect(1, name, "string")
    DistributedEvent.super.init(self, name)

    return self
end

---@param signature any
---@return boolean
function DistributedEvent:validate(signature)
    return true
end

---@return any
function DistributedEvent:sign()
    return ""
end

function DistributedEvent:send()
    os.queueEvent(self.name, self)

    if e.broadcastMap[self.name] then
        initNetwork()
        if e.online then
            rednet.broadcast({
                type = e.type,
                src = getComputer(),
                name = self.name,
                event = self,
                signature = self:sign()
            })
        end
    end
end

---@class am.e.ProgressEvent:am.e.DistributedEvent
local ProgressEvent = DistributedEvent:extend("am.e.ProgressEvent")
e.ProgressEvent = ProgressEvent
function ProgressEvent:init(name)
    v.expect(1, name, "string")
    ProgressEvent.super.init(self, name)

    return self
end

---@class am.e.QuarryProgressEvent:am.e.ProgressEvent
---@param pos am.p.TurtlePosition
---@param job am.q.QuarryJob
---@param progress am.q.QuarryProgress
local QuarryProgressEvent = ProgressEvent:extend("am.e.QuarryProgressEvent")
e.QuarryProgressEvent = QuarryProgressEvent
function QuarryProgressEvent:init(pos, job, progress)
    v.expect(1, pos, "table")
    v.expect(2, job, "table")
    v.expect(3, progress, "table")
    h.requirePosition(1, pos)
    QuarryProgressEvent.super.init(self, e.c.Event.Progress.quarry)

    self.pos = pos
    self.job = job
    self.progress = progress

    return self
end

-- eventLib.b.progressQuarry = function(job, progress, pos)
--     v.expect(1, job, "table")
--     v.expect(2, progress, "table")
--     v.expect(3, pos, "table")

--     eventLib.b.raw({eventLib.e.progress, eventLib.e.progress_quarry, job, progress, pos})
-- end

---@class am.e.PathfindEvent:am.e.DistributedEvent
local PathfindEvent = DistributedEvent:extend("am.e.PathfindEvent")
e.PathfindEvent = PathfindEvent
function PathfindEvent:init(name)
    v.expect(1, name, "string")
    PathfindEvent.super.init(self, name)

    return self
end

---@class am.e.PositionUpdateEvent:am.e.PathfindEvent
---@field position am.p.TurtlePosition
local PositionUpdateEvent = PathfindEvent:extend("am.e.PositionUpdateEvent")
e.PositionUpdateEvent = PositionUpdateEvent
function PositionUpdateEvent:init(position)
    v.expect(1, position, "table")
    h.requirePosition(1, position)
    PositionUpdateEvent.super.init(self, e.c.Event.Pathfind.position)

    self.position = position
    return self
end

---@class am.e.ResetPathfindEvent:am.e.PathfindEvent
local ResetPathfindEvent = PathfindEvent:extend("am.e.ResetPathfindEvent")
e.ResetPathfindEvent = ResetPathfindEvent
function ResetPathfindEvent:init()
    ResetPathfindEvent.super.init(self, e.c.Event.Pathfind.reset)

    return self
end

---@class am.e.NewNodeEvent:am.e.PathfindEvent
---@field position am.p.TurtlePosition
---@field isReturn boolean|nil
local NewNodeEvent = PathfindEvent:extend("am.e.NewNodeEvent")
e.NewNodeEvent = NewNodeEvent
function NewNodeEvent:init(position, isReturn)
    v.expect(1, position, "table")
    v.expect(1, isReturn, "boolean", "nil")
    h.requirePosition(1, position)
    NewNodeEvent.super.init(self, e.c.Event.Pathfind.node)
    if isReturn == nil then
        isReturn = false
    end

    self.position = position
    self.isReturn = isReturn
    return self
end

---@class am.e.ResetNodesEvent:am.e.PathfindEvent
---@field isReturn boolean|nil
local ResetNodesEvent = PathfindEvent:extend("am.e.ResetNodesEvent")
e.ResetNodesEvent = ResetNodesEvent
function ResetNodesEvent:init(isReturn)
    v.expect(1, isReturn, "boolean", "nil")
    ResetNodesEvent.super.init(self, e.c.Event.Pathfind.reset_nodes)
    if isReturn == nil then
        isReturn = false
    end

    self.isReturn = isReturn
    return self
end

---@class am.e.FailableTurtleEvent:am.e.PathfindEvent
---@field success boolean|nil
local FailableTurtleEvent = PathfindEvent:extend("am.e.FailableTurtleEvent")
e.FailableTurtleEvent = FailableTurtleEvent
function FailableTurtleEvent:init(name, success)
    v.expect(1, name, "string")
    v.expect(2, success, "boolean", "nil")
    FailableTurtleEvent.super.init(self, name)

    self.success = success
    return self
end

---@class am.e.PathfindTurnEvent:am.e.FailableTurtleEvent
---@field dir number
local PathfindTurnEvent = FailableTurtleEvent:extend("am.e.PathfindTurnEvent")
e.PathfindTurnEvent = PathfindTurnEvent
function PathfindTurnEvent:init(dir, success)
    v.expect(1, dir, "number")
    v.expect(2, success, "boolean", "nil")
    v.range(dir, 1, 4)
    FailableTurtleEvent.super.init(self, e.c.Event.Pathfind.turn, success)

    self.dir = dir
    return self
end

---@class am.e.PathfindGoToEvent:am.e.FailableTurtleEvent
---@field startPos number
---@field destPos number
local PathfindGoToEvent = FailableTurtleEvent:extend("am.e.PathfindGoToEvent")
e.PathfindGoToEvent = PathfindGoToEvent
function PathfindGoToEvent:init(destPos, startPos, gotoType, success)
    v.expect(1, destPos, "table")
    v.expect(2, startPos, "table")
    v.expect(3, gotoType, "number")
    v.expect(4, success, "boolean", "nil")
    h.requirePosition(1, destPos)
    h.requirePosition(2, startPos)
    v.range(gotoType, 0, 2)
    PathfindGoToEvent.super.init(self, e.c.Event.Pathfind.go_to, success)

    self.destPos = destPos
    self.startPos = startPos
    self.gotoType = gotoType
    return self
end

---@class am.e.TurtleEvent:am.e.DistributedEvent
local TurtleEvent = DistributedEvent:extend("am.e.TurtleEvent")
e.TurtleEvent = TurtleEvent
function TurtleEvent:init(name)
    v.expect(1, name, "string")
    TurtleEvent.super.init(self, name)

    return self
end

---@class am.e.TurtleStartedEvent:am.e.TurtleEvent
local TurtleStartedEvent = TurtleEvent:extend("am.e.TurtleStartedEvent")
e.TurtleStartedEvent = TurtleStartedEvent
function TurtleStartedEvent:init()
    TurtleStartedEvent.super.init(self, e.c.Event.Turtle.started)

    return self
end

---@class am.e.TurtlePausedEvent:am.e.TurtleEvent
local TurtlePausedEvent = TurtleEvent:extend("am.e.TurtlePausedEvent")
e.TurtlePausedEvent = TurtlePausedEvent
function TurtlePausedEvent:init()
    TurtlePausedEvent.super.init(self, e.c.Event.Turtle.paused)

    return self
end

---@class am.e.TurtleExitEvent:am.e.TurtleEvent
---@field completed boolean
local TurtleExitEvent = TurtleEvent:extend("am.e.TurtleExitEvent")
e.TurtleExitEvent = TurtleExitEvent
function TurtleExitEvent:init(completed)
    v.expect(1, completed, "boolean")
    TurtleExitEvent.super.init(self, e.c.Event.Turtle.exited)

    self.completed = completed
    return self
end

---@class am.e.TurtleRequestHaltEvent:am.e.TurtleEvent
local TurtleRequestHaltEvent = TurtleEvent:extend("am.e.TurtleRequestHaltEvent")
e.TurtleRequestHaltEvent = TurtleRequestHaltEvent
function TurtleRequestHaltEvent:init()
    TurtleRequestHaltEvent.super.init(self, e.c.Event.Turtle.request_halt)

    return self
end

---@class am.e.TurtleRequestPauseEvent:am.e.TurtleEvent
local TurtleRequestPauseEvent = TurtleEvent:extend("am.e.TurtleRequestPauseEvent")
e.TurtleRequestPauseEvent = TurtleRequestPauseEvent
function TurtleRequestPauseEvent:init()
    TurtleRequestPauseEvent.super.init(self, e.c.Event.Turtle.request_pause)

    return self
end

---@class am.e.TurtleRequestContinueEvent:am.e.TurtleEvent
local TurtleRequestContinueEvent = TurtleEvent:extend("am.e.TurtleRequestHaltEvent")
e.TurtleRequestContinueEvent = TurtleRequestContinueEvent
function TurtleRequestContinueEvent:init()
    TurtleRequestContinueEvent.super.init(self, e.c.Event.Turtle.request_continue)

    return self
end

---@class am.e.TurtleErrorEvent:am.e.TurtleEvent
---@field error string
local TurtleErrorEvent = TurtleEvent:extend("am.e.TurtleErrorEvent")
e.TurtleErrorEvent = TurtleErrorEvent
function TurtleErrorEvent:init(error)
    v.expect(1, error, "string")
    TurtleErrorEvent.super.init(self, e.c.Event.Turtle.error)

    self.error = error
    return self
end

---@class am.e.TurtleCompletableEvent:am.e.TurtleEvent
---@field completed boolean
local TurtleCompletableEvent = TurtleEvent:extend("am.e.TurtleCompletableEvent")
e.TurtleCompletableEvent = TurtleCompletableEvent
function TurtleCompletableEvent:init(name, completed)
    v.expect(1, name, "string")
    v.expect(2, completed, "boolean")
    TurtleCompletableEvent.super.init(self, name)

    self.completed = completed
    return self
end

---@class am.e.TurtleEmptyEvent:am.e.TurtleCompletableEvent
---@field items table<string, cc.item[]>|nil
local TurtleEmptyEvent = TurtleCompletableEvent:extend("am.e.TurtleEmptyEvent")
e.TurtleEmptyEvent = TurtleEmptyEvent
function TurtleEmptyEvent:init(completed, items)
    v.expect(1, completed, "boolean")
    v.expect(2, items, "table", "nil")
    if completed and items == nil then
        error("Must include items if is complete")
    end
    TurtleEmptyEvent.super.init(self, e.c.Event.Turtle.empty, completed)

    self.items = items
    return self
end

---@class am.e.TurtleFetchFillEvent:am.e.TurtleCompletableEvent
---@field item cc.item[]|nil
local TurtleFetchFillEvent = TurtleCompletableEvent:extend("am.e.TurtleFetchFillEvent")
e.TurtleFetchFillEvent = TurtleFetchFillEvent
function TurtleFetchFillEvent:init(completed, item)
    v.expect(1, completed, "boolean")
    v.expect(2, item, "table", "nil")
    if completed and item == nil then
        error("Must include item if is complete")
    end
    TurtleFetchFillEvent.super.init(self, e.c.Event.Turtle.fetch_fill, completed)

    self.item = item
    return self
end

---@class am.e.TurtleRefuelEvent:am.e.TurtleCompletableEvent
---@field requested number|nil
---@field oldLevel number|nil
---@field newLevel number|nil
local TurtleRefuelEvent = TurtleCompletableEvent:extend("am.e.TurtleRefuelEvent")
e.TurtleRefuelEvent = TurtleRefuelEvent
function TurtleRefuelEvent:init(completed, requested, oldLevel, newLevel)
    v.expect(1, completed, "boolean")
    v.expect(2, requested, "number", "nil")
    v.expect(3, oldLevel, "number", "nil")
    v.expect(4, newLevel, "number", "nil")
    if completed and (oldLevel == nil or newLevel == nil) then
        error("Must include levels if is complete")
    end
    TurtleRefuelEvent.super.init(self, e.c.Event.Turtle.refuel, completed)

    self.requested = requested
    self.oldLevel = oldLevel
    self.newLevel = newLevel
    return self
end

---@class am.e.TurtleDigEvent:am.e.TurtleCompletableEvent
---@field count number
local TurtleDigEvent = TurtleCompletableEvent:extend("am.e.TurtleDigEvent")
e.TurtleDigEvent = TurtleDigEvent
function TurtleDigEvent:init(completed, moveDir, count)
    v.expect(1, completed, "boolean")
    v.expect(2, moveDir, "number")
    v.expect(3, count, "number")
    v.range(moveDir, -1, 1)
    TurtleDigEvent.super.init(self, e.c.Event.Turtle.dig, completed)

    self.moveDir = moveDir
    self.count = count
    return self
end

e.initNetwork = initNetwork
e.getComputer = getComputer

return e