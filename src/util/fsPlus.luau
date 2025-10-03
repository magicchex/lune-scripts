local fs = require("@lune/fs")

local Path = require("./Path")

local fsPlus = {}

function fsPlus.readDir(directoryPath: string, iteratorFunc: (key: number, path: string) -> ())
	for i, v in ipairs(fs.readDir(directoryPath)) do
		iteratorFunc(i, Path.join(directoryPath, v))
	end
end
function fsPlus.writeDir(path: string)
	if not fs.isDir(path) then
		fs.writeDir(path)
	end
end
return fsPlus
