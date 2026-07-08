return function(Context)

    Context:AddTitle({
        Text = "Aimbot Settings"
    })

    local FOVCircle
    local renderConnection = nil
    local TargetPart

    Context:AddToggle({
        Text = "Aimbot",
        Callback = function(Enabled)
            if Enabled then
                FOVCircle = Drawing.new("Circle")
                FOVCircle.Visible = true
                FOVCircle.Filled = false
                FOVCircle.Thickness = 2
                FOVCircle.Radius = 150
                FOVCircle.NumSides = 64
                FOVCircle.Position = workspace.CurrentCamera.ViewportSize / 2

                -- Disconnect previous connection if exists
                if renderConnection then
                    renderConnection:Disconnect()
                end

                -- Create new connection
                renderConnection = game:GetService("RunService").RenderStepped:Connect(function()
                    FOVCircle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)
                    
                    local closestPlayer = nil
                    local minDistance = math.huge
                    
                    for _, player in ipairs(workspace:GetChildren()) do
                        if player:IsA("Model") and game.Players:GetPlayerFromCharacter(player) then
                            local humanoidRootPart = player:FindFirstChild("HumanoidRootPart")
                            if humanoidRootPart then
                                local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
                                if onScreen then
                                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - FOVCircle.Position).Magnitude
                                    if distance < minDistance and distance <= FOVCircle.Radius then
                                        minDistance = distance
                                        closestPlayer = player
                                    end
                                end
                            end
                        end
                    end
                    
                    if closestPlayer then

                        local target = closestPlayer:FindFirstChild(TargetPart) or closestPlayer:FindFirstChild("HumanoidRootPart")

                        print(TargetPart,target)

                        if target then
                            workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, target.Position)
                        end
                    end
                end)
            else
                if FOVCircle then
                    FOVCircle:Remove()
                    FOVCircle = nil
                end
                
                -- Disconnect when disabled
                if renderConnection then
                    renderConnection:Disconnect()
                    renderConnection = nil
                end
            end
        end
    })

    Context:AddDropdown({

        Text = "Target Part",

        Items = {
            "Head",
            "HumanoidRootPart",
        },

        Callback = function(Value)
            TargetPart = Value
        end

    })

    Context:AddTitle({
        Text = "Ignore Settings"
    })

    Context:AddToggle({
        Text = "Ignore Civilians",

        Callback = function(Enabled)

        end
    })

    Context:AddToggle({
        Text = "Ignore Untouchable Teams",

        Callback = function(Enabled)

        end
    })

end