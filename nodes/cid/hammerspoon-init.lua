-- hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "R", function()
-- 	hs.reload()
-- 	hs.alert("🔁 Hammerspoon reloaded")
-- end)

hs.hotkey.bind({ "alt" }, "space", function()
	hs.application.launchOrFocus("Raycast")
end)

hs.hotkey.bind({ "cmd" }, "space", function()
	hs.application.launchOrFocus("Raycast")
end)
