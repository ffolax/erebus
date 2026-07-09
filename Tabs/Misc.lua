local Plr = game:GetService("Players").LocalPlayer

function FindPlrVehicle()

    local car = Vehicles:FindFirstChild(tostring(Plr))

    if car then

        return car

    end

end

return function(Context)

    Context:AddTitle({
        Text = "Troll"
    })

    local Spinning = false

    Context:AddToggle({

        Text = "Noclip through vehicles",

        Callback = function(State)

            if State then

                for _,v in pairs(game.workspace:GetDescendants()) do

                    if v:IsDescendantOf(game.workspace.Vehicles) then

                        local Vehicle = FindPlrVehicle()

                        if Vehicle then

                            if v:IsDescendantOf(Vehicle) then continue end

                            if v:IsA("BasePart") then

                                if v.CanCollide == false then continue end

                                v.CanCollide = false

                            end

                       end

                   end

                end

            else

                for _,v in pairs(game.workspace:GetDescendants()) do

                    if v:IsDescendantOf(game.workspace.Vehicles) then

                        local Vehicle = FindPlrVehicle()

                        if Vehicle then

                            if v:IsDescendantOf(Vehicle) then continue end

                            if v:IsA("BasePart") then

                                if v.CanCollide == true then continue end

                                v.CanCollide = true

                            end

                       end

                   end

                end

            end

        end

    })

end