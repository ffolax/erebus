local BASE = "https://raw.githubusercontent.com/ffolax/erebus/main/"

local function Load(Path)

	local Success, Result = pcall(function()
		return loadstring(game:HttpGet(BASE .. Path))()
	end)

	if not Success then
		warn("[Loader] Failed loading:", Path)
		warn(Result)
		return nil
	end

	return Result

end

local Context = Load("Context.lua")
assert(Context, "Context failed to load.")

local Icons = Load("Icons.lua")
assert(Icons, "Icons failed to load.")

local UI = Load("UI.lua")
assert(UI, "UI failed to load.")

Context.BASE = BASE

Context:Init()

UI:Init(
	Context,
	Icons
)

Load("Modules/Tabs.lua")(Context, UI)
Load("Modules/Config.lua")(Context, UI)
Load("Modules/Utilities.lua")(Context, UI)
