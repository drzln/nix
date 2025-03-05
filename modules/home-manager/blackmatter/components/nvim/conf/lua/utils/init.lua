local M = {}

--[[
This function loads files from a given directory.

Parameters:
dir (string): The directory to load files from.
--]]
function M.load_files(dir)
	local directories = M.list_directories(dir)
	for _, directory in ipairs(directories) do
		local substrings = M.split(directory, "/")
		for _, file in ipairs(M.list_files(directory)) do
			local thisfile = string.gsub(file, "%.lua$", "")
			local path = string.format("includes.%s.%s", substrings[#substrings], thisfile)
			require(path).setup()
		end
	end
end

--[[
This function lists directories at a given path.

Parameters:
path (string): The path to list directories from.

Returns:
table: A table of directory paths.
--]]
function M.list_directories(path)
	local cmd = string.format("ls -d %s/*/ 2>/dev/null", path)
	local handle = io.popen(cmd)
	local result = nil
	if handle then
		result = handle:read("*a")
		handle:close()
	end
	local directories = {}
	for dir in result:gmatch("(.-)\n") do
		table.insert(directories, dir)
	end
	return directories
end

--[[
This function splits a string by a given separator.

Parameters:
str (string): The string to split.
sep (string): The separator to split by. Defaults to space.

Returns:
table: A table of substrin
--]]
function M.split(str, sep)
	sep = sep or "%s"
	local parts = {}
	for match in string.gmatch(str, "([^" .. sep .. "]+)") do
		table.insert(parts, match)
	end
	return parts
end

--[[
This function lists files at a given path.

Parameters:
path (string): The path to list files from.

Returns:
table: A table of file names.
--]]
function M.list_files(path)
	local files = {}
	for file in io.popen("ls " .. path .. " 2>/dev/null"):lines() do
		if not file:match("/$") then
			table.insert(files, file)
		end
	end
	return files
end

--[[
This function removes the file extension from a given filename.

Parameters:
filename (string): The filename to remove the extension from.

Returns:
string: The filename without the extension.
--]]
-- function M.remove_file_extension(filename)
-- 	local basename = filename:match("(.+)%.[^.]*$")
-- 	return basename or filename
-- end

--[[
This function gets subdirectories of a given directory.

Parameters:
directory (string): The directory to get subdirectories from.

Returns:
table: A table of subdirectory paths.
--]]
-- function M.get_subdirectories(directory)
-- 	local subdirectories = {}
-- 	local handle = io.popen(
-- 		"find " .. directory .. " -maxdepth 1 -type d -not -name '.' 2>/dev/null"
-- 	)
-- 	if handle then
-- 		for entry in handle:lines() do
-- 			table.insert(subdirectories, entry)
-- 		end
-- 		handle:close()
-- 	end
-- 	return subdirectories
-- end

--[[
This function gets files from a given module.

Parameters:
module_name (string): The name of the module to get files from.

Returns:
table: A table of file paths.
--]]
-- function M.get_files(module_name)
-- 	local path = package.searchpath(module_name, package.path)
-- 	local files = {}
-- 	if path then
-- 		local handle = io.popen("find " .. path:match("(.*/)") .. " -type f 2>/dev/null")
-- 		if handle then
-- 			for entry in handle:lines() do
-- 				table.insert(files, entry)
-- 			end
-- 			handle:close()
-- 		end
-- 	end
-- 	return files
-- end

--[[
-- safely load module with a warning
--
-- Parameters:
-- module_name: string
--
-- Returns:
-- module or false
--]]
-- function M.safe_module_load(module_name)
-- 	local status_ok = pcall(require, module_name)
-- 	if not status_ok then
-- 		print(module_name .. " not working")
-- 	end
-- 	return false
-- end

return M
