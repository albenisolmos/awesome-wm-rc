local aspawn   = require('awful.spawn')
local VOLUME_CMD = 'pactl set-sink-volume @DEFAULT_SINK@ '
local M = {}
local object = require('gears.object') {class = {value=0}}
local log = require('utils.debug').log

function M.connect_signal(name, func)
	object:connect_signal(name, func)
end

function M.emit_signal(name, ...)
	object:emit_signal(name, ...)
end

function M.increase(value)
	local percent = string.format('+%s%%', value)
	aspawn.with_shell(VOLUME_CMD .. percent, false)
	M.get(function(curr_vol)
		M.emit_signal('property::value', curr_vol+value)
	end)
	--awesome.emit_signal('sound::level', percent)
end

function M.decrease(value)
	local percent = string.format('-%s%%', value)
	aspawn.with_shell(VOLUME_CMD .. percent, false)
	M.get(function(curr_vol)
		M.emit_signal('property::value', curr_vol-value)
	end)
	--awesome.emit_signal('sound::level', percent)
end

function M.set(value)
	local percent = string.format('%s%%', value)
	aspawn.with_shell(
		VOLUME_CMD .. percent,
		false
	)

	object:emit_signal('property::value', value)
end

function M.get(callback)
	assert(type(callback) == 'function')

	aspawn.easy_async_with_shell(
		[[pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -n 1]],
		function(stdout)
			stdout = string.gsub(stdout, "\n", "")
			stdout = tonumber(stdout)
			callback(stdout)
		end
	)
end

-- TODO: callback must be called with a table {left, right} with the volume
-- of each side
function M.get_by_side(callback)
	aspawn.easy_async_with_shell(
		[[bash -c "amixer -D pulse sget Master"]],
		function(stdout)
			local volumen = string.match(stdout, '(%d?%d?%d)%%')
			pcall(callback, tonumber(volumen))
		end
	)
end

return M
