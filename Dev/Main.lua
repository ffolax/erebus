local BASE = "https://raw.githubusercontent.com/ffolax/erebus/main/"

local function Load(Path)

    local Source = game:HttpGet(BASE .. Path)

    local Chunk, Error = loadstring(Source)

    if not Chunk then
        warn("[EREBUS] Compile failed:", Path)
        warn(Error)
        return nil
    end

    local Success, Result = pcall(Chunk)

    if not Success then
        warn("[EREBUS] Runtime failed:", Path)
        warn(Result)
        return nil
    end

    return Result

end

local Context = Load("Context.lua")
assert(Context, "[EREBUS] Context failed to load.")

local Icons = Load("Icons.lua")
assert(Icons, "[EREBUS] Icons failed to load.")

local UI = Load("Dev/UI.lua")
assert(UI, "[EREBUS] UI failed to load.")

local ErebusAPI = Load("ErebusAPI.lua")
assert(ErebusAPI, "[EREBUS] API failed to load. IF YOU GET THIS WARNING, REPORT IT TO THE DISCORD IN #tickets")

Context.BASE = BASE

Context.Services = {
    API = ErebusAPI,
    UI = UI,
    Icons = Icons,
}

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

local VehicleTeleport loadstring(game:HttpGet(BASE .. "Modules/VehicleTeleport.lua"))()


UI:RegisterTab("Home", Home)
UI:RegisterTab("Player", Player)
UI:RegisterTab("Vehicle", Vehicle)
UI:RegisterTab("Visuals", Visuals)
UI:RegisterTab("Misc", Misc)


ErebusAPI:StartSession()
ErebusAPI:StartStatsLoop()

task.spawn(function()

    while task.wait(30) do
        ErebusAPI:Heartbeat()
    end

end)


UI:OpenTab("Home")