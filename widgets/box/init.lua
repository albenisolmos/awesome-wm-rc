local gtable = require('gears.table')
local gshape = require('gears.shape')
local base = require('wibox.widget.base')
local background = require('wibox.container.background')
local beautiful = require('beautiful')
local cairo = require('lgi').cairo
local color = require('gears.color')
local unpack = unpack or table.unpack

local box = { mt = {} }
local box_prop_defaults = {
    widget = nil,
    shape = gshape.rectangle,
    foreground = nil,
	background = color('#00000000'),
    background_hover = nil,
    background_press = nil,
    last_background = nil,
    track_size_behavior = 'box',
	margin_top = 0,
	margin_bottom = 0,
	margin_left = 0,
	margin_right = 0,
    padding_top = 0,
    padding_bottom = 0,
    padding_left = 0,
    padding_right = 0
}

box.set_widget = base.set_widget_common
box.set_bg = background.set_bg
box.get_bg = background.get_bg
box.set_fg = background.set_fg
box.get_fg = background.get_fg
box.set_shape = background.set_shape
box.set_border_color = background.set_border_color
box.set_border_width = background.set_border_width
box.get_border_color = background.get_border_color
box.get_border_width = background.get_border_width

-- Make sure a surface pattern is freed *now*
local function dispose_pattern(pattern)
    local status, s = pattern:get_surface()
    if status == 'SUCCESS' then
        s:finish()
    end
end

local function get_free_draw_area(self, width, height)
	local margin_left = self._private.margin_left or self._private.margins
	local margin_top = self._private.margin_top or self._private.margins
	local margin_right = self._private.margin_right or self._private.margins
	local margin_bottom = self._private.margin_bottom or self._private.margins

	local free_width = width - margin_left - margin_right
	local free_height = height - margin_top - margin_bottom

	return free_width, free_height
end

local function on_event(self, event_name, callback)
    if type(callback) ~= 'function' then
        return
    end

    self:connect_signal(event_name, callback)
end

local function set_background_hover(self)
    self._private.last_background = self._private.background
    self._private.background = self._private.background_hover
    self:emit_signal('widget::redraw_needed')
    self:emit_signal('property::bg', self._private.background_hover)
end

local function set_background(self)
    self._private.background = self._private.last_background
    self._private.last_background = self._private.background
    self:emit_signal('widget::redraw_needed')
    self:emit_signal('property::bg', self._private.background)
end

function box:get_widget()
    return self._private.widget
end

function box:get_children()
    return {self._private.widget}
end

function box:set_children(children)
    self:set_widget(children[1])
end

function box:fit(context, width, height)
	--local pad_left = self._private.padding_left or self._private.padding
	local pad_right = self._private.padding_right or self._private.padding
	--local pad_top = self._private.padding_top or self._private.padding
	local pad_bottom = self._private.padding_bottom or self._private.padding
    local w, h = get_free_draw_area(self, width, height)
    w, h = background.fit(self, context, w, h)
    return w-pad_right, h-pad_bottom
end

function box:set_track_size_behavior(bool)
    self._private.track_size_behavior = bool
end

function box:get_track_size_behavior(bool)
    self._private.track_size_behavior = (bool == 'content' or bool == 'box') and bool or nil
end

function box:set_track_size(bool)
    self._private.track_size = bool
end

function box:get_track_size(bool)
    self._private.track_size = bool
end

function box:set_bg_hover(bg)
    self._private.background_hover = bg and color(bg) or nil

    self:connect_signal('mouse::enter', set_background_hover)
    self:connect_signal('mouse::leave', set_background)

    self:emit_signal('widget::redraw_needed')
    self:emit_signal('property::bg', bg)
end

function box:set_margins(val)
    if type(val) == 'number' or not val then
        if self._private.margin_left   == val and
           self._private.margin_right  == val and
           self._private.margin_top    == val and
           self._private.margin_bottom == val then
            return
        end

        self._private.margin_left   = val
        self._private.margin_right  = val
        self._private.margin_top    = val
        self._private.margin_bottom = val
    elseif type(val) == 'table' then
        self._private.margin_left   = val.left or self._private.margin_left
        self._private.margin_right  = val.right or self._private.margin_right
        self._private.margin_top    = val.top or self._private.margin_top
        self._private.margin_bottom = val.bottom or self._private.margin_bottom
    end

    self:emit_signal('widget::layout_changed')
    self:emit_signal('property::margins')
end

function box:set_padding(val)
    if type(val) == 'number' or not val then
        if self._private.padding_left   == val and
           self._private.padding_right  == val and
           self._private.padding_top    == val and
           self._private.padding_bottom == val then
            return
        end

        self._private.padding_left   = val
        self._private.padding_right  = val
        self._private.padding_top    = val
        self._private.padding_bottom = val
    elseif type(val) == 'table' then
        self._private.padding_left   = val.left or self._private.padding_left
        self._private.padding_right  = val.right or self._private.padding_right
        self._private.padding_top    = val.top or self._private.padding_top
        self._private.padding_bottom = val.bottom or self._private.padding_bottom
    end

    self:emit_signal('widget::layout_changed')
    self:emit_signal('property::padding')
end

function box:set_on_press(callback)
    on_event(self, 'button::press', callback)
    self._private.on_press = callback
end

function box:set_on_release(callback)
    on_event(self, 'button::release', callback)
    self._private.on_release = callback
end

function box:get_on_release()
    return self._private.on_release
end

function box:get_on_press()
    return self._private.on_press
end

-- Prepare drawing the children of this widget
function box:before_draw_children(context, cr, width, height)
    width, height = get_free_draw_area(self, width, height)
	local l = self._private.margin_left or self._private.margins
	local t = self._private.margin_top or self._private.margins
    local bw    = self._private.shape_border_width or 0
    local shape = self._private.shape or (bw > 0 and gshape.rectangle or nil)

    -- Redirect drawing to a temporary surface if there is a shape
    if shape then
        cr:push_group_with_content(cairo.Content.COLOR_ALPHA)
    end

    -- Draw the background
    if self._private.background then
        cr:save()
        cr:set_source(self._private.background)
        cr:rectangle(l, t, width+l, height+t)
        cr:fill()
        cr:restore()
    end

    if self._private.bgimage then
        cr:save()
        if type(self._private.bgimage) == 'function' then
            self._private.bgimage(context, cr, width, height,unpack(self._private.bgimage_args))
        else
            local pattern = cairo.Pattern.create_for_surface(self._private.bgimage)
            cr:set_source(pattern)
            cr:rectangle(0, 0, width, height)
            cr:fill()
        end
        cr:restore()
    end

    if self._private.foreground then
        cr:set_source(self._private.foreground)
    end
end

-- Draw the border
function box:after_draw_children(_, cr, width, height)
    width, height = get_free_draw_area(self, width, height)
	local margin_left = self._private.margin_left or self._private.margins
	local margin_top = self._private.margin_top or self._private.margins
    local border_width = self._private.shape_border_width or 0
    local shape = self._private.shape or (border_width > 0 and gshape.rectangle or nil)

    if not shape then
        return
    end

    -- Okay, there is a shape. Get it as a path.

    cr:translate(border_width, border_width)
    shape(cr, margin_left + width - 2*border_width, margin_top + height - 2*border_width, unpack(self._private.shape_args or {}))
    cr:translate(-border_width, -border_width)

    if border_width > 0 then
        -- Now we need to do a border, somehow. We begin with another
        -- temporary surface.
        cr:push_group_with_content(cairo.Content.ALPHA)

        -- Mark everything as "this is border"
        cr:set_source_rgba(0, 0, 0, 1)
        cr:paint()

        -- Now remove the inside of the shape to get just the border
        cr:set_operator(cairo.Operator.SOURCE)
        cr:set_source_rgba(0, 0, 0, 0)
        cr:fill_preserve()

        local mask = cr:pop_group()
        PRINTNN(self._private.foreground)
        -- Now actually draw the border via the mask we just created.
        cr:set_source(color(self._private.shape_border_color or self._private.foreground or beautiful.fg_normal))
        cr:set_operator(cairo.Operator.SOURCE)
        cr:mask(mask)

        dispose_pattern(mask)
    end

    -- We now have the right content in a temporary surface. Copy it to the
    -- target surface. For this, we need another mask
    cr:push_group_with_content(cairo.Content.ALPHA)

    -- Draw the border with 2 * border width (this draws both
    -- inside and outside, only half of it is outside)
    cr.line_width = 2 * border_width
    cr:set_source_rgba(0, 0, 0, 1)
    cr:stroke_preserve()

    -- Now fill the whole inside so that it is also include in the mask
    cr:fill()

    local mask = cr:pop_group()
    local source = cr:pop_group() -- This pops what was pushed in before_draw_children

    -- This now draws the content of the background widget to the actual
    -- target, but only the part that is inside the mask
    cr:set_operator(cairo.Operator.OVER)
    cr:set_source(source)
    cr:mask(mask)

    dispose_pattern(mask)
    dispose_pattern(source)
end

function box:layout(_, width, height)
    if not self._private.widget then
        return
    end

    local w, h = get_free_draw_area(self, width, height)
	local margin_left = self._private.margin_left or self._private.margins
	local margin_top = self._private.margin_top or self._private.margins
	local pad_left = self._private.padding_left or self._private.padding
	local pad_right = self._private.padding_right or self._private.padding
	local pad_top = self._private.padding_top or self._private.padding
	local pad_bottom = self._private.padding_bottom or self._private.padding

    if w >= 0 and h >= 0 then
        local border_width = self._private.border_strategy == 'inner' and
        self._private.shape_border_width or 0

        if self._private.track_size_behavior == 'box' and self._private.track_size then
            self._private.width = width
            self._private.height = height
        end

        return {base.place_widget_at(
            self._private.widget,
            margin_left + border_width + pad_left,
            margin_top + border_width + pad_top,
            w - (2 * pad_right) - 2*border_width,
            h - (2 * pad_bottom) - 2*border_width
        )}
    end
end

local function new(widget)
	local ret = base.make_widget(nil, nil, {
		enable_properties = true,
	})

    -- Copy methods and properties over
    -- Except those, which don't belong in the widget instance
    gtable.crush(ret, box, true)
    -- Set initial values for properties.
    gtable.crush(ret._private, box_prop_defaults, true)

    ret:set_widget(widget)
	return ret
end

function box.mt:__call(...)
	return new(...)
end

return setmetatable(box, box.mt)
