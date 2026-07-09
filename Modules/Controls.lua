local UserInputService = game:GetService("UserInputService")

local Controls = {}

Controls.Bindings = {}
Controls.Connections = {}

function Controls:Bind(Keybind, Callback)

    local Binding = {
        Keybind = Keybind,
        Callback = Callback
    }

    table.insert(self.Bindings, Binding)

    function Binding:Disconnect()

        local Index = table.find(Controls.Bindings, self)

        if Index then
            table.remove(Controls.Bindings, Index)
        end

    end

    return Binding

end

function Controls:Unbind(Key)

    self.Binds[Key] = nil

end

function Controls:Clear()

    table.clear(self.Bindings)

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

            for _, Binding in ipairs(self.Bindings) do

                if Input.KeyCode == Binding.Keybind:GetValue() then
                    Binding.Callback(true)
                end

            end

        end)

    self.Connections.InputEnded =
        UserInputService.InputEnded:Connect(function(Input)

            for _, Binding in ipairs(self.Bindings) do

                if Input.KeyCode == Binding.Keybind:GetValue() then
                    Binding.Callback(false)
                end

            end

        end)

end

function Controls:Destroy()

    for _, Connection in pairs(self.Connections) do
        Connection:Disconnect()
    end

    table.clear(self.Connections)
    table.clear(self.Bindings)

end

return Controls