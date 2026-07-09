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

            end

        end
    })

end