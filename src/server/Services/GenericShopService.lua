local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local RewardHelper = require(ServerScriptService.Server.Util.RewardHelper)
local ShopDefs = require(ReplicatedStorage.Shared.Defs.ShopDefs)
local t = require(ReplicatedStorage.Packages.t)
local GenericShopService = {
	Priority = 0,
}

type GenericShopService = typeof(GenericShopService)

function GenericShopService.PrepareBlocking(self: GenericShopService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "GenericShopService")
	self.ShopOpened = self.Comm:CreateSignal("ShopOpened")

	self.Comm:BindFunction("BuyProduct", function(player, shopId, productIndex)
		if not t.string(shopId) then return end
		if not t.integer(productIndex) then return end
		if not t.numberPositive(productIndex) then return end

		local def = ShopDefs[shopId]
		if not def then return end

		local product = def.Products[productIndex]
		if not product then return end

		return CurrencyService:ApplyPrice(player, product.Price)
			:andThen(function(success)
				if not success then return false end

				return RewardHelper.GiveReward(player, product.Reward):andThenReturn(true)
			end)
			:expect()
	end)
end

function GenericShopService.OpenShop(self: GenericShopService, player: Player, shopId: string)
	self.ShopOpened:Fire(player, shopId)
end

return GenericShopService
