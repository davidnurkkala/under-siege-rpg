local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local component = React.memo(function(props)
	local visible = props.Visible
	local onActivated = props[React.Event.Activated]
	local image = props.Image
	local text = props.Text
	local buttonRef = props.buttonRef
	local anchorPoint = props.AnchorPoint or Vector2.new(0, 0)
	local position = props.Position or UDim2.fromScale(0, 0)
	local height = props.height or UDim.new(0, 0)
	local selectable = if props.Selectable == nil then true else props.Selectable

	local textSize, setTextSize = React.useState(0)
	local absoluteSizeChangedCallback = React.useCallback(function(rbx)
		setTextSize(rbx.AbsoluteSize.Y * 0.8)
	end, {})

	return React.createElement("ImageButton", {
		Visible = visible,
		BackgroundTransparency = 0,
		Size = UDim2.new(UDim.new(), height),
		AutomaticSize = Enum.AutomaticSize.X,
		AnchorPoint = anchorPoint,
		Position = position,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		ZIndex = 2,
		Image = "",
		[React.Event.Activated] = onActivated,
		ref = buttonRef,
		Selectable = selectable,
	}, {
		UICorner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0.5, 0),
		}),
		UIStroke = React.createElement("UIStroke", {
			Thickness = 2,
			Color = Color3.fromRGB(255, 255, 255),
		}),
		UIListLayout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		ButtonFrame = React.createElement("Frame", {
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
		}, {
			AspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
				DominantAxis = Enum.DominantAxis.Height,
				AspectType = Enum.AspectType.ScaleWithParentSize,
			}),
			Image = React.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.65, 0.65),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = image,
			}),
		}),
		Text = React.createElement("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 0.7, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = 2,
			Text = text,
			Font = Enum.Font.GothamBold,
			TextWrapped = false,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextStrokeTransparency = 0,
			TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
			TextSize = textSize,
			[React.Change.AbsoluteSize] = absoluteSizeChangedCallback,
			Visible = text ~= "",
		}),
		RightSpacer = React.createElement("Frame", {
			Size = UDim2.new(0.2, 0, 0.2, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency = 1,
			LayoutOrder = 3,
			Visible = text ~= "",
		}),
	})
end)

return component
