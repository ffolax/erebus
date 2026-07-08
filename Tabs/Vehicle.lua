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

return function(Context)

    local Container = Context:CreateContainer(250)

    Context:AddViewport({
        Container = Container,
        Model = FindVehicle
    })

    Context:AddButton({
        Text = "Enter Vehicle",

        Callback = function()

            local LocalPlayer = game:GetService("Players").LocalPlayer
            local Character = LocalPlayer.Character
            local Vehicle = FindVehicle()

            if Vehicle then

                local DriveSeat = Vehicle:FindFirstChildOfClass("Seat")

                if DriveSeat then

                    DriveSeat:Sit(Character.Humanoid)

                end

            end

        end
    })

    Context:AddButton({
        Text = "Bring Vehicle",

        Callback = function()

            local TeleportService = game:GetService("TeleportService")
            local LocalPlayer = game:GetService("Players").LocalPlayer

            TeleportService:TeleportToPlaceInstance(
                game.PlaceId,
                game.JobId,
                LocalPlayer
            )

        end
    })

    Context:AddTitle({
        Text = "Vehicle Settings"
    })

    

end