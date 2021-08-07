local awful = require('awful')
local wibox = require('wibox')
local surface = require('gears.surface')
local shape = require('gears.shape')
local common = require('awful.widget.common')

local thumbnail = {}

local function fit(self, context, width, height)
	local size = math.min( width, height)
	return size, size
end

local function set_client( self, c )
	ret._private.client[1] = c
	self:emit_signal('widget::redraw_needed')
end

local function draw( self, content,  cr, width, height )
	local c = self._private.client[1]
	local s, geo = surface(c.content), c:geometry()
	local scale = math.min( width/ geo.width, height / geo.height)
	local w, h = geo.width*scale, geo.height*scale
	local dx, dy = (width-w)/2, (height-h)/2
	cr:translate( dx, dy )
	shape.rounded_rect(cr, w, h, 5)
	cr:clip()
	cr:scale( scale, scale )
	cr:set_source_surface(s)
	cr:paint()
	s:finish()
end

local function new(c)
	local ret = wibox.widget.base.make_widget( nil, nil, {
		enabled_properties = true
	})

	rawset( ret, 'fit', fit )
	rawset( ret, 'draw', draw )
	rawset( ret, 'set_client', set_client )
	ret._private.client = setmetatable( {c}, {__mode='v'})

	return ret
end

return setmetatable( thumbnail, {__call = function( _, ... ) return new(...) end} )
