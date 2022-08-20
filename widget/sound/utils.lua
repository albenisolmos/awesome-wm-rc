local spawn = require('awful.spawn')
local M = {}

function M.calc_volume(expresion, current_volume)
	local from, to = string.find(expresion, '%d+')
	local volume = tonumber(string.sub(expresion, from, to))
	local action = expresion:sub(1,1)

	if action == '-' then
		volume = current_volume - volume
	elseif action == '+' then
		volume = current_volume + volume
	end

	if volume < 0 then
		volume = 0
	elseif volume > 100 then
		volume = 100
	end

	return tonumber(volume)
end


function M.get_volume(callback)
	spawn.easy_async_with_shell(
		[[bash -c "amixer -D pulse sget Master"]],
		function(stdout)
			local volumen = string.match(stdout, '(%d?%d?%d)%%')
			pcall(callback, tonumber(volumen))
		end
	)
end

return M
