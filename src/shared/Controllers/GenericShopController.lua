local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local GenericShopController = {
	Priority = 0,
}

type GenericShopController = typeof(GenericShopController)

function GenericShopController.PrepareBlocking(self: GenericShopController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "GenericShopService")
	self.ShopOpened = self.Comm:GetSignal("ShopOpened")
	self.BuyProduct = self.Comm:GetFunction("BuyProduct")
end

return GenericShopController
