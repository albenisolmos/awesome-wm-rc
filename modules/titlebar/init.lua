local amouse = require('awful.mouse')
local abutton = require('awful.button')
local atitlebar = require('awful.titlebar')
local gtable = require('gears.table')
local gtimer = require('gears.timer')
local settings = require('settings')

local windows_titlebar = require('modules.titlebar.windows')
local wmenu = require('widgets.menu')
local current_client
local double_click_timer = nil

atitlebar.enable_tooltip = false

local menu = wmenu({
	items = {
		{'Close', function()
			current_client:kill()
		end},
		{'Minimize', function()
				current_client.minimized = false
		end},
		{'Maximize', function()
				current_client.maximized = not current_client.maximized
		end},
		{'Tabalize', function()
				--tab.enable_tabs(current_client)
		end}
	}
})

local function double_click_event_handler(double_click_event)
    if double_click_timer then
        double_click_timer:stop()
        double_click_timer = nil

        double_click_event()

        return
    end

    double_click_timer = gtimer.start_new(0.20, function()
        double_click_timer = nil
        return false
    end)
end

return {
    init = function()
        client.connect_signal('request::titlebars', function(c)
            atitlebar(c, { size = settings.titlebar_height or 35 }).widget = windows_titlebar(gtable.join(
                abutton({ }, 1, function()
                    c:emit_signal('request::activate', 'mouse_click', {raise = true})
                    amouse.client.move(c)
                    double_click_event_handler(function()
                        c.floating = false
                        c.maximized = not c.maximized
                    end)
                end),
                abutton({ }, 3, function()
                    current_client = c
                    menu:show()
                    c:emit_signal('request::activate', 'mouse_click', {raise = true})
                    amouse.client.resize(c)
                end)
                ), c)
        end)
    end
}
