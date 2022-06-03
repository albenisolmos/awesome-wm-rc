function table.filter(t, filter)
	assert(t and filter, "table.filter: must be passed a table and a filter function")
		
	local filtered = {}

	for i, item in pairs(t) do
		if filter(item, i, filtered) then
			table.insert(filtered, item)
		end
	end

	return filtered
end

function table.for_each(tbl, callback)
	for i, el in pairs(tbl) do
		callback(el, i)
	end
end
