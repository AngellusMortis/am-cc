require(settings.get("ghu.base").."core/apis/ghu")local a=require("am.tree")local b=require("am.core")local function c(d)if d==nil then d="true"end;d=b.strBool(d)a.harvestTrees(not d)end;c(arg[1])
