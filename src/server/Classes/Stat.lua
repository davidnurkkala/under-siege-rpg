local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)
local Stat = {}
Stat.__index = Stat

type Modifier = (number) -> number

export type Stat = typeof(setmetatable(
	{} :: {
		Base: number,
		Percent: number,
		Flat: number,
		Modifiers: {
			Base: { [Modifier]: boolean },
			Percent: { [Modifier]: boolean },
			Flat: { [Modifier]: boolean },
		},
	},
	Stat
))

function Stat.new(base: number): Stat
	local self: Stat = setmetatable({
		Base = base,
		Percent = 0,
		Flat = 0,
		Modifiers = {
			Base = {},
			Percent = {},
			Flat = {},
		},
	}, Stat)

	return self
end

function Stat.Modify(self: Stat, name: "Base" | "Percent" | "Flat", modifier: Modifier): () -> ()
	self.Modifiers[name][modifier] = true

	return function()
		self.Modifiers[name][modifier] = nil
	end
end

function Stat.Get(self: Stat): number
	local numbers = Sift.Dictionary.map(self.Modifiers, function(modifiers, name)
		return Sift.Array.reduce(Sift.Set.toArray(modifiers), function(total, modifier)
			return modifier(total)
		end, self[name])
	end)

	return numbers.Base * (1 + numbers.Percent) + numbers.Flat
end

function Stat.Destroy(self: Stat) end

return Stat
