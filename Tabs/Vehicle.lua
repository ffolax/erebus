local function FindVehicle()

    local Player = game:GetService("Players").LocalPlayer
    local Vehicles = workspace:FindFirstChild("Vehicles")

    if Vehicles then
        return Vehicles:FindFirstChild(Player.Name)
    end

end

return function(Context)

    local Container = Context:CreateContainer(250)

    Context:AddViewport({
        Container = Container,
        Model = FindVehicle
    })

end