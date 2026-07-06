return function(Context, UI)

    UI:CreateTab("Main", function(content)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 40)
        label.BackgroundTransparency = 1
        label.Text = "Welcome to Main Tab"
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.Font = Enum.Font.Gotham
        label.TextSize = 16
        label.Parent = content

    end)

    UI:CreateTab("Settings", function(content)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 40)
        label.BackgroundTransparency = 1
        label.Text = "Settings Tab"
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.Font = Enum.Font.Gotham
        label.TextSize = 16
        label.Parent = content

    end)

end
