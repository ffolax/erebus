return function(Context)

    local function FindVehicle()

        local p = game:GetService("Players").LocalPlayer
        local Vehicles = game.workspace:FindFirstChild("Vehicles")

        if Vehicles and Vehicles:FindFirstChild(p.Name) then
            
            return Vehicles:FindFirstChild(p.Name)

        end

    end

    Context:AddViewport({
        Container = Container,
        Model = FindVehicle()
    })

end