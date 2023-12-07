local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Aspect = require(ReplicatedStorage.Shared.React.Common.Aspect)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local GridLayout = require(ReplicatedStorage.Shared.React.Common.GridLayout)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local PetDefs = require(ReplicatedStorage.Shared.Defs.PetDefs)
local PetPreview = require(ReplicatedStorage.Shared.React.PetGacha.PetPreview)
local PromptWindow = require(ReplicatedStorage.Shared.React.Common.PromptWindow)
local React = require(ReplicatedStorage.Packages.React)
local ScrollingFrame = require(ReplicatedStorage.Shared.React.Common.ScrollingFrame)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SystemWindow = require(ReplicatedStorage.Shared.React.Common.SystemWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

return function(props: {
	Visible: boolean,
	Close: () -> (),
	Select: (string, number, number) -> any,
	Pets: any,
})
	local promptedEntry, setPromptedEntry = React.useState(nil)
	local awaiting, setAwaiting = React.useState(false)

	return React.createElement(React.Fragment, nil, {
		Prompt = promptedEntry and React.createElement(PromptWindow, {
			TextSize = 0.4,
			HeaderText = TextStroke("Confirm Merge"),
			Text = TextStroke(`Merge how many tier {promptedEntry.Tier} {PetDefs[promptedEntry.PetId].Name} pets?`),
			[React.Event.Activated] = function()
				setPromptedEntry(nil)
			end,
			Options = {
				{
					Text = TextStroke("2\n50% chance"),
					Select = function()
						setAwaiting(true)
						props.Select(promptedEntry.PetId, promptedEntry.Tier, 2):andThen(function()
							setAwaiting(false)
						end)
						setPromptedEntry(nil)
					end,
					Props = {
						ImageColor3 = ColorDefs.PaleGreen,
					},
				},
				{
					Text = TextStroke("3\n75% chance"),
					Select = function()
						setAwaiting(true)
						props.Select(promptedEntry.PetId, promptedEntry.Tier, 3):andThen(function()
							setAwaiting(false)
						end)
						setPromptedEntry(nil)
					end,
					Props = {
						ImageColor3 = if promptedEntry.Count >= 3 then ColorDefs.PaleGreen else nil,
						Active = promptedEntry.Count >= 3,
					},
				},
				{
					Text = TextStroke("4\n100% chance"),
					Select = function()
						setAwaiting(true)
						props.Select(promptedEntry.PetId, promptedEntry.Tier, 4):andThen(function()
							setAwaiting(false)
						end)
						setPromptedEntry(nil)
					end,
					Props = {
						ImageColor3 = if promptedEntry.Count >= 4 then ColorDefs.PaleGreen else nil,
						Active = promptedEntry.Count >= 4,
					},
				},
			},
		}),

		Menu = React.createElement(SystemWindow, {
			Visible = props.Visible and (promptedEntry == nil) and (awaiting == false),
			HeaderText = TextStroke("Merge Pets"),
			[React.Event.Activated] = props.Close,
		}, {
			Content = React.createElement(ScrollingFrame, {
				RenderLayout = function(setCanvasSize)
					return React.createElement(GridLayout, {
						CellSize = UDim2.fromScale(1 / 5, 1),
						[React.Change.AbsoluteContentSize] = function(object)
							setCanvasSize(UDim2.fromOffset(0, object.AbsoluteContentSize.Y))
						end,
					}, {
						Aspect = React.createElement(Aspect, {
							AspectRatio = 1,
						}),
					})
				end,
			}, {
				Buttons = React.createElement(
					React.Fragment,
					nil,
					Sift.Dictionary.map(
						Sift.Array.sort(
							Sift.Dictionary.values(Sift.Dictionary.map(
								Sift.Array.toSet(Sift.Array.map(Sift.Dictionary.values(props.Pets.Owned), function(slot)
									return `{slot.PetId} {slot.Tier}`
								end)),
								function(_, hash)
									local petId, tier = unpack(string.split(hash, " "))
									tier = tonumber(tier)

									local count = Sift.Dictionary.count(props.Pets.Owned, function(slot)
										return (slot.PetId == petId) and (slot.Tier == tier)
									end)

									return { PetId = petId, Tier = tier, Count = count }
								end
							)),
							function(a, b)
								if a.PetId == b.PetId then
									return a.Tier > b.Tier
								else
									return a.PetId < b.PetId
								end
							end
						),
						function(entry, index)
							local def = PetDefs[entry.PetId]
							local canMerge = entry.Count >= 2

							return React.createElement(LayoutContainer, {
								LayoutOrder = index,
								Padding = 6,
							}, {
								Button = React.createElement(Button, {
									Active = canMerge,
									ImageColor3 = if canMerge then ColorDefs.PaleGreen else ColorDefs.PaleBlue,
									[React.Event.Activated] = function()
										setPromptedEntry(entry)
									end,
								}, {
									Preview = React.createElement(PetPreview, {
										PetId = entry.PetId,
									}),

									Count = React.createElement(Label, {
										Text = TextStroke(`x{entry.Count}`),
										TextXAlignment = Enum.TextXAlignment.Right,
										TextYAlignment = Enum.TextYAlignment.Bottom,
										Size = UDim2.fromScale(0.4, 0.4),
										Position = UDim2.fromScale(1, 1),
										AnchorPoint = Vector2.new(1, 1),
										ZIndex = 4,
									}),

									Name = React.createElement(Label, {
										Text = TextStroke(`{def.Name} T{entry.Tier}`),
										TextXAlignment = Enum.TextXAlignment.Left,
										Size = UDim2.fromScale(1, 0.25),
										ZIndex = 4,
									}),
								}),
							}),
								`{entry.PetId}Tier{entry.Tier}`
						end
					)
				),
			}),
		}),
	})
end
