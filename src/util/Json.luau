local Json = {}

function Json.ToJson(dict: { any: any }, indentionLevel: number?): string
	local stringJson = "{"
	local isList = false
	for key, value in pairs(dict) do
		if #stringJson > 1 then
			stringJson ..= ","
		end
		if not isList then
			isList = tonumber(key)
		end
		if not tonumber(key) and isList then
			error("List component has an string key!")
		end
		local k = tonumber(key) and "" or string.format('"%s":', key)
		if type(value) == "number" then
			stringJson ..= string.format("%s%d", k, value)
		end
		if type(value) == "string" then
			stringJson ..= string.format('%s"%s"', k, value)
		end
		if type(value) == "table" then
			stringJson ..= string.format("%s%s", k, Json.ToJson(value))
		end
	end
	stringJson = stringJson .. "}"
	if isList then
		stringJson = stringJson:gsub("{", "["):gsub("}", "]")
	end
	return stringJson
end

return Json
