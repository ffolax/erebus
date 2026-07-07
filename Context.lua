local Context = {}

Context.State = {
    Tabs = {},
    ActiveTab = nil,
    UI = nil
}

function Context:SetParent(parent)
    self.Parent = parent
end

function Context:Init()
    print("[EREBUS] Initialized")
end

function Context:RegisterTab(name, data)
    self.State.Tabs[name] = data
end

function Context:SetActiveTab(name)

    self.State.ActiveTab = name

    local Tab = self.State.Tabs[name]

    if Tab and Tab.Build then
        Tab.Build()
    end

    if Tab and Tab.OnOpen then
        Tab.OnOpen()
    end

end

function Context:CreateContainer(height)

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1,-20,0,height)
    Container.BackgroundColor3 = Color3.fromRGB(22,22,32)
    Container.BorderSizePixel = 0
    Container.Parent = self.Parent

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0,5)
    Layout.Parent = Container

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0,8)
    Corner.Parent = Container

    return Container

end

function Context:AddTitle(options)

    local Container = self:CreateContainer(40)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.fromScale(0.95,1)
    Label.Position = UDim2.fromScale(0.05,0)
    Label.BackgroundTransparency = 1
    Label.Text = options.Text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 20
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextColor3 = options.Color3 or Color3.fromRGB(255,255,255)
    Label.Parent = Container

end

function Context:AddButton(options)

    local Container = options.Container or self:CreateContainer(42)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,-10,1,-10)
    Button.Position = UDim2.new(0,5,0,5)

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0,8)
    Corner.Parent = Button

    Button.Text = options.Text
    Button.Parent = Container

    if options.Callback then
        Button.MouseButton1Click:Connect(function()
            options.Callback(Button)
        end)
    end

    return Button

end

function Context:AddToggle(options)

    local Enabled = options.Default or false

    local Button = self:AddButton({
        Text = options.Text,
        Container = options.Container
    })

    Button.MouseButton1Click:Connect(function()

        Enabled = not Enabled

        if Enabled then
            Button.Text = options.Text .. " ON"
        else
            Button.Text = options.Text .. " OFF"
        end

        if options.Callback then
            options.Callback(Enabled)
        end

    end)

    return Button

end

function Context:AddSlider(options)

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1,-20,0,55)
    Frame.Parent = options.Container or self.Parent

    -- build slider here

    return Frame

end

return Context
