-- THDN打印服务器CUPS配置模型
-- LuCI CBI模型定义

local fs = require "nixio.fs"
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()

m = Map("cups", translate("CUPS Print Server"),
	translate("Configure CUPS printing service for THDN Print Server"))

s = m:section(TypedSection, "cups", translate("General Settings"))
s.anonymous = true
s.addremove = false

o = s:option(Flag, "enabled", translate("Enable CUPS"))
o.default = o.enabled
o.rmempty = false

o = s:option(Value, "port", translate("Port"))
o.datatype = "port"
o.default = "631"
o.rmempty = false

o = s:option(Flag, "web_interface", translate("Web Interface"))
o.default = o.enabled
o.rmempty = false

o = s:option(Flag, "remote_admin", translate("Remote Administration"))
o.default = o.disabled
o.rmempty = false

-- 打印机配置部分
s = m:section(TypedSection, "printer", translate("Printers"))
s.anonymous = true
s.addremove = true
s.template = "cbi/tblsection"

o = s:option(Value, "name", translate("Printer Name"))
o.rmempty = false

o = s:option(ListValue, "type", translate("Type"))
o:value("usb", translate("USB Printer"))
o:value("network", translate("Network Printer"))
o.default = "usb"
o.rmempty = false

o = s:option(Value, "device", translate("Device URI"))
o.placeholder = "usb://HP/LaserJet%201020"
o.rmempty = false

o = s:option(Value, "ppd", translate("PPD File"))
o.placeholder = "/usr/share/cups/model/HP-LaserJet_1020.ppd"
o.rmempty = false

o = s:option(Flag, "enabled", translate("Enable"))
o.default = o.enabled
o.rmempty = false

-- 状态显示
s = m:section(TypedSection, "status", translate("Service Status"))
s.anonymous = true
s.addremove = false

local cups_running = (sys.call("pidof cupsd >/dev/null") == 0)
local status_text = cups_running and 
	"<span style='color:green'>Running</span>" or 
	"<span style='color:red'>Stopped</span>"

s:option(DummyValue, "_status", translate("CUPS Status")).value = status_text

-- 已连接打印机
local printers = {}
local lpstat_output = sys.exec("lpstat -p 2>/dev/null")
if lpstat_output and #lpstat_output > 0 then
	for line in lpstat_output:gmatch("[^\r\n]+") do
		local name, state = line:match("printer%s+([^%s]+)%s+([^%s]+)")
		if name and state then
			table.insert(printers, name .. " (" .. state .. ")")
		end
	end
end

local printer_text = #printers > 0 and table.concat(printers, ", ") or "No printers found"
s:option(DummyValue, "_printers", translate("Connected Printers")).value = printer_text

-- 重启按钮
o = s:option(Button, "_restart")
o.title = translate("Restart CUPS")
o.inputtitle = translate("Restart")
o.inputstyle = "action"
function o.write()
	sys.call("/etc/init.d/cups restart >/dev/null 2>&1")
end

return m
