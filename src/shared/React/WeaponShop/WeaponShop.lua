local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SquishWindow = require(ReplicatedStorage.Shared.React.Common.SquishWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local Trove = require(ReplicatedStorage.Packages.Trove)
local WeaponDefs = require(ReplicatedStorage.Shared.Defs.WeaponDefs)

local WeaponRotation = CFrame.Angles(0, math.pi / 2, 0) * CFrame.Angles(0, 0, math.pi / 2) * CFrame.Angles(0, -math.pi / 4, 0)

local function weaponPreview(props: {
	Def: any,
})
	local ref = React.useRef(nil)

	React.useEffect(function()
		if not ref.current then return end

		local trove = Trove.new()

		local model = trove:Clone(props.Def.Model)
		model:PivotTo(WeaponRotation)
		model.Parent = ref.current

		local camera = trove:Construct(Instance, "Camera")
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = CFrame.new(0, 0, 4)
		camera.Parent = ref.current
		ref.current.CurrentCamera = camera

		return function()
			trove:Clean()
		end
	end, {})

	return React.createElement("ViewportFrame", {
		Size = UDim2.fromScale(0.85, 0.85),
		Position = UDim2.fromScale(0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		ref = ref,
	}, {})
end

return function(props: {
	Visible: boolean,
})
	return React.createElement(SquishWindow, {
		Visible = props.Visible,
		Position = UDim2.fromScale(0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		Size = UDim2.fromScale(1, 1),
		HeaderText = TextStroke("Weapons", 2),

		RenderContainer = function()
			return React.createElement("UISizeConstraint", {
				MaxSize = Vector2.new(500, 300),
			})
		end,
	}, {
		Layout = React.createElement("UIGridLayout", {
			CellSize = UDim2.fromScale(0.25, 1),
			CellPadding = UDim2.new(),
		}, {
			Constraint = React.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
			}),
		}),

		Buttons = React.createElement(
			React.Fragment,
			nil,
			Sift.Dictionary.map(WeaponDefs, function(def)
				return React.createElement(LayoutContainer, {
					Padding = 8,
				}, {
					Button = React.createElement(Button, {}, {
						Text = React.createElement(Label, {
							Position = UDim2.fromScale(0.5, 1),
							AnchorPoint = Vector2.new(0.5, 1),
							Size = UDim2.fromScale(1, 0.15),
							Text = TextStroke(def.Name, 2),
						}),

						Preview = React.createElement(weaponPreview, {
							Def = def,
						}),
					}),
				}),
					def.Id
			end)
		),
	})
end
