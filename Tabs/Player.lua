local Player = {}

Player.Speed = 20
Player.TargetPart = "HumanoidRootPart"

Player.RenderSteppedConn = nil
Player.FOVCircle = nil

Player.RenderStepName = "ErebusAimbot"

Player.Connections = {}

local RunService = game:GetService("RunService")

function Player:Build(Context)

    local Controls = Context.Services.Controls

    Context:AddTitle({
        Text = "Player Settings"
    })
    
    local SpeedHackToggle = Context:AddToggle({
        Text = "Speed Hack",
        Callback = function(Enabled)

            if Enabled then

                local Character = game.Players.LocalPlayer.Character
                local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
                local Root = Character and Character:FindFirstChild("HumanoidRootPart")

                if not Humanoid or not Root then
                    return
                end

                renderSteppedConn = RunService.RenderStepped:Connect(function()

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

            else

                if renderSteppedConn then
                    renderSteppedConn:Disconnect()
                    renderSteppedConn = nil
                end

            end

        end
    })

    local SpeedSlider = Context:AddSlider({

        Text = "Speed",

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

    Context:RegisterConnection(
        Context.Services.Controls:Bind(SpeedHackKey,function(Down)

            if Down then
                SpeedHackToggle:Toggle()
            end

        end)
    )

    local AimbotToggle = Context:AddToggle({
        Text = "Aimbot",

        Callback = function(Enabled)

            if Enabled then

                if not self.FOVCircle then
                    self.FOVCircle = Drawing.new("Circle")
                end

                self.FOVCircle.Visible = true
                self.FOVCircle.Filled = false
                self.FOVCircle.Thickness = 2
                self.FOVCircle.Radius = 150
                self.FOVCircle.NumSides = 64
                self.FOVCircle.Position = workspace.CurrentCamera.ViewportSize / 2

                RunService:UnbindFromRenderStep(RenderStepName)

                RunService:BindToRenderStep(
                    RenderStepName,
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

                RunService:UnbindFromRenderStep(RenderStepName)

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
            self.TargetPart = Value
        end

    })

    local FOVSlider = Context:AddSlider({

        Text = "FOV Circle",

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

function Player:Destroy()

    if self.RenderSteppedConn then
        self.RenderSteppedConn:Disconnect()
        self.RenderSteppedConn = nil
    end

    RunService:UnbindFromRenderStep(self.RenderStepName)

    if self.FOVCircle then
        self.FOVCircle:Remove()
        self.FOVCircle = nil
    end

    for _,Connection in ipairs(self.Connections) do
        Connection:Disconnect()
    end

    table.clear(self.Connections)

end

return Player