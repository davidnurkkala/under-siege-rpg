local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

local WeightTable = {}
WeightTable.__index = WeightTable

export type WeightTableEntryDef = {
	Result: any,
	Weight: number,
}

type WeightTableEntry = WeightTableEntryDef & {
	Range: {
		Min: number,
		Max: number,
	},
	Chance: number,
}

export type WeightTable = typeof(setmetatable(
	{} :: {
		Entries: { WeightTableEntry },
		Weight: number,
		Random: Random,
	},
	WeightTable
))

function WeightTable.new(entries: { WeightTableEntryDef }, random: Random?): WeightTable
	entries = Sift.Dictionary.copyDeep(entries)

	local weight = Sift.Array.reduce(entries, function(acc, entry)
		entry.Range = {
			Min = acc,
			Max = acc + entry.Weight,
		}

		return acc + entry.Weight
	end, 0)

	for _, entry in entries do
		entry.Chance = entry.Weight / weight
	end

	local self: WeightTable = setmetatable({
		Entries = entries :: { WeightTableEntry },
		Weight = weight,
		Random = random or Random.new(),
	}, WeightTable)

	return self
end

function WeightTable.Is(object)
	return getmetatable(object) == WeightTable
end

function WeightTable.GetEntries(self: WeightTable)
	return self.Entries
end

function WeightTable.Roll(self: WeightTable): any
	local selector = self.Random:NextNumber(0, self.Weight)

	local selected
	if selector == 0 then
		selected = self.Entries[1]
	else
		for _, entry in self.Entries do
			if selector > entry.Range.Min and selector <= entry.Range.Max then
				selected = entry
				break
			end
		end

		assert(selected, `Weight table somehow corrupted`)
	end

	local result = selected.Result

	if typeof(result) == "table" then
		return Sift.Dictionary.copyDeep(result)
	else
		return result
	end
end

function WeightTable.Print(self: WeightTable)
	print(table.concat(
		Sift.Array.map(self.Entries, function(entry)
			return `{entry.Result} = {entry.Weight} ({math.floor(entry.Chance * 100)}%)`
		end),
		`\n`
	))
end

function WeightTable.Destroy(_self: WeightTable) end

return WeightTable
