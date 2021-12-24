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

