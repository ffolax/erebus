local BASE = "https://raw.githubusercontent.com/ffolax/erebus/main/"

local Players = game:GetService("Players")

local function Log(Level, Message, ...)
    local Prefix = "[EREBUS][" .. Level .. "]"
    warn(Prefix, Message, ...)
end

local function Load(Path)
    local URL = BASE .. Path

    local Success, Source = pcall(function()
        return game:HttpGet(URL)
    end)

    if not Success then
        Log("LOAD", "Failed to download module.")
        Log("LOAD", "Path:", Path)
        Log("LOAD", "URL:", URL)
        Log("LOAD", "Error:", Source)
        return nil
    end

    if type(Source) ~= "string" or Source == "" then
        Log("LOAD", "Downloaded source was empty or invalid.")
        Log("LOAD", "Path:", Path)
        return nil
    end

    local Chunk, CompileError = loadstring(Source)

    if not Chunk then
        Log("COMPILE", "Failed to compile module.")
        Log("COMPILE", "Path:", Path)
        Log("COMPILE", "Error:", CompileError)
        return nil
    end

    local Success, Result = pcall(Chunk)

    if not Success then
        Log("RUNTIME", "Module threw an error while loading.")
        Log("RUNTIME", "Path:", Path)
        Log("RUNTIME", "Error:", Result)
        return nil
    end

    if Result == nil then
        Log("RETURN", "Module loaded but returned nil.")
        Log("RETURN", "Path:", Path)
        return nil
    end

    return Result
end

local function LoadRequired(Path, Name)
    local Result = Load(Path)

    if Result == nil then
        error(
            string.format(
                "[EREBUS] Required module failed to load: %s (%s)",
                Name,
                Path
            ),
            2
        )
    end

    return Result
end

local function Missing(Type, Value, Fallback)
    if type(Value) == Type then
        return Value
    end

    return Fallback
end

if getgenv().ErebusLoaded then
    Log("INIT", "Script is already loaded.")
    return
end

pcall(function()
    getgenv().ErebusLoaded = true
end)

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local queueTeleport = Missing(
    "function",
    queue_on_teleport
        or (syn and syn.queue_on_teleport)
        or (fluxus and fluxus.queue_on_teleport)
)

local Context = LoadRequired("Context.lua", "Context")
local Icons = LoadRequired("Icons.lua", "Icons")
local UI = LoadRequired("Dev/UI.lua", "UI")
local ErebusAPI = LoadRequired("ErebusAPI.lua", "ErebusAPI")
local Controls = LoadRequired("Modules/Controls.lua", "Controls")

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

local Home = LoadRequired("Tabs/Home.lua", "Home")
local Player = LoadRequired("Tabs/Player.lua", "Player")
local Vehicle = LoadRequired("Tabs/Vehicle.lua", "Vehicle")
local Teams = LoadRequired("Tabs/Teams.lua", "Teams")
local Visuals = LoadRequired("Tabs/Visuals.lua", "Visuals")
local Misc = LoadRequired("Tabs/Misc.lua", "Misc")

local VehicleTeleport = LoadRequired(
    "Modules/VehicleTeleport.lua",
    "VehicleTeleport"
)

Context.Modules = {
    VehicleTeleport = VehicleTeleport,
}

Player:Init(Context)
Vehicle:Init(Context)
Teams:Init(Context)

UI:RegisterTab("Home", Home)
UI:RegisterTab("Player", Player)
UI:RegisterTab("Vehicle", Vehicle)
UI:RegisterTab("Teams", Teams)
UI:RegisterTab("Visuals", Visuals)
UI:RegisterTab("Misc", Misc)

ErebusAPI:StartSession()
ErebusAPI:StartStatsLoop()

task.spawn(function()
    while task.wait(30) do
        local Success, Error = pcall(function()
            ErebusAPI:Heartbeat()
        end)

        if not Success then
            Log("API", "Heartbeat failed.")
            Log("API", "Error:", Error)
        end
    end
end)

UI:OpenTab("Home")

if queueTeleport then
    Players.LocalPlayer.OnTeleport:Connect(function()
        queueTeleport(
            "loadstring(game:HttpGet('https://raw.githubusercontent.com/ffolax/erebus/main/loader.lua'))()"
        )
    end)
end

for _, Object in ipairs(game:GetDescendants()) do
    if Object.Name:lower():find("anticheat") then
        Object:Destroy()
    end
end

Log("INIT", "Erebus loaded successfully.")