local Rand = Random.new()
local Tau = math.pi * 2

return function()
	return CFrame.Angles(Rand:NextNumber(0, Tau), 0, Rand:NextNumber(0, Tau))
end
