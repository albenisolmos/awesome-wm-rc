local timer = require('gears.timer')
local object = require('gears.object')
local multispawn = { mt = {} }

function multispawn:start()
	self.time = 0
	self.stop_now = false

	self.timer = timer { timeout = 0.1, autostart = true }

	self.timer:connect_signal('timeout', function()
		if self.stop_now then
			self.timer:stop()
			return
		end

		self.timer:stop()
		self.time = self.time + 1

		if self.time >= self.timeout then
			self.on_hold()
			self.timer:stop()
			return
		end

		self.timer:again()
	end)
end

function multispawn:stop()
	self.stop_now = true
	if self.time < self.timeout then
		self.on_click()
	end
end

function multispawn:get_time()
	return self.time
end

function multispawn:set_on_click(callback)
	self.on_click = callback
end

function multispawn:set_on_hold(callback)
	self.on_hold = callback
end

local timer_instace_mt = {
	__index = function(self, property)
		if property == 'timeout' then
			return self.data.timeout
		end
		return multispawn[property]
	end
}

function multispawn.new(args)
	args = args or {}
	local ret = object()
	ret.data = { timeout = 5}
	setmetatable(ret, timer_instace_mt)

	for k, v in pairs(args) do
		ret[k] = v
	end

	return ret
end

function multispawn.mt.__call(_, ...)
	return multispawn.new(...)
end

return setmetatable(multispawn, multispawn.mt)
