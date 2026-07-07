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
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
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
    Label.Position = UDim2.fromScale(0.2,0)
    Label.BackgroundTransparency = 1
    Label.Text = options.Text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 20
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextColor3 = options.Color3 or Color3.fromRGB(255,255,255)
    Label.Parent = Container

end

function Context:AddStatistics(options)

    local Container = options.Container or self:CreateContainer(140)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1,-10,0,24)
    Title.Position = UDim2.new(0,5,0,5)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Color3.fromRGB(255,255,255)
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Text = options.Title or "Statistics"
    Title.Parent = Container

    local Holder = Instance.new("Frame")
    Holder.BackgroundTransparency = 1
    Holder.Position = UDim2.new(0,5,0,32)
    Holder.Size = UDim2.new(1,-10,1,-37)
    Holder.Parent = Container

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0,4)
    Layout.Parent = Holder

    local Labels = {}

    for _, Stat in ipairs(options.Stats or {}) do

        local Name = Stat[1]
        local Getter = Stat[2]

        local Label = Instance.new("TextLabel")
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(1,0,0,18)
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Text = Name .. ": " .. tostring(Getter())
        Label.TextColor3 = Color3.fromRGB(255,255,255)
        Label.Parent = Holder

        Labels[#Labels + 1] = {
            Label = Label,
            Name = Name,
            Getter = Getter
        }

    end

    task.spawn(function()

        while Container.Parent do

            for _, Stat in ipairs(Labels) do

                Stat.Label.Text = Stat.Name .. ": " .. tostring(Stat.Getter())

            end

            task.wait(0.25)

        end

    end)

    return Container

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

function Context:AddViewport(options)

    local RunService = game:GetService("RunService")

    local Container = options.Container or self:CreateContainer(250)

    local Viewport = Instance.new("ViewportFrame")
    Viewport.Size = UDim2.new(1, -10, 1, -35)
    Viewport.Position = UDim2.new(0, 5, 0, 5)
    Viewport.BackgroundColor3 = Color3.fromRGB(18,18,24)
    Viewport.BorderSizePixel = 0
    Viewport.Parent = Container

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0,8)
    Corner.Parent = Viewport

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1,-10,0,22)
    NameLabel.Position = UDim2.new(0,8,1,-26)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextSize = 15
    NameLabel.TextColor3 = Color3.fromRGB(235,235,245)
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Text = "No Vehicle"
    NameLabel.Parent = Container

    local Camera = Instance.new("Camera")
    Camera.Parent = Viewport
    Viewport.CurrentCamera = Camera

    local CurrentVehicle
    local CurrentModel
    local CurrentRotation = 0

    local function LoadVehicle(Vehicle)

        if CurrentModel then
            CurrentModel:Destroy()
            CurrentModel = nil
        end

        CurrentVehicle = Vehicle

        if not Vehicle then
            NameLabel.Text = "No Vehicle"
            return
        end

        NameLabel.Text = tostring(Vehicle:GetAttribute("Config") or Vehicle.Name)

        CurrentModel = Vehicle:Clone()
        CurrentModel.Parent = Viewport

        if not CurrentModel.PrimaryPart then
            CurrentModel.PrimaryPart = CurrentModel:FindFirstChildWhichIsA("BasePart", true)
        end

        if CurrentModel.PrimaryPart then
            CurrentModel:PivotTo(CFrame.new())
        end

        CurrentRotation = 0

        local CF, Size = CurrentModel:GetBoundingBox()
        local Radius = math.max(Size.X, Size.Y, Size.Z)

        Camera.CFrame = CFrame.lookAt(
            Vector3.new(Radius * 0.75, Radius * 0.45, Radius * 0.75),
            Vector3.zero
        )

    end

    LoadVehicle(options.Model())

    RunService.RenderStepped:Connect(function(dt)

        local Vehicle = options.Model()

        if Vehicle ~= CurrentVehicle then
            LoadVehicle(Vehicle)
        end

        if CurrentModel then

            CurrentRotation += dt * 35

            CurrentModel:PivotTo(
                CFrame.Angles(
                    0,
                    math.rad(CurrentRotation),
                    0
                )
            )

        end

    end)

    return Viewport

end

return Context
