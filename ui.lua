return function()
    -- Create main UI container
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DarkUI"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Dark theme colors
    local colors = {
        background = Color3.fromRGB(30, 30, 30),
        sidebar = Color3.fromRGB(45, 45, 45),
        border = Color3.fromRGB(70, 70, 70),
        text = Color3.fromRGB(255, 255, 255),
        button = Color3.fromRGB(60, 60, 60),
        buttonHover = Color3.fromRGB(80, 80, 80)
    }
    
    -- Create sidebar panel
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 200, 1, 0)
    sidebar.BackgroundColor3 = colors.sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = screenGui
    
    -- Create tabs container
    local tabsContainer = Instance.new("ScrollingFrame")
    tabsContainer.Name = "TabsContainer"
    tabsContainer.Size = UDim2.new(1, 0, 1, 0)
    tabsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabsContainer.ScrollBarThickness = 0
    tabsContainer.BackgroundColor3 = colors.sidebar
    tabsContainer.BorderSizePixel = 0
    tabsContainer.Parent = sidebar
    
    -- Tab data structure
    local tabs = {
        {name="Home", icon="🏠"},
        {name="Player", icon="👤"},
        {name="Vehicle", icon="🚗"},
        {name="Visuals", icon="🎨"}
    }
    
    -- Create tabs dynamically
    for i, tab in ipairs(tabs) do
        local button = Instance.new("TextButton")
        button.Name = tab.name
        button.Text = tab.icon .. " " .. tab.name
        button.Size = UDim2.new(1, -10, 0, 40)
        button.Position = UDim2.new(0, 5, 0, (i-1)*45 + 10)
        button.BackgroundColor3 = colors.sidebar
        button.TextColor3 = colors.text
        button.Font = Enum.Font.SourceSansBold
        button.TextSize = 14
        button.BackgroundTransparency = 0.3
        button.BorderSizePixel = 0
        
        -- Hover effect
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = colors.buttonHover
            button.BackgroundTransparency = 0.2
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = colors.sidebar
            button.BackgroundTransparency = 0.3
        end)
        
        -- Tab selection handler
        button.MouseButton1Click:Connect(function()
            -- Reset all buttons
            for _, child in ipairs(tabsContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = colors.sidebar
                    child.BackgroundTransparency = 0.3
                end
            end
            
            -- Highlight selected
            button.BackgroundColor3 = colors.button
            button.BackgroundTransparency = 0.1
            
            -- Show corresponding tab content
            showTabContent(tab.name)
        end)
        
        button.Parent = tabsContainer
    end
    
    -- Content area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -200, 1, 0)
    contentArea.Position = UDim2.new(0, 200, 0, 0)
    contentArea.BackgroundColor3 = colors.background
    contentArea.BorderSizePixel = 0
    contentArea.Parent = screenGui
    
    -- Create tab content containers
    local tabContents = {}
    for _, tab in ipairs(tabs) do
        local frame = Instance.new("Frame")
        frame.Name = tab.name .. "Content"
        frame.Visible = false
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = colors.background
        frame.BorderSizePixel = 0
        frame.Parent = contentArea
        
        tabContents[tab.name] = frame
    end
    
    -- Initial tab selection
    tabsContainer:FindFirstChild("Home").MouseButton1Click:Fire()
    
    -- Function to show tab content
    function showTabContent(tabName)
        for name, frame in pairs(tabContents) do
            frame.Visible = (name == tabName)
        end
        
        -- Load content based on tab
        if tabName == "Home" then
            createHomeContent(tabContents[tabName])
        elseif tabName == "Player" then
            createPlayerContent(tabContents[tabName])
        elseif tabName == "Vehicle" then
            createVehicleContent(tabContents[tabName])
        elseif tabName == "Visuals" then
            createVisualsContent(tabContents[tabName])
        end
    end
    
    -- Tab content creation functions
    function createHomeContent(container)
        container:ClearAllChildren()
        local label = Instance.new("TextLabel")
        label.Text = "Welcome to the Dark UI Theme!"
        label.Size = UDim2.new(0.8, 0, 0.1, 0)
        label.Position = UDim2.new(0.1, 0, 0.1, 0)
        label.BackgroundColor3 = colors.sidebar
        label.BorderSizePixel = 0
        label.TextColor3 = colors.text
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 18
        label.Parent = container
    end
    
    function createPlayerContent(container)
        container:ClearAllChildren()
        -- Player controls would go here
    end
    
    function createVehicleContent(container)
        container:ClearAllChildren()
        -- Vehicle controls would go here
    end
    
    function createVisualsContent(container)
        container:ClearAllChildren()
        -- Visual settings would go here
    end
    
    return screenGui
end
