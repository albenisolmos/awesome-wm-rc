function table.filter(t, filter)
	local filtered = {}

	for i, item in pairs(t) do
		if filter(item, i, filtered) then
			table.insert(filtered, item)
		end
	end

	return filtered
end
