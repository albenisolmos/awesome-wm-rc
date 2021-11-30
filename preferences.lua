local dir = require('gears').filesystem.get_configuration_dir()

_G.preferences  = {
	theme = 'dark',
	titlebar_style = 'windows',
	wallpaper = dir ..'themes/wallpaper.jpg',
	icon_user  = dir .. 'icon-user.png',
	dock = true,
	dock_autohide = true,
	dock_bg_solid = false,
	topbar_tasklist = false,
	topbar_bg_solid = false,
	topbar_hide_maximized = false,
	topbar_autohide = false,
	desktop_icon = false,
	client_rounded_corners = 8,
	switcher_preview = false,
	web_browser = 'firefox',
	music_player = 'lollypop',
	terminal = 'xfce4-terminal',
	launcher = 'rofi -show drun',
	manager_network = 'wicd-gtk',
	manager_package = 'synaptic-pkexec',
	manager_sound = 'pavucontrol',
	shell = '/bin/sh',
	cmd_vol_up = '',
	cmd_vol_down = '',
	cmd_play_player = '',
	cmd_pause_player = '',
	once_spawn = {
		'picom',
		'/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1',
	}
}
