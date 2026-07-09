local Plr = game:GetService("Players").LocalPlayer
local Vehicles = game.workspace:FindFirstChild("Vehicles")

function FindPlrVehicle()

    local car = Vehicles:FindFirstChild(tostring(Plr))

    if car then

        return car

    end

end

return function(Context)

    Context:AddTitle({
        Text = "Morph"
    })

    local SelectedMorph

    Context:AddButton({
        Text = "Vehicle Morph",

        Callback = function()

            if SelectedMorph then

                local SourceVehicle = Vehicles:FindFirstChild(tostring(SelectedMorph))
                if not SourceVehicle then return end

                local MyVehicle = FindPlrVehicle()
                if not MyVehicle then return end

                local SourceBody = SourceVehicle:FindFirstChild("Body")
                if not SourceBody then
                    warn("Source vehicle has no Body model.")
                    return
                end

                local OldBody = MyVehicle.Body

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

                if NewBody.PrimaryPart and MyVehicle.PrimaryPart then
                    NewBody:PivotTo(MyVehicle.PrimaryPart.CFrame * CFrame.new(2,1.5,2))
                end

                local MainBody = NewBody:FindFirstChild("Body", true)

                if not MainBody or not MainBody:IsA("BasePart") then
                    warn("Couldn't find main Body meshpart.")
                    return
                end

                for _, Part in ipairs(NewBody:GetDescendants()) do
                    if Part:IsA("BasePart") and Part ~= MainBody then

                        Part.Anchored = false

                        local Weld = Instance.new("WeldConstraint")
                        Weld.Part0 = MainBody
                        Weld.Part1 = Part
                        Weld.Parent = MainBody

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

        end
    })

    local VehicleTable = {}

    for _,v in pairs(Vehicles:GetChildren()) do

        if v:FindFirstChild("DriveSeat") and v.DriveSeat:GetAttribute("Rent") == true then

            v.Name = "E-Scooter"

        end

        table.insert(VehicleTable,v.Name)

    end


    Context:AddDropdown({

        Text = "Morph Into",
        Items = VehicleTable or {},

        Callback = function(Value)
            SelectedMorph = Value
        end

    })

    Context:AddTitle({
        Text = "Troll"
    })

    local Spinning = false

    Context:AddToggle({

        Text = "Noclip through vehicles",

        Callback = function(State)

            local Vehicle = FindPlrVehicle()

            if not Vehicle then
                return
            end

            for _, v in ipairs(Vehicles:GetDescendants()) do

                if v:IsDescendantOf(Vehicles) then

                    if Vehicle then

                        if v:IsDescendantOf(Vehicle) then continue end

                        if v:IsA("BasePart") then

                            v.CanCollide = not State

                        end

                    end

                end

            end

        end

    })

end