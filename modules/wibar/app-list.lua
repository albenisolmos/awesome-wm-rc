local wibox = require('wibox')
local beautiful = require('beautiful')
local aspawn = require('awful.spawn')
local abutton = require('awful.button')
local gtable = require('gears.table')

local log = require('utils.debug').log
local utable = require('utils.table')
local box = require('widgets.box')

local APPS_DIR = '/usr/share/applications/'
local CONFIG_DIR = require('gears.filesystem').get_xdg_config_home()
local clients = {}

-- TODO: add to client-list a signal on remove a client
-- -[[
-- step: click: if theres no client spawm one
--       else focus the first on the list
--       if 
-- ]]

local function focus(cli)
    cli.minimized = false

    if not cli:isvisible() and cli.first_tag then
        cli.first_tag:view_only()
    end

    client.focus = cli
    cli:raise()
end

local function focus_or_spawn(c)
    if c == client.focus then
        c.minimized = true
    else
        focus(c)
    end
end

local function client_widget(cli)
    return wibox.widget {
        layout = box,
        client = cli,
        forced_width = 150,
        bg_hover = beautiful.bg_hover,
        padding_left = 10,
        padding_right = 10,
        shape = 'rounded',
        buttons = gtable.join(
            abutton({}, 1, function(self)
                focus_or_spawn(self.widget.client)
            end),
            abutton({}, 2, function(self)
                self.widget.client:kill()
            end)
        ),
        {
            layout = wibox.layout.fixed.horizontal,
            spacing = 5,
            {
                image = cli.icon,
                forced_width = 15,
                forced_height = 15,
                valing = 'center',
                widget = wibox.widget.imagebox
            },
            {
                text = cli.name,
                widget = wibox.widget.textbox
            }
        }
    }
end

local apps = wibox.widget {
    widget = require('widgets.client-list'),
    widget_template = client_widget
}

local function app_widget(data)
    local self = client_widget(data)
    self.exec = data.exec
    self.on_press = function(_self)
        aspawn(_self.exec, {callback = function(cli)
            clients[cli.class] = self
            apps:remove_widgets(self)
        end})
    end

    return self
end

local function extract_key_value(initFile, key)
    local file = io.open(initFile, "r")
    local execValue

    if file then
        for line in file:lines() do
            local k, value = line:match("(%w+)%s-=%s-(.*)")
            if k == key then
                execValue = value:gsub(" %%.", "") -- Remove % flags
                break
            end
        end
        file:close()
    end

    return execValue
end

local function get_app_data(desktop_file)
    return {
        name = extract_key_value(desktop_file, 'Name'),
        exec = extract_key_value(desktop_file, 'Exec')
            or extract_key_value(desktop_file, 'TryExec'),
        icon = extract_key_value(desktop_file, 'Icon')
    }
end

local function update_apps()
    local cache = utable.load(CONFIG_DIR..'awesome-cache.lua')
    if type(cache) ~= 'table' then
        return
    end

    for _, value in pairs(cache) do
        apps:add(app_widget(get_app_data(APPS_DIR..value)))
    end
end

--update_apps()

local reset = apps.reset
function apps:reset(...)
    reset(self, ...)
    --update_apps()
end

apps:connect_signal('on::remove_client', function(_, client)
    if clients[client.class] then
        apps:add(clients[client.class])
    end
end)

return apps
