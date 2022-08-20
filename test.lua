local tbl1 = {loco1={1,2,3}, loco2={4,5,6}}
local tbl2 = {["loco1"]={1,2,3}, ["loco2"]={4,5,6}}
local tbl3 = {{1,2,3}, {4,5,6}}

for n, tlayouts in pairs(tbl1) do
	print(n, tlayouts)
end

print(select('#', {1,2,3}, {123,1}))
