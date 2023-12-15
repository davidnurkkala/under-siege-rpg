local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local PlatformContext = require(ReplicatedStorage.Shared.React.PlatformContext.PlatformContext)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)

local PlatformByEnum = Sift.Dictionary.merge(unpack(Sift.Dictionary.values(Sift.Dictionary.map({
	Desktop = { "MouseButton1", "MouseButton2", "MouseButton3", "MouseWheel", "MouseMovement", "Keyboard", "TextInput" },
	Mobile = { "Touch", "Accelerometer", "Gyro" },
	Console = { "Gamepad1", "Gamepad2", "Gamepad3", "Gamepad4", "Gamepad5", "Gamepad6", "Gamepad7", "Gamepad8" },
}, function(enumNameList, platform)
	return Sift.Dictionary.map(enumNameList, function(enumName)
		return platform, Enum.UserInputType[enumName]
	end)
end))))

local function getPlatform()
	return PlatformByEnum[UserInputService:GetLastInputType()] or "Desktop"
end

return function(props)
	local platform, setPlatform = React.useState(getPlatform())

	React.useEffect(function()
		local connection = UserInputService.LastInputTypeChanged:Connect(function()
			local newPlatform = getPlatform()
			if newPlatform ~= platform then setPlatform(newPlatform) end
		end)

		return function()
			connection:Disconnect()
		end
	end, { platform })

	return React.createElement(PlatformContext.Provider, {
		value = platform,
	}, props.children)
end
