local awful     = require('awful')
local wibox     = require('wibox')
local shape     = require('gears.shape')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi
local clickable = require 'widget.clickable'

local atextbox  = wibox.widget.textbox()
local mode

return function(screen)
	local dialog = wibox {
		screen = screen,
		--type   = 'utility',
		visible= false,
		ontop  = true,
		x = (screen.workarea.width / 2) - (500/2),
		y = (screen.workarea.height / 2) - (60/2),
		width  = dpi(500),
		height = dpi(50),
		bg = beautiful.bg,
		shape = shape.rounded_rect,
		widget = {
			margins = dpi(10),
			layout = wibox.container.margin,
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(10),
				{
					widget = wibox.widget.imagebox,
					image = beautiful.icon_arrow_right,
					resize = true,
					id = 'icon'
				},
				atextbox
			}
		}
	}
	local icon = dialog:get_children_by_id('icon')[1]
	icon:connect_signal('button::release', function()
		icon:set_image(beautiful.icon_taglist_web_browser)
		mode = 'web'
	end)

	awesome.connect_signal('dialog::write', function(arg)
		mode = arg or 'run'
		icon:set_image(beautiful.icon_arrow_right)
		dialog.visible = true

		awful.prompt.run {
			prompt       = '',
			textbox      = atextbox,
			keypressed_callback = function(mod, key, cmd)
				if key == 'Tab' then
					icon:set_image(beautiful.icon_taglist_web_browser)
					mode = 'web'
				end
			end,
			history_path = os.getenv('HOME') .. '/.config/awesome/cache/cache',
			exe_callback = function(cmd)
				if mode == 'web' then
					awful.spawn({'xdg-open', 'https://www.google.com/search?client=ubuntu&channel=fs&q=' .. cmd .. '&ie=utf-8&oe=utf-8'})
				elseif mode == 'dock' then
					search_app(cmd, true)
				else
					awful.spawn(cmd)
				end
				dialog.visible = false
			end,
			done_callback = function() 
				dialog.visible = false
			end
		}
	end)

	return dialog
end
