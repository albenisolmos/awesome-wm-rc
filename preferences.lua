local dir = require('gears.filesystem').get_configuration_dir()
local dpi = require('beautiful').xresources.apply_dpi

_G.preferences  = {
	theme = 'dark',
	titlebar_style = 'windows',
	wallpaper = dir .. 'themes/wallpaper.jpg',
	icon_user  = dir .. 'icon-user.png',
	dock = true,
	dock_autohide = true,
	dock_bg_solid = false,
	topbar_tasklist = false,
	topbar_bg_solid = false,
	topbar_hide_maximized = false,
	topbar_autohide = false,
	desktop_icon = false,
	client_rounded_corners = 15,
	client_border_width = dpi(1),
	client_rounded_corner_on_maximized = true,
	switcher_preview = false,
	web_browser = 'firefox',
	music_player = 'lollypop',
	terminal = 'xfce4-terminal',
	launcher = 'rofi -show drun',
	manager_network = 'wicd-gtk',
	manager_package = 'synaptic-pkexec',
	manager_sound = 'pavucontrol',
	shell = '/bin/sh',
	modkey = 'Mod4',
	cmd_vol_up = '',
	cmd_vol_down = '',
	cmd_player_play = '',
	cmd_player_pause = 'dbus-send --print-reply --dest=org.gnome.Lollypop /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause',
	once_spawn = {
		'picom',
		'/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1'
	}
}
