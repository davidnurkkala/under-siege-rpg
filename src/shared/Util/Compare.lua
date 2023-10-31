local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Sift = require(ReplicatedStorage.Packages.Sift)

return function(a, b)
	if typeof(a) == "table" and typeof(b) == "table" then
		return Sift.Dictionary.equalsDeep(a, b)
	else
		return a == b
	end
end
