require(settings.get("ghu.base") .. "core/apis/ghu")

local tree = require("am.tree")

if tree.d.canResume.get() then
    tree.harvestTrees(true)
end
