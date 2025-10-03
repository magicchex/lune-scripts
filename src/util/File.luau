local fs = require("@lune/fs")
local datetime = require("@lune/datetime")

local File = {}
File.__index = File

type FileType = "file" | "directory"

type self = {
	path: string,
	fullName: string,
	type: FileType,
}
export type File = typeof(setmetatable({} :: self, File))

function File.new(path: string): File
	local self: self = {
		path = "",
		fullName = "",
		type = fs.isFile(path) and "file" or fs.isDir(path) and "directory" or error(
			"Could not create File Object! Invalid Path!"
		),
	}
	self.path = path
	local depth = path:split("/")
	if string.find(path, "\\") then
		depth = path:split("\\")
	end
	self.fullName = depth[#depth]
	return setmetatable(self, File)
end

function File:getFullName(): string?
	return self.fullName
end

function File:getName(): string?
	local fullName: string = self:getFullName()
	local idx = string.find(fullName:reverse(), "%.")
	if idx then
		return fullName:sub(0, #fullName - idx)
	end
	return nil
end

function File:getPath(): string?
	return self.path
end

function File:getType(): FileType
	return self.type
end

function File:getMetadata(): fs.Metadata?
	return fs.metadata(self:getPath())
end
function File:getModifiedAtUnix(): number
	local metadata: fs.Metadata = self:getMetadata()
	local modified: datetime.DateTime = metadata.modifiedAt
	return modified.unixTimestamp
end

function File:getContents(): string
	if self.getType() == "directory" then
		error(string.format('Could not get contents of file! "%s" is type %s!', self.getFullName(), self.getType()))
	end
	return fs.readFile(self.path)
end

return File
