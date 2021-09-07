local awful     = require('awful')
local wibox     = require('wibox')
local shape     = require('gears.shape')
local beautiful = require('beautiful')
local dpi       = beautiful.xresources.apply_dpi
local clickable = require 'widget.clickable'
local apps      = require 'apps'

local app_path  = '/usr/share/applications/'
local apps_cache = require('gears').filesystem.get_configuration_dir() .. '/cache/dock'
local icon_path = '/usr/share/icons/Papirus/32x32/apps/'
local atextbox  = wibox.widget.textbox()
local mode

local function get_output(command)
	local output
	command = io.popen(command)
	output = command:read('*all')
	command:close()

	return output
end

local function save_app(app)
	local apps = io.open(apps_cache, 'a')
	apps:write(app, '\n')
	apps:close()
end

local function search_app(app, bool)
	local app_file, content, icon, exec, terminal, name

	local posible_app_file = io.popen('find '..app_path.. ' -maxdepth 1 -iname *' ..app..'*' )
	for file in posible_app_file:lines() do
		app_file = io.open(file, 'r')
		break
	end
	posible_app_file:close()
	if not app_file then
		return
	end
	content = app_file:read('*all')
	app_file:close()

	name = content:match('Name=(.-)\n')
	icon = content:match('Icon=(.-)\n')

	exec = content:match('TryExec=(.-)\n')
	if exec == nil then
		exec = content:match('Exec=(.-)\n'):gsub('(%%.)', '')
	end

	terminal = content:match('Terminal=(.-)\n')
	if terminal == 'true' then
		exec = apps.terminal .. ' -e' .. exec
	end

	awesome.emit_signal('dock::item', {
		icon    = string.format('%s%s.svg', icon_path, icon),
		onclick = exec,
		name    = name
	})

	if bool == true then
		save_app(app)
	end
end

local function remember_apps()
	local apps = io.open(apps_cache, 'r')
	for app in apps:lines() do
		search_app(app)
	end
	apps:close()
end

return function(screen)
	remember_apps()

	local dialog = wibox {
		screen = screen,
		--type   = 'utility',
		visible= false,
		ontop  = true,
		x = (screen.workarea.width / 2) - (500/2),
		y = (screen.workarea.height / 2) - (60/2),
		width  = dpi(500),
		height = dpi(50),
		bg = beautiful.bg,
		shape = shape.rounded_rect,
		widget = {
			margins = dpi(10),
			layout = wibox.container.margin,
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = dpi(10),
				{
					widget = wibox.widget.imagebox,
					image = beautiful.icon_arrow_right,
					resize = true,
					id = 'icon'
				},
				atextbox
			}
		}
	}
	local icon = dialog:get_children_by_id('icon')[1]
	icon:connect_signal('button::release', function()
		icon:set_image(beautiful.icon_taglist_web_browser)
		mode = 'web'
	end)

	awesome.connect_signal('dialog::write', function(arg)
		mode = arg or 'run'
		icon:set_image(beautiful.icon_arrow_right)
		dialog.visible = true

		awful.prompt.run {
			prompt       = '',
			textbox      = atextbox,
			keypressed_callback = function(mod, key, cmd)
				if key == 'Tab' then
					icon:set_image(beautiful.icon_taglist_web_browser)
					mode = 'web'
				end
			end,
			history_path = os.getenv('HOME') .. '/.config/awesome/cache/cache',
			exe_callback = function(cmd)
				if mode == 'web' then
					awful.spawn({'xdg-open', 'https://www.google.com/search?client=ubuntu&channel=fs&q=' .. cmd .. '&ie=utf-8&oe=utf-8'})
				elseif mode == 'dock' then
					search_app(cmd, true)
				else
					awful.spawn(cmd)
				end
				dialog.visible = false
			end,
			done_callback = function() 
				dialog.visible = false
			end
		}
	end)

	return dialog
end
