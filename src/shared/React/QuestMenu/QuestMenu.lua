local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MenuContext = require(ReplicatedStorage.Shared.React.MenuContext.MenuContext)
local React = require(ReplicatedStorage.Packages.React)
local SystemWindow = require(ReplicatedStorage.Shared.React.Common.SystemWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

return function()
	local menu = React.useContext(MenuContext)

	return React.createElement(SystemWindow, {
		Visible = menu.Is("Journal"),
		HeaderText = TextStroke("Quests"),
		[React.Event.Activated] = function()
			menu.Unset("Journal")
		end,
	})
end
