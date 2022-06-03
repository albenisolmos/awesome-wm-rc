local naughty = require('naughty')
local beautiful = require('beautiful')

do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        if in_error then return end
        in_error = true

		naughty.notify({
				preset = naughty.config.presets.critical,
				title = "Oops, an error happened!",
				text = tostring(err)
			})

		in_error = false
    end)
end

if awesome.startup_errors then
	naughty.notify {
		urgency = "critical",
		title   = "Oops, an error happened during startup!",
		message = awesome.startup_errors,
		app_name = 'Awesome',
		icon = beautiful.awesome_icon
	}
end
