local wibox = require('wibox')
local spawn = require('awful.spawn')
local abutton = require('awful.button')
local shape = require('gears.shape')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi

local status

local function build_button( icon, exec )
	local button = wibox.widget {
		layout = wibox.container.margin,
		margins = 0,
		id = 'margins',
		{
			id = 'icon',
			image = icon,
			widget = wibox.widget.imagebox
		}
	}

	button:buttons({
		abutton({}, 1, function()
			local margin = 1
			while margin ~= 2 do
				margin = margin + 1
				button:set_margins(margin)
			end
		end,
		function()
			spawn.with_shell(exec)
		end)
	})

	button:connect_signal('mouse::enter', function(self)
		local margin = 0
		while margin ~= 1 do
			margin = margin + 1
			self:set_margins(margin)
		end
	end)

	button:connect_signal('mouse::leave', function(self)
		local margin = 2
		while margin ~= 0 do
			margin = margin - 1
			self:set_margins(margin)
		end
	end)

	return button
end

local play_pause = build_button( beautiful.icon_player_play, 'dbus-send --print-reply --dest=org.gnome.Lollypop /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause')

awesome.connect_signal('player::status', function(status)
	if status then
		play_pause:get_children_by_id('icon')[1]:set_image(beautiful.icon_player_pause)
	else
		play_pause:get_children_by_id('icon')[1]:set_image(beautiful.icon_player_play)
	end
end)

return wibox.widget {
	layout = wibox.layout.align.horizontal,
	expand = 'none',
	nil,
	{
		layout = wibox.layout.fixed.horizontal,
		spacing = dpi(8),
		build_button( beautiful.icon_player_prev, 'dbus-send --print-reply --dest=org.gnome.Lollypop /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous'),
		play_pause,
		build_button( beautiful.icon_player_next, 'dbus-send --print-reply --dest=org.gnome.Lollypop /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next')
	},
	nil
}
