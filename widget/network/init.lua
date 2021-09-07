local wibox      = require('wibox')
local abutton    = require('awful.button')
local shape      = require('gears.shape')
local beautiful  = require('beautiful')
local multispawn = require('util.multispawn')
local dpi        = beautiful.xresources.apply_dpi

return function( icon, title )
	local restore_subtitle = wibox.widget {
		layout = wibox.container.background,
		bg = beautiful.transparent,
		fg = beautiful.fg_soft,
		{
			widget = wibox.widget.textbox,
			font   = beautiful.font_small,
			text   = subtitle,
			id     = 'id_subtitle'
		}
	}

	local network = wibox.widget
	{
		layout = wibox.layout.fixed.horizontal,
		spacing = dpi(8),
		{
			layout = wibox.container.background,
			bg = beautiful.bg_chips,
			shape = shape.circle,
			forced_height = dpi(25),
			forced_width = dpi(25),
			id  = 'id_bg',
			{
				layout  = wibox.container.margin,
				margins = dpi(4),
				{
					layout = wibox.container.place,
					{
						widget = wibox.widget.imagebox,
						image  = icon,
						resize = true,
						id     = 'id_icon'
					}
				}
			}
		},
		{
			layout = wibox.layout.flex.vertical,
			spacing = -5,
			id = 'id_text',
			{
				widget = wibox.widget.textbox,
				font   = beautiful.font_bold,
				text   = title,
				valign = 'center'
			}
		}
	}

	local background = network:get_children_by_id('id_bg')[1]
	local text       = network:get_children_by_id('id_text')[1]
	local subtitle   = restore_subtitle:get_children_by_id('id_subtitle')[1]
	local actived, connected, name_network

	function network:connect(name)
		if connected then
			subtitle:set_text(name)
		else
			text:add(restore_subtitle)
			subtitle:set_text(name)
		end
		network:on()
		name_network = name
		connected = true
	end

	function network:disconnect()
		text:remove(2)
		connected = false
	end

	function network:on()
		background:set_bg(beautiful.bg_highlight)
		actived = true
	end

	function network:off()
		background:set_bg(beautiful.bg_chips)
		text:remove(2)
		connected, actived = false, false
	end

	function network:get_status()
		return actived
	end

	function network:actions(args)
		local network_timer = multispawn {
			timeout = 4,
			on_click = function()
				if actived then
					background:set_bg(beautiful.bg_chips)
					actived = false
				else
					background:set_bg(beautiful.bg_highlight)
					actived = true
				end
				args.on_click()
			end,
			on_hold = function()
				awesome.emit_signal('popup::hide')
				assert(args.on_hold())
			end
		}

		background:buttons({
			abutton({}, 1,
			function() network_timer:start() end, 
			function() network_timer:stop() end)
		})
	end

	return network
end
