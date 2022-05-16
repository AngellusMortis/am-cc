require(settings.get("ghu.base") .. "core/apis/ghu")

local tree = require("am.tree")

if tree.s.canResume.get() then
    tree.harvestTrees(true)
end
