local alayout = require('awful.layout')
local amouse = require('awful.mouse')
local udock = require('modules.dock.utils')

local M = {}
local dock = {}

local function hide_if_needed(cli)
	if (not cli.floating)
		and alayout.get(cli.screen) ~= alayout.suit.floating then
		return
	end

	local cli_south = cli.y + cli.height
	local cli_east = cli.x + cli.width
	local cli_west = cli.x

	local dock_north = dock.y
	local dock_east = dock.x + dock.width
	local dock_west = dock.x

	if cli_south >= dock_north and
		cli_east >= dock_west and
		cli_west <= dock_east then
		awesome.emit_signal('dock::hide')
	elseif not udock.is_necessary_hide() then
		awesome.emit_signal('dock::show')
	end
end

function M.init(_dock)
	dock = _dock

	client.connect_signal('property::maximized', udock.toggle_by_client)
	client.connect_signal('property::fullscreen', udock.toggle_by_client)

	awesome.connect_signal('dock::show', udock.show)
	awesome.connect_signal('dock::hide', udock.hide)
	awesome.connect_signal('dock::update', udock.update)
	awesome.connect_signal('dock::show_temporarily', udock.show_temporarily)

	dock:connect_signal('mouse::enter', udock.on_mouse_enter)
	dock:connect_signal('mouse::leave', udock.on_mouse_leave)

	amouse.resize.add_leave_callback(hide_if_needed, 'mouse.move')
	amouse.resize.add_leave_callback(hide_if_needed, 'mouse.resize')
end

function M.finish()
	client.disconnect_signal('property::maximized', udock.toggle_by_client)
	client.disconnect_signal('property::fullscreen', udock.toggle_by_client)
	awesome.disconnect_signal('dock::update', udock.update)
	awesome.disconnect_signal('dock::show_temporarily', udock.show_temporarily)
	awesome.disconnect_signal('dock::show', udock.show)
	awesome.disconnect_signal('dock::hide', udock.hide)
	dock:disconnect_signal('mouse::enter', udock.on_mouse_enter)
	dock:disconnect_signal('mouse::leave', udock.on_mouse_leave)
end

return M
