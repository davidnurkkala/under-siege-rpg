local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Aspect = require(ReplicatedStorage.Shared.React.Common.Aspect)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local GridLayout = require(ReplicatedStorage.Shared.React.Common.GridLayout)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local PetDefs = require(ReplicatedStorage.Shared.Defs.PetDefs)
local PetHelper = require(ReplicatedStorage.Shared.Util.PetHelper)
local PetPreview = require(ReplicatedStorage.Shared.React.PetGacha.PetPreview)
local React = require(ReplicatedStorage.Packages.React)
local ScrollingFrame = require(ReplicatedStorage.Shared.React.Common.ScrollingFrame)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SystemWindow = require(ReplicatedStorage.Shared.React.Common.SystemWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

return function(props: {
	Visible: boolean,
	Close: () -> (),
	Select: (string) -> any,
	EquipBest: () -> any,
	Pets: {
		Owned: { [string]: any },
		Equipped: { [string]: boolean },
	},
})
	return React.createElement(SystemWindow, {
		Visible = props.Visible,
		HeaderText = TextStroke("Pets"),
		[React.Event.Activated] = props.Close,
		Ratio = 4 / 3,
	}, {
		Stats = React.createElement(Panel, {
			Size = UDim2.new(1, 0, 0.2, -4),
			Position = UDim2.fromScale(0, 1),
			AnchorPoint = Vector2.new(0, 1),
			Padding = UDim.new(0, 8),
			ImageColor3 = ColorDefs.PaleRed,
		}, {
			Layout = React.createElement(ListLayout, {
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0.025, 0),
			}),

			Icon = React.createElement(Image, {
				LayoutOrder = 2,
				Size = UDim2.fromScale(0.8, 0.8),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Image = CurrencyDefs.Primary.Image,
			}),

			Total = React.createElement(Label, {
				LayoutOrder = 1,
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				Text = TextStroke(`Bonus\nx{PetHelper.GetTotalPower(props.Pets) // 0.1 / 10}`),
				TextXAlignment = Enum.TextXAlignment.Right,
			}),

			Button = React.createElement(Button, {
				LayoutOrder = 3,
				Size = UDim2.fromScale(2, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				ImageColor3 = ColorDefs.PalePurple,
				[React.Event.Activated] = props.EquipBest,
			}, {
				Text = React.createElement(Label, {
					Text = TextStroke("Equip Best"),
				}),
			}),
		}),

		Pets = React.createElement(ScrollingFrame, {
			Size = UDim2.fromScale(1, 0.8),
			RenderLayout = function(setCanvasSize)
				return React.createElement(GridLayout, {
					CellSize = UDim2.fromScale(1 / 5, 1),
					[React.Change.AbsoluteContentSize] = function(object)
						setCanvasSize(UDim2.fromOffset(0, object.AbsoluteContentSize.Y))
					end,
				}, {
					Ratio = React.createElement(Aspect, {
						AspectRatio = 1,
					}),
				})
			end,
		}, {
			Buttons = React.createElement(
				React.Fragment,
				nil,
				Sift.Array.map(
					Sift.Array.sort(Sift.Dictionary.keys(props.Pets.Owned), function(slotIdA, slotIdB)
						local slotA = props.Pets.Owned[slotIdA]
						local petA = PetDefs[slotA.PetId]
						local equippedA = props.Pets.Equipped[slotIdA] == true

						local slotB = props.Pets.Owned[slotIdB]
						local petB = PetDefs[slotB.PetId]
						local equippedB = props.Pets.Equipped[slotIdB] == true

						if equippedA then
							if not equippedB then return true end
						else
							if equippedB then return false end
						end

						if petA.Name == petB.Name then
							return slotA.Tier < slotB.Tier
						else
							return petA.Name < petB.Name
						end
					end),
					function(slotId, index)
						local petSlot = props.Pets.Owned[slotId]
						local petDef = PetDefs[petSlot.PetId]
						local isEquipped = props.Pets.Equipped[slotId] == true
						local power = PetHelper.GetPetPower(petSlot.PetId, petSlot.Tier)

						return React.createElement(LayoutContainer, {
							Padding = 8,
							LayoutOrder = index,
						}, {
							Button = React.createElement(Button, {
								ImageColor3 = ColorDefs.PaleYellow,
								[React.Event.Activated] = function()
									props.Select(slotId)
								end,
							}, {
								Name = React.createElement(Label, {
									Size = UDim2.fromScale(1, 0.25),
									Text = TextStroke(`{petDef.Name}{if petSlot.Tier > 1 then ` T{petSlot.Tier}` else ``}`),
									TextXAlignment = Enum.TextXAlignment.Left,
									ZIndex = 4,
								}),

								Power = React.createElement(Container, {
									Size = UDim2.fromScale(1, 0.25),
									AnchorPoint = Vector2.new(0, 1),
									Position = UDim2.fromScale(0, 1),
								}, {
									Layout = React.createElement(ListLayout, {
										HorizontalAlignment = Enum.HorizontalAlignment.Center,
										FillDirection = Enum.FillDirection.Horizontal,
										Padding = UDim.new(0, 2),
									}),

									Text = React.createElement(Label, {
										LayoutOrder = 1,
										Size = UDim2.fromScale(0.5, 1),
										Text = TextStroke(`x{power // 0.1 / 10}`),
										TextXAlignment = Enum.TextXAlignment.Right,
									}),

									Icon = React.createElement(Image, {
										LayoutOrder = 2,
										Size = UDim2.fromScale(1, 1),
										SizeConstraint = Enum.SizeConstraint.RelativeYY,
										Image = CurrencyDefs.Primary.Image,
									}),
								}),

								Preview = React.createElement(PetPreview, {
									PetId = petSlot.PetId,
								}),

								Equipped = isEquipped and React.createElement(Image, {
									Size = UDim2.fromScale(0.2, 0.2),
									Position = UDim2.fromScale(1, 0),
									AnchorPoint = Vector2.new(1, 0),
									Image = "rbxassetid://15360109124",
									ImageColor3 = ColorDefs.LightGreen,
								}),
							}),
						})
					end
				)
			),
		}),
	})
end
