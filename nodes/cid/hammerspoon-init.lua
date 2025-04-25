------------------------------------------------------------------
-- Raycast helpers
------------------------------------------------------------------
local function showRaycast()
	-- simulate the default Raycast shortcut: ⌘ + space
	hs.eventtap.keyStroke({ "cmd" }, "space", 0)
end
------------------------------------------------------------------
-- Spotlight helpers
------------------------------------------------------------------
local function showSpotlight()
	-- simulate the default Spotlight shortcut: ⌘ + space
	hs.eventtap.keyStroke({ "cmd" }, "space", 0)
end

------------------------------------------------------------------
-- Hot-keys
------------------------------------------------------------------
-- Alt + Space  ➜ Spotlight
hs.hotkey.bind({ "alt" }, "space", showSpotlight)

-- Cmd + Space ➜ Spotlight  (works even if you disabled the macOS
-- global shortcut and gave it to Raycast)
hs.hotkey.bind({ "cmd" }, "space", showSpotlight)
