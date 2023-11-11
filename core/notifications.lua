local shape     = require('gears.shape')
local naughty   = require('naughty')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi

return function()
    naughty.config.defaults.title = 'System Notification'
    naughty.config.defaults.border_width = 1
    naughty.config.defaults.margin = dpi(10)
    naughty.config.defaults.position = 'top_right'
    naughty.config.defaults.shape = shape.rounded_rect
    naughty.config.defaults.icon_size = dpi(60)
    naughty.config.defaults.ontop = true
    naughty.config.defaults.timeout = 5

    naughty.config.spacing = dpi(10)
    naughty.config.padding = dpi(10)

    naughty.config.presets.critical.bg = beautiful.notification_critical

    naughty.config.icon_dirs = {
        '/usr/share/icons/hicolor/',
        '/usr/share/icons/gnome/',
        '/usr/share/icons/pixmaps/'
    }

    naughty.config.icon_formats = {
        'png',
        'svg',
        'jpg',
        'gif'
    }
end
