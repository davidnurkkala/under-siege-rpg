local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)

local ProductController = {
	Priority = 0,
}

type ProductController = typeof(ProductController)

function ProductController.PrepareBlocking(self: ProductController)
	self.Comm = Comm.ClientComm.new(ReplicatedStorage, true, "ProductService")
	self.GetOwnsProduct = self.Comm:GetFunction("GetOwnsProduct")
	self.PurchaseProduct = self.Comm:GetFunction("PurchaseProduct")
end

return ProductController
