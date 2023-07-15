local wibox = require('wibox')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi

local function place_center(cli, obj)
	obj.x = cli.x + ((cli.width - obj.width) / 2)
	obj.y = cli.y + ((cli.height - obj.height) / 2)
end

return function(screen)
	local popup_tile_layouts = wibox {
		screen = screen,
		visible = false,
		ontop = true,
		width = dpi(200),
		height = dpi(150),
		bg = beautiful.bg,
		widget = wibox.widget{
			layout = wibox.container.margin,
			margins = dpi(5),
			{
				layout = wibox.layout.grid.vertical,
				spacing = dpi(5),
				require('modules.client.tile_layout').make_grid_tile_layouts(
					require('modules.client.tile_layouts')
				)
			}
		}
	}

	awesome.connect_signal('popup_tile_layouts::toggle', function()
		if popup_tile_layouts.visible then
			popup_tile_layouts.visible = false
			return
		elseif not client.focus then return end

		place_center(client.focus, popup_tile_layouts)
		popup_tile_layouts.visible = true
	end)

	awesome.connect_signal('popup_tile_layouts::hide', function()
		popup_tile_layouts.visible = false
	end)
end
