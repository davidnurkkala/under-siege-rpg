return function(dictionary, predicate)
	for key, val in dictionary do
		if predicate(val, key) then return val, key end
	end
	return nil
end
