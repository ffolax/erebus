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

        Text = "Spin Vehicle",

        Callback = function(State)

            Spinning = State

            if not State then
                return
            end

            local Vehicle = FindPlrVehicle()

            if Vehicle then

                local Root = Vehicle:FindFirstChildOfClass("Seat")

                local Attachment = Instance.new("Attachment")
                Attachment.Parent = Root

                local Spin = Instance.new("AngularVelocity")
                Spin.Attachment0 = Attachment
                Spin.AngularVelocity = Vector3.new(0, 50, 0)
                Spin.MaxTorque = math.huge
                Spin.RelativeTo = Enum.ActuatorRelativeTo.World
                Spin.Parent = Root

            end

        end

    })

end