local UserInputService = game:GetService("UserInputService")

local Controls = {}

Controls.Bindings = {}
Controls.Connections = {}
Controls.Context = nil
Controls.Held = {}

local function IsInputMatch(Input, Binding)

    local Value = Binding.Keybind:GetValue()

    if not Value then
        return false
    end

    if Value.EnumType == Enum.KeyCode then
        return Input.KeyCode == Value
    end

    if Value.EnumType == Enum.UserInputType then
        return Input.UserInputType == Value
    end

    return false

end

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

function Controls:Clear()

    table.clear(self.Bindings)

end

function Controls:Init(Context)

    self.Context = Context

    if self.Connections.InputBegan then
        return
    end

    self.Connections.InputBegan =
        UserInputService.InputBegan:Connect(function(Input, GameProcessed)

            if GameProcessed then
                return
            end

            if Input.UserInputType == Enum.UserInputType.Keyboard then
                Controls.Held[Input.KeyCode] = true
            end

            for _, Binding in ipairs(self.Bindings) do
                if IsInputMatch(Input, Binding) then
                    Binding.Callback(true)
                end
            end

        end)

    self.Connections.InputEnded =
        UserInputService.InputEnded:Connect(function(Input)

            if Input.UserInputType == Enum.UserInputType.Keyboard then
                Controls.Held[Input.KeyCode] = nil
            end

            for _, Binding in ipairs(self.Bindings) do
                if IsInputMatch(Input, Binding) then
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

    self.Context = nil

end

return Controls