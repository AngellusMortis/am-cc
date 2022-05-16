require(settings.get("ghu.base") .. "core/apis/ghu")

local tree = require("am.tree")
local core = require("am.core")

---@param autoDiscover string
local function main(autoDiscover)
    if autoDiscover == nil then
        autoDiscover = "true"
    end
    autoDiscover = core.strBool(autoDiscover)
    ---@cast autoDiscover boolean

    tree.harvestTrees(not autoDiscover)
end

main(arg[1])
