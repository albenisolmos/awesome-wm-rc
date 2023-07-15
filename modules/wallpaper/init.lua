local wibox = require('wibox')
local gwallpaper = require('gears.wallpaper')
local awallpaper = require('awful.wallpaper')
local settings = require('settings')

local function new_wallpaper(wallpaper, s)
	awallpaper {
		screen = s,
		widget = {
			{
				upscale   = true,
				downscale = true,
				image = wallpaper,
				widget = wibox.widget.imagebox,
			},
			valign = 'center',
			halign = 'center',
			tiled  = false,
			widget = wibox.container.tile,
		}
	}
end

local function set_wallpaper(s)
	if settings.wallpaper then
		local wallpaper = settings.wallpaper

		if type(wallpaper) == 'function' then
			wallpaper = wallpaper(s)
		end

		if wallpaper[0] == '#' then
			gwallpaper.set(wallpaper)
		else
			new_wallpaper(wallpaper, s)
		end
	else
		-- TODO hadle two case wallpaper in .config and
		-- default
		new_wallpaper(require('gears.filesystem').get_xdg_config_home() .. 'wallpaper.jpg', s)
	end
end

screen.connect_signal('property::geometry', set_wallpaper)
screen.connect_signal('request::wallpaper', set_wallpaper)

return {
    on_screen = set_wallpaper
}
