local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TryNow = require(ReplicatedStorage.Shared.Util.TryNow)

return function(player)
	return TryNow(function()
		return ((player.Character :: Model).PrimaryPart :: BasePart).Position
	end, Vector3.zero)
end
