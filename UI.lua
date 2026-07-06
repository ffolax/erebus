local TweenService = game:GetService("TweenService")

local UI = {}

function UI:Init(Context)
    self.Context = Context

    -- ScreenGui
    local screen = Instance.new("ScreenGui")
    screen.Name = "ModernHub"
    screen.ResetOnSpawn = false
    screen.Parent = game.CoreGui

    -- Main container
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 650, 0, 420)
    main.Position = UDim2.new(0.5, -325, 0.5, -210)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    main.BorderSizePixel = 0
    main.Parent = screen

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = main

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 160, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main

    local sideCorner = Instance.new("UICorner")
    sideCorner.CornerRadius = UDim.new(0, 10)
    sideCorner.Parent = sidebar

    -- Content area
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -160, 1, 0)
    content.Position = UDim2.new(0, 160, 0, 0)
    content.BackgroundTransparency = 1
    content.Parent = main

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Modern Hub"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 18
    title.Parent = sidebar

    -- Tab container
    local tabHolder = Instance.new("Frame")
    tabHolder.Size = UDim2.new(1, 0, 1, -40)
    tabHolder.Position = UDim2.new(0, 0, 0, 40)
    tabHolder.BackgroundTransparency = 1
    tabHolder.Parent = sidebar

    self.Screen = screen
    self.Main = main
    self.Sidebar = sidebar
    self.Content = content
    self.TabHolder = tabHolder

    self.Tabs = {}
    self.ActiveTab = nil

    print("[UI] Modern UI Initialized")
end

function UI:CreateTab(name, onClick)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 38)
    button.Position = UDim2.new(0, 5, 0, #self.Tabs * 42)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    button.Text = name
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.BorderSizePixel = 0
    button.Parent = self.TabHolder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    -- hover effect
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        }):Play()
    end)

    button.MouseLeave:Connect(function()
        if self.ActiveTab ~= button then
            TweenService:Create(button, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            }):Play()
        end
    end)

    button.MouseButton1Click:Connect(function()
        self:SetActiveTab(button)

        if onClick then
            self:ClearContent()
            onClick(self.Content)
        end
    end)

    self.Tabs[name] = button

    return button
end

function UI:SetActiveTab(button)
    if self.ActiveTab then
        TweenService:Create(self.ActiveTab, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        }):Play()
    end

    self.ActiveTab = button

    TweenService:Create(button, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    }):Play()
end

function UI:ClearContent()
    for _, v in pairs(self.Content:GetChildren()) do
        if v:IsA("GuiObject") then
            v:Destroy()
        end
    end
end
