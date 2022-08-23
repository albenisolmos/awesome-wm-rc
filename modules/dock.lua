local placement = require('awful.placement')
local spawn = require('awful.spawn')
local timer = require('gears.timer')
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local animate = require('utils.animate')
local uclient = require('utils.client')
local partial_show
local timer_callback

local function need_hide_dock()
	local clients = uclient.get_clients()

	if #clients > 0 then
		for _, client in pairs(clients) do
			if (client.maximized or client.fullscreen) and not client.minimized then
				return true
			end
		end
	end

	return false
end

local time_hide_dock = timer {
	timeout = 1,
	autostart = false,
	single_shot = true,
	callback = function ()
		timer_callback()
	end
}

local function dock_show(dock, coord)
	if dock.y == coord then return end
	partial_show = true
	animate.move.y(dock, coord)
	if SETTINGS.dock_autohide then
		dock.ontop = true
		time_hide_dock:start()
	else
		dock:struts({ bottom = dpi(48) })
	end
end

local function dock_hide(dock, coord)
	if dock.y == coord then return end
	partial_show = false
	dock:struts({ bottom = 0 })
	animate.move.y(dock, coord)
end

return { init = function()
	spawn.single_instance('olmos-dock', {
		placement = placement.bottom + placement.center,
		skip_taskbar = true,
		sticky = true,
		callback = function(cli)
			local dock = cli
			local s = cli.screen
			local dock_height = dock.height
			local normal_coord = s.geometry.height - dock_height - dpi(9)
			local offscreen_coord = s.geometry.height + 1

			timer_callback = function()
				dock_hide(dock, offscreen_coord)
			end

			dock:connect_signal('mouse::leave', function()
				if partial_show then
					time_hide_dock:start()
				end
			end)

			dock:connect_signal('mouse::enter', function()
				if time_hide_dock.started then
					time_hide_dock:stop()
				end
			end)

			awesome.connect_signal('dock::kill', function ()
				dock:kill()
				dock = nil
			end)

			awesome.connect_signal('dock::update', function()
				if not dock then return end
				if need_hide_dock() then
					dock_hide(dock, offscreen_coord)
				else
					dock_show(dock, normal_coord)
				end
			end)

			awesome.connect_signal('dock::partial_show', function()
				if not dock or dock.y == normal_coord then return end
				dock.ontop = true
				partial_show = true
				animate.move.y(dock, normal_coord)
				time_hide_dock:start()
			end)

			local function client_toggle_dock(c)
				if c.maximized or c.fullscreen then
					dock.ontop = true
					dock_hide(dock, offscreen_coord)
				else
					if need_hide_dock() then
						return
					else
						dock.ontop = false
						dock_show(dock, normal_coord)
					end
				end
			end

			client.connect_signal('property::maximized', client_toggle_dock)
			client.connect_signal('property::fullscreen', client_toggle_dock)
			tag.connect_signal('property::layout', function(t)
				local clients = t:clients()
				for _, c in pairs(clients) do
					if not c.floating then
						dock.ontop = true
						dock_hide(dock, offscreen_coord)
						return
					end
				end
			end)
		end})

		return {
			on_screen = function(s)
				require('display.hot-corners') {
					screen = s,
					position = 'bottom',
					callback = function()
						awesome.emit_signal('dock::partial_show')
					end
				}
			end
		}
	end
}
