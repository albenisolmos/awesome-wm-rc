local animate = require('utils.animate')
local uclient = require('utils.client')
local gtimer = require('gears.timer')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi

local M = {}
local dock = {}
local inscreen_coord
local offscreen_coord
local partial_show = false
local current_hiding_module

local function is_client_big(cli)
	return cli.floating and not cli.minimized
	and cli.maximized or cli.fullscreen
end

function M.init(_dock)
	dock = _dock
	local s = dock.screen
	inscreen_coord = s.geometry.height - dock.height - (SETTINGS.dock_gap or dpi(5))
	offscreen_coord = s.geometry.height + 1
end

function M.is_necessary_hide()
	local clients = uclient.get_clients()

	for _, cli in pairs(clients) do
		if is_client_big(cli) then
			return true
		end
	end

	return false
end

function M.kill()
	dock:kill()
	current_hiding_module.finish()
	dock = nil
end

function M.hide()
	if dock.y == offscreen_coord then return end
	dock:struts({ bottom = 0 })
	animate.move.y(dock, offscreen_coord)
end

local dock_timer = gtimer {
	timeout = 1,
	autostart = false,
	single_shot = true,
	callback = function()
		partial_show = false
		M.hide()
		dock.ontop = false
	end
}

function M.show()
	if dock.y == inscreen_coord then return end
	animate.move.y(dock, inscreen_coord)
end

function M.show_temporarily()
	partial_show = true
	dock.ontop = true
	M.show()
	dock_timer:start()
end

function M.center(_dock)
	local dock = _dock or dock
	dock.x = (dock.screen.geometry.width - dock.width )/2
end

function M.update()
	if M.is_necessary_hide() then
		M.hide()
	else
		M.show()
	end
end

function M.toggle_by_client(cli)
	if cli.maximized or cli.fullscreen then
		M.hide()
	else
		M.show()
	end
end

function M.on_mouse_leave()
	if partial_show then
		dock_timer:start()
	end
end

function M.on_mouse_enter()
	if dock_timer.started then
		dock_timer:stop()
	end
end

function M.set_hiding_type(hiding_type)
	if current_hiding_module then
		current_hiding_module.finish()
	end

	if hiding_type == 'needed' then
		current_hiding_module = require('modules.dock.hiding_needed')
		current_hiding_module.init(dock)
	elseif hiding_type == 'always' then
		current_hiding_module = require('modules.dock.hiding_always')
		current_hiding_module.init(dock)
	elseif hiding_type == 'never' or not hiding_type then
		udock.show()
	else
		if current_hiding_module then
			current_hiding_module.init(dock)
		end

		require('naughty').notify {
			urgency = "critical",
			title   = "An error happened emiting signal 'dock::property::hide'",
			message = 'Invalid dock hide_type option' .. tostring(hiding_type),
			app_name = 'Awesome',
			icon = beautiful.awesome_icon
		}
	end
end

return M
