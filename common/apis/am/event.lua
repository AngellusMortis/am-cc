local v = require("cc.expect")

require(settings.get("ghu.base") .. "core/apis/ghu")

local BaseEvent = require("am.ui").e.BaseEvent

local h = require("am.helpers")
local core = require("am.core")
local hmac = require("ext.hmac")
local log = require("am.log")

local e = {}

local s = {}
s.signing = {
    name = "event.signing",
    default = false,
    type = "boolean"
}
s.psk = {
    name = "event.psk",
    default = "",
    type = "string"
}
s = core.makeSettingWrapper(s)

local INITALIZED_NETWORK = false
local MESSAGE_LIFE = 72000 * 3 -- 3 seconds of "game time"
e.online = false
e.type = "am.net"

---@class am.net.src
---@field id number
---@field label string|nil

---@class am.raw
---@field type "am.net"
---@field src am.net.src
---@field name string
---@field event am.e.DistributedEvent

---@class am.net:am.raw
---@field signature string|nil
---@field epoch number|nil

---@class am.turtle_request:am.net
---@field event am.e.TurtleRequestHaltEvent|am.e.TurtleRequestPauseEvent|am.e.TurtleRequestContinueEvent

local function initNetwork()
    if INITALIZED_NETWORK then
        return
    end

    if not s.signing.get() or s.psk.get() ~= "" then
        e.online = false
        local modems = { peripheral.find("modem", function(name, modem)
            return modem.isWireless()
        end) }

        if #modems > 0 then
            rednet.open(peripheral.getName(modems[1]))
            e.online = true
        end
    end
    INITALIZED_NETWORK = true
end

---@return am.net.src
local function getComputer()
    return {
        id = os.getComputerID(),
        label = os.computerLabel()
    }
end

---@return am.net?
local function receive()
    if not e.online then
        return nil
    end

    local _, data = rednet.receive(nil, 3)
    if data ~= nil and data.type == e.type then
        if e.DistributedEvent.validate(nil, core.copy(data, false)) then
            return data
        end
    end
    return nil
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

---@type table<string, number>
e.c.RunType = {
    Running = 1,
    Completed = 2,
    Paused = 3,
    Halted = 4
}

---@type table<string, boolean>
e.broadcastMap = {
    ["am.error"] = false,
    ["am.ping"] = true,

    ["am.progress_quarry"] = true,
    ["am.progress_collect"] = true,
    ["am.progress_tree"] = true,

    ["am.pathfind_position"] = true,
    ["am.pathfind_node"] = false,
    ["am.pathfind_reset_nodes"] = false,
    ["am.pathfind_reset"] = false,
    ["am.pathfind_turn"] = false,
    ["am.pathfind_go_to"] = false,

    ["am.turtle_started"] = true,
    ["am.turtle_paused"] = true,
    ["am.turtle_exited"] = true,
    ["am.turtle_request_halt"] = true,
    ["am.turtle_request_pause"] = true,
    ["am.turtle_request_continue"] = true,
    ["am.turtle_empty"] = false,
    ["am.turtle_fetch_fill"] = false,
    ["am.turtle_refuel"] = false,
    ["am.turtle_dig"] = false,
    ["am.turtle_error"] = false,
    ["am.turtle_error_clear"] = false,

    ["am.colonies_status_poll"] = true,
    ["am.colonies_warehouse_poll"] = true,
}

e.c.Lookup = {}
e.c.Lookup.Progress = {
    ["am.progress_quarry"] = true,
    ["am.progress_collect"] = true,
    ["am.progress_tree"] = true,
    ["am.colonies_status_poll"] = true,
    ["am.colonies_warehouse_poll"] = true,
}

e.c.Event = {}
---@type table<string, string>
e.c.Event.Common = {
    error = "am.error",
    ping = "am.ping",
}
---@type table<string, string>
e.c.Event.Progress = {
    quarry = "am.progress_quarry",
    collect = "am.progress_collect",
    tree = "am.progress_tree",
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
    error = "am.turtle_error",
    error_clear = "am.turtle_error_clear"
}
e.c.Event.Colonies = {
    warehouse_poll = "am.colonies_warehouse_poll",
    status_poll = "am.colonies_status_poll",
}

---@class am.e.DistributedEvent:am.ui.e.BaseEvent
local DistributedEvent = BaseEvent:extend("am.e.DistributedEvent")
e.DistributedEvent = DistributedEvent
---@param name string
---@return am.e.DistributedEvent
function DistributedEvent:init(name)
    v.expect(1, name, "string")
    DistributedEvent.super.init(self, name)

    return self
end

---@param message am.net
---@return boolean
function DistributedEvent:validate(message)
    if not s.signing.get() and message.signature == nil then
        return true
    end

    if not e.online then
        log.debug("bad message: offline")
        return false
    end

    if message.signature == nil or message.epoch == nil then
        log.debug("bad message: missing signature")
        return false
    end

    if type(message.signature) ~= "string" or type(message.epoch) ~= "number" then
        log.debug("bad message: invalid signature")
        return false
    end

    local now = os.epoch()
    if message.epoch > now or (now - MESSAGE_LIFE) > message.epoch then
        log.debug(string.format(
            "bad message: outdated signature: %s %s %s", message.src, now, message.epoch
        ))
        return false
    end

    local provided = message.signature
    message.signature = nil
    local actual = hmac.hmac(hmac.sha256, s.psk.get(), log.format(message))
    local valid = provided == actual
    if not valid then
        log.debug(string.format(
            "bad message: mismatch: %s %s %s", log.format(message.src), provided, actual
        ))
    end
    return valid
end

---@param message am.raw
---@return am.net
function DistributedEvent:sign(message)
    if not s.signing.get() then
        return message
    end
    message.epoch = os.epoch()
    local signature = hmac.hmac(hmac.sha256, s.psk.get(), log.format(message))
    message.signature = signature
    return message
end

function DistributedEvent:send()
    os.queueEvent(self.name, self)

    if e.broadcastMap[self.name] then
        initNetwork()
        if e.online then
            rednet.broadcast(self:sign({
                type = e.type,
                src = getComputer(),
                name = self.name,
                event = core.copy(self, false),
            }))
        end
    end
end

---@class am.e.ErrorEvent:am.e.DistributedEvent
---@field error string
local ErrorEvent = DistributedEvent:extend("am.e.ErrorEvent")
e.ErrorEvent = ErrorEvent
---@param msg string
---@return am.e.ErrorEvent
function ErrorEvent:init(msg)
    v.expect(1, msg, "string")
    ErrorEvent.super.init(self, e.c.Event.Common.error)

    self.error = msg
    return self
end

---@class am.e.PingEvent:am.e.ProgressEvent
local PingEvent = DistributedEvent:extend("am.e.PingEvent")
e.PingEvent = PingEvent
---@return am.e.PingEvent
function PingEvent:init()
    PingEvent.super.init(self, e.c.Event.Common.ping)
    return self
end

---@class am.e.ProgressEvent:am.e.DistributedEvent
local ProgressEvent = DistributedEvent:extend("am.e.ProgressEvent")
e.ProgressEvent = ProgressEvent
---@param name string
---@return am.e.ProgressEvent
function ProgressEvent:init(name)
    v.expect(1, name, "string")
    ProgressEvent.super.init(self, name)

    return self
end

---@class am.collect_rate
---@field item cc.item
---@field rate number

---@class am.e.CollectProgressEvent:am.e.ProgressEvent
---@field status string
---@field rates am.collect_rate[]
local CollectProgressEvent = ProgressEvent:extend("am.e.CollectProgressEvent")
e.CollectProgressEvent = CollectProgressEvent
---@param status string
---@param rates am.collect_rate[]
---@return am.e.CollectProgressEvent
function CollectProgressEvent:init(status, rates)
    v.expect(1, rates, "table")
    CollectProgressEvent.super.init(self, e.c.Event.Progress.collect)

    self.status = status
    self.rates = rates

    return self
end

---@class am.e.TreeProgressEvent:am.e.CollectProgressEvent
---@field pos am.p.TurtlePosition
---@field trees am.t.tree_location[]
---@field status string
local TreeProgressEvent = CollectProgressEvent:extend("am.e.TreeProgressEvent")
e.TreeProgressEvent = TreeProgressEvent
---@param pos am.p.TurtlePosition
---@param trees am.t.tree_location[]
---@param status string
---@param rates am.collect_rate[]
---@return am.e.TreeProgressEvent
function TreeProgressEvent:init(pos, trees, status, rates)
    v.expect(1, pos, "table")
    v.expect(2, trees, "table")
    v.expect(3, status, "string")
    v.expect(4, rates, "table")
    h.requirePosition(1, pos)
    TreeProgressEvent.super.init(self, status, rates)

    self.name = e.c.Event.Progress.tree
    self.pos = pos
    self.trees = trees

    return self
end

---@class am.e.QuarryProgressEvent:am.e.ProgressEvent
---@field pos am.p.TurtlePosition
---@field job am.q.QuarryJob
---@field progress am.q.QuarryProgress
local QuarryProgressEvent = ProgressEvent:extend("am.e.QuarryProgressEvent")
e.QuarryProgressEvent = QuarryProgressEvent
---@param pos am.p.TurtlePosition
---@param job am.q.QuarryJob
---@param progress am.q.QuarryProgress
---@return am.e.QuarryProgressEvent
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

---@class am.e.PathfindEvent:am.e.DistributedEvent
local PathfindEvent = DistributedEvent:extend("am.e.PathfindEvent")
e.PathfindEvent = PathfindEvent
---@param name string
---@return am.e.PathfindEvent
function PathfindEvent:init(name)
    v.expect(1, name, "string")
    PathfindEvent.super.init(self, name)

    return self
end

---@class am.e.PositionUpdateEvent:am.e.PathfindEvent
---@field position am.p.TurtlePosition
local PositionUpdateEvent = PathfindEvent:extend("am.e.PositionUpdateEvent")
e.PositionUpdateEvent = PositionUpdateEvent
---@param position am.p.TurtlePosition
---@return am.e.PositionUpdateEvent
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
---@return am.e.ResetPathfindEvent
function ResetPathfindEvent:init()
    ResetPathfindEvent.super.init(self, e.c.Event.Pathfind.reset)

    return self
end

---@class am.e.NewNodeEvent:am.e.PathfindEvent
---@field position am.p.TurtlePosition
---@field isReturn boolean|nil
local NewNodeEvent = PathfindEvent:extend("am.e.NewNodeEvent")
e.NewNodeEvent = NewNodeEvent
---@param position am.p.TurtlePosition
---@param isReturn? boolean
---@return am.e.NewNodeEvent
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
---@param isReturn? boolean
e.ResetNodesEvent = ResetNodesEvent
---@return am.e.ResetNodesEvent
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
---@param name string
---@param success? boolean
---@return am.e.FailableTurtleEvent
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
---@param dir number
---@param success? boolean
---@return am.e.PathfindTurnEvent
function PathfindTurnEvent:init(dir, success)
    v.expect(1, dir, "number")
    v.expect(2, success, "boolean", "nil")
    v.range(dir, 1, 4)
    FailableTurtleEvent.super.init(self, e.c.Event.Pathfind.turn, success)

    self.dir = dir
    return self
end

---@class am.e.PathfindGoToEvent:am.e.FailableTurtleEvent
---@field startPos am.p.TurtlePosition
---@field destPos am.p.TurtlePosition
local PathfindGoToEvent = FailableTurtleEvent:extend("am.e.PathfindGoToEvent")
e.PathfindGoToEvent = PathfindGoToEvent
---@param destPos am.p.TurtlePosition
---@param startPos am.p.TurtlePosition
---@param gotoType number
---@param success? boolean
---@return am.e.PathfindGoToEvent
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
---@param name string
---@return am.e.TurtleEvent
function TurtleEvent:init(name)
    v.expect(1, name, "string")
    TurtleEvent.super.init(self, name)

    return self
end

---@class am.e.TurtleStartedEvent:am.e.TurtleEvent
local TurtleStartedEvent = TurtleEvent:extend("am.e.TurtleStartedEvent")
e.TurtleStartedEvent = TurtleStartedEvent
---@return am.e.TurtleStartedEvent
function TurtleStartedEvent:init()
    TurtleStartedEvent.super.init(self, e.c.Event.Turtle.started)

    return self
end

---@class am.e.TurtlePausedEvent:am.e.TurtleEvent
local TurtlePausedEvent = TurtleEvent:extend("am.e.TurtlePausedEvent")
e.TurtlePausedEvent = TurtlePausedEvent
---@return am.e.TurtlePausedEvent
function TurtlePausedEvent:init()
    TurtlePausedEvent.super.init(self, e.c.Event.Turtle.paused)

    return self
end

---@class am.e.TurtleExitEvent:am.e.TurtleEvent
---@field completed boolean
local TurtleExitEvent = TurtleEvent:extend("am.e.TurtleExitEvent")
e.TurtleExitEvent = TurtleExitEvent
---@param completed boolean
---@return am.e.TurtleExitEvent
function TurtleExitEvent:init(completed)
    v.expect(1, completed, "boolean")
    TurtleExitEvent.super.init(self, e.c.Event.Turtle.exited)

    self.completed = completed
    return self
end

---@class am.e.TurtleRequestHaltEvent:am.e.TurtleEvent
---@field id string
local TurtleRequestHaltEvent = TurtleEvent:extend("am.e.TurtleRequestHaltEvent")
e.TurtleRequestHaltEvent = TurtleRequestHaltEvent
---@param id string
---@return am.e.TurtleRequestHaltEvent
function TurtleRequestHaltEvent:init(id)
    TurtleRequestHaltEvent.super.init(self, e.c.Event.Turtle.request_halt)

    self.id = id
    return self
end

---@class am.e.TurtleRequestPauseEvent:am.e.TurtleEvent
---@field id string
local TurtleRequestPauseEvent = TurtleEvent:extend("am.e.TurtleRequestPauseEvent")
e.TurtleRequestPauseEvent = TurtleRequestPauseEvent
---@param id string
---@return am.e.TurtleRequestPauseEvent
function TurtleRequestPauseEvent:init(id)
    TurtleRequestPauseEvent.super.init(self, e.c.Event.Turtle.request_pause)

    self.id = id
    return self
end

---@class am.e.TurtleRequestContinueEvent:am.e.TurtleEvent
---@field id string
local TurtleRequestContinueEvent = TurtleEvent:extend("am.e.TurtleRequestHaltEvent")
e.TurtleRequestContinueEvent = TurtleRequestContinueEvent
---@param id string
---@return am.e.TurtleRequestContinueEvent
function TurtleRequestContinueEvent:init(id)
    TurtleRequestContinueEvent.super.init(self, e.c.Event.Turtle.request_continue)

    self.id = id
    return self
end

---@class am.e.TurtleErrorEvent:am.e.TurtleEvent
---@field error string
local TurtleErrorEvent = TurtleEvent:extend("am.e.TurtleErrorEvent")
e.TurtleErrorEvent = TurtleErrorEvent
---@param msg string
---@return am.e.TurtleErrorEvent
function TurtleErrorEvent:init(msg)
    v.expect(1, msg, "string")
    TurtleErrorEvent.super.init(self, e.c.Event.Turtle.error)

    self.error = msg
    return self
end

---@class am.e.TurtleErrorClearEvent:am.e.TurtleEvent
local TurtleErrorClearEvent = TurtleEvent:extend("am.e.TurtleErrorClearEvent")
e.TurtleErrorClearEvent = TurtleErrorClearEvent
---@return am.e.TurtleErrorClearEvent
function TurtleErrorClearEvent:init()
    TurtleErrorClearEvent.super.init(self, e.c.Event.Turtle.error_clear)
    return self
end

---@class am.e.TurtleCompletableEvent:am.e.TurtleEvent
---@field completed boolean
local TurtleCompletableEvent = TurtleEvent:extend("am.e.TurtleCompletableEvent")
e.TurtleCompletableEvent = TurtleCompletableEvent
---@param name string
---@param completed boolean
---@return am.e.TurtleCompletableEvent
function TurtleCompletableEvent:init(name, completed)
    v.expect(1, name, "string")
    v.expect(2, completed, "boolean")
    TurtleCompletableEvent.super.init(self, name)

    self.completed = completed
    return self
end

---@class am.e.TurtleEmptyEvent:am.e.TurtleCompletableEvent
---@field items cc.item[]|nil
local TurtleEmptyEvent = TurtleCompletableEvent:extend("am.e.TurtleEmptyEvent")
e.TurtleEmptyEvent = TurtleEmptyEvent
---@param completed boolean
---@param items table<string, cc.item[]>|nil
---@return am.e.TurtleEmptyEvent
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
---@param completed boolean
---@param item cc.item[]|nil
---@return am.e.TurtleFetchFillEvent
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
---@param completed boolean
---@param requested? number
---@param oldLevel? number
---@param newLevel? number
---@return am.e.TurtleRefuelEvent
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
---@param completed boolean
---@param moveDir number
---@param count number
---@return am.e.TurtleDigEvent
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

---@class am.e.ColoniesEvent:am.e.DistributedEvent
local ColoniesEvent = DistributedEvent:extend("am.e.ColoniesEvent")
e.ColoniesEvent = ColoniesEvent
---@param name string
---@return am.e.ColoniesEvent
function ColoniesEvent:init(name)
    v.expect(1, name, "string")
    ColoniesEvent.super.init(self, name)

    return self
end

---@class am.e.ColonyStatusPollEvent:am.e.ColoniesEvent
---@field status cc.colony
local ColonyStatusPollEvent = ColoniesEvent:extend("am.e.ColonyStatusPollEvent")
e.ColonyStatusPollEvent = ColonyStatusPollEvent
---@param status cc.colony
---@param text string
---@return am.e.ColonyStatusPollEvent
function ColonyStatusPollEvent:init(status, text)
    v.expect(1, status, "table")
    ColonyStatusPollEvent.super.init(self, e.c.Event.Colonies.status_poll)

    self.status = status
    self.text = text
    return self
end

---@class am.e.ColonyWarehousePollEvent:am.e.ColoniesEvent
---@field id number
---@field items cc.item.colonies[]
---@field slots number
local ColonyWarehousePollEvent = ColoniesEvent:extend("am.e.ColonyWarehousePollEvent")
e.ColonyWarehousePollEvent = ColonyWarehousePollEvent
---@param id number
---@param items cc.item.colonies[]
---@param usedSlots number
---@param totalSlots number
---@return am.e.ColonyWarehousePollEvent
function ColonyWarehousePollEvent:init(id, items, usedSlots, totalSlots)
    v.expect(1, id, "number")
    v.expect(2, items, "table")
    v.expect(3, usedSlots, "number")
    v.expect(4, totalSlots, "number")
    ColonyWarehousePollEvent.super.init(self, e.c.Event.Colonies.warehouse_poll)

    self.id = id
    self.items = items
    self.usedSlots = usedSlots
    self.totalSlots = totalSlots
    return self
end

e.initNetwork = initNetwork
e.getComputer = getComputer
e.receive = receive

return e
