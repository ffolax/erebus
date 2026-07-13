local Misc = {}
local Plr = game:GetService("Players").LocalPlayer
local Vehicles = game.workspace:FindFirstChild("Vehicles")

function FindPlrVehicle()

    local car = Vehicles:FindFirstChild(tostring(Plr))

    if car then

        return car

    end

end

function Misc:Build(Context)

    Context:AddTitle({
        Text = "Vehicle Morph"
    })

    local SelectedMorph

    Context:AddButton({
        Text = "Morph (CLIENT-SIDED)",

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

function Misc:Destroy()

end

return Misc