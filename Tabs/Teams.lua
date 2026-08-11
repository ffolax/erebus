local TeamTab = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Plr = Players.LocalPlayer

TeamTab.State = {
    Flinging = false
}

function TeamTab:FlingVehicle()

    if self.State.Flinging then
        return
    end

    if Plr.Team.Name ~= "HARS" then
        return
    end

    self.State.Flinging = true

    local Vehicle = FindPlrVehicle()
    if not Vehicle then
        self.State.Flinging = false
        return
    end

    local Seat = Vehicle:FindFirstChildOfClass("Seat")

    if not Seat then
        self.State.Flinging = false
        return
    end

    Seat.Anchored = true

    ReplicatedStorage.2Wz["de90f020-3c93-46b4-a00c-d7270b5f706e"]:FireServer(true)
    ReplicatedStorage.2Wz["25e6d86c-eaf5-4698-9e4d-20022e3d46c2"]:FireServer()
    ReplicatedStorage.2Wz["de90f020-3c93-46b4-a00c-d7270b5f706e"]:FireServer(false)

    local EndTime = tick() + 1

    while tick() < EndTime do
        RunService.Heartbeat:Wait()

        Seat.Velocity = Vector3.new(
            math.random(-10000,10000),
            10000,
            math.random(-10000,10000)
        )
    end

    Seat.Velocity = Vector3.zero

    task.wait(0.25)

    Seat.Anchored = false

    self.State.Flinging = false

end

function TeamTab:Init(Context)

    -- future keybinds / persistent connections

end

function TeamTab:Build(Context)

    Context:AddTitle({
        Text = "HARS"
    })

    Context:AddTitle({
        Text = "Info: Wait until the vehicle is on your bed then press 'Fling Vehicle'."
    })

    Context:AddButton({
        Text = "Fling Vehicle",

        Callback = function()
            self:FlingVehicle()
        end
    })

end

function TeamTab:Destroy()

end

return TeamTab