require(settings.get("ghu.base").."core/apis/ghu")local a=require("am.quarry")local function b()if a.canResume()then a.runJob(true)end end;b()
