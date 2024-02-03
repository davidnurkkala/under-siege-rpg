local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeightTable = require(ReplicatedStorage.Shared.Classes.WeightTable)

return function(...)
	local amounts = { ... }
	local count = #amounts
	local entries = {}
	for index, amount in amounts do
		local step = count - (index - 1)
		local weight = 2 ^ step
		table.insert(entries, { Weight = weight, Result = amount })
	end
	return WeightTable.new(entries)
end
