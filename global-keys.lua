local spawn = require('awful.spawn')
local key = require('awful.key')
local button = require('awful.button')
local mouse = require('awful.mouse')
local client = require('awful.client')
local tag = require('awful.tag')
local naughty = require('naughty')
local gtable = require('gears.table')

local pic_path   = '/Pictures/'
local modkey = _G.preferences.modkey

local global_keys = gtable.join(
	key({ modkey }, 'n', function()
		awesome.emit_signal('notifcenter::toggle')
	end, { description = 'Toggle notification center', group = 'Awesome' }),
	key({ modkey }, 'Escape', function()
		awesome.emit_signal('exitscreen::show')
	end, { description = 'Show exit screen', group = 'Awesome' }),
	key({ modkey, 'Control' }, 'r', function()
		awesome.restart()
	end, { description = 'Reload awesome', group = 'Awesome' }),
	key({ modkey }, 'i', function()
		awesome.emit_signal('hotkeys::show')
	end, { description = 'Show help', group = 'Awesome' }),
	key({ modkey }, 'r', function()
		awesome.emit_signal('runner::run', 'run')
	end, { description = 'Open Runner', group = 'Awesome' }),
	key({ modkey }, 'p', function()
		spawn.with_shell(_G.preferences.cmd_player_pause)
	end, { description = 'Play/Pause music player', group = 'System'}),
	key({ modkey }, '+', function()
		awesome.emit_signal('sound::level', '+5%')
	end, { description = 'Increase volume level', group = 'System'}),
	key({ modkey }, '-', function()
		awesome.emit_signal('sound::level', '-5%')
	end, { description = 'Decrease volume level', group = 'System'}),
	key({}, 'Print', function()
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
	key({ 'Mod1' }, 'Print', function()
		spawn('scrot -s')
	end, { description='Take a Rectangle Screenshot', group = 'Launch' }),
	key({ modkey }, 'Return', function()
		spawn(_G.preferences.terminal)
	end, { description = 'Open a terminal', group = 'System' }),
	key({ }, 'Super_R', function()
		spawn(_G.preferences.launcher)
	end, { description = 'Apps launcher', group = 'System' }),
	key({ modkey, 'Control' }, 's', function()
		local c = client.restore()
		if c then
			c:emit_signal("request::activate", "key.unminimized", {raise = true})
		end
	end, { description = 'Restore minimized client', group = 'client' }),
	key({ modkey }, 'a', function() tag.viewprev() end,
	{ description = 'Go to previous tag', group = 'Tag' }),
	key({ modkey }, 'd', function() tag.viewnext() end,
	{ description = 'Go to next tag', group = 'Tag' }),
	key({ modkey }, 'h', function() tag.viewprev() end,
	{ description = 'Go to previous tag', group = 'Tag' }),
	key({ modkey }, 'l', function() tag.viewnext() end,
	{ description = 'Go to next tag', group = 'Tag' }),
	key({ modkey }, 'Left', function() tag.viewprev() end,
	{ description = 'Go to previous tag', group = 'Tag' }),
	key({ modkey  }, 'Right', function() tag.viewnext() end,
	{ description = 'Go to next tag', group = 'Tag' }),
	key({ modkey, 'Control' }, 'd', function()
		local t = screen.focused().selected_tag
		tag.incgap(-5, t)
		if t.gap == 0 then
			for _, c in pairs(t:clients()) do
				if not c.floating then
					c.shape = shape.rectangle
				end
			end
		end
	end, { description = 'Increase spacing between clients', group = 'Tag'}),
	key({ modkey, 'Control' }, 'a', function()
		tag.incgap(5)
	end, { description = 'Increase spacing between clients', group = 'Tag'})
)

--[[
	key {
		modifiers   = { modkey },
		keygroup    = 'numrow',
		description = 'only view tag',
		group       = 'Tag',
		on_press    = function (index)
			local screen = screen.focused()
			local tag = screen.tags[index]
			if tag then
				tag:view_only()
			end
		end,
	},
	key {
		modifiers = { modkey, 'Control' },
		keygroup    = 'numrow',
		description = 'Move focused client to tag',
		group       = 'Tag',
		on_press    = function(index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end,
	},
]]
_G.print(global_keys)
return global_keys
