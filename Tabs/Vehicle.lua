local Vehicle = {}
Vehicle.VehicleTeleport = nil

local function FindVehicle()

    local Player = game:GetService("Players").LocalPlayer
    local Vehicles = workspace:FindFirstChild("Vehicles")

    if Vehicles then

        local PlrVehicle = Vehicles:FindFirstChild(Player.Name)

        if PlrVehicle then

           return PlrVehicle

        end
    end

end

function Vehicle:Build(Context)

    self.VehicleTeleport = Context.Modules.VehicleTeleport

    Context:AddTitle({
        Text = "Teleport"
    })

    local Container = Context:CreateContainer(250)

    Context:AddViewport({
        Container = Container,
        Model = FindVehicle
    })

    Context:AddTitle({
        Text = "TIP: You can press any location on the map UI to teleport there!"
    })

    Context:AddButton({
        Text = "Enter Vehicle",

        Callback = function()

            local Players = game:GetService("Players")

            local LocalPlayer = Players.LocalPlayer
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChild("Humanoid")
            local Root = Character and Character:FindFirstChild("HumanoidRootPart")

            local PlrVehicle = FindVehicle()

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

                local Steps = math.ceil(Distance / 15)

                for i = 1, Steps do

                    local Alpha = i / Steps

                    Root.CFrame = CFrame.new(Start:Lerp(Goal, Alpha))

                    task.wait(0.03)

                end

            end

            DriveSeat:Sit(Humanoid)

        end
    })

    Context:AddButton({
        Text = "Bring Vehicle",

        Callback = function()

            local Players = game:GetService("Players")

            local LocalPlayer = Players.LocalPlayer
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChild("Humanoid")
            local Root = Character and Character:FindFirstChild("HumanoidRootPart")

            local PlrVehicle = FindPlrVehicle()

            if PlrVehicle and Root then

                local TeleportPos = Root.CFrame * CFrame.new(0,0,-2)
                local Position = TeleportPos.Position

                self.VehicleTeleport:MoveVehicle(Position,500,false)

            end

        end
    })

    Context:AddTitle({
        Text = "Vehicle Settings"
    })

    local SuspensionSlider = Context:AddSlider({

        Text = "Suspension Height",
        Id = "SuspensionHeight",

        Min = 1,
        Max = 15,

        Default = 1,

        Callback = function(Value)

            local PlrVehicle = FindPlrVehicle()

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

    })

    Context:AddButton({
        Text = "Godmode",

        Callback = function()

            local car = FindPlrVehicle()

            if car then

                car:SetAttribute("currentHealth",500)
                car:SetAttribute("IsOn",true)
                car:SetAttribute("currentFuel",math.huge)

            end

        end
    })

end

function Vehicle:Destroy()



end

return Vehicle