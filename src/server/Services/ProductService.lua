local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ProductDefs = require(ReplicatedStorage.Shared.Defs.ProductDefs)
local Promise = require(ReplicatedStorage.Packages.Promise)
local t = require(ReplicatedStorage.Packages.t)

local ProductService = {
	Priority = 0,
}

type ProductService = typeof(ProductService)

function ProductService.PrepareBlocking(self: ProductService)
	self.Comm = Comm.ServerComm.new(ReplicatedStorage, "ProductService")

	self.Comm:BindFunction("PurchaseProduct", function(player: Player, id)
		if not t.string(id) then return end

		local def = ProductDefs[id]
		if not def then return end

		if def.Type == "GamePass" then
			MarketplaceService:PromptGamePassPurchase(player, def.AssetId)

			return Promise.fromEvent(MarketplaceService.PromptGamePassPurchaseFinished):expect()
		else
			error(`Unimplemented product type {def.Type}`)
		end
	end)

	self.Comm:BindFunction("PurchasePremium", function(player: Player)
		MarketplaceService:PromptPremiumPurchase(player)

		return Promise.fromEvent(MarketplaceService.PromptPremiumPurchaseFinished):expect()
	end)

	self.Comm:BindFunction("GetOwnsProduct", function(player: Player, id)
		if not t.string(id) then return end

		return self:GetOwnsProduct(player, id):expect()
	end)

	-- tag VIP players as VIP
	Observers.observePlayer(function(player)
		local promise = Promise.try(function()
			return MarketplaceService:UserOwnsGamePassAsync(player.UserId, ProductDefs.Vip.AssetId)
		end):andThen(function(isVip)
			if not isVip then return end

			player:SetAttribute("IsVip", true)
		end)

		return function()
			promise:cancel()
		end
	end)
end

function ProductService.GetVipBoostedSecondary(self: ProductService, player: Player, amount: number)
	if self:IsVip(player) then
		return math.ceil(amount * 1.1)
	else
		return amount
	end
end

function ProductService.GetOwnsProduct(self: ProductService, player: Player, productId: string)
	local def = ProductDefs[productId]
	assert(def, `No product for id {productId}`)

	return Promise.new(function(resolve)
		if def.FreeForPremium and player.MembershipType == Enum.MembershipType.Premium then
			resolve(true)
			return
		end

		if def.Type == "GamePass" then
			resolve(MarketplaceService:UserOwnsGamePassAsync(player.UserId, def.AssetId))
		else
			error(`Unimplemented product type {def.Type}`)
		end
	end)
end

function ProductService.IsVip(_self: ProductService, player: Player)
	if RunService:IsStudio() then return false end

	return player:GetAttribute("IsVip")
end

return ProductService
