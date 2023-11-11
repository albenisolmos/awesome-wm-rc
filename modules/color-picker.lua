local akey = require('awful.key')
local gtable = require('gears.table')
local gsurface = require('gears.surface')
local gshape = require('gears.shape')
local aspawn = require('awful.spawn')
local naughty = require('naughty')
local lgi = require('lgi')
local gdk = lgi.require('Gdk', '3.0')

local settings = require('settings')

gdk.init({}) -- this was missing

local function get_pixel(x, y)
    local w = gdk.get_default_root_window()
    local pb = gdk.pixbuf_get_from_window(w, x, y, 1, 1)
    local bytes = pb:get_pixels()
    -- convert bytestring to hex via googled gsub
    return bytes:gsub('.', function(c)
        return ('%02x'):format(c:byte())
    end)
end

local function show_color(color)
    naughty.notification {
        title = 'Color',
        text = color,
        image = gsurface.load_from_shape(35, 35, gshape.rectangle, color, color)
    }
end

local function copy_color_to_clipboard(color)
    aspawn.with_shell(
        string.format(
            'echo "%s" | xclip -selection clipboard',
            color
        )
    )
end

return {
    on_keymaps = function()
        return gtable.join(
            akey({settings.modkey}, 'k', function()
                local mc = mouse.coords()
                local pixel = get_pixel(mc.x, mc.y)
                local color = '#' .. pixel

                show_color(color)
                copy_color_to_clipboard(color)
            end)
        )
    end
}
