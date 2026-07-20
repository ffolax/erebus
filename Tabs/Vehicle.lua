local Vehicle = {}

Vehicle.State = {
    Acceleration = 1,
    CarFlyToggle = false,
    CarFlySpeed = 50,
}

Vehicle.Runtime = {
    CarFlyConn = nil,
}

Vehicle.Modules = {
    VehicleTeleport = nil
}

local RunService = game:GetService("RunService")

function Vehicle:GetVehicle()

    local Vehicles = workspace:FindFirstChild("Vehicles")
    if not Vehicles then
        return
    end

    return Vehicles:FindFirstChild(game.Players.LocalPlayer.Name)

end

function Vehicle:GetCharacter()

    local Character = game.Players.LocalPlayer.Character
    if not Character then
        return
    end

    return Character,
        Character:FindFirstChildOfClass("Humanoid"),
        Character:FindFirstChild("HumanoidRootPart")

end

function Vehicle:EnterVehicle()

    local Character, Humanoid, Root = self:GetCharacter()

    local PlrVehicle = self:GetVehicle()

    if not (Character and Humanoid and Root and PlrVehicle) then
        return
    end

    local DriveSeat = PlrVehicle:FindFirstChildOfClass("Seat")

    if not DriveSeat then
        return
    end

    local Distance = (Root.Position - DriveSeat.Position).Magnitude

    if Distance > 100 then

        local Start = Root.Position
        local Goal = DriveSeat.Position + Vector3.new(0, 5, 0)

        local Steps = math.ceil(Distance / 5)

        for i = 1, Steps do

            local Alpha = i / Steps

            Root.CFrame = CFrame.new(Start:Lerp(Goal, Alpha))

            RunService.Heartbeat:Wait()

        end

    end

    DriveSeat:Sit(Humanoid)

end

function Vehicle:BringVehicle()

    local Character, Humanoid, Root = self:GetCharacter()

    local PlrVehicle = self:GetVehicle()

    if PlrVehicle and Root then

        local TeleportPos = Root.CFrame * CFrame.new(0,0,-2)
        local Position = TeleportPos.Position

        self.Modules.VehicleTeleport:MoveVehicle(Position,500,false)

    end

end

function Vehicle:UpdateAcceleration()

    local PlrVehicle = self:GetVehicle()

    if not PlrVehicle then
        return
    end

    local DriveSeat = PlrVehicle:FindFirstChildOfClass("Seat")
    if not DriveSeat then
        return
    end

    local Attachment = DriveSeat:FindFirstChild("AccelerationAttachment")
    if not Attachment then
        Attachment = Instance.new("Attachment")
        Attachment.Name = "AccelerationAttachment"
        Attachment.Parent = DriveSeat
    end

    local Force = DriveSeat:FindFirstChild("AccelerationForce")
    if not Force then
        Force = Instance.new("VectorForce")
        Force.Name = "AccelerationForce"
        Force.Attachment0 = Attachment
        Force.RelativeTo = Enum.ActuatorRelativeTo.World
        Force.ApplyAtCenterOfMass = true
        Force.Parent = DriveSeat
    end

    Force.Force = DriveSeat.CFrame.LookVector * (PlrVehicle:GetAttribute("Throttle") * self.State.Acceleration * 500)

end

function Vehicle:Godmode()

    local car = self:GetVehicle()

    if car then

        car:SetAttribute("currentHealth",500)
        car:SetAttribute("IsOn",true)
        car:SetAttribute("currentFuel",math.huge)

    end

end

function Vehicle:SetSuspensionHeight(Value)

    local PlrVehicle = self:GetVehicle()

    if PlrVehicle then

        local DriveSeat = PlrVehicle:FindFirstChildOfClass("Seat")

        if DriveSeat then

            for _,v in pairs(DriveSeat:GetChildren()) do

                if v:IsA("RopeConstraint") then

                    v.Length = 15

                end

                if v:IsA("SpringConstraint") then

                    v.LimitsEnabled = true
                    v.Damping = 0
                    v.MaxLength = 15
                    v.MinLength = Value
                    v.FreeLength = Value

                end

            end

        end

    end

end

function Vehicle:CarFly(Context, Enabled)

    if Enabled then
        self:EnterVehicle()
        self.Runtime.CarFlyConn = Context:RegisterPersistentConnection(
            RunService.RenderStepped:Connect(function()
                
                local Held = Context.Services.Controls.Held

                print(Context.Services.Controls.Held)

                local Velocity = Vector3.zero

                if Held[Enum.KeyCode.W] then
                    Velocity += Camera.CFrame.LookVector
                end

                if Held[Enum.KeyCode.S] then
                    Velocity -= Camera.CFrame.LookVector
                end

                if Held[Enum.KeyCode.D] then
                    Velocity += Camera.CFrame.RightVector
                end

                if Held[Enum.KeyCode.A] then
                    Velocity -= Camera.CFrame.RightVector
                end

                if Held[Enum.KeyCode.Space] then
                    Velocity += Camera.CFrame.UpVector
                end

                if Held[Enum.KeyCode.LeftShift] then
                    Velocity -= Camera.CFrame.UpVector
                end

                local PlrVehicle = self:GetVehicle()

                if not PlrVehicle then
                    return
                end

                local DriveSeat = PlrVehicle:FindFirstChildOfClass("Seat")

                if not DriveSeat then
                    return
                end

                if Velocity.Magnitude > 0 then
                    Velocity = Velocity.Unit
                end

                local DesiredVelocity = Velocity * self.State.CarFlySpeed

                DriveSeat.AssemblyLinearVelocity = DesiredVelocity * 500

            end)
        )
    else
        if self.Runtime.CarFlyConn then
            self.Runtime.CarFlyConn:Disconnect()
            self.Runtime.CarFlyConn = nil
        end

        local PlrVehicle = self:GetVehicle()
        if PlrVehicle and PlrVehicle.PrimaryPart then
            PlrVehicle.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
        end
    end
end

function Vehicle:Init(Context)

    self.Modules.VehicleTeleport = Context.Modules.VehicleTeleport

    Context:RegisterPersistentConnection(

        RunService.Heartbeat:Connect(function()

            self:UpdateAcceleration()

        end)

    )

    local CarFlyKey = Context:AddKeybind({
        Text = "Car Fly Keybind",
        Default = Enum.KeyCode.X
    })

    Context:RegisterPersistentConnection(
        Context.Services.Controls:Bind(CarFlyKey,function(Down)

            if Down then
                Context.Values.CarFly = not Context.Values.CarFly
                self:CarFly(Context, Context.Values.CarFly)

                if self.State.CarFlyToggle then
                    self.State.CarFlyToggle:SetValue(Context.Values.CarFly)
                end
            end

        end)
    )

end

function Vehicle:Build(Context)

    self.Modules.VehicleTeleport = Context.Modules.VehicleTeleport

    Context:AddTitle({
        Text = "Teleport"
    })

    local Container = Context:CreateContainer(250)

    Context:AddViewport({
        Container = Container,
        Model = function()
            return self:GetVehicle()
        end
    })

    Context:AddTitle({
        Text = "TIP: You can press any location on the map UI to teleport there!"
    })

    Context:AddButton({
        Text = "Enter Vehicle",

        Callback = function()

            self:EnterVehicle()

        end
    })

    Context:AddButton({
        Text = "Bring Vehicle",

        Callback = function()

            self:BringVehicle()

        end
    })

    Context:AddTitle({
        Text = "Fly"
    })

    self.State.CarFlyToggle = Context:AddToggle({
        Text = "Car Fly",
        Id = "CarFly",

        Callback = function(Enabled)
            self:CarFly(Context,Enabled)
        end
    })

    local CarFlySlider = Context:AddSlider({

        Text = "Fly Speed",
        Id = "CarFlySpeed",

        Min = 10,
        Max = 200,

        Default = 50,

        Callback = function(Value)

            self.State.CarFlySpeed = Value

        end

    })

    Context:AddTitle({
        Text = "Vehicle Settings"
    })

    local AccelerationSlider = Context:AddSlider({

        Text = "Acceleration",
        Id = "Acceleration",

        Min = 1,
        Max = 10,

        Default = 1,

        Callback = function(Value)

            self.State.Acceleration = Value

        end

    })

    local SuspensionSlider = Context:AddSlider({

        Text = "Suspension Height",
        Id = "SuspensionHeight",

        Min = 1,
        Max = 15,

        Default = 1.5,

        Callback = function(Value)

            self:SetSuspensionHeight(Value)

        end

    })

    Context:AddButton({
        Text = "Godmode",

        Callback = function()

            self:Godmode()

        end
    })

end

function Vehicle:Destroy()



end

return Vehicle