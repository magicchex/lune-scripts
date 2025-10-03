local process = require("@lune/process")
local fs = require("@lune/fs")

local File = require("./File")
local Path = require("./Path")
local IO = require("./IO")

local function getOS(): "linux" | "windows" | "macos"
	return process.os
end

local RobloxPlus = {}

function RobloxPlus.getStudioFolder(usesModManager: boolean?): string
	local homeDirectory = process.env["HOME"] and process.env["HOME"] or error("Could not get home directory")
	if getOS() == "windows" then
		local LocalAppData = Path.join(homeDirectory, "AppData", "Local")
		if not fs.isDir(LocalAppData) then
			error("Could not find ../AppData/Local folder!")
		end

		local environment = Path.join(LocalAppData, "Roblox", "Versions")
		if type(usesModManager) == "boolean" and usesModManager then
			environment = Path.join(LocalAppData, "Roblox Studio")
			if not fs.isDir(environment) then
				error('Could not find "%s"', environment)
			end
			return environment
		end
		if not fs.isDir(environment) then
			error('Could not find "%s"', environment)
		end

		local latestFolder
		IO.readDir(environment, function(_, path)
			local f = File.new(path)
			if f:getType() == "file" then
				return
			end
			if not latestFolder then
				latestFolder = f
				return
			end
			if f:getModifiedAtUnix() > latestFolder:getModifiedAtUnix() then
				latestFolder = f
			end
		end)
		return latestFolder:getPath()
	end
	return "Unimplemented for unix systems!"
end

return RobloxPlus
