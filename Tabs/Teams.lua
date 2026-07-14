local TeamTab = {}

function TeamTab:Build(Context)

    Context:AddTitle({
        Text = "HARS"
    })

    Context:AddTitle({
        Text = "INFO: Wait until the vehicle is on your bed then press 'Fling Vehicle' to fling them!"
    })

    Context:AddButton({
        Text = "Fling Vehicle",

        Callback = function()

            if Plr.Team.Name == "HARS" then

                local Event = game:GetService("ReplicatedStorage").Zp3["d86a1e0e-1163-44cf-8647-c2c5fecf62c9"]
                Event:FireServer(true)

                local Event = game:GetService("ReplicatedStorage").Zp3["6b0e798f-3ca7-46dd-8dd6-b6037b63cf48"]
                Event:FireServer()

                local Event = game:GetService("ReplicatedStorage").Zp3["d86a1e0e-1163-44cf-8647-c2c5fecf62c9"]
                Event:FireServer(false)

                task.wait(0.15)

                local PlrVehicle = FindPlrVehicle()

                if PlrVehicle then

                    local Plate = PlrVehicle:FindFirstChild("Plate",true)
                    local DriveSeat = PlrVehicle:FindFirstChildOfClass("Seat")

                    if Plate and DriveSeat then

                        local stop = false

                        task.delay(1,function()

                            stop = true

                        end)

                        DriveSeat.Anchored = true

                        repeat RunService.Heartbeat:Wait()

                            Plate.Velocity = Vector3.new(math.random(-10000,10000),100000,math.random(-10000,10000))

                        until stop == true

                        Plate.Velocity = Vector3.new(0,0,0)
                        task.wait(0.25)
                        DriveSeat.Anchored = false

                    end

                end

            else

                -- warn("[EREBUS] You aren't on the HARS team!")

            end

        end
    })

end

function TeamTab:Destroy()

end

return TeamTab