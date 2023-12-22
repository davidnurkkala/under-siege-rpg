local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local PlatformContext = require(ReplicatedStorage.Shared.React.PlatformContext.PlatformContext)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local UseMotor = require(ReplicatedStorage.Shared.React.Hooks.UseMotor)
local Window = require(ReplicatedStorage.Shared.React.Common.Window)

return function(props)
	local binding, motor = UseMotor(0)
	local windowRef = React.useRef(nil)

	local platform = React.useContext(PlatformContext)

	local visible = if props.Visible == nil then true else props.Visible
	local renderContainer = props.RenderContainer or function() end

	props = Sift.Dictionary.removeKeys(props, "Visible", "RenderContainer")

	React.useEffect(function()
		if not visible then
			GuiService.SelectedObject = nil
			return
		end

		local window = windowRef.current

		local addedGuid
		if window then
			addedGuid = HttpService:GenerateGUID(false)
			GuiService:AddSelectionParent(addedGuid, window)

			if platform == "Console" then GuiService:Select(windowRef.current) end
		end

		return function()
			if addedGuid then GuiService:RemoveSelectionGroup(addedGuid) end
		end
	end, { visible })

	-- This is here so that someone plugging in a gamepad in the middle of a game doesn't get locked out.
	React.useEffect(function()
		if visible and platform == "Console" and GuiService.SelectedObject == nil then GuiService:Select(windowRef.current) end
	end, { platform, visible })

	React.useEffect(function()
		if visible then
			motor:setGoal(Flipper.Spring.new(1))
		else
			motor:setGoal(Flipper.Spring.new(0))
		end
	end, { visible })

	local containerProps =
		Sift.Dictionary.merge(Sift.Dictionary.withKeys(props, "ZIndex", "Size", "SizeConstraint", "Position", "AnchorPoint", "LayoutOrder"), {
			Visible = visible,
		})

	local windowProps = Sift.Dictionary.merge(props, {
		Size = binding:map(function(value)
			return UDim2.fromScale(value, value)
		end),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		windowRef = windowRef,
		interactable = visible,
	})

	return React.createElement(Container, containerProps, {
		Window = React.createElement(Window, windowProps),
		Container = renderContainer(),
	})
end
