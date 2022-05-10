require(settings.get("ghu.base") .. "core/apis/ghu")

local core = require("am.core")
local e = require("am.event")

local colonies = {}

local s = {}
s.mods = {
    name = "colonies.blacklistedMods",
    default = {
        ["minecraft"] = true,
        ["domum_ornamentum"] = true,
        ["minecolonies"] = true,
    },
    type = "table"
}
s.maxStacks = {
    name = "colonies.maxStacks",
    default = 4,
    type = "number"
}
colonies.s = core.makeSettingWrapper(s)

local COLONY = nil

---@return table
local function getColony()
    if COLONY == nil then
        COLONY = peripheral.find("colonyIntegrator")
        if COLONY == nil then
            error("Could not find Colony Integrator")
        end
    end

    return COLONY
end

---@class cc.colony.location
---@field x number
---@field y number
---@field z number

---@class cc.colony.dim_location:cc.colony.location
---@field world string

---@class cc.colony.player
---@field name string
---@field rank string
---@field present boolean

---@class cc.colony.rank
---@field name string
---@field hostile string
---@field permissions table

---@class cc.colony.player_detail
---@field players cc.colony.player[]
---@field ranks cc.colony.rank[]

---@class cc.colony.skill
---@field level number
---@field xp number

---@class cc.colony.visitor
---@field id number
---@field name string
---@field location cc.colony.location
---@field chair cc.colony.location
---@field age string
---@field sex string
---@field saturation number
---@field happiness number
---@field skills table<string, cc.colony.skill>
---@field cost cc.item

---@class cc.colony.footprint
---@field corner1 cc.colony.location
---@field corner2 cc.colony.location
---@field mirror boolean
---@field rotation number

---@class cc.colony.citizen_ref
---@field id number
---@field name string

---@class cc.colony.building
---@field location cc.colony.location
---@field type string
---@field style string
---@field level number
---@field maxLevel number
---@field name string
---@field claimRadius number
---@field built boolean
---@field wip boolean
---@field priority number
---@field footprint cc.colony.footprint
---@field citizens cc.colony.citizen_ref[]
---@field storageBlocks number
---@field storageSlots number
---@field guarded boolean

---@class cc.colony.request
---@field count number
---@field desc string
---@field items cc.item
---@field minCount number
---@field name string
---@field state string
---@field target string

---@class cc.colony.home_location
---@field level number
---@field location cc.colony.location
---@field type string

---@class cc.colony.work_location
---@field level number
---@field location cc.colony.location
---@field name string
---@field type string

---@class cc.colony.citizen
---@field id number
---@field name string
---@field location cc.colony.location
---@field bedPos cc.colony.location
---@field betterFood boolean
---@field home cc.colony.home_location
---@field isAsleep boolean
---@field isIdle boolean
---@field work cc.colony.work_location
---@field state string
---@field age string
---@field gender string
---@field saturation number
---@field happiness number
---@field skills table<string, cc.colony.skill>
---@field health number
---@field maxHealth number
---@field armor number
---@field toughness number

---@class cc.colony_base
---@field id number
---@field name string
---@field style string
---@field active boolean
---@field location cc.colony.dim_location
---@field happiness number
---@field raid boolean
---@field citizens number
---@field maxCitizens number

---@class cc.colony:cc.colony_base
---@field graves number
---@field constructionCount number
---@field tavernCount number
---@field buildings cc.colony.building[]
---@field players cc.colony.player[]
---@field visitorCount number
---@field visitors table<number, cc.colony.visitor>
---@field citizenCount number
---@field citizens table<number, cc.colony.citizen>
---@field requests cc.colony.request[]

---@return cc.colony
local function pollColony()
    if colony == nil or not colony.isValid() then
        error("Could not find colony info")
    end

    local c = getColony()
    local status = colony.getInfo()
    ---@cast status cc.colony_base

    if not status.active then
        error("Colony is not active")
    end

    status.graves = c.amountOfGraves()
    status.constructionCount = c.amountOfConstructionSites()
    status.players = colony.getPlayers().players
    status.requests = colony.getRequests()
    status.buildings = colony.getBuildings()
    status.tavernCount = 0
    for _, building in ipairs(status.buildings) do
        if building.type == "tavern" and building.level > 0 then
            status.tavernCount = status.tavernCount + 1
            break
        end
    end

    local visitors = colony.getVisitors()
    status.visitorCount = #visitors
    status.visitors = {}
    for _, visitor in ipairs(visitors) do
        status.visitors[visitor.id] = visitor
    end

    local citizens = c.getCitizens()
    status.citizenCount = #citizens
    status.citizens = {}
    for _, citizen in ipairs(citizens) do
        status.citizens[citizen.id] = citizen
    end
    ---@cast status cc.colony

    e.ColonyStatusPollEvent(status):send()
    return status
end

colonies.pollColony = pollColony

return colonies
