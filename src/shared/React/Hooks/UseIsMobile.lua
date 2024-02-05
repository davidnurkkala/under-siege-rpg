local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlatformContext = require(ReplicatedStorage.Shared.React.PlatformContext.PlatformContext)
local React = require(ReplicatedStorage.Packages.React)

return function()
	return React.useContext(PlatformContext) == "Mobile"
end
