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

local UI = Load("Release/UI.lua")
assert(UI, "UI failed to load.")

Context.BASE = BASE

Context:Init()

UI:Init(
	Context,
	Icons
)

UI:RegisterTab("Home", function(content)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 30)
	label.Position = UDim2.new(0, 10, 0, 10)
	label.BackgroundTransparency = 1
	label.Text = "Welcome to EREBUS"
	label.TextColor3 = Color3.fromRGB(235, 235, 245)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 18
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = content

end)

UI:RegisterTab("Player", function(content)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 30)
	label.Position = UDim2.new(0, 10, 0, 10)
	label.BackgroundTransparency = 1
	label.Text = "Player Settings"
	label.TextColor3 = Color3.fromRGB(235, 235, 245)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 18
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = content

end)

UI:RegisterTab("Vehicle", function(content)
	-- car stuff here
end)

UI:RegisterTab("Visuals", function(content)
	-- ESP, effects, etc
end)

UI:RegisterTab("Misc", function(content)
	-- utilities, settings, etc
end)

--[[
Load("Modules/Tabs.lua")(Context, UI)
Load("Modules/Config.lua")(Context, UI)
Load("Modules/Utilities.lua")(Context, UI)
]]
