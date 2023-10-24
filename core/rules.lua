local ascreen = require('awful.screen')
local aclient = require('awful.client')
local amouse = require('awful.mouse')
local aplacement = require('awful.placement')
local abutton = require('awful.button')
local gshape = require('gears.shape')
local gtable = require('gears.table')
local ruled = require('ruled')
local settings = require('settings')

local shape = type(settings.client_shape) == 'function'
    and settings.client_shape(gshape)
    or function(cr, w, h)
        gshape.rounded_rect(cr, w, h, settings.client_shape)
    end

local buttons_client = gtable.join(
    -- Resize clients by dragging at bottom left/right corner
    -- Radius is set in theme variable `client_corner_resize_radius`
    abutton({ }, 1, function(c)
        c:emit_signal('request::activate', 'mouse_click', {raise = true})
        awesome.emit_signal('menu::hide')
        awesome.emit_signal('popup::hide')

        -- FIX: why c.floating is false when client is really floating
        if c.floating then
            return
        end

        -- Only use bottom left/right corner, because dragging titlebar is already mapped to move
        local m = mouse.coords()
        local corners = {
            { c.x + c.width, c.y + c.height },
            { c.x, c.y + c.height },
        }

        for _, pos in ipairs(corners) do
            if math.sqrt((m.x - pos[1]) ^ 2 + (m.y - pos[2]) ^ 2) <= 10 then
                amouse.client.resize(c)
                break
            end
        end
    end),
    abutton({settings.modkey}, 1, function(c)
        c:emit_signal('request::activate', 'mouse_click', {raise = true})
        amouse.client.move(c)
    end),
    abutton({settings.modkey}, 3, function(c)
        c:emit_signal('request::activate', 'mouse_click', {raise = true})
        amouse.client.resize(c)
    end)
)

local splash_gesture = gtable.join(
    abutton({}, 1, function(c)
        c:emit_signal('request::activate', 'mouse_click', {raise = true})
        amouse.client.move(c)
    end)
)

return function()
    ruled.client.connect_signal('request::rules', function()
        local rule = ruled.client.append_rule

        rule {
            id = 'global',
            rule = {},
            properties = {
                focus = aclient.focus.filter,
                raise = true,
                screen = ascreen.preferred,
                placement = aplacement.no_offscreen + aplacement.centered,
                buttons = buttons_client,
                keys = require('core.keymaps-client'),
                shape = shape,
                honor_workarea = true,
                titlebars_enabled = function(c)
                    return not c.requests_no_titlebar
                end,
                callback = function(cli)
                    -- Fix client size not respecting screen size
                    local s = cli.screen
                    if cli.width > s.geometry.width or cli.height > s.geometry.height then
                        cli.maximized = false
                        cli.maximized = true
                    end
                end
            }
        }

        rule {
            rule_any = { type = {'dialog'} },
            callback = function(cli)
                -- Center dialog on his parent
                local parent = cli.transient_for
                if not parent then return end
                cli.x = parent.x - ((cli.width - parent.width) / 2)
                cli.y = parent.y - ((cli.height - parent.height) / 2)
            end
        }

        rule {
            rule_any = {type = {'splash'}},
            buttons = splash_gesture,
            placement = aplacement.centered,
            properties = {titlebars_enabled = false}
        }

        rule {
            id = 'floating',
            rule_any = {
                instance = {'DTA', 'copyq'},
                name     = {'Event Tester'},
                role     = {'AlarmWindow', 'ConfigManager', 'pop-up'}
            },
            properties = {floating = true}
        }
    end)
end
