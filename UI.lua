local UI = {}

function UI:Init(Context)
    self.Context = Context

    local screen = Instance.new("ScreenGui")
    screen.Name = "HubUI"
    screen.Parent = game.CoreGui

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 500, 0, 350)
    main.Position = UDim2.new(0.5, -250, 0.5, -175)
    main.BackgroundColor3 = Color3.fromRGB(25,25,25)
    main.Parent = screen

    self.Screen = screen
    self.Main = main

    print("[UI] Loaded")
end

function UI:CreateButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.Text = text
    btn.Parent = self.Main

    btn.MouseButton1Click:Connect(callback)

    return btn
end

return UI
