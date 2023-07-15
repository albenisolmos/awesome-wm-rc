local wibox = require('wibox')
local aspawn = require('awful.spawn')
local gshape = require('gears.shape')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi

local applet = require('widgets.applet')
local box = require('widgets.box')

local function option(layout)
    return wibox.widget {
        widget = box,
        bg_hover = beautiful.bg_chips,
        fg = '#ffffff',
        shape = gshape.rounded_rect,
        padding = dpi(5),
        forced_height = dpi(100),
        forced_width = dpi(100),
        on_release = function()
            aspawn.with_shell('~/Dev/scripts/imap ' .. layout)
        end,
        {
            widget = wibox.widget.textbox,
            text = string.upper(layout),
            font = beautiful.font_small
        }
    }
end

return applet(
    wibox.widget.imagebox(beautiful.icon_desktop),
    wibox.widget {
        widget = box,
        padding = dpi(10),
        {
            layout = wibox.layout.flex.horizontal,
            option('qwerty'),
            option('colemak')
        }
    }
)
