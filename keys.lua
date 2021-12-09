local awful      = require('awful')
local naughty    = require('naughty')
local pic_path   = '/Pictures/'
local modkey     = 'Mod4'

require('awful.autofocus')

client.connect_signal('request::default_keybindings', function()
	awful.keyboard.append_client_keybindings({
		awful.key({ modkey }, 'ñ',  function(c)
			awful.spawn.easy_async('xprop -id ' .. c.window, function(stdout)
				naughty.notification {
					title = 'notif',
					message = stdout,
					timeout = 0
				}
			end)
		end,
		{ description = 'toggle floating', group = 'client' }),

		awful.key({ modkey }, 'f',  awful.client.floating.toggle,
		{ description = 'toggle floating', group = 'client' }),

		awful.key({ modkey }, 'g', function(c)
			c.ontop = not c.ontop
		end,
		{ description = 'toggle keep on top', group = 'client' }),

		awful.key({ modkey }, 'y', function(c)
			c.sticky = not c.sticky
			c:raise()
		end,
		{ description = 'Toggle keep on sticky', group = 'client' }),

		awful.key({ modkey }, 'q', function(c) c:kill() end,
		{ description = 'close', group = 'client' }),

		awful.key({ modkey }, 's', function(c)
			c.minimized = true
		end,
		{ description = 'Toggle minimize', group = 'client' }),

		awful.key({ modkey }, 'w', function (c)
			c.maximized = not c.maximized
			c:raise()
		end,
		{ description = 'Toggle maximize', group = 'client' }),

		awful.key({ modkey, 'Control' }, 'w', function (c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end,
		{ description = 'Toggle fullscreen', group = 'client' }),

		awful.key({ modkey }, 't', awful.titlebar.toggle,
		{ description = 'Toggle  titlebar', group='client' })
	})
end)

awful.keyboard.append_global_keybindings({
	awful.key({ modkey }, 'n', function()
		awesome.emit_signal('notifcenter::toggle')
	end,
	{ description = 'Toggle notification center', group = 'Awesome' }),

	awful.key({ modkey }, 'Escape', function()
		awesome.emit_signal('exitscreen::show')
	end,
	{ description = 'Show exit screen', group = 'Awesome' }),

	awful.key({ modkey, 'Control' }, 'r', function()
		awesome.restart()
	end,
	{ description = 'Reload awesome', group = 'Awesome' }),

	awful.key({ modkey }, 'i', function()
		awesome.emit_signal('hotkeys::show')
	end,
	{ description = 'Show help', group = 'Awesome' }),

	awful.key({ modkey }, 'r', function()
		awesome.emit_signal('runner::run', 'run')
	end,
	{ description = 'Open Runner', group = 'Awesome' }),

	awful.key({ modkey }, 'p', function()
		awful.spawn.with_shell('dbus-send --print-reply --dest=org.gnome.Lollypop /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause')
	end,
	{ description = 'Play/Pause music player', group = 'System'}),

	awful.key({ modkey }, '+', function()
		awesome.emit_signal('sound::level', '+5%')
	end,
	{ description = 'Increase volume level', group = 'System'}),

	awful.key({ modkey }, '-', function()
		awesome.emit_signal('sound::level', '-5%')
	end,
	{ description = 'Decrease volume level', group = 'System'}),

	awful.key({ }, 'Print', function()
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

		awful.spawn.easy_async_with_shell(
		string.format('scrot $f %s%s%s', home, pic_path, name),
		function()
			naughty.notification {
				app_name = 'Awesome',
				title = 'Screenshot saved',
				message = '~' .. pic_path .. name,
				icon = home .. pic_path .. name,
			}
		end)
		collectgarbage('collect')
	end,
	{ description='Take a Screenshot', group = 'System' }),

	awful.key({ 'Mod1' }, 'Print', function()
		awful.spawn('scrot -s')
	end,
	{ description='Take a Rectangle Screenshot', group = 'Launch' }),

	awful.key({ modkey }, 'Return', function()
		awful.spawn(_G.preferences.terminal)
	end,
	{ description = 'Open a terminal', group = 'System' }),

	awful.key({ }, 'Super_R', function()
		awful.spawn(_G.preferences.launcher)
	end,
	{ description = 'Apps launcher', group = 'System' }),

	awful.key({ modkey, 'Control' }, 's', function()
		local c = awful.client.restore()
		if c then
			c:activate { raise = true, context = 'key.unminized'}
		end
	end,
	{ description = 'Restore minimized client', group = 'client' })
})

awful.keyboard.append_global_keybindings({
	awful.key({ modkey }, 'a', awful.tag.viewprev,
	{ description = 'Go to previous tag', group = 'Tag' }),

	awful.key({ modkey }, 'd', awful.tag.viewnext,
	{ description = 'Go to next tag', group = 'Tag' }),

	awful.key({ modkey }, 'h', awful.tag.viewprev,
	{ description = 'Go to previous tag', group = 'Tag' }),

	awful.key({ modkey }, 'l', awful.tag.viewnext,
	{ description = 'Go to next tag', group = 'Tag' }),

	awful.key({ modkey }, 'Left', awful.tag.viewprev,
	{ description = 'Go to previous tag', group = 'Tag' }),

	awful.key({ modkey  }, 'Right', awful.tag.viewnext,
	{ description = 'Go to next tag', group = 'Tag' }),

	awful.key {
		modifiers   = { modkey },
		keygroup    = 'numrow',
		description = 'only view tag',
		group       = 'Tag',
		on_press    = function (index)
			local screen = awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				tag:view_only()
			end
		end,
	},
	awful.key {
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

	awful.key({ modkey, 'Control' }, 'd', function()
		local t = awful.screen.focused().selected_tag
		awful.tag.incgap(-5, t)
		if t.gap == 0 then
			for _, c in pairs(t:clients()) do
				if not c.floating then
					c.shape = shape.rectangle
				end
			end
		end

	end,
	{ description = 'Increase spacing between clients', group = 'Tag'}),

	awful.key({ modkey, 'Control' }, 'a', function()
		awful.tag.incgap(5)
	end,
	{ description = 'Increase spacing between clients', group = 'Tag'})

})

client.connect_signal('request::default_mousebindings', function()
	awful.mouse.append_client_mousebindings({
		awful.button({ }, 1, function(c)
			c:activate { context = 'mouse_click' }
			awesome.emit_signal('popup::hide')
		end),
		awful.button({ modkey }, 1, function(c)
			c:activate { context = 'mouse_click', action = 'mouse_move'  }
		end),
		awful.button({ modkey }, 3, function(c)
			c:activate { context = 'mouse_click', action = 'mouse_resize'}
		end)
	})
end)
