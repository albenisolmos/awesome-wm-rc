local wibox     = require('wibox')
local shape     = require('gears.shape')
local beautiful = require('beautiful')

local album_cover = wibox.widget {
	layout = wibox.layout.align.horizontal,
	expand = 'none',
	nil,
	{
		widget     = wibox.widget.imagebox,
		image      = beautiful.icon_player_music,
		clip_shape = shape.rounded_rect,
		resize     = true,
		id         = 'cover'
	},
	nil
}

awesome.connect_signal('player::expand', function(expand)
	if expand then
		album_cover:get_children_by_id('cover')[1].forced_height = 200
	else
		album_cover:get_children_by_id('cover')[1].forced_heigth = 0
	end
	album_cover:emit_signal('widget::redraw_needed')
end)

return album_cover
