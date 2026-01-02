-- THDN打印服务器CUPS控制器
-- 为LuCI界面提供CUPS管理功能

module("luci.controller.cups", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/cups") then
		return
	end
	
	local page = entry({"admin", "services", "cups"}, 
		cbi("cups"), 
		_("Print Server"), 
		60)
	page.dependent = true
	page.acl_depends = { "luci-app-cups" }
	
	entry({"admin", "services", "cups", "status"}, 
		call("action_status")).leaf = true
	
	entry({"admin", "services", "cups", "restart"}, 
		call("action_restart")).leaf = true
end

function action_status()
	local status = {
		running = (sys.call("pidof cupsd >/dev/null") == 0),
		printers = {}
	}
	
	-- 获取打印机列表
	local printers = sys.exec("lpstat -p 2>/dev/null")
	if printers and #printers > 0 then
		for line in printers:gmatch("[^\r\n]+") do
			local name, state = line:match("printer%s+([^%s]+)%s+([^%s]+)")
			if name and state then
				table.insert(status.printers, {
					name = name,
					state = state
				})
			end
		end
	end
	
	luci.http.prepare_content("application/json")
	luci.http.write_json(status)
end

function action_restart()
	local result = sys.call("/etc/init.d/cups restart >/dev/null 2>&1")
	luci.http.prepare_content("application/json")
	luci.http.write_json({ 
		success = (result == 0),
		message = result == 0 and "CUPS服务重启成功" or "CUPS服务重启失败"
	})
end
