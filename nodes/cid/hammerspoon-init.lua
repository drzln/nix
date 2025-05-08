-- nodes/cid/hammerspoon-init.lua
-- local function run(cmd)
-- 	hs.execute(cmd, true)
-- end

-- local function dockIsAutoHidden()
-- 	local out = run([[defaults read com.apple.dock autohide || echo 0]])
-- 	return tonumber(out) == 1
-- end

------------------------------------------------------------------
-- Raycast helpers
------------------------------------------------------------------
local function showRaycast()
	-- simulate the default Raycast shortcut: ⌘ + space
	hs.eventtap.keyStroke({ "cmd" }, "space", 0)
end
hs.hotkey.bind({ "cmd" }, "space", showRaycast)
------------------------------------------------------------------
-- Spotlight helpers
------------------------------------------------------------------
-- local function showSpotlight()
-- 	-- simulate the default Spotlight shortcut: ⌘ + space
-- 	hs.eventtap.keyStroke({ "cmd" }, "space", 0)
-- end

------------------------------------------------------------------
-- Hot-keys
------------------------------------------------------------------
-- Alt + Space  ➜ Spotlight
-- hs.hotkey.bind({ "alt" }, "space", showSpotlight)

-- Cmd + Space ➜ Spotlight  (works even if you disabled the macOS
-- global shortcut and gave it to Raycast)
-- hs.hotkey.bind({ "cmd" }, "space", showSpotlight)

-- Toggle auto-hide (⌃⌥⌘ D)
-- hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "D", function()
-- 	if dockIsAutoHidden() then
-- 		run([[defaults write com.apple.dock autohide -bool false]])
-- 		hs.alert.show("Dock: always visible")
-- 	else
-- 		run([[defaults write com.apple.dock autohide -bool true]])
-- 		hs.alert.show("Dock: auto-hide")
-- 	end
-- 	run([[killall Dock]])
-- end)
-- hs.hotkey.bind({ "cmd" }, "space", function()
-- 	hs.alert.show("Triggered")
-- end)
