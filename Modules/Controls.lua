local UserInputService = game:GetService("UserInputService")

local Controls = {}

Controls.Connections = {}

Controls:BindKey(options)

    if options.Type == Enum.UserInputType then

    elseif options.Type == Enum.KeyCode then

        local connection = UserInputService.InputBegan:Connect(function(input,gameprocessed)

            

        end)

        table.insert(Controls.Connections,connection)

    end

end

return Controls