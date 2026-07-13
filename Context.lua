local Context = {}

Context.NextLayoutOrder = 1

Context.Values = {}

Context.ActiveControls = {}
Context.TabConnections = {}
Context.PersistentConnections = {}
Context.TabObjects = {}

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

function Context:RegisterControl(Control)
    table.insert(self.ActiveControls, Control)
    return Control
end

function Context:RegisterConnection(Connection)
    table.insert(self.TabConnections, Connection)
    return Connection
end

function Context:RegisterPersistentConnection(Connection)
    table.insert(self.PersistentConnections, Connection)
    return Connection
end

function Context:RegisterObject(Object)
    table.insert(self.TabObjects, Object)
    return Object
end

function Context:ClearTab()

    -- Controls
    for _,Control in ipairs(self.ActiveControls) do
        pcall(function()
            if Control.Destroy then
                Control:Destroy()
            end
        end)
    end

    table.clear(self.ActiveControls)

    -- Connections
    for _,Connection in ipairs(self.TabConnections) do
        pcall(function()
            Connection:Disconnect()
        end)
    end

    table.clear(self.TabConnections)

    -- Objects
    for _,Object in ipairs(self.TabObjects) do

        pcall(function()

            if typeof(Object) == "Instance" then
                Object:Destroy()

            elseif Object.Remove then
                Object:Remove()

            elseif Object.Destroy then
                Object:Destroy()
            end

        end)

    end

    table.clear(self.TabObjects)

end

function Context:SetActiveTab(Name)

    if self.State.ActiveTab then

        local Previous = self.State.Tabs[self.State.ActiveTab]

        if Previous and Previous.Destroy then
            Previous:Destroy()
        end

        self:ClearTab()

    end

    self.State.ActiveTab = Name

    local Tab = self.State.Tabs[Name]

    if Tab and Tab.Build then
        Tab:Build(self)
    end

    if Tab and Tab.OnOpen then
        Tab:OnOpen(self)
    end

end

function Context:CreateControl(options)

    local Context = self

    local Control = {}

    Control.Flag = options.Flag or options.Id or options.Text

    if Context.Values[Control.Flag] == nil then
        Context.Values[Control.Flag] = options.Default
    end

    Control.Value = Context.Values[Control.Flag]

    Control.Container = options.Container or Context:CreateContainer(42)
    Control.Container.UIListLayout.VerticalAlignment =
        Enum.VerticalAlignment.Center

    Control.Button = Instance.new("TextButton")
    Control.Button.Size = UDim2.new(1,-10,1,-10)
    Control.Button.Position = UDim2.new(0,5,0,5)
    Control.Button.BackgroundColor3 = Color3.fromRGB(120,60,220)
    Control.Button.Text = options.Text or ""
    Control.Button.TextScaled = true
    Control.Button.Font = Enum.Font.GothamBold
    Control.Button.TextColor3 = Color3.new(1,1,1)
    Control.Button.Parent = Control.Container

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0,8)
    Corner.Parent = Control.Button

    function Control:SetValue(Value)

        self.Value = Value
        Context.Values[self.Flag] = Value

    end

    function Control:GetValue()

        return self.Value

    end

    function Control:SetText(Text)

        self.Button.Text = Text

    end

    function Control:Show()

        self.Container.Visible = true

    end

    function Control:Hide()

        self.Container.Visible = false

    end

    function Control:Destroy()

        self.Container:Destroy()

    end

    Context:RegisterControl(Control)

    return Control

end

function Context:CreateContainer(height)

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1,-20,0,height)
    Container.BackgroundColor3 = Color3.fromRGB(22,22,32)
    Container.BorderSizePixel = 0
    Container.Parent = self.Parent

    Container.LayoutOrder = self.NextLayoutOrder
    self.NextLayoutOrder += 1

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

function Context:CreateSpacer()

    local Spacer = Instance.new("Frame")
    Spacer.Size = UDim2.new(1,-20,0,0)
    Spacer.BackgroundTransparency = 1
    Spacer.BorderSizePixel = 0
    Spacer.Parent = self.Parent

    Spacer.LayoutOrder = self.NextLayoutOrder
    self.NextLayoutOrder += 1

    return Spacer

end

function Context:AddTitle(options)

    local Container = self:CreateContainer(40)

    Container.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.fromScale(0.95,0.75)
    Label.Position = UDim2.fromScale(0.2,0)
    Label.BackgroundTransparency = 1
    Label.Text = options.Text
    Label.Font = Enum.Font.GothamBold
    Label.TextScaled = true
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

                if typeof(Stat.Getter) == "function" then

                    local Success, Result = pcall(Stat.Getter)

                    if Success then
                        Stat.Label.Text = Stat.Name .. ": " .. tostring(Result)
                    else
                        Stat.Label.Text = Stat.Name .. ": Error"
                        warn("[STAT ERROR]", Stat.Name, Result)
                    end

                else

                    warn("[EREBUS] Invalid getter for:", Stat.Name)
                    Stat.Label.Text = Stat.Name .. ": Error"

                end

            end

            task.wait(0.25)

        end

    end)

    return Container

end

function Context:AddButton(options)

    local Button = self:CreateControl(options)

    function Button:Press()

        if options.Callback then
            options.Callback(self.Button)
        end

    end

    Button.Button.MouseButton1Click:Connect(function()
        Button:Press()
    end)

    return Button

end

function Context:AddToggle(options)

    local Toggle = self:CreateControl(options)

    function Toggle:SetValue(Value)

        self.Value = Value
        Context.Values[self.Flag] = Value

        self.Button.Text =
            options.Text ..
            (Value and ": On" or ": Off")

        if options.Callback then
            options.Callback(Value)
        end

    end

    function Toggle:Toggle()

        self:SetValue(not self.Value)

    end

    function Toggle:GetValue()
        return Enabled
    end

    Toggle.Button.MouseButton1Click:Connect(function()
        Toggle:Toggle()
    end)

    Toggle:SetValue(Toggle.Value)

    return Toggle

end

function Context:AddDropdown(options)

    local TweenService = game:GetService("TweenService")

    local Items = options.Items or {}
    local Open = false

    local Dropdown = self:CreateControl(options)
    local Context = self

    local Button = Dropdown.Button
    local MainContainer = Dropdown.Container

    Button.Text = ""

    Dropdown.Value = Dropdown.Value or Items[1] or "None"

    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1,-35,1,0)
    Label.Position = UDim2.new(0,10,0,0)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14
    Label.TextColor3 = Color3.new(1,1,1)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Button

    local Arrow = Instance.new("ImageLabel")
    Arrow.BackgroundTransparency = 1
    Arrow.Size = UDim2.new(0,20,1,0)
    Arrow.Position = UDim2.new(1,-25,0,0)
    Arrow.Image = Context.Services.Icons.Controls.Dropdown
    Arrow.Parent = Button

    local Spacer = self:CreateSpacer()

    Spacer.LayoutOrder = MainContainer.LayoutOrder + 1

    local SpacerLayout = Instance.new("UIListLayout")
    SpacerLayout.Padding = UDim.new(0,5)
    SpacerLayout.Parent = Spacer

    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1,-20,0,0)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(22,22,32)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.Visible = false
    DropdownFrame.ClipsDescendants = true
    DropdownFrame.Parent = Spacer

    local DropCorner = Instance.new("UICorner")
    DropCorner.CornerRadius = UDim.new(0,8)
    DropCorner.Parent = DropdownFrame

    local DropdownLayout = Instance.new("UIListLayout")
    DropdownLayout.Padding = UDim.new(0,5)
    DropdownLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    DropdownLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    DropdownLayout.Parent = DropdownFrame

    DropdownFrame.LayoutOrder = MainContainer.LayoutOrder + 1

    function Dropdown:Open()

        Open = true

        local Height = DropdownLayout.AbsoluteContentSize.Y + 6

        DropdownFrame.Visible = true

        TweenService:Create(
            Arrow,
            TweenInfo.new(.15),
            {Rotation = 180}
        ):Play()

        TweenService:Create(
            Spacer,
            TweenInfo.new(.15),
            {
                Size = UDim2.new(1,-20,0,Height)
            }
        ):Play()

        TweenService:Create(
            DropdownFrame,
            TweenInfo.new(.15),
            {
                Size = UDim2.new(1,0,0,Height)
            }
        ):Play()

    end

    function Dropdown:Close()

        Open = false

        TweenService:Create(
            Arrow,
            TweenInfo.new(
                .15,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Rotation = 0
            }
        ):Play()

        TweenService:Create(
            Spacer,
            TweenInfo.new(
                .15,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Size = UDim2.new(
                    1,
                    -20,
                    0,
                    0
                )
            }
        ):Play()

        TweenService:Create(
            DropdownFrame,
            TweenInfo.new(
                .15,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Size = UDim2.new(
                    1,
                    0,
                    0,
                    0
                )
            }
        ):Play()

        task.delay(.15, function()

            if not Open then
                DropdownFrame.Visible = false
            end

        end)

    end

    function Dropdown:SetValue(Value)

        self.Value = Value
        Context.Values[self.Flag] = Value

        Label.Text = string.format(
            "%s: %s",
            options.Text or "Dropdown",
            tostring(Value)
        )

        if options.Callback then
            options.Callback(Value)
        end

    end

    for _, Item in ipairs(Items) do

        local Option = Instance.new("TextButton")
        Option.Size = UDim2.new(1,-10,0,28)
        Option.Position = UDim2.new(0,5,0,0)
        Option.BackgroundColor3 = Color3.fromRGB(32,32,42)
        Option.TextColor3 = Color3.new(1,1,1)
        Option.Font = Enum.Font.Gotham
        Option.TextSize = 14
        Option.Text = tostring(Item)
        Option.Parent = DropdownFrame

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0,6)
        Corner.Parent = Option

        Option.MouseButton1Click:Connect(function()

            Dropdown:SetValue(Item)
            Dropdown:Close()

        end)

    end

    Dropdown:SetValue(Dropdown.Value)

    Button.MouseButton1Click:Connect(function()

        if Open then
            Dropdown:Close()
        else
            Dropdown:Open()
        end

    end)

    return Dropdown

end

function Context:AddSlider(options)

    local UserInputService = game:GetService("UserInputService")

    local Id = options.Id or options.Text

    local Slider = self:CreateControl(options)

    Slider.Button:Destroy()
    Slider.Button = nil

    Slider.Min = options.Min or 0
    Slider.Max = options.Max or 100

    if self.Values[Id] == nil then
        self.Values[Id] = options.Default or Slider.Min
    end

    Slider.Value = self.Values[Id]

    local Dragging = false

    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1,-20,0,18)
    Label.Position = UDim2.new(0,10,0,3)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14
    Label.TextColor3 = Color3.new(1,1,1)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Slider.Container

    ---------------------------------------------------
    -- Bar
    ---------------------------------------------------

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1,-20,0,6)
    Bar.Position = UDim2.new(0,10,1,-14)
    Bar.BackgroundColor3 = Color3.fromRGB(45,45,55)
    Bar.BorderSizePixel = 0
    Bar.Parent = Slider.Container

    Instance.new("UICorner",Bar).CornerRadius = UDim.new(1,0)

    ---------------------------------------------------
    -- Fill
    ---------------------------------------------------

    local Fill = Instance.new("Frame")
    Fill.BackgroundColor3 = Color3.fromRGB(120,60,220)
    Fill.Size = UDim2.fromScale(0,1)
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar

    Instance.new("UICorner",Fill).CornerRadius = UDim.new(1,0)

    ---------------------------------------------------
    -- Knob
    ---------------------------------------------------

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.fromOffset(12,12)
    Knob.AnchorPoint = Vector2.new(.5,.5)
    Knob.Position = UDim2.fromScale(0,.5)
    Knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Knob.Parent = Bar

    Instance.new("UICorner",Knob).CornerRadius = UDim.new(1,0)

    ---------------------------------------------------
    -- Update
    ---------------------------------------------------

    local Context = self

    function Slider:SetValue(Value)

        Value = math.clamp(Value,Slider.Min,Slider.Max)

        Slider.Value = Value
        Context.Values[Id] = Value

        local Alpha =
            (Value-Slider.Min) /
            (Slider.Max-Slider.Min)

        Fill.Size = UDim2.fromScale(Alpha,1)
        Knob.Position = UDim2.fromScale(Alpha,.5)

        Label.Text = string.format(
            "%s: %s",
            options.Text,
            math.floor(Value)
        )

        if options.Callback then
            options.Callback(Value)
        end

    end

    function Slider:GetValue()
        return Slider.Value
    end

    function Slider:Destroy()
        Slider.Container:Destroy()
    end

    ---------------------------------------------------
    -- Drag
    ---------------------------------------------------

    local function UpdateSlider(Input)

        local X =
            math.clamp(
                Input.Position.X-Bar.AbsolutePosition.X,
                0,
                Bar.AbsoluteSize.X
            )

        local Alpha = X/Bar.AbsoluteSize.X

        Slider:SetValue(
            Slider.Min +
            (Slider.Max-Slider.Min)*Alpha
        )

    end

    Bar.InputBegan:Connect(function(Input)

        if Input.UserInputType == Enum.UserInputType.MouseButton1 then

            Dragging = true
            UpdateSlider(Input)

        end

    end)

    UserInputService.InputChanged:Connect(function(Input)

        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then

            UpdateSlider(Input)

        end

    end)

    UserInputService.InputEnded:Connect(function(Input)

        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end

    end)

    Slider:SetValue(Slider.Value)

    return Slider

end

function Context:AddKeybind(options)

    local UserInputService = game:GetService("UserInputService")

    local Keybind = self:CreateControl(options)

    Keybind.Button:Destroy()
    Keybind.Button = nil
    Keybind.Container.UIListLayout.FillDirection = Enum.FillDirection.Horizontal

    Keybind:SetValue(
        Keybind:GetValue() or Enum.KeyCode.Unknown
    )

    local Binding = false

    ---------------------------------------------------
    -- Name
    ---------------------------------------------------

    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1,-95,1,0)
    Label.Position = UDim2.new(0,10,0,0)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14
    Label.TextColor3 = Color3.new(1,1,1)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Text = options.Text
    Label.Parent = Keybind.Container

    ---------------------------------------------------
    -- Bind Button
    ---------------------------------------------------

    local BindButton = Instance.new("TextButton")
    BindButton.AnchorPoint = Vector2.new(1,.5)
    BindButton.Position = UDim2.new(1,-10,.5,0)
    BindButton.Size = UDim2.new(0,75,0,24)
    BindButton.BackgroundColor3 = Color3.fromRGB(35,35,45)
    BindButton.Font = Enum.Font.GothamBold
    BindButton.TextSize = 13
    BindButton.TextColor3 = Color3.new(1,1,1)
    BindButton.Parent = Keybind.Container

    Instance.new("UICorner", BindButton).CornerRadius = UDim.new(0,6)

    ---------------------------------------------------
    -- Override SetValue
    ---------------------------------------------------

    local BaseSetValue = Keybind.SetValue

    function Keybind:SetValue(Value)

        BaseSetValue(self, Value)

        BindButton.Text = Value.Name

        if options.OnChanged then
            options.OnChanged(Value)
        end

    end

    ---------------------------------------------------
    -- Rebinding
    ---------------------------------------------------

    BindButton.MouseButton1Click:Connect(function()

        if Binding then
            return
        end

        Binding = true
        BindButton.Text = "..."

        local Connection

        Connection = UserInputService.InputBegan:Connect(function(Input, GP)

            if GP then
                return
            end

            if Input.UserInputType == Enum.UserInputType.Keyboard then

                Connection:Disconnect()
                Binding = false

                Keybind:SetValue(Input.KeyCode)

            end

        end)

    end)

    Keybind:SetValue(Keybind:GetValue())

    return Keybind

end

function Context:AddViewport(options)

    local RunService = game:GetService("RunService")

    local Container = options.Container or self:CreateContainer(250)
    
    Container.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

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
            Vector3.new(Radius * 0.5, Radius * 0.45, Radius * 0.5),
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
