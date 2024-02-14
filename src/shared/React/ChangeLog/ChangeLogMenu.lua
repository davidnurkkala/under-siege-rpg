local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChangeLog = require(ReplicatedStorage.Shared.ChangeLog)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SystemWindow = require(ReplicatedStorage.Shared.React.Common.SystemWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

function changeLog()
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

	return React.createElement("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 10,
		Size = UDim2.fromScale(1, 1),
		VerticalScrollBarInset = Enum.ScrollBarInset.Always,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		Selectable = true,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 20),
		}),

		Padding = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 4),
		}),

		Lines = React.createElement(
			React.Fragment,
			nil,
			Sift.Array.map(lines, function(line, index)
				return React.createElement("TextLabel", {
					BackgroundTransparency = 1,
					TextSize = 24,
					Text = TextStroke(line.content),
					RichText = true,
					Font = Enum.Font.FredokaOne,
					LineHeight = 1.1,
					TextColor3 = ColorDefs.White,
					Size = UDim2.fromScale(1 - (0.025 * line.depth), 0),
					LayoutOrder = index,
					AutomaticSize = Enum.AutomaticSize.Y,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = true,
				})
			end)
		),
	})
end

return function()
	local menu = React.useContext(MenuContext)

	return React.createElement(SystemWindow, {
		Visible = menu.Is("ChangeLog"),
		[React.Event.Activated] = function()
			menu.Unset("ChangeLog")
		end,
		HeaderText = TextStroke("Update Log"),
	}, {
		Content = React.createElement(changeLog),
	})
end
