local gtimer = require('gears.timer')
local wibox = require('wibox')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi

local settings = require('settings')
local uclient = require('utils.client')

local is_temporarily_showed = false
local is_popup_visible
local wibar = {}
local MISSING_PIXELS = 3
local M = {}

-- Undefined functions
local get_coord_hide, get_coord_show
local get_struct_hide, get_struct_show
local overstep_edge

local function wibar_hide()
	if is_popup_visible then return end
	is_temporarily_showed = false
	wibar:struts(get_struct_hide())
	wibar.y = get_coord_hide()
end

local timer_hide_wibar = gtimer {
	timeout = 0.7,
	autostart = false,
	single_shot = true,
	callback = function()
		wibar_hide()
	end
}

awesome.connect_signal('popup::visible', function(visible)
	is_popup_visible = visible
	if not visible and settings.wibar_autohide then
		timer_hide_wibar:start()
	end
end)

local function wibar_show()
	if wibar.y == get_coord_show() then return end

	wibar:struts(get_struct_show())
	wibar.y = get_coord_show()

	if settings.wibar_autohide then
		timer_hide_wibar:start()
	end
end

local function wibar_show_temporarily()
	if wibar.y == get_coord_show() then return end
	is_temporarily_showed = true
	wibar.ontop = true
	wibar.y = get_coord_show()
	wibar:struts(get_struct_show(true))
end

local function wibar_update_client(cli)
	if settings.wibar_autohide then
		return
	end

	if cli.fullscreen and not cli.minimized then
		wibar_hide()
		wibar.bg = beautiful.transparent
		return true
	elseif cli.maximized
		or (not cli.floating and not cli.minimized)
		and cli.skip_taskbar then
		wibar.bg = beautiful.bg
		wibar_show()
		return true
	end
end

local function wibar_update()
	if settings.wibar_autohide then
		return
	end

	local clients = uclient.get_clients()

	for _, cli in pairs(clients) do
		if wibar_update_client(cli) then
			return
		end
	end

	wibar.bg = beautiful.transparent
	wibar_show()
end

local function wibar_on_enter()
	if is_temporarily_showed then
		timer_hide_wibar:stop()
	end
end

local function wibar_on_leave()
	if is_temporarily_showed and overstep_edge() then
		timer_hide_wibar:start()
	end
end

function M.on_screen(screen)
	if not settings.wibar_position or settings.wibar_position == 'top' then
		get_coord_hide = function()
			return screen.geometry.y - wibar.height
		end
		get_coord_show = function()
			return screen.geometry.y
		end
		get_struct_hide = function()
			return {top = 0}
		end
		get_struct_show = function(invade)
			if invade and settings.wibar_invade_on_maimized then
				return
			end

			return {top = wibar.height}
		end
		overstep_edge = function()
			return mouse.coords().y >= (screen.geometry.y + MISSING_PIXELS)
		end
	elseif settings.wibar_position == 'bottom' then
		get_coord_hide = function()
			return screen.geometry.height + wibar.height
		end
		get_coord_show = function()
			return screen.geometry.height - (wibar.height)
		end
		get_struct_hide = function()
			return {bottom = 0}
		end
		get_struct_show = function(invade)
			if invade and not settings.wibar_invade_on_maximized then
				return
			end
			return {bottom = wibar.height}
		end
		overstep_edge = function()
			return mouse.coords().y <= (screen.geometry.height - MISSING_PIXELS)
		end
	end

	wibar = wibox({
		screen = screen,
		type = 'dock',
		ontop = false,
		visible = true,
		height = settings.wibar_height,
		width = screen.geometry.width,
		bg = beautiful.transparent,
		widget = wibox.widget {
			layout = wibox.container.margin,
			margins = dpi(3),
			id = 'margin',
			{
				layout = wibox.layout.align.horizontal,
				{
					layout = wibox.layout.align.horizontal,
					require('widgets.system.applet'),
                    require 'widgets.workspaces'
				},
				{
					layout = wibox.layout.align.horizontal,
					fill_space = true,
					expand = 'outside',
					nil,
					require 'widgets.tasklist'(screen),
					nil
				},
				{
					layout = wibox.layout.fixed.horizontal,
					require 'widgets.systray',
					require 'widgets.taglist'(screen),
					require 'widgets.sound.applet'(screen),
					require 'widgets.dollar.applet',
					require 'widgets.keyboard-layout.applet',
					require 'widgets.clock.applet'
				}
			}
		}
	})

	if not settings.wibar_autohide then
		wibar_show()
	end

	wibar:connect_signal('mouse::enter', wibar_on_enter)
	wibar:connect_signal('mouse::leave', wibar_on_leave)
	awesome.connect_signal('wibar::update', wibar_update)
	client.connect_signal('property::minimized', wibar_update_client)
	client.connect_signal('property::maximized', wibar_update_client)
	awesome.connect_signal('wibar::partial_show', wibar_show_temporarily)
	client.connect_signal('property::fullscreen', function(c)
		if c.fullscreen then
			wibar_hide()
		else
			wibar_show()
		end
	end)

	require('display.hot-corners') {
		screen = screen,
		position = settings.wibar_position or 'top',
		callback = function()
			awesome.emit_signal('wibar::partial_show')
		end
	}

	return wibar
end

--[[ Make rounded corner bottom in then bar like gnome
local increased_height = height + 20 + dpi(settings.client_rounded_corners)
local function wibar_reset_size()
	--return
	if wibar.height ~= height then
		wibar.height = height
		wibar_struct_show()
		wibar.shape = gshape.rectangle
	end
end

local function wibar_shape(cr, w, h)
	--local degrees = math.pi / 180.0;
	--cr:arc(w - radius, radius, radius, -90 * degrees, 0 * degrees)
	--cr:arc_negative(w - radius, h - radius , radius, 0 * degrees, -90 * degrees)
	--cr:arc_negative(radius, h - radius, radius, -90 * degrees, 180 * degrees)
	--cr:arc(radius, radius, radius, 180 * degrees, 270 * degrees)
end

local function wibar_inc_size()
	--if wibar.height ~= increased_height then
	--	margin.bottom = 35
	--	wibar.height = increased_height
	--	wibar:struts({ top = increased_height - radius - 20 })
	--	wibar.shape = wibar_shape
	--end
end
]]

return M
