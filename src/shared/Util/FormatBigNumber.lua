local Divisions = {
	{ Number = 1e3, Name = "k" },
	{ Number = 1e6, Name = "m" },
	{ Number = 1e9, Name = "b" },
	{ Number = 1e12, Name = "t" },
	{ Number = 1e15, Name = "q" },
}

local function format(number, division)
	local whole, frac = math.modf(number / division.Number)
	return `{whole}.{math.floor(frac * 10)}{division.Name}`
end

return function(number: number): string
	if number < 1000 then
		return `{math.floor(number)}`
	else
		for index = 1, #Divisions - 1 do
			local lower = Divisions[index]
			local upper = Divisions[index + 1]
			if number >= lower.Number and number < upper.Number then return format(number, lower) end
		end
	end
	return format(number, Divisions[#Divisions])
end
