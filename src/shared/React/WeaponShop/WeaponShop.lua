local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Aspect = require(ReplicatedStorage.Shared.React.Common.Aspect)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local FormatBigNumber = require(ReplicatedStorage.Shared.Util.FormatBigNumber)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local React = require(ReplicatedStorage.Packages.React)
local ScrollingFrame = require(ReplicatedStorage.Shared.React.Common.ScrollingFrame)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SystemWindow = require(ReplicatedStorage.Shared.React.Common.SystemWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local Trove = require(ReplicatedStorage.Packages.Trove)
local WeaponDefs = require(ReplicatedStorage.Shared.Defs.WeaponDefs)
local WeaponShopDefs = require(ReplicatedStorage.Shared.Defs.WeaponShopDefs)

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
	ShopId: string,
	Weapons: any,
	Select: (string) -> (),
	Close: () -> (),
})
	return React.createElement(SystemWindow, {
		Visible = props.Visible,
		HeaderText = TextStroke("Weapons", 2),
		[React.Event.Activated] = props.Close,
	}, {
		ScrollingFrame = React.createElement(ScrollingFrame, {
			RenderLayout = function(setCanvasSize)
				return React.createElement(ListLayout, {
					[React.Change.AbsoluteContentSize] = function(object)
						setCanvasSize(UDim2.fromOffset(0, object.AbsoluteContentSize.Y))
					end,
				})
			end,
		}, {
			Panels = React.createElement(
				React.Fragment,
				nil,
				Sift.Dictionary.map(
					Sift.Array.sort(WeaponShopDefs[props.ShopId], function(idA, idB)
						local a, b = WeaponDefs[idA], WeaponDefs[idB]
						return a.Power < b.Power
					end),
					function(id, index)
						local def = WeaponDefs[id]

						local isOwned = props.Weapons.Owned[id] ~= nil
						local isEquipped = props.Weapons.Equipped == id

						return React.createElement(LayoutContainer, {
							Size = UDim2.fromScale(1, 0),
							Padding = 8,
							LayoutOrder = index,
						}, {
							Aspect = React.createElement(Aspect, {
								AspectRatio = 5,
							}),

							Panel = React.createElement(Panel, {
								ImageColor3 = ColorDefs.PaleRed,
							}, {
								PreviewContainer = React.createElement(Container, {
									Size = UDim2.fromScale(1, 1),
									SizeConstraint = Enum.SizeConstraint.RelativeYY,
								}, {
									Preview = React.createElement(weaponPreview, {
										Def = def,
									}),
								}),

								Name = React.createElement(Label, {
									Position = UDim2.fromScale(0.2, 0),
									Size = UDim2.fromScale(0.5, 0.5),
									Text = TextStroke(def.Name, 2),
									TextXAlignment = Enum.TextXAlignment.Left,
									ZIndex = 4,
								}),

								Power = React.createElement(Label, {
									Position = UDim2.fromScale(0.2, 0.5),
									Size = UDim2.fromScale(0.5, 0.5),
									Text = TextStroke(`+{def.Power}`, 2),
									TextXAlignment = Enum.TextXAlignment.Left,
									ZIndex = 4,
								}),

								Button = React.createElement(Button, {
									Size = UDim2.fromScale(0.25, 1),
									AnchorPoint = Vector2.new(1, 0),
									Position = UDim2.fromScale(1, 0),
									ImageColor3 = ColorDefs.DarkRed,
									BorderColor3 = if isEquipped then ColorDefs.Red else nil,
									BorderSizePixel = 2,
									[React.Event.Activated] = function()
										props.Select(id)
									end,
								}, {
									Price = (not isOwned) and React.createElement(React.Fragment, nil, {
										Layout = React.createElement(ListLayout, {
											FillDirection = Enum.FillDirection.Horizontal,
											HorizontalAlignment = Enum.HorizontalAlignment.Center,
											VerticalAlignment = Enum.VerticalAlignment.Center,
											Padding = UDim.new(0.05, 0),
										}),

										CurrencyIcon = React.createElement(Image, {
											LayoutOrder = 1,
											Size = UDim2.fromScale(0.4, 0.4),
											SizeConstraint = Enum.SizeConstraint.RelativeYY,
											Image = CurrencyDefs.Primary.Image,
											ZIndex = 4,
										}),

										Price = React.createElement(Label, {
											LayoutOrder = 2,
											Size = UDim2.fromScale(0.45, 0.5),
											Text = TextStroke(FormatBigNumber(def.Price), 2),
											TextXAlignment = Enum.TextXAlignment.Left,
											ZIndex = 4,
										}),
									}),

									Equip = isOwned and React.createElement(React.Fragment, nil, {
										Label = React.createElement(Label, {
											Size = UDim2.fromScale(1, 0.5),
											Position = UDim2.fromScale(0.5, 0.5),
											AnchorPoint = Vector2.new(0.5, 0.5),
											Text = if isEquipped then TextStroke("EQUIPPED", 2) else TextStroke("Equip", 2),
										}),
									}),
								}),
							}),
						}),
							def.Id
					end
				)
			),
		}),
	})
end
