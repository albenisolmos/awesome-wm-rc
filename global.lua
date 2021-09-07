local gtimer  = require('gears.timer')
local spawn   = require('awful.spawn')
local naughty = require('naughty')

awesome.set_preferred_icon_size(64)

awesome.connect_signal('sound::level', function(level)
	spawn.with_shell('pactl set-sink-volume @DEFAULT_SINK@ ' .. level,
	false)
end)

-- Update wifi
local wifi_updater = gtimer {
	timeout = 5,
	autostart = false,
	call_now = true,
	callback = function()
		spawn.easy_async('bash -c "iw dev wlp3s0 link"',
		function(stdout)
			stdout = stdout:match('SSID: (.-)\n')
			_G.essid = stdout
			awesome.emit_signal('wifi::update', stdout)
		end)
	end
}

awesome.connect_signal('wifi::status', function(status)
	if status then
		status = 'on'
		wifi_updater:start()
	else
		status = 'off'
		wifi_updater:stop()
	end
	spawn.with_shell('nmcli radio wifi ' .. status)
end)

client.connect_signal('request::unmanage', function()
	awesome.emit_signal('topbar::update')
	awesome.emit_signal('dock::update')
end)

screen.connect_signal('tag::history::update', function()
	awesome.emit_signal('topbar::update')
	awesome.emit_signal('popup::hide')
	awesome.emit_signal('notifcenter::hide')
	awesome.emit_signal('dock::update')
end)

awesome.connect_signal('popup::visible', function(visible)
	if visible then
		update_hardwareMonitor:start()
		update_hardwareMonitor:emit_signal('timeout')
	else
		update_hardwareMonitor:stop()
	end
end)

update_hardwareMonitor = gtimer {
	timeout = 5,
	autostart = false,
	callback = function()
		-- Update cpu usage
		spawn.easy_async([[bash -c "awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else print ($2+$4-u1) * 100 / (t-t1); }' <(grep 'cpu ' /proc/stat) <(sleep 1;grep 'cpu ' /proc/stat)"]],
		function(stdout)
			local percent, value
			percent = tonumber(stdout)
			value = math.floor(stdout + 0.5)
			awesome.emit_signal('cpu_usage::update', value)
			collectgarbage('collect')
		end)

		-- Update cpu temperature
		spawn.easy_async('bash -c sensors',
		function(stdout)
			local core0, core1, value
			core0 = stdout:match('Core 0: (.-)\n'):sub(8,11)
			core1 = stdout:match('Core 1: (.-)\n'):sub(8,11)
			value = (core0 + core1) / 2
			awesome.emit_signal('temperature_level::update', value)
			collectgarbage('collect')
		end)

		-- Update harddrive usage
		spawn.easy_async([[bash -c "df -h /home|grep '^/' | awk '{print $5}'"]],
		function(stdout)
			local value = tonumber(string.sub(stdout, 1, 2))
			awesome.emit_signal('harddrive_usage::update', value)
			collectgarbage('collect')
		end)

		-- Update ram usage
		spawn.easy_async('bash -c free | grep -z Mem.*Swap.*',
		function(stdout)
			local total, used, free, shared, buff_cache, available, total_swap, used_swap, free_swap = stdout:match('(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)')
			value = used / total * 100
			awesome.emit_signal('ram_usage::update', value)
			collectgarbage('collect')
		end)
	end
}

awesome.connect_signal('notif', function(notif)
	naughty.notification {
		title = 'Test',
		text = tostring(notif)
	}
end)

_G.notif = function(str)
	naughty.notification {
		title = 'Test',
		text = tostring(notif)
	}
end
