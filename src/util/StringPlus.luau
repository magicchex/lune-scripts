local StringPlus = {}

function StringPlus.conditionalSplit(str: string, splitPattern: string, invalidMatchPattern: string)
	local i = 0
	local result = {}
	while i < #str do
		i += 1
		local _, tail = string.find(str, splitPattern, i)
		local invalidBegin, invalidEnd = string.find(str, invalidMatchPattern, i)

		tail = tail and tail or #str

		if invalidBegin and invalidEnd and tail > invalidBegin and tail <= invalidEnd then
			table.insert(result, str:sub(invalidBegin, invalidEnd))
			i = invalidEnd
		else
			table.insert(result, str:sub(i, tail - 1))
			i = tail
		end
	end
	return result
end

return StringPlus
