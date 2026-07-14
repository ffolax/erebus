local Misc = {}

Misc.State = {
    SelectedMorph = nil,
    VehicleList = {},
    Reviving = false
}

Misc.Runtime = {
    ReviveConn = nil
}

local Players = game:GetService("Players")
local Plr = Players.LocalPlayer
local Vehicles = workspace:WaitForChild("Vehicles")
local RunService = game:GetService("RunService")

function Misc:GetPlayerVehicle()
    return Vehicles:FindFirstChild(Plr.Name)
end

function Misc:RefreshVehicleList()

    table.clear(self.State.VehicleList)

    for _,vehicle in ipairs(Vehicles:GetChildren()) do

        if vehicle:FindFirstChild("DriveSeat") then

            local Name = vehicle.Name

            if vehicle.DriveSeat:GetAttribute("Rent") then
                Name = "E-Scooter"
            end

            table.insert(self.State.VehicleList, Name)

        end
    end
end

function Misc:GetCharacter()

    local Character = game.Players.LocalPlayer.Character
    if not Character then
        return
    end

    return Character,
        Character:FindFirstChildOfClass("Humanoid"),
        Character:FindFirstChild("HumanoidRootPart")

end

function Misc:MorphVehicle()

    local SelectedMorph = self.State.SelectedMorph

    if not SelectedMorph then
        return
    end

    local SourceVehicle = Vehicles:FindFirstChild(SelectedMorph)
    if not SourceVehicle then
        return
    end

    local MyVehicle = self:GetPlayerVehicle()
    if not MyVehicle then
        return
    end

    local SourceBody = SourceVehicle:FindFirstChild("Body")

    if not SourceBody then
        warn("Source vehicle has no Body model.")
        return
    end

    local OldBody = MyVehicle.Body
    OldBody.Body.CanCollide = false

    if MyVehicle:FindFirstChild("MorphBody") then

        MyVehicle:FindFirstChild("MorphBody"):Destroy()

    end

    local NewBody = SourceBody:Clone()
    NewBody.Parent = MyVehicle
    NewBody.Name = "MorphBody"

    local Wheels = NewBody:FindFirstChild("Wheels", true)
    if Wheels then
        for _,v in pairs(Wheels:GetDescendants()) do

            if not v:IsA("BasePart") and not v:IsA("Model") then

                v:Destroy()

            end

        end
    end

    local MainBody = NewBody:FindFirstChild("Body", true)

    if not MainBody or not MainBody:IsA("BasePart") then
        warn("Couldn't find main Body meshpart.")
        return
    end

    if NewBody.PrimaryPart and MyVehicle.PrimaryPart and MainBody then

        local YOffset = MainBody.Size.Y / 3

        NewBody:PivotTo(
            MyVehicle.PrimaryPart.CFrame *
            CFrame.new(1.5, YOffset, 2)
        )

    end

    for _, Part in ipairs(NewBody:GetDescendants()) do
        if Part:IsA("BasePart") and Part ~= MainBody then

            Part.Anchored = false

            local Weld = Instance.new("WeldConstraint")
            Weld.Part0 = MainBody
            Weld.Part1 = Part
            Weld.Parent = MainBody

            local destroyconn

            destroyconn = Part.Destroying:Connect(function()

                Weld:Destroy()

                destroyconn:Disconnect()

            end)

        end
    end

    for _, Part in ipairs(NewBody:GetDescendants()) do
        if Part:IsA("BasePart") then

            Part.CanCollide = false
            Part.Massless = true

        end
    end

    for _, Part in ipairs(OldBody:GetDescendants()) do
        if Part:IsA("BasePart") then

            Part.Transparency = 1

        end

        if Part:IsA("SurfaceGui") then

            Part.Enabled = false

        end

        if Part:IsA("Decal") then

            Part:Destroy()

        end
    end

    local DriveSeat = MyVehicle:FindFirstChild("DriveSeat")

    if DriveSeat and MainBody then
        MainBody.Anchored = false

        local Weld = Instance.new("WeldConstraint")
        Weld.Part0 = DriveSeat
        Weld.Part1 = MainBody
        Weld.Parent = DriveSeat
    else
        warn("Couldn't find DriveSeat or Body meshpart.")
    end

end

function Misc:SetVehicleNoclip(Enabled)

    local Vehicle = self:GetPlayerVehicle()

    if not Vehicle then
        return
    end

    for _,Part in ipairs(Vehicles:GetDescendants()) do

        if Part:IsA("BasePart")
        and not Part:IsDescendantOf(Vehicle) then

            Part.CanCollide = not Enabled

        end
    end
end

function Misc:AutoRevive(Enabled,Context)

    if Enabled then

        local Character, Humanoid, Root = self:GetCharacter()

        Misc.Runtime.ReviveConn = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()

            if Humanoid.Health < 25 then

                if Misc.State.Reviving then
                    return
                end

                Misc.State.Reviving = true

                local VehicleTeleport = Context.Modules.VehicleTeleport

                if not VehicleTeleport then
                    return
                end

                VehicleTeleport:MoveVehicle(Vector3.new(-465, 5, 3014),200,true)

                print("A")

            end

        end)

    else

        if Misc.Runtime.ReviveConn then
            Misc.Runtime.ReviveConn:Disconnect()
            Misc.Runtime.ReviveConn = nil
        end

    end

end

function Misc:Build(Context)

    self:RefreshVehicleList()

    Context:AddTitle({
        Text = "Essentials"
    })

    Context:AddToggle({
        Text = "Auto-Revive",
        Callback = function(Enabled)
            self:AutoRevive(Enabled,Context)
        end
    })

    Context:AddTitle({
        Text = "Vehicle Morph"
    })

    Context:AddButton({
        Text = "Morph (CLIENT-SIDED)",
        Callback = function()
            self:MorphVehicle()
        end
    })

    Context:AddDropdown({
        Text = "Morph Into",
        Items = self.State.VehicleList,
        Callback = function(Value)
            self.State.SelectedMorph = Value
        end
    })

    Context:AddTitle({
        Text = "Troll"
    })

    Context:AddToggle({
        Text = "Noclip through vehicles",
        Callback = function(Enabled)
            self:SetVehicleNoclip(Enabled)
        end
    })

end

function Misc:Destroy()

end

return Misc