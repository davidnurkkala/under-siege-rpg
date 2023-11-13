local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Aspect = require(ReplicatedStorage.Shared.React.Common.Aspect)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local GridLayout = require(ReplicatedStorage.Shared.React.Common.GridLayout)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local PetDefs = require(ReplicatedStorage.Shared.Defs.PetDefs)
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
	Pets: {
		Owned: { [string]: any },
		Equipped: { [string]: boolean },
	},
})
	return React.createElement(SystemWindow, {
		Visible = props.Visible,
		HeaderText = TextStroke("Pets"),
		[React.Event.Activated] = props.Close,
	}, {
		Frame = React.createElement(ScrollingFrame, {
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

						return petA.Name < petB.Name
					end),
					function(slotId, index)
						local petSlot = props.Pets.Owned[slotId]
						local petDef = PetDefs[petSlot.PetId]
						local isEquipped = props.Pets.Equipped[slotId] == true

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
									Size = UDim2.fromScale(1, 0.2),
									Text = TextStroke(petDef.Name),
									ZIndex = 4,
								}),

								Preview = React.createElement(PetPreview, {
									PetId = petSlot.PetId,
								}),

								Equipped = isEquipped and React.createElement(Label, {
									Size = UDim2.fromScale(1, 0.2),
									Text = TextStroke(`<b>Equipped</b>`, 2),
									Position = UDim2.fromScale(0, 1),
									AnchorPoint = Vector2.new(0, 1),
								}),
							}),
						})
					end
				)
			),
		}),
	})
end
