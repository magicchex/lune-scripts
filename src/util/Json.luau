local Json = {}

local StringPlus = require("./StringPlus")

local function numberOrString(s: string): number | string
	return tonumber(s) and tonumber(s) or s:gsub('"', "")
end

function Json.decode(json: string)
	local dict: { [string]: number | string | { any } | { any: any } } = {}
	local key = ""
	local value = ""
	local isValueMode = false
	local i = 0
	while i <= #json do
		i += 1
		local c = json:sub(i, i)
		-- Object Handling
		if isValueMode and c == "{" then
			isValueMode = false
			local _, tail = string.find(json, "}", i)
			value = json:sub(i, tail)
			dict[key] = value
			key = ""
			i = tail + 1
			continue
		end

		-- List Handling
		if isValueMode and c == "[" then
			isValueMode = false
			local _, tail = string.find(json, "%]", i)
			value = json:sub(i, tail)
			local items = {}
			for _, v in ipairs(StringPlus.conditionalSplit(value:gsub("[%[%]]", ""), ",", "{.+}")) do
				if string.find(v, "{+.*}+") then
					table.insert(items, v)
					continue
				end
				table.insert(items, numberOrString(v))
			end
			dict[key] = items
			key = ""
			i = tail + 1
			continue
		end

		-- Number / String Handling
		if isValueMode and c == "," or i == #json then
			isValueMode = false
			dict[key] = numberOrString(value)
			key = ""
			continue
		end

		-- Key Setting
		if key == "" and c == '"' then
			local _, tail = string.find(json, '"', i + 1)
			key = json:sub(i + 1, tail - 1)
			i = tail
			continue
		end

		-- isValueMode Switch
		if c == ":" then
			isValueMode = true
			value = ""
			continue
		end
		value ..= c
	end

	for k, v in pairs(dict) do
		if type(v) == "string" and string.find(v, "{+.*}+") then
			dict[k] = Json.decode(v)
		end
		if type(v) == "table" then
			for idx, item in ipairs(v) do
				if type(item) == "string" and string.find(item, "{+.*}+") then
					table.insert(v, idx, Json.decode(item))
					table.remove(v, idx + 1)
				end
			end
		end
	end

	return dict
end

function Json.encode(dict: { any: any }, indentionLevel: number?): string
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
			stringJson ..= string.format("%s%s", k, Json.encode(value))
		end
	end
	stringJson = stringJson .. "}"
	if isList then
		stringJson = stringJson:gsub("^{", "["):gsub("}$", "]")
	end
	return stringJson
end

return Json
