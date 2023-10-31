return function(lower: number, upper: number?, step: number?)
	if not upper then
		upper = lower
		lower = 1
	end

	if not step then step = 1 end

	local list = {}
	for number = lower, upper :: number, step :: number do
		table.insert(list, number)
	end

	return list
end
