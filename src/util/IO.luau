local fs = require("@lune/fs")

local Path = require("./Path")

local IO = {}
function IO.readDir(directoryPath: string, iteratorFunc: (key: number, path: string) -> ())
	for i, v in ipairs(fs.readDir(directoryPath)) do
		iteratorFunc(i, Path.join(directoryPath, v))
	end
end
return IO
