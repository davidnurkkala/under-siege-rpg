local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChangeLog = require(ReplicatedStorage.Shared.ChangeLog)
local Promise = require(ReplicatedStorage.Packages.Promise)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)

return function()
	local lines = {}
	local function process(list, depth)
		depth = depth or 0
		for _, entry in list do
			if typeof(entry) == "table" then
				process(entry, depth + 1)
			else
				table.insert(lines, {
					content = entry,
					depth = depth,
				})
			end
		end
	end
	process(ChangeLog)

	local adornee, setAdornee = React.useState(nil)

	React.useEffect(function()
		local promise = Promise.new(function(resolve, _, onCancel)
			local board = nil
			repeat
				board = Sift.Array.first(Sift.Array.filter(CollectionService:GetTagged("ChangeLogBoard"), function(object)
					return object:IsDescendantOf(workspace)
				end))
				if not board then
					task.wait()
					if onCancel() then return end
				end
			until board

			resolve(board)
		end):andThen(setAdornee)

		return function()
			promise:cancel()
		end
	end, {})

	return (adornee ~= nil)
		and React.createElement("SurfaceGui", {
			Adornee = adornee,
			ResetOnSpawn = false,
			PixelsPerStud = 64,
			SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud,
		}, {
			Title = React.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.1),
				TextScaled = true,
				TextColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.GothamBold,
				Text = "Update Log",
				BackgroundTransparency = 1,
			}, {
				Stroke = React.createElement("UIStroke", {
					Thickness = 3,
					Color = Color3.new(0, 0, 0),
				}),
			}),

			Background = React.createElement("ImageLabel", {
				Size = UDim2.fromScale(1, 0.9),
				Position = UDim2.fromScale(0, 0.1),
				BackgroundTransparency = 1,
				Image = "rbxassetid://14663594778",
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(32, 32, 224, 224),
			}, {
				Padding = React.createElement("UIPadding", {
					PaddingTop = UDim.new(0, 32),
					PaddingBottom = UDim.new(0, 32),
					PaddingRight = UDim.new(0, 32),
					PaddingLeft = UDim.new(0, 32),
				}),

				Content = React.createElement("ScrollingFrame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ScrollBarThickness = 20,
					Size = UDim2.fromScale(1, 1),
					VerticalScrollBarInset = Enum.ScrollBarInset.Always,
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					CanvasSize = UDim2.new(),
					Selectable = false,
				}, {
					Layout = React.createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						Padding = UDim.new(0, 20),
					}),

					Lines = React.createElement(
						React.Fragment,
						nil,
						Sift.Array.map(lines, function(line, index)
							return React.createElement("TextLabel", {
								BackgroundTransparency = 1,
								TextSize = 45,
								Text = line.content,
								Font = Enum.Font.Gotham,
								LineHeight = 1.1,
								TextColor3 = Color3.new(1, 1, 1),
								Size = UDim2.fromScale(1 - (0.025 * line.depth), 0),
								LayoutOrder = index,
								AutomaticSize = Enum.AutomaticSize.Y,
								TextXAlignment = Enum.TextXAlignment.Left,
								TextWrapped = true,
							})
						end)
					),
				}),
			}),
		})
end
