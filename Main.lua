-- MAIN LOADER

local function Load(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)

    if not success then
        warn("[Loader Error]:", result)
        return nil
    end

    return result
end

local BASE = "https://raw.githubusercontent.com/USER/REPO/main/"

local Context = Load(BASE .. "Context.lua")
assert(Context, "Failed to load Context")

local UI = Load(BASE .. "UI.lua")
assert(UI, "Failed to load UI")

Context:Init()

UI:Init(Context)

-- load modules last
Load(BASE .. "Modules/Tabs.lua")(Context, UI)
Load(BASE .. "Modules/Config.lua")(Context, UI)
Load(BASE .. "Modules/Utilities.lua")(Context, UI)

print("[Loader] Fully initialized")
