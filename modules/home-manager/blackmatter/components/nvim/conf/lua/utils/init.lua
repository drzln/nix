local M = {}

-- Split a path string into components by separator
function M.split(str, sep)
	sep = sep or "/"
	local parts = {}
	for match in string.gmatch(str, "([^" .. sep .. "]+)") do
		table.insert(parts, match)
	end
	return parts
end

-- List immediate subdirectories
function M.list_directories(path)
	local result = {}
	local p = vim.loop.fs_scandir(path)
	if not p then
		return result
	end

	while true do
		local name, t = vim.loop.fs_scandir_next(p)
		if not name then
			break
		end
		if t == "directory" then
			table.insert(result, path .. "/" .. name)
		end
	end

	return result
end

-- List `.lua` files (no recursion)
function M.list_files(path)
	local result = {}
	local p = vim.loop.fs_scandir(path)
	if not p then
		return result
	end

	while true do
		local name, t = vim.loop.fs_scandir_next(p)
		if not name then
			break
		end
		if t == "file" and name:match("%.lua$") then
			table.insert(result, name)
		end
	end

	return result
end

-- Load a single module safely with setup()
local function load_module(modpath)
	local ok, mod = pcall(require, modpath)
	if not ok then
		vim.notify("Failed to load module: " .. modpath, vim.log.levels.WARN)
		return
	end
	if type(mod.setup) == "function" then
		pcall(mod.setup)
	end
end

-- Load .lua modules from `dir` and all subdirectories
function M.load_files(dir)
	local parts = M.split(dir, "/")
	local lua_index = vim.tbl_indexof(parts, "lua")
	if not lua_index then
		return
	end

	local base_module = table.concat(vim.list_slice(parts, lua_index + 1), ".")

	-- Load files in the base directory
	for _, file in ipairs(M.list_files(dir)) do
		local modname = file:gsub("%.lua$", "")
		load_module(base_module .. "." .. modname)
	end

	-- Load files in all subdirectories
	for _, subdir in ipairs(M.list_directories(dir)) do
		local rel_parts = M.split(subdir, "/")
		local modpath = table.concat(vim.list_slice(rel_parts, lua_index + 1), ".")

		for _, file in ipairs(M.list_files(subdir)) do
			local modname = file:gsub("%.lua$", "")
			load_module(modpath .. "." .. modname)
		end
	end
end

return M
