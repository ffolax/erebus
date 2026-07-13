local BASE = "https://raw.githubusercontent.com/ffolax/erebus/main/"

function Load(Path)

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

if getgenv().ErebusLoaded then
    warn("[EREBUS] Script already loaded!")
    return
end

pcall(function() getgenv().ErebusLoaded = true end)
if not game:IsLoaded() then game.Loaded:Wait() end

function missing(t, f, fallback)
	if type(f) == t then return f end
	return fallback
end

queueteleport = missing("function", queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport))

local Context = Load("Context.lua")
assert(Context, "[EREBUS] Context failed to load.")

local Icons = Load("Icons.lua")
assert(Icons, "[EREBUS] Icons failed to load.")

local UI = Load("Dev/UI.lua")
assert(UI, "[EREBUS] UI failed to load.")

local ErebusAPI = Load("ErebusAPI.lua")
assert(ErebusAPI, "[EREBUS] API failed to load. IF YOU GET THIS WARNING, REPORT IT TO THE DISCORD IN #tickets")

local Controls = Load("Modules/Controls.lua")
assert(Controls, "[EREBUS] Controls failed to load.")

Context.BASE = BASE

Context.Services = {
    API = ErebusAPI,
    UI = UI,
    Icons = Icons,
    Controls = Controls,
}

Context:Init()
Controls:Init(Context)

UI:Init(
    Context,
    Icons
)

local Home = loadstring(game:HttpGet(BASE .. "Tabs/Home.lua"))()
local Player = loadstring(game:HttpGet(BASE .. "Tabs/Player.lua"))()
local Vehicle = loadstring(game:HttpGet(BASE .. "Tabs/Vehicle.lua"))()
local Visuals = loadstring(game:HttpGet(BASE .. "Tabs/Visuals.lua"))()
local Misc = loadstring(game:HttpGet(BASE .. "Tabs/Misc.lua"))()

local VehicleTeleport = loadstring(game:HttpGet(BASE .. "Modules/VehicleTeleport.lua"))()

Context.Modules = {

    VehicleTeleport = VehicleTeleport
    
}

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

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if queueteleport then

    LocalPlayer.OnTeleport:Connect(function()

        queueteleport()

    end)

end