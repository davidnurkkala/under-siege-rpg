local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Comm = require(ReplicatedStorage.Packages.Comm)
local CurrencyService = require(ServerScriptService.Server.Services.CurrencyService)
local DataService = require(ServerScriptService.Server.Services.DataService)
local DictionaryFind = require(ReplicatedStorage.Shared.Util.DictionaryFind)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ProductDefs = require(ReplicatedStorage.Shared.Defs.ProductDefs)
local ProductHelper = require(ReplicatedStorage.Shared.Util.ProductHelper)
local Promise = require(ReplicatedStorage.Packages.Promise)
local RewardHelper = require(ServerScriptService.Server.Util.RewardHelper)
local Sift = require(ReplicatedStorage.Packages.Sift)
local Signal = require(ReplicatedStorage.Packages.Signal)
local t = require(ReplicatedStorage.Packages.t)

local ProductService = {
	Priority = 0,
	ProductPurchaseCompleted = Signal.new(),
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
		elseif def.Type == "DeveloperProduct" then
			MarketplaceService:PromptProductPurchase(player, def.AssetId)

			return Promise.fromEvent(self.ProductPurchaseCompleted, function(completingPlayer, completingId)
				return completingPlayer == player and completingId == id
			end):expect()
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

	-- convert users that had multi roll
	local key = "AlphaConvertedMultiRoll"
	Observers.observePlayer(function(player)
		DataService:GetSaveFile(player):andThen(function(saveFile)
			if saveFile:Get(key) then return end

			self:GetOwnsProduct(player, "MultiRoll")
				:andThen(function(owns)
					if owns then
						return CurrencyService:AddCurrency(player, "Gems", 300)
					else
						return Promise.resolve()
					end
				end)
				:andThen(function()
					saveFile:Set(key, true)
				end)
		end)
	end)

	MarketplaceService.ProcessReceipt = function(receipt)
		local player = Players:GetPlayerByUserId(receipt.PlayerId)
		local assetId = receipt.ProductId

		local def = DictionaryFind(ProductDefs, function(productDef)
			return productDef.AssetId == assetId
		end)

		if not def then return Enum.ProductPurchaseDecision.NotProcessedYet end

		Promise.all(Sift.Array.map(def.Rewards, function(reward)
			return RewardHelper.GiveReward(player, reward)
		end)):expect()

		self.ProductPurchaseCompleted:Fire(player, def.Id)

		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end

function ProductService.GetVipBoostedSecondary(self: ProductService, player: Player, amount: number)
	if ProductHelper.IsVip(player) then
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

return ProductService
