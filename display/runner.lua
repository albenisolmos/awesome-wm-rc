local spawn = require('awful.spawn')
local aprompt = require('awful.prompt')
local wibox = require('wibox')
local shape = require('gears.shape')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi

local textbox  = wibox.widget.textbox()

local verbs = {
	w = function(value)
		return 'firefox -search '..value
	end,
	t = function(value)
		return 'x-terminal-emulator -e '..value
	end
}

local function expand_verb(cmd)
	if (not cmd) or cmd:sub(2,2) ~= ':' then return cmd end
	local verb, fixed_cmd = cmd:gmatch('([a-zA-Z1-9]+):(.*)')()
	return verbs[verb](fixed_cmd)
end

return function(screen)
	local runner = wibox {
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
		widget = wibox.widget {
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
				textbox
			}
		}
	}

	runner:get_children_by_id('icon')[1]:connect_signal('button::release', function(self)
		self:set_image(beautiful.icon_taglist_web_browser)
		current_verb = 'w'
	end)

	awesome.connect_signal('runner::run', function(arg)
		current_verb = arg or 'run'
		runner.visible = true

		aprompt.run {
			prompt  = '',
			textbox = textbox,
			exe_callback = function(cmd)
				cmd = expand_verb(cmd)
				spawn(cmd)
			end,
			done_callback = function()
				runner.visible = false
			end,
			history_path = os.getenv('HOME') .. '/.config/awesome/cache/cache',
		}
	end)

	return runner
end
