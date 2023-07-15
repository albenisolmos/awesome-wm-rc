local tag = require('awful.tag')
local ascreen = require('awful.screen')
local akey = require('awful.key')
local aclient = require('awful.client')
local spawn = require('awful.spawn')
local naughty = require('naughty')
local gtable = require('gears.table')
local gshape = require('gears.shape')

local uclient = require('utils.client')
local settings = require('settings')

local M = {}
local keymaps = {}
local pic_path   = '/Pictures/'
local modkey = settings.modkey

function M.init()
	keymaps = gtable.join(keymaps,
	akey({ modkey }, 'Escape', function()
		awesome.emit_signal('exitscreen::show')
	end, { description = 'Show exit screen', group = 'Awesome' }),
	akey({ modkey, 'Control' }, 'r', function()
		awesome.restart()
	end, { description = 'Reload awesome', group = 'Awesome' }),
	akey({ modkey }, 'i', function()
		awesome.emit_signal('hotkeys::show')
	end, { description = 'Show help', group = 'Awesome' }),
	--key({ modkey }, 'space', function()
	--	awesome.emit_signal('runner::run', 'run')
	--end, { description = 'Open Runner', group = 'Awesome' }),
	akey({ modkey }, 'p', function()
		spawn.with_shell(settings.cmd_player_pause)
	end, { description = 'Play/Pause music player', group = 'System'}),
	akey({ modkey }, ']', function()
		awesome.emit_signal('sound::level', '+5%')
	end, { description = 'Increase volume level', group = 'System'}),
	akey({ modkey }, '[', function()
		awesome.emit_signal('sound::level', '-5%')
	end, { description = 'Decrease volume level', group = 'System'}),
	akey({}, 'Print', function()
		local home = os.getenv('HOME')
		local name = 'screenshot-' .. os.date( '%d-%m-%G' ) .. '-1.png'
		local num = 1
		local dir = io.popen(string.format('ls %s%s', home, pic_path))
		local get_dir = dir:read('*a')
		dir:close()
		-- gsub('.[^.]+$', '')
		for file in get_dir:gmatch('%S+') do
			file = file:gsub( '%\n', '' )
			while true do
				if name == file then
					name = name:gsub( '[^-]+$', '' )
					num = num + 1
					name = name .. tostring(num) .. '.png'
					break
				else
					break
				end
			end
		end

		spawn.easy_async_with_shell(
		string.format('scrot $f %s%s%s', home, pic_path, name),
		function()
			naughty.notify {
				app_name = 'Awesome',
				title = 'Screenshot saved',
				message = '~' .. pic_path .. name,
				icon = home .. pic_path .. name,
			}
		end
		)

		collectgarbage('collect')
	end, { description='Take a Screenshot', group = 'System' }),
	akey({ 'Mod1' }, 'Print', function()
		spawn('scrot -s')
	end, { description='Take a Rectangle Screenshot', group = 'Launch' }),
	akey({ modkey }, 'Return', function()
		spawn(settings.terminal)
	end, { description = 'Open a terminal', group = 'System' }),
	akey({ modkey }, 'r', function()
		spawn(settings.launcher)
	end, { description = 'Apps launcher', group = 'System' }),
	akey({ modkey, 'Control' }, 's', function()
		local c = aclient.restore()
		if c then
			c:emit_signal("request::activate", "key.unminimized", {raise = true})
		end
	end, { description = 'Restore minimized client', group = 'client' }),
	akey({ modkey }, 'p', function() tag.viewprev() end,
	{ description = 'Go to previous tag', group = 'Tag' }),
	akey({ modkey }, 'b', function() tag.viewnext() end,
	{ description = 'Go to next tag', group = 'Tag' }),
	akey({ modkey }, 'Left', function() tag.viewprev() end,
	{ description = 'Go to previous tag', group = 'Tag' }),
	akey({ modkey  }, 'Right', function() tag.viewnext() end,
	{ description = 'Go to next tag', group = 'Tag' }),
	akey({ modkey, 'Control' }, 'd', function()
		local t = screen.focused().selected_tag
		tag.incgap(-5, t)
		if t.gap == 0 then
			for _, c in pairs(t:clients()) do
				if not c.floating then
					c.shape = gshape.rectangle
				end
			end
		end
	end, { description = 'Increase spacing between clients', group = 'Tag'}),
	akey({ modkey, 'Control' }, 'a', function()
		tag.incgap(5)
	end, { description = 'Increase spacing between clients', group = 'Tag'})
	)

	local function selected_client_by_index(index)
		local clients = uclient.get_clients(function(cli)
			return uclient.is_displayable(cli)
		end)

		local cli = clients[index]
		if cli then
			client.focus = cli
			cli:raise()
		end
	end

	local function view_tag(i)
		local screen = ascreen.focused()
		local tag = screen.tags[i]
		if tag then
			tag:view_only()
		end
	end

	for i=1, 9 do
		keymaps = gtable.join(keymaps,
		akey({ modkey, 'Shift' }, '#' .. i + 9, function()
			selected_client_by_index(i)
		end, { description = 'Select client by index', group = 'Client'}),

		akey({ modkey }, '#' .. i + 9, function()
			view_tag(i)
		end, { description = 'only view tag', group = 'Tag'}),

		akey({ modkey, 'Control' }, '#' .. i + 9, function()
			if client.focus then
				local c = client.focus
				local tag = c.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, {description = 'Move focused client to tag', group = 'Tag'})
		)
	end

	return keymaps
end

function M.add(_keymaps)
	keymaps = gtable.join(keymaps, _keymaps)
end

return M
