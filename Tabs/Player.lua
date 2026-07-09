return function(Context)

    local Controls = Context.Services.Controls
    local RunService = game:GetService("RunService")

    Context:AddTitle({
        Text = "Player Settings"
    })

    local renderSteppedConn

    local SpeedHackToggle = Context:AddToggle({
        Text = "Speed Hack",
        Callback = function(Enabled)
            if Enabled then
                local lastPosition = game.Players.LocalPlayer.CharacterRootPart.Position
                local lastTime = tick()
                
                renderSteppedConn = RunService.RenderStepped:Connect(function()
                    local currentTime = tick()
                    local deltaTime = currentTime - lastTime
                    
                    if deltaTime > 0 then
                        local currentVelocity = (game.Players.LocalPlayer.CharacterRootPart.Position - lastPosition) / deltaTime
                        local targetVelocity = Vector3.new(10, 0, 10)

                        local newPosition = game.Players.LocalPlayer.CharacterRootPart.Position + (targetVelocity - currentVelocity) * deltaTime

                        game.Players.LocalPlayer.CharacterRootPart.Anchored = true
                        game.Players.LocalPlayer.CharacterRootPart.CFrame = CFrame.new(newPosition)
                        
                        spawn(function()
                            wait(0.1)
                            game.Players.LocalPlayer.CharacterRootPart.Anchored = false
                        end)
                    end
                    
                    lastPosition = game.Players.LocalPlayer.CharacterRootPart.Position
                    lastTime = currentTime
                end)
            else
                if renderSteppedConn then
                    renderSteppedConn:Disconnect()
                    renderSteppedConn = nil
                end
            end
        end
    })

    local SpeedHackKey = Context:AddKeybind({
        Text = "Speed Hack Keybind",
        Default = Enum.KeyCode.B
    })

    Context:RegisterConnection(
        Context.Services.Controls:Bind(SpeedHackKey,function(Down)

            if Down then
                SpeedHackToggle:Toggle()
            end

        end)
    )

    Context:AddTitle({
        Text = "Aimbot Settings"
    })

    local FOVCircle
    local TargetPart = "HumanoidRootPart"
    local RenderStepName = "ErebusAimbot"

    local AimbotToggle = Context:AddToggle({
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

                MouseConnection = Context.Services.Controls:Bind(MouseBind,function(Down)

                    print("Down:", Down)

                end)

                RunService:UnbindFromRenderStep(RenderStepName)

                RunService:BindToRenderStep(
                    RenderStepName,
                    10000,
                    function()

                        FOVCircle.Position =
                            workspace.CurrentCamera.ViewportSize / 2

                        local closestPlayer
                        local minDistance = math.huge

                        for _, player in ipairs(game.Players:GetPlayers()) do

                            if player == game.Players.LocalPlayer then
                                continue
                            end

                            local character = player.Character
                            if not character then
                                continue
                            end

                            local humanoidRootPart =
                                character:FindFirstChild("HumanoidRootPart")

                            if humanoidRootPart then

                                local screenPos, onScreen =
                                    workspace.CurrentCamera:WorldToViewportPoint(
                                        humanoidRootPart.Position
                                    )

                                if onScreen then

                                    local distance =
                                        (
                                            Vector2.new(screenPos.X, screenPos.Y)
                                            - FOVCircle.Position
                                        ).Magnitude

                                    if distance < minDistance
                                    and distance <= FOVCircle.Radius then

                                        minDistance = distance
                                        closestPlayer = character

                                    end
                                end
                            end
                        end

                        if closestPlayer then

                            local target =
                                closestPlayer:FindFirstChild(TargetPart)
                                or closestPlayer:FindFirstChild("HumanoidRootPart")

                            if target then

                                workspace.CurrentCamera.CFrame = CFrame.lookAt(
                                    workspace.CurrentCamera.CFrame.Position,
                                    target.Position
                                )

                            end
                        end

                    end
                )

            else

                if FOVCircle then
                    FOVCircle:Remove()
                    FOVCircle = nil
                end

                RunService:UnbindFromRenderStep(RenderStepName)

            end

        end
    })

    
    local AimbotKey = Context:AddKeybind({
        Text = "Aimbot Keybind",
        Default = Enum.KeyCode.V
    })

    Context:RegisterConnection(
        Context.Services.Controls:Bind(AimbotKey,function(Down)

            if Down then
                AimbotToggle:Toggle()
            end

        end)
    )

    Context:AddDropdown({

        Text = "Target Part",
        Items = {
            "Head",
            "HumanoidRootPart",
        },
        Default = "HumanoidRootPart",

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

    Context:AddToggle({
        Text = "Wall Check",

        Callback = function(Enabled)

        end
    })

end