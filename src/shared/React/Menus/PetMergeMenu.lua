local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Aspect = require(ReplicatedStorage.Shared.React.Common.Aspect)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local GridLayout = require(ReplicatedStorage.Shared.React.Common.GridLayout)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local PetDefs = require(ReplicatedStorage.Shared.Defs.PetDefs)
local PetHelper = require(ReplicatedStorage.Shared.Util.PetHelper)
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
	Select: (string, number) -> any,
	Pets: any,
})
	local promptedEntry, setPromptedEntry = React.useState(nil)
	local promptedHash = (promptedEntry ~= nil) and PetHelper.InfoToHash(promptedEntry.PetId, promptedEntry.Tier)

	local awaiting, setAwaiting = React.useState(false)

	return React.createElement(React.Fragment, nil, {
		Prompt = promptedEntry and React.createElement(PromptWindow, {
			TextSize = 0.4,
			HeaderText = TextStroke("Confirm Merge"),
			Text = TextStroke(`Merge how many level {promptedEntry.Tier} {PetDefs[promptedEntry.PetId].Name} pets?`),
			[React.Event.Activated] = function()
				GuiService.SelectedObject = nil
				setPromptedEntry(nil)
			end,
			Options = {
				{
					Text = TextStroke("2\n50% chance"),
					Select = function()
						setAwaiting(true)
						props.Select(promptedHash, 2):andThen(function()
							setAwaiting(false)
						end)
						setPromptedEntry(nil)
					end,
					Props = {
						ImageColor3 = ColorDefs.PaleGreen,
						SelectionOrder = -1,
					},
				},
				{
					Text = TextStroke("3\n75% chance"),
					Select = function()
						setAwaiting(true)
						props.Select(promptedHash, 3):andThen(function()
							setAwaiting(false)
						end)
						setPromptedEntry(nil)
					end,
					Props = {
						ImageColor3 = if promptedEntry.Count >= 3 then ColorDefs.PaleGreen else nil,
						Active = promptedEntry.Count >= 3,
						SelectionOrder = -1,
					},
				},
				{
					Text = TextStroke("4\n100% chance"),
					Select = function()
						setAwaiting(true)
						props.Select(promptedHash, 4):andThen(function()
							setAwaiting(false)
						end)
						setPromptedEntry(nil)
					end,
					Props = {
						ImageColor3 = if promptedEntry.Count >= 4 then ColorDefs.PaleGreen else nil,
						Active = promptedEntry.Count >= 4,
						SelectionOrder = -1,
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
					Sift.Dictionary.map(Sift.Array.sort(Sift.Dictionary.keys(props.Pets.Owned), PetHelper.SortByPower), function(hash, index)
						local count = props.Pets.Owned[hash]
						local petId, tier = PetHelper.HashToInfo(hash)
						local def = PetDefs[petId]
						local canMerge = count >= 2

						return React.createElement(LayoutContainer, {
							LayoutOrder = index,
							Padding = 6,
						}, {
							Button = React.createElement(Button, {
								Active = canMerge,
								ImageColor3 = if canMerge then ColorDefs.PaleGreen else ColorDefs.PaleBlue,
								[React.Event.Activated] = function()
									setPromptedEntry({ PetId = petId, Tier = tier, Count = count })
								end,
								SelectionOrder = canMerge and -1 or 1,
							}, {
								Preview = React.createElement(PetPreview, {
									PetId = petId,
								}),

								Count = React.createElement(Label, {
									Text = TextStroke(`x{count}`),
									TextXAlignment = Enum.TextXAlignment.Right,
									TextYAlignment = Enum.TextYAlignment.Bottom,
									Size = UDim2.fromScale(0.4, 0.4),
									Position = UDim2.fromScale(1, 1),
									AnchorPoint = Vector2.new(1, 1),
									ZIndex = 4,
								}),

								Name = React.createElement(Label, {
									Text = TextStroke(`{def.Name} Lv. {tier}`),
									TextXAlignment = Enum.TextXAlignment.Left,
									Size = UDim2.fromScale(1, 0.25),
									ZIndex = 4,
								}),
							}),
						}),
							`{petId}Tier{tier}`
					end)
				),
			}),
		}),
	})
end
