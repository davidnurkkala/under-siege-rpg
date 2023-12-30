local ProductHelper = {}

function ProductHelper.IsVip(player)
	return player:GetAttribute("IsVip") == true
end

return ProductHelper
