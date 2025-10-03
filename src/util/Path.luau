local fs = require("@lune/fs")
local process = require("@lune/process")

local Path = {}
Path.__index = Path
Path.sep = process.os == "windows" and "\\" or "/"
Path.cur = "."
Path.par = ".."

function Path.convert(path: string, forceUnix: boolean?): string
	if type(forceUnix) == "boolean" then
		if forceUnix then
			return path:gsub("\\", "/")
		else
			return path:gsub("/", "\\")
		end
	end
	local unixIdx = string.find(path, "/", 0, true)
	local winIdx = string.find(path, "\\", 0, true)
	if unixIdx and winIdx and unixIdx - winIdx > 0 then
		return path:gsub("\\", "/")
	else
		return path:gsub("/", "\\")
	end
end

function Path.join(...: string): string
	local newPath = ""
	for i, path in { ... } do
		if i == #{ ... } then
			newPath ..= path
			continue
		end
		if Path.convert(path:sub(-1), process.os ~= "windows") ~= Path.sep then
			newPath ..= path .. Path.sep
		else
			newPath ..= path
		end
	end
	return newPath
end
return Path
