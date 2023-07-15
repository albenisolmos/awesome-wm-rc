local gtimer = require('gears.timer')
local lgi = require('lgi')
local Gdk = lgi.require('Gdk')

Gdk.init({})

local function get_pixels(x, y)
	local w = Gdk.get_default_root_window()
	local pb = Gdk.pixbuf_get_from_window(w, x, y, 1, 1)
	local bytes = pb:get_pixels()
	return bytes:gsub('.', function(c)
		return ('%02x'):format(c:byte())
	end)
end

-- TODO implement the reactive efect
-- when change wallpaper, when client is maximized (SETTINGS.bar_color_adaptive)
return function(bar)
	local timer_dynamic_color = gtimer {
		timeout = 0.4,
		autostart = false,
		single_shot = true,
		callback = function()
			bar.bg = '#' .. get_pixels(10, 30)
		end
	}
end
