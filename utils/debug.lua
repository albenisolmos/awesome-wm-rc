local naughty = require('naughty')
local M = {}

function M.log(...)
	local msg = ''
	local arg = type(...) ~= 'table' and {...} or ...

    for _, item in pairs(arg) do
		msg = string.format('%s %s', msg, tostring(item))
    end

	naughty.notify {
		timeout = 0,
		title = 'Log',
		text = tostring(msg)
	}
end

return M
