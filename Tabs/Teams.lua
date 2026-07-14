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

    ReplicatedStorage.Zp3["d86a1e0e-1163-44cf-8647-c2c5fecf62c9"]:FireServer(true)
    ReplicatedStorage.Zp3["6b0e798f-3ca7-46dd-8dd6-b6037b63cf48"]:FireServer()
    ReplicatedStorage.Zp3["d86a1e0e-1163-44cf-8647-c2c5fecf62c9"]:FireServer(false)

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
        Text = "INFO: Wait until the vehicle is on your bed then press 'Fling Vehicle'."
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