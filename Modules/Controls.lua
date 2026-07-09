local UserInputService = game:GetService("UserInputService")

local Controls = {}

Controls.Binds = {}
Controls.Connections = {}

function Controls:Bind(Key, Callback)

    self.Binds[Key] = Callback

end

function Controls:Unbind(Key)

    self.Binds[Key] = nil

end

function Controls:Clear()

    table.clear(self.Binds)

end

function Controls:Init()

    if self.Connections.InputBegan then
        return
    end

    self.Connections.InputBegan =
        UserInputService.InputBegan:Connect(function(Input, GameProcessed)

            if GameProcessed then
                return
            end

            local Callback = self.Binds[Input.KeyCode] or self.Binds[Input.UserInputType]

            if Callback then
                Callback(true)
            end

        end)

    self.Connections.InputEnded =
        UserInputService.InputEnded:Connect(function(Input)

            local Callback = self.Binds[Input.KeyCode] or self.Binds[Input.UserInputType]

            if Callback then
                Callback(false)
            end

        end)

end

function Controls:Destroy()

    for _, Connection in pairs(self.Connections) do
        Connection:Disconnect()
    end

    table.clear(self.Connections)
    table.clear(self.Binds)

end

return Controls