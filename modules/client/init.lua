local spawn = require('awful.spawn')
local amouse = require('awful.mouse')
local alayout = require('awful.layout')
local gshape = require('gears.shape')
local abutton = require('awful.button')
local dpi = require('beautiful').xresources.apply_dpi
local ushape = require('utils.shape')
local settings = require('settings')

local client_shape_on_maximized = ushape.build(settings.client_shape_on_maximized)
local last_coords = {x = 0, y = 0}
local M = {}

local function hard_shadow(cr, width, height, radius)
    radius = radius or 10

    if width / 2 < radius then
        radius = width / 2
    end

    if height / 2 < radius then
        radius = height / 2
    end

    cr:move_to(0, radius)

    cr:arc( radius      , radius       , radius,    math.pi   , 3*(math.pi/2) )
    cr:arc( width-radius, radius       , radius, 3*(math.pi/2),    math.pi*2  )
    cr:arc( width-radius, height-radius, radius,    math.pi*2 ,    math.pi/2  )
    cr:arc( radius      , height-radius, radius,    math.pi/2 ,    math.pi    )

    cr:close_path()
end

local function client_shape(cr, w, h)
	hard_shadow(cr, w, h, dpi(settings.client_rounded_corners))
	--gshape.rounded_rect(cr, w, h, dpi(settings.client_rounded_corners))
end

local function on_fullscreen(cli)
	if cli.fullscreen then
		cli.shape = gshape.rectangle
	else
		M.restore_client(cli)
	end
end

function M.on_maximized(cli)
	if cli.size_hints_honor then
		-- FIX: Cant make to center client when is maximized
		--aplacement.centered(cli)
		cli.y = (cli.height - cli.screen.workarea.height) / 2
		cli.x = (cli.width - cli.screen.workarea.width) / 2
	end

	if cli.maximized then
		cli.shape = client_shape_on_maximized
	else
		M.restore_client(cli)
	end
end

local function on_tiled_client(cli)
	if cli.floating then
		M.restore_client(cli)
	else
		cli.shape = settings.client_shape_on_tiled or gshape.rectangle
	end
end

local function on_activate(cli)
	if cli.active then
		spawn('xprop -set _NET_WM_STATE_FOCUSED true -id ' .. cli.window)
	else
		spawn('xprop -remove _NET_WM_STATE_FOCUSED -id ' .. cli.window)
	end
end

local function on_tiled_clients(t)
	awesome.emit_signal('topbar::update')
	for _, cli in pairs(t:clients()) do
		on_tiled_client(cli)
	end
end

function M.restore_client(cli)
	cli.shape = client_shape
	cli.border_width = settings.client_border_width
end

function M.init()
	awesome.register_xproperty('_NET_WM_STATE_FOCUSED', 'boolean')

	client.connect_signal('request::activate', on_activate)
	client.connect_signal('property::fullscreen', on_fullscreen)
	client.connect_signal('property::maximized', M.on_maximized)
	client.connect_signal('property::floating', on_tiled_client)
	tag.connect_signal('property::layout', on_tiled_clients)
    client.connect_signal('request::default_mousebindings', function()
        amouse.append_client_mousebindings({
            abutton({ }, 1, function(c)
                c:activate { context = 'mouse_click' }
                awesome.emit_signal('popup::hide')
            end),
            abutton({settings.modkey}, 1, function(c)
                c:activate { context = 'mouse_click', action = 'mouse_move'  }
            end),
            abutton({settings.modkey}, 3, function(c)
                c:activate { context = 'mouse_click', action = 'mouse_resize'}
            end)
        })
end)

end

amouse.resize.add_enter_callback(function(c)
	last_coords.x = c.x
	last_coords.y = c.y
end, 'mouse.move')

amouse.resize.add_leave_callback(function(c)
	if (not c.floating)
		and alayout.get(c.screen) ~= alayout.suit.floating
		or c.type == 'dialog' then
		return
	end

	local coords = mouse.coords()
	local sg = c.screen.geometry
	local sw = c.screen.workarea
	local snap = amouse.snap.default_distance

	if coords.x > snap + sg.x
		and coords.x < sg.x + sg.width - snap
		and coords.y <= snap + sg.y
		and coords.y >= sg.y
		then
		c.maximized = true
		c:raise()
	elseif coords.x > snap + sg.x
		and coords.x < sg.x + sg.width - snap
		and coords.y >= sg.height - snap
		and coords.y <= sg.height
		then
		c.minimized = true
		c.x = last_coords.x
		c.y = last_coords.y
	elseif coords.x == 0 then
		c.x = 0
		c.y = sw.y
		c.width = sg.width / 2
		c.height = sw.height
	elseif coords.x >= sg.width - snap then
		c.x = sg.width - c.width
		c.y = sw.y
		c.width = sg.width / 2
		c.height = sw.height
    elseif c.y + c.height >= sw.height then
        c.y = sw.height - c.height
	end
end, 'mouse.move')

return M
