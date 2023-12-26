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
local PetDefs = require(ReplicatedStorage.Shared.Defs.PetDefs)
local PetHelper = require(ReplicatedStorage.Shared.Util.PetHelper)
local PetPreview = require(ReplicatedStorage.Shared.React.PetGacha.PetPreview)
local React = require(ReplicatedStorage.Packages.React)
local ScrollingFrame = require(ReplicatedStorage.Shared.React.Common.ScrollingFrame)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SystemWindow = require(ReplicatedStorage.Shared.React.Common.SystemWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

local function petButton(props: {
	Select: () -> (),
	Hash: string,
	Count: number?,
})
	local petId, tier = PetHelper.HashToInfo(props.Hash)
	local power = PetHelper.GetPetPower(petId, tier)
	local def = PetDefs[petId]
	local count = props.Count or 1

	return React.createElement(Button, {
		ImageColor3 = ColorDefs.PaleYellow,
		[React.Event.Activated] = props.Select,
	}, {
		Name = React.createElement(Label, {
			Size = UDim2.fromScale(1, 0.7),
			Text = TextStroke(`{def.Name}{if tier > 1 then `\nLv. {tier}` else `\n `}{if count > 1 then `\nx{count}` else `\n `}`),
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
				Text = TextStroke(`{power // 0.1 / 10}`),
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
			PetId = petId,
		}),
	})
end

return function(props: {
	Visible: boolean,
	Close: () -> (),
	Equip: (string) -> any,
	Unequip: (string) -> any,
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
		Ratio = 6 / 5,
	}, {
		Stats = React.createElement(Container, {
			Size = UDim2.new(1, 0, 0.275, -4),
			Position = UDim2.fromScale(0, 1),
			AnchorPoint = Vector2.new(0, 1),
		}, {
			Layout = React.createElement(ListLayout, {
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0.025, 0),
			}),

			Pets = React.createElement(
				React.Fragment,
				nil,
				Sift.Array.map(
					Sift.Array.concat(unpack(Sift.Dictionary.values(Sift.Dictionary.map(props.Pets.Equipped, function(count, hash)
						return Sift.Array.create(count, hash)
					end)))),
					function(hash, index)
						return React.createElement(LayoutContainer, {
							Padding = 0,
							LayoutOrder = -index,
							Size = UDim2.fromScale(1, 1),
							SizeConstraint = Enum.SizeConstraint.RelativeYY,
						}, {
							Button = React.createElement(petButton, {
								Select = function()
									props.Unequip(hash)
								end,
								Hash = hash,
							}),
						}),
							`Pet{index}`
					end
				)
			),

			Right = React.createElement(Container, {
				LayoutOrder = 3,
				Size = UDim2.fromScale(1.5, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
			}, {
				Top = React.createElement(Container, {
					Size = UDim2.fromScale(1, 0.5),
				}, {
					Layout = React.createElement(ListLayout, {
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
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
						Size = UDim2.fromScale(1.5, 1),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Text = TextStroke(`x{PetHelper.GetTotalPower(props.Pets) // 0.1 / 10}`),
						TextXAlignment = Enum.TextXAlignment.Right,
					}),
				}),

				Button = React.createElement(Button, {
					Size = UDim2.fromScale(1, 0.5),
					Position = UDim2.fromScale(0, 0.5),
					ImageColor3 = ColorDefs.PalePurple,
					[React.Event.Activated] = props.EquipBest,
					SelectionOrder = -1,
				}, {
					Text = React.createElement(Label, {
						Text = TextStroke("Equip Best"),
					}),
				}),
			}),
		}),

		Pets = React.createElement(ScrollingFrame, {
			Size = UDim2.fromScale(1, 0.725),
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
				Sift.Array.map(Sift.Array.sort(Sift.Dictionary.keys(props.Pets.Owned), PetHelper.SortByPower), function(hash, index)
					local count = props.Pets.Owned[hash] - (props.Pets.Equipped[hash] or 0)
					if count == 0 then return end

					return React.createElement(LayoutContainer, {
						Padding = 8,
						LayoutOrder = index,
					}, {
						Button = React.createElement(petButton, {
							Select = function()
								props.Equip(hash)
							end,
							Hash = hash,
							Count = count,
						}),
					}),
						hash
				end)
			),
		}),
	})
end
