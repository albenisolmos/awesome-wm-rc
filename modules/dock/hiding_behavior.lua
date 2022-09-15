local animate = require('utils.animate')
local uclient = require('utils.client')
local gtimer = require('gears.timer')
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local dock = {}
local inscreen_coord
local offscreen_coord
local partial_show

local function dock_hide()
	if dock.y == offscreen_coord then return end
	partial_show = false
	dock:struts({ bottom = 0 })
	animate.move.y(dock, offscreen_coord)
end

local time_hide_dock = gtimer {
	timeout = 1,
	autostart = false,
	single_shot = true,
	callback = function()
		dock_hide()
	end
}

local function dock_show()
	if dock.y == inscreen_coord then return end
	dock.ontop = true
	animate.move.y(dock, inscreen_coord)
	if partial_show then
		time_hide_dock:start()
	end
end

local function is_client_big(cli)
	return (cli.maximized or cli.fullscreen) and
	not cli.minimized
end

local function need_hide_dock()
	local clients = uclient.get_clients()

	for _, cli in pairs(clients) do
		if is_client_big(cli) then
			return true
		end
	end

	return false
end

local function dock_update()
	if not dock then return end
	if need_hide_dock() then
		dock_hide()
	else
		dock_show()
	end
end

local function client_toggle_dock(c)
	if c.maximized or c.fullscreen then
		dock.ontop = true
		dock_hide()
	else
		dock.ontop = false
		dock_show()
	end
end

local function dock_mouse_leave()
	if partial_show then
		time_hide_dock:start()
	end
end

local function dock_mouse_enter()
	if time_hide_dock.started then
		time_hide_dock:stop()
	end
end

local function dock_partial_show()
	partial_show = true
	dock_show()
end

return function(_dock)
	dock = _dock
	local s = dock.screen
	inscreen_coord = s.geometry.height - dpi(52)
	offscreen_coord = s.geometry.height + 1

	awesome.connect_signal('dock::kill', function ()
		dock:kill()
		dock = nil
	end)
	tag.connect_signal('property::layout', function(t) -- TODO separate to function of the signal
		local clients = t:clients()
		for _, c in pairs(clients) do
			if not c.floating then
				dock.ontop = true
				dock_hide()
				return
			end
		end
	end)

	-- shy, hidden
	awesome.connect_signal('dock::hiding_behavior', function(behavior)
		if SETTINGS.dock_hide == 'necessary' then
			client.connect_signal('property::maximized', client_toggle_dock)
			client.connect_signal('property::fullscreen', client_toggle_dock)
			awesome.connect_signal('dock::update', dock_update)
			awesome.connect_signal('dock::partial_show', dock_partial_show)
			awesome.connect_signal('dock::show', dock_show)
			awesome.connect_signal('dock::hide', dock_hide)
			dock:connect_signal('mouse::enter', dock_mouse_enter)
			dock:connect_signal('mouse::leave', dock_mouse_leave)
		elseif SETTINGS.dock_hide == 'always' then
			client.disconnect_signal('property::maximized', client_toggle_dock)
			client.disconnect_signal('property::fullscreen', client_toggle_dock)
			awesome.disconnect_signal('dock::update', dock_update)
			awesome.connect_signal('dock::partial_show', dock_partial_show)
			awesome.connect_signal('dock::show', dock_show)
			awesome.connect_signal('dock::hide', dock_hide)
			awesome.emit_signal('dock::hide')
		elseif not SETTINGS.dock_hide then
			client.disconnect_signal('property::maximized', client_toggle_dock)
			client.disconnect_signal('property::fullscreen', client_toggle_dock)
			dock:disconnect_signal('mouse::enter', dock_mouse_enter)
			dock:disconnect_signal('mouse::leave', dock_mouse_leave)
			awesome.disconnect_signal('dock::partial_show', dock_partial_show)
			awesome.disconnect_signal('dock::update', dock_update)
			awesome.emit_signal('dock::show')
			awesome.disconnect_signal('dock::show', dock_show)
		else
			require('naughty').notify {
				urgency = "critical",
				title   = "An error happened emiting signal 'dock::hiding_behavior'",
				message = 'Invalid dock hiding behavior option' .. tostring(behavior),
				app_name = 'Awesome',
				icon = beautiful.awesome_icon
			}
		end
	end)
end
