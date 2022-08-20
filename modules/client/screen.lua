local wibox = require('wibox')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi

local function place_center(cli, obj)
	obj.x = cli.x + ((cli.width - obj.width) / 2)
	obj.y = cli.y + ((cli.height - obj.height) / 2)
end

return function(screen)
	local tile_layout_indicator = wibox {
		screen = screen,
		visible = false,
		ontop = true,
		width = dpi(400),
		height = dpi(400),
		bg = beautiful.bg,
		widget = wibox.widget{
			layout = wibox.container.margin,
			margins = dpi(5),
			{
				layout = wibox.layout.grid.vertical,
				spacing = dpi(5),
				require('modules.client.tile_layout').tile_layouts_widget(
					require('modules.client.tile_layouts')
				)
			}
		}
	}

	awesome.connect_signal('tile_layout_indicator::show', function()
		place_center(client.focus, tile_layout_indicator)
		tile_layout_indicator.visible = true
	end)

	-- TODO trigger this signal when:
	--		* Press Escape
	awesome.connect_signal('tile_layout_indicator::hide', function()
		tile_layout_indicator.visible = false 
	end)
end
