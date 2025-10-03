local process = require("@lune/process")
local fs = require("@lune/fs")

local File = require("./File")
local Path = require("./Path")
local fsPlus = require("./fsPlus")
local Node = require("./Node")

local function getOS(): "linux" | "windows" | "macos"
	return process.os
end

local function getStudioEnvironment(usesModManager: boolean?)
	-- Mod Manager: https://github.com/MaximumADHD/Roblox-Studio-Mod-Manager
	local homeDirectory = process.env["HOME"] and process.env["HOME"] or error("Could not get home directory")
	local environment
	if getOS() == "windows" then
		local LocalAppData = Path.join(homeDirectory, "AppData", "Local")
		if not fs.isDir(LocalAppData) then
			error("Could not find ../AppData/Local folder!")
		end

		environment = Path.join(LocalAppData, "Roblox", "Versions")
		if type(usesModManager) == "boolean" and usesModManager then
			environment = Path.join(LocalAppData, "Roblox Studio")
		end
		if not fs.isDir(environment) then
			error('Could not find "%s"', environment)
		end
	else
	end
	return environment
end

local RobloxPlus = {}

function RobloxPlus.getStudioFolder(usesModManager: boolean?): string
	if getOS() == "windows" then
		local environment = getStudioEnvironment(usesModManager)
		if usesModManager then
			return environment
		end
		local latestFolder
		fsPlus.readDir(environment, function(_, path)
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

function RobloxPlus.getListOfStudioVersions()
	local list = {}
	fsPlus.readDir(getStudioEnvironment(), function(_, path)
		local f = File.new(path)
		if f:getType() == "file" then
			return
		end
		table.insert(list, f)
	end)
	return list
end

return RobloxPlus
