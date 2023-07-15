local wibox = require('wibox')
local gtable = require('gears.table')
local akey = require('awful.key')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi

local M = {}
local wibox_test = {}

function M.init()
	wibox_test = wibox {
		height = 300,
		width = 300,
		visible = SETTINGS.wibox_test_visible,
		x =  0,
		bg = '#ffffff',
        widget = {
            layout = wibox.container.background,
            bg = '#999999',
            {
                widget = require('widgets.box'),
                margins = dpi(15),
                padding = dpi(15),
                bg = '#33ff22',
                on_press = function(self)
                    PRINTNN('on_press')
                    self.bg = '#ffffff'
                    self:set_bg('#ffffff')
                end,
                {
                    layout = wibox.container.background,
                    bg = '#ffffff',
                    {
                        widget = wibox.widget.textbox,
                        text = 'TTTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestest'
                    }
                }
                --{
                --    widget = wibox.widget.imagebox,
                --    resize = true,
                --    forced_width = dpi(100),
                --    forced_height = dpi(100),
                --    image = beautiful.icon_sound
                --}
            }
		}
	}
end

function M.on_keymaps()
	return gtable.join(
		akey({ SETTINGS.modkey }, 'b', function()
			wibox_test.visible = not wibox_test.visible
		end, { description = 'Toggle test wibox', group = 'Awesome' })
	)
end

return M
