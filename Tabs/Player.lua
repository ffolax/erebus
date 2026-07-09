return function(Context)

    local Controls = Context.Services.Controls

    Context:AddTitle({
        Text = "Aimbot Settings"
    })

    local FOVCircle
    local TargetPart = "HumanoidRootPart"

    local RunService = game:GetService("RunService")
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

    print(Controls.Bindings)

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