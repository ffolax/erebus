local Vehicle = {}

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

    local VehicleTeleport = Context.Modules.VehicleTeleport

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

            local Vehicle = FindVehicle()

            if not (Character and Humanoid and Root and Vehicle) then
                return
            end

            local DriveSeat = Vehicle:FindFirstChildOfClass("Seat")

            if not DriveSeat then
                return
            end

            local Distance = (Root.Position - DriveSeat.Position).Magnitude

            -- Safe teleport if too far away
            if Distance > 300 then

                local Start = Root.Position
                local Goal = DriveSeat.Position + Vector3.new(0, 5, 0)

                local Steps = math.ceil(Distance / 75)

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

            local Vehicle = FindPlrVehicle()

            if Vehicle and Root then

                local Position = Root.CFrame * CFrame.new(0,0,10)

                VehicleTeleport:MoveVehicle(Position,200,false)

            end

        end
    })

    Context:AddTitle({
        Text = "Vehicle Settings"
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