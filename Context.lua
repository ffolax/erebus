local Context = {}

Context.NextLayoutOrder = 1

Context.Values = {}

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
    Label.Size = UDim2.fromScale(0.95,0.9)
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

    local Container = options.Container or self:CreateContainer(42)

    Container.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,-10,1,-10)
    Button.Position = UDim2.new(0,5,0,5)
    Button.BackgroundColor3 = Color3.fromRGB(120, 60, 220)
    Button.TextColor3 = Color3.fromRGB(255,255,255)
    Button.TextScaled = true
    Button.Font = Enum.Font.GothamBold

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

    local API = {}

    API.Button = Button
    API.Container = Container

    function API:Press()

        if options.Callback then
            options.Callback(Button)
        end

    end

    Button.MouseButton1Click:Connect(function()
        API:Press()
    end)

    return API

end

function Context:AddToggle(options)

    local Id = options.Id or options.Text

    if self.Values[Id] == nil then
        self.Values[Id] = options.Default or false
    end

    local Enabled = self.Values[Id]

    local Toggle = self:AddButton({
        Text = options.Text,
        Container = options.Container
    })

    local Button = Toggle.Button

    function Toggle:SetValue(Value)

        Enabled = Value
        self.Values[Id] = Value

        Button.Text = options.Text ..
            (Enabled and ": On" or ": Off")

        if options.Callback then
            options.Callback(Value)
        end

    end

    function Toggle:GetValue()
        return Enabled
    end

    function Toggle:Toggle()
        self:SetValue(not Enabled)
    end

    Button.MouseButton1Click:Connect(function()
        Toggle:Toggle()
    end)

    Toggle:SetValue(Enabled)

    return Toggle

end

function Context:AddDropdown(options)

    local TweenService = game:GetService("TweenService")

    local Items = options.Items or {}
    local Open = false

    local Id = options.Id or options.Text

    if self.Values[Id] == nil then
        self.Values[Id] = options.Default or Items[1] or "None"
    end

    local Selected = self.Values[Id]

    ---------------------------------------------------
    -- Main Container
    ---------------------------------------------------

    local MainContainer = options.Container or self:CreateContainer(42)

    MainContainer.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local Spacer = Instance.new("Frame")
    Spacer.BackgroundTransparency = 1
    Spacer.BorderSizePixel = 0
    Spacer.Size = UDim2.new(1,-20,0,0)
    Spacer.Parent = MainContainer.Parent

    Spacer.LayoutOrder = MainContainer.LayoutOrder + 1

    local SpacerLayout = Instance.new("UIListLayout")
    SpacerLayout.Padding = UDim.new(0,5)
    SpacerLayout.Parent = Spacer

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,-10,1,-10)
    Button.Position = UDim2.new(0,5,0,5)
    Button.BackgroundColor3 = Color3.fromRGB(120,60,220)
    Button.Text = ""
    Button.Parent = MainContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0,8)
    Corner.Parent = Button

    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1,-35,1,0)
    Label.Position = UDim2.new(0,10,0,0)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Text = string.format("%s: %s", options.Text or "Dropdown", Selected)
    Label.Parent = Button

    local Arrow = Instance.new("ImageLabel")
    Arrow.BackgroundTransparency = 1
    Arrow.Size = UDim2.new(0,20,1,0)
    Arrow.Position = UDim2.new(1,-25,0,0)
    Arrow.Image = Context.Services.Icons.Controls.Dropdown
    Arrow.Parent = Button

    ---------------------------------------------------
    -- Dropdown Container
    ---------------------------------------------------

    local Dropdown = Instance.new("Frame")
    Dropdown.Size = UDim2.new(1,-20,0,0)
    Dropdown.BackgroundColor3 = Color3.fromRGB(22,22,32)
    Dropdown.BorderSizePixel = 0
    Dropdown.Visible = false
    Dropdown.Parent = Spacer

    local DropCorner = Instance.new("UICorner")
    DropCorner.CornerRadius = UDim.new(0,8)
    DropCorner.Parent = Dropdown

    local DropdownLayout = Instance.new("UIListLayout")
    DropdownLayout.Padding = UDim.new(0,5)
    DropdownLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    DropdownLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Dropdown.ClipsDescendants = true
    DropdownLayout.Parent = Dropdown

    Dropdown.LayoutOrder = MainContainer.LayoutOrder + 1

    local function OpenDropdown()

        Open = true

        local Layout = Dropdown:FindFirstChildOfClass("UIListLayout")

        local Height = Layout.AbsoluteContentSize.Y + 6

        Dropdown.Visible = true

        TweenService:Create(
            Arrow,
            TweenInfo.new(
                .15,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),
            {
                Rotation = 180
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
                    Height
                )
            }
        ):Play()

        TweenService:Create(
            Dropdown,
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
                    Height
                )
            }
        ):Play()

    end

    local function CloseDropdown()

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
            Dropdown,
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
                Dropdown.Visible = false
            end

        end)

    end

    ---------------------------------------------------
    -- Options
    ---------------------------------------------------

    for _, Item in ipairs(Items) do

        local Option = Instance.new("TextButton")
        Option.Size = UDim2.new(1,-10,0,28)
        Option.Position = UDim2.new(0,5,0,0)
        Option.BackgroundColor3 = Color3.fromRGB(32,32,42)
        Option.TextColor3 = Color3.new(1,1,1)
        Option.Font = Enum.Font.Gotham
        Option.TextSize = 14
        Option.Text = tostring(Item)
        Option.Parent = Dropdown

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0,6)
        Corner.Parent = Option

        Option.MouseButton1Click:Connect(function()

            CloseDropdown()

            Label.Text = string.format(
                "%s: %s",
                options.Text or "Dropdown",
                tostring(Item)
            )

            Selected = Item
            self.Values[Id] = Item

            if options.Callback then
                options.Callback(Item)
            end

        end)

    end

    ---------------------------------------------------
    -- Toggle
    ---------------------------------------------------

    Button.MouseButton1Click:Connect(function()

        if Open then
            CloseDropdown()
        else
            OpenDropdown()
        end

    end)

    ---------------------------------------------------
    -- API
    ---------------------------------------------------

    return {

        GetValue = function()
            return Selected
        end,

        SetValue = function(Value)

            Selected = Value
            self.Values[Id] = Value

            Label.Text = string.format(
                "%s: %s",
                options.Text or "Dropdown",
                tostring(Value)
            )

            if options.Callback then
                options.Callback(Value)
            end

        end,

        Destroy = function()

            MainContainer:Destroy()
            Spacer:Destroy()

        end
    }

end

function Context:AddSlider(options)

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1,-20,0,55)
    Frame.Parent = options.Container or self.Parent

    -- build slider here

    return Frame

end

function Context:AddKeybind(options)

    local UserInputService = game:GetService("UserInputService")

    local Container = options.Container or self:CreateContainer(42)
    Container.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local Binding = false

    local Flag = options.Flag or options.Text

    if self.Values[Flag] == nil then
        self.Values[Flag] = options.Default or Enum.KeyCode.Unknown
    end

    local Key = self.Values[Flag]

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
    Label.Parent = Container

    ---------------------------------------------------
    -- Bind Button
    ---------------------------------------------------

    local BindButton = Instance.new("TextButton")
    BindButton.AnchorPoint = Vector2.new(1,0.5)
    BindButton.Position = UDim2.new(1,-10,.5,0)
    BindButton.Size = UDim2.new(0,75,0,24)
    BindButton.BackgroundColor3 = Color3.fromRGB(35,35,45)
    BindButton.Font = Enum.Font.GothamBold
    BindButton.TextSize = 13
    BindButton.TextColor3 = Color3.new(1,1,1)
    BindButton.Text = Key.Name
    BindButton.Parent = Container

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0,6)
    Corner.Parent = BindButton

    ---------------------------------------------------
    -- Rebind
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

                Key = Input.KeyCode
                self.Values[Flag] = Key

                BindButton.Text = Key.Name

                Binding = false
                Connection:Disconnect()

                if options.OnChanged then
                    options.OnChanged(Key)
                end

            end

        end)

    end)

    ---------------------------------------------------
    -- API
    ---------------------------------------------------

    return {

        GetValue = function()
            return Key
        end,

        SetValue = function(Value)

            Key = Value
            self.Values[Flag] = Value
            BindButton.Text = Value.Name

            if options.OnChanged then
                options.OnChanged(Value)
            end

        end,

        GetKey = function()
            return Key
        end

    }

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
