local spawn = require('awful.spawn')
local gears = require('gears')

local function update_backdrop(w, c)
    local cairo = require("lgi").cairo
    local geo = c.screen.geometry

    w.x = geo.x
    w.y = geo.y
    w.width = geo.width
    w.height = geo.height

    -- Create an image surface that is as large as the wibox
    local shape = cairo.ImageSurface.create(cairo.Format.A1, geo.width, geo.height)
    local cr = cairo.Context(shape)

    -- Fill with "completely opaque"
    cr.operator = "SOURCE"
    cr:set_source_rgba(1, 1, 1, 1)
    cr:paint()

    -- Remove the shape of the client
    local c_geo = c:geometry()
    local c_shape = gears.surface(c.shape_bounding)
    cr:set_source_rgba(0, 0, 0, 0)
    cr:mask_surface(c_shape, c_geo.x + c.border_width, c_geo.y + c.border_width)
    c_shape:finish()

    w.shape_bounding = shape._native
    shape:finish()
end

local function backdrop(c)
    local w = wibox{ ontop = true, bg = "#ff0000" }
    local function update()
        update_backdrop(w, c)
    end
    c:connect_signal("property::geometry", update)
    c:connect_signal("property::shape_client_bounding", function()
        gears.timer.delayed_call(update)
    end)
    c:connect_signal("unmanage", function()
        w.visible = false
    end)
    update()
    w.visible = true
end

local function grab_first_client(c)
    client.disconnect_signal("manage", grab_first_client)
    backdrop(c)
end
client.connect_signal("manage", grab_first_client)

-- Just for fun, test this with xeyes
spawn({"xeyes"})
