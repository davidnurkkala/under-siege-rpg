local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local GenericShopService = {
	Priority = 0,
}

type GenericShopService = typeof(GenericShopService)

function GenericShopService.PrepareBlocking(self: GenericShopService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "GenericShopService")
	self.ShopOpened = self.Comm:CreateSignal("ShopOpened")
end

function GenericShopService.OpenShop(self: GenericShopService, player: Player, shopId: string)
	self.ShopOpened:Fire(player, shopId)
end

return GenericShopService
