local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local GridLayout = require(ReplicatedStorage.Shared.React.Common.GridLayout)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
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
		camera.CFrame = CFrame.new(0, 0, 6)
		camera.FieldOfView = 30
		camera.Parent = ref.current
		ref.current.CurrentCamera = camera

		return function()
			trove:Clean()
		end
	end, {})

	return React.createElement("ViewportFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ref = ref,
	}, {})
end

return function(props: {
	Visible: boolean,
	Weapons: any,
	Select: (string) -> (),
})
	return React.createElement(SquishWindow, {
		Visible = props.Visible,
		Position = UDim2.fromScale(0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		Size = UDim2.fromScale(1, 1),
		HeaderText = TextStroke("Weapons", 2),
		BackgroundColor3 = Color3.fromHex("#BD7975"),
		ImageColor3 = Color3.fromHex("#BD9F75"),

		RenderContainer = function()
			return React.createElement("UISizeConstraint", {
				MaxSize = Vector2.new(500, 300),
			})
		end,
	}, {
		Layout = React.createElement(GridLayout, {
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
			Sift.Dictionary.map(
				Sift.Array.sort(Sift.Dictionary.keys(WeaponDefs), function(idA, idB)
					local a, b = WeaponDefs[idA], WeaponDefs[idB]
					return a.Power < b.Power
				end),
				function(id, index)
					local def = WeaponDefs[id]

					local isOwned = props.Weapons.Owned[id] ~= nil
					local isEquipped = props.Weapons.Equipped == id

					return React.createElement(LayoutContainer, {
						Padding = 8,
						LayoutOrder = index,
					}, {
						Button = React.createElement(Button, {
							ImageColor3 = Color3.fromHex("#BD4549"),
							BorderColor3 = if isEquipped then Color3.fromHex("#BD5946") else nil,
							[React.Event.Activated] = function()
								props.Select(id)
							end,
						}, {
							Name = React.createElement(Label, {
								Position = UDim2.fromScale(0, 0),
								AnchorPoint = Vector2.new(0, 0),
								Size = UDim2.fromScale(1, 0.15),
								Text = TextStroke(def.Name, 2),
								TextXAlignment = Enum.TextXAlignment.Left,
								ZIndex = 4,
							}),

							Power = React.createElement(Label, {
								Position = UDim2.fromScale(0, 0.2),
								Size = UDim2.fromScale(1, 0.15),
								Text = TextStroke(`+{def.Power}`, 2),
								TextColor3 = BrickColor.new("Light red").Color,
								TextXAlignment = Enum.TextXAlignment.Left,
								ZIndex = 4,
							}),

							Price = (not isOwned) and React.createElement(React.Fragment, nil, {
								CurrencyIcon = React.createElement(Image, {
									Size = UDim2.fromScale(0.15, 0.15),
									Position = UDim2.fromScale(0, 1),
									AnchorPoint = Vector2.new(0, 1),
									Image = CurrencyDefs.Primary.Image,
									ZIndex = 4,
								}),

								Price = React.createElement(Label, {
									Size = UDim2.fromScale(0.8, 0.15),
									Position = UDim2.fromScale(0.2, 1),
									AnchorPoint = Vector2.new(0, 1),
									Text = TextStroke(def.Requirements.Currency.Primary, 2),
									TextXAlignment = Enum.TextXAlignment.Left,
									ZIndex = 4,
								}),
							}),

							Equip = isOwned and React.createElement(React.Fragment, nil, {
								Label = React.createElement(Label, {
									Size = UDim2.fromScale(1, 0.15),
									Position = UDim2.fromScale(0, 1),
									AnchorPoint = Vector2.new(0, 1),
									TextXAlignment = Enum.TextXAlignment.Left,
									Text = if isEquipped then TextStroke("EQUIPPED", 2) else TextStroke("Equip", 2),
								}),
							}),

							Preview = React.createElement(weaponPreview, {
								Def = def,
							}),
						}),
					}),
						def.Id
				end
			)
		),
	})
end
