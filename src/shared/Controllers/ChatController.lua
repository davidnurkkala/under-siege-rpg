local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TextChatService = game:GetService("TextChatService")

local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local ProductHelper = require(ReplicatedStorage.Shared.Util.ProductHelper)
local TextColor = require(ReplicatedStorage.Shared.React.Util.TextColor)

local ChatController = {
	Priority = 0,
}

type ChatController = typeof(ChatController)

function ChatController.PrepareBlocking(_self: ChatController)
	TextChatService.OnIncomingMessage = function(message)
		local properties = Instance.new("TextChatMessageProperties")

		if message.TextSource then
			local player = Players:GetPlayerByUserId(message.TextSource.UserId)
			if player and ProductHelper.IsVip(player) then properties.PrefixText = TextColor("[VIP] ", ColorDefs.LightYellow) .. message.PrefixText end
		end

		return properties
	end
end

return ChatController
