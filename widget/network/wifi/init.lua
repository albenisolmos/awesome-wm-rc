local spawn     = require('awful.spawn')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi
local apps      = require 'apps'
local network   = require 'widget.network'

local wifi = network( beautiful.icon_wifi_on, 'Wi-fi' )

wifi:actions {
	on_click = function()
		if wifi:get_status() then
			awesome.emit_signal('wifi::status', true)
		else
			awesome.emit_signal('wifi::status', false)
		end
	end,
	on_hold = function()
		spawn(apps.network_manager)
	end
}

awesome.connect_signal('wifi::status', function(status)
	if status then
		wifi:on()
	else
		wifi:off()
	end
end)

-- Update wifi status once for each 4 second
awesome.connect_signal('wifi::update', function(essid)
	if essid then
		wifi:connect(essid)
	else
		if wifi:get_status() then
			wifi:on()
		else
			wifi:off()
		end
	end
end)

-- Update wifi status in startup
spawn.easy_async('bash -c "nmcli radio wifi"', function(stdout)
	stdout = string.gsub(stdout, '^%s*(.-)%s*$', '%1')
	if stdout == 'disabled' then
		awesome.emit_signal('wifi::status', false)
	else
		awesome.emit_signal('wifi::status', true)
	end
end)


return wifi
