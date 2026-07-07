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

local UI = Load("Dev/UI.lua")
assert(UI, "UI failed to load.")

Context.BASE = BASE

Context:Init()

UI:Init(
	Context,
	Icons
)

local Home = loadstring(game:HttpGet(BASE .. "Tabs/Home.lua"))()
local Player = loadstring(game:HttpGet(BASE .. "Tabs/Player.lua"))()
local Vehicle = loadstring(game:HttpGet(BASE .. "Tabs/Vehicle.lua"))()
local Visuals = loadstring(game:HttpGet(BASE .. "Tabs/Visuals.lua"))()
local Misc = loadstring(game:HttpGet(BASE .. "Tabs/Misc.lua"))()

local Tabs = {
    Home,
    Player,
    Vehicle,
    Visuals,
    Misc
}

for _,Tab in ipairs(Tabs) do
    Tab.Load(Context)
end

UI:RegisterTab("Home", Home)
UI:RegisterTab("Player", Player)
UI:RegisterTab("Vehicle", Vehicle)
UI:RegisterTab("Visuals", Visuals)
UI:RegisterTab("Misc", Misc)