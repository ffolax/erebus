local Player = {}

Player.RenderSteppedConn = nil
Player.FOVCircle = nil

Player.RenderStepName = "ErebusAimbot"

local RunService = game:GetService("RunService")

function Player:Build(Context)

    local Controls = Context.Services.Controls
    self.Speed = Context.Values.PlayerSpeed or 20
    self.TargetPart = Context.Values.TargetPart or "HumanoidRootPart"

    Context:AddTitle({
        Text = "Player Settings"
    })
    
    local SpeedHackToggle = Context:AddToggle({
        Text = "Speed Hack",
        Id = "SpeedHack",
        Callback = function(Enabled)

            if Enabled then

                local Character = game.Players.LocalPlayer.Character
                local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
                local Root = Character and Character:FindFirstChild("HumanoidRootPart")

                if not Humanoid or not Root then
                    return
                end

                self.RenderSteppedConn = Context:RegisterConnection(
                    RunService.RenderStepped:Connect(function()

                        local MoveDirection = Humanoid.MoveDirection

                        if MoveDirection.Magnitude > 0 then

                            local Y = Root.AssemblyLinearVelocity.Y

                            Root.AssemblyLinearVelocity =
                                Vector3.new(
                                    MoveDirection.X * self.Speed,
                                    Y,
                                    MoveDirection.Z * self.Speed
                                )

                        end

                    end)
                )

            else

            end

        end
    })

    local SpeedSlider = Context:AddSlider({

        Text = "Speed",
        Id = "PlayerSpeed",

        Min = 16,
        Max = 32,

        Default = 20,

        Callback = function(Value)

            self.Speed = Value

        end

    })

    local SpeedHackKey = Context:AddKeybind({
        Text = "Speed Hack Keybind",
        Default = Enum.KeyCode.B
    })

    Context.Services.Controls:Bind(SpeedHackKey,function(Down)

        if Down then
            SpeedHackToggle:Toggle()
        end

    end)

    local AimbotToggle = Context:AddToggle({
        Text = "Aimbot",
        Id = "Aimbot",

        Callback = function(Enabled)

            if Enabled then

                if not self.FOVCircle then
                    self.FOVCircle = Drawing.new("Circle")
                    Context:RegisterObject(self.FOVCircle)
                end

                self.FOVCircle.Visible = true
                self.FOVCircle.Filled = false
                self.FOVCircle.Thickness = 2
                self.FOVCircle.Radius = 150
                self.FOVCircle.NumSides = 64
                self.FOVCircle.Position = workspace.CurrentCamera.ViewportSize / 2

                RunService:UnbindFromRenderStep(self.RenderStepName)

                RunService:BindToRenderStep(
                    self.RenderStepName,
                    10000,
                    function()

                        self.FOVCircle.Position =
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
                                            - self.FOVCircle.Position
                                        ).Magnitude

                                    if distance < minDistance
                                    and distance <= self.FOVCircle.Radius then

                                        minDistance = distance
                                        closestPlayer = character

                                    end
                                end
                            end
                        end

                        if closestPlayer then

                            local target =
                                closestPlayer:FindFirstChild(self.TargetPart)
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

                if self.FOVCircle then
                    self.FOVCircle:Remove()
                    self.FOVCircle = nil
                end

                RunService:UnbindFromRenderStep(self.RenderStepName)

            end

        end
    })

    Context:AddTitle({
        Text = "Aimbot Settings"
    })

    local AimbotKey = Context:AddKeybind({
        Text = "Aimbot Keybind",
        Default = Enum.KeyCode.V
    })

    Context.Services.Controls:Bind(AimbotKey,function(Down)

        if Down then
            AimbotToggle:Toggle()
        end

    end)

    Context:AddDropdown({

        Text = "Target Part",
        Id = "TargetPart",
        Items = {
            "Head",
            "HumanoidRootPart",
        },
        Default = "HumanoidRootPart",

        Callback = function(Value)
            self.TargetPart = Value
        end

    })

    local FOVSlider = Context:AddSlider({

        Text = "FOV Circle",
        Id = "FOVCircle",

        Min = 25,
        Max = 500,

        Default = 150,

        Callback = function(Value)

            if self.FOVCircle then
                self.FOVCircle.Radius = Value
            end

        end

    })

    Context:AddTitle({
        Text = "Ignore Settings"
    })

    Context:AddToggle({
        Text = "Ignore Civilians",
        Id = "IgnoreCivilians",

        Callback = function(Enabled)

        end
    })

    Context:AddToggle({
        Text = "Ignore Untouchable Teams",
        Id = "IgnoreUntouchableTeams",

        Callback = function(Enabled)

        end
    })

    Context:AddToggle({
        Text = "Wall Check",
        Id = "Wall Check",

        Callback = function(Enabled)

        end
    })

end

function Player:Destroy()

    RunService:UnbindFromRenderStep(self.RenderStepName)

end

return Player