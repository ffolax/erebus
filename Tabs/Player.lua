local Player = {}

Player.State = {
    Speed = 20,
    TargetPart = "HumanoidRootPart",

    SpeedConnection = nil,
    RenderStepName = "ErebusAimbot",
    FOVCircle = nil,
    SpeedToggle = nil,
    AimbotToggle = nil,
}

local RunService = game:GetService("RunService")

function Player:GetCharacter()

    local Character = game.Players.LocalPlayer.Character
    if not Character then
        return
    end

    return Character,
        Character:FindFirstChildOfClass("Humanoid"),
        Character:FindFirstChild("HumanoidRootPart")

end

function Player:GetClosestPlayer()
    local Camera = workspace.CurrentCamera
    local FOVCircle = self.State.FOVCircle

    if not Camera or not FOVCircle then
        return nil
    end

    local LocalPlayer = game.Players.LocalPlayer
    local ClosestCharacter = nil
    local ClosestDistance = FOVCircle.Radius
    local Center = Camera.ViewportSize / 2

    for _, Player in ipairs(game.Players:GetPlayers()) do
        if Player == LocalPlayer then
            continue
        end

        local Character = Player.Character
        if not Character then
            continue
        end

        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if not Humanoid or Humanoid.Health <= 0 then
            continue
        end

        local TargetPart =
            Character:FindFirstChild(self.State.TargetPart)
            or Character:FindFirstChild("HumanoidRootPart")

        if not TargetPart then
            continue
        end

        local ScreenPosition, OnScreen =
            Camera:WorldToViewportPoint(TargetPart.Position)

        if not OnScreen or ScreenPosition.Z <= 0 then
            continue
        end

        local ScreenDistance = (
            Vector2.new(ScreenPosition.X, ScreenPosition.Y) - Center
        ).Magnitude

        if ScreenDistance <= ClosestDistance then
            ClosestDistance = ScreenDistance
            ClosestCharacter = Character
        end
    end

    return ClosestCharacter
end

function Player:SetSpeedHack(Context, Enabled)

    if Enabled then

        local Character, Humanoid, Root = self:GetCharacter()

        if not Humanoid or not Root then
            return
        end

        if self.State.SpeedConnection then
            self.State.SpeedConnection:Disconnect()
        end

        self.State.SpeedConnection = Context:RegisterPersistentConnection(
            RunService.RenderStepped:Connect(function()

                local MoveDirection = Humanoid.MoveDirection

                if MoveDirection.Magnitude > 0 then

                    local Y = Root.AssemblyLinearVelocity.Y

                    Root.AssemblyLinearVelocity =
                        Vector3.new(
                            MoveDirection.X * self.State.Speed,
                            Y,
                            MoveDirection.Z * self.State.Speed
                        )

                end

            end)
        )

    else

        if self.State.SpeedConnection then
            self.State.SpeedConnection:Disconnect()
            self.State.SpeedConnection = nil
        end

    end
    
end

function Player:SetAimbot(Context, Enabled)
    if Enabled then
        if not self.State.FOVCircle then
            self.State.FOVCircle = Drawing.new("Circle")
            self.State.FOVCircle.Filled = false
            self.State.FOVCircle.Thickness = 2
            self.State.FOVCircle.NumSides = 64
        end

        local FOVCircle = self.State.FOVCircle
        FOVCircle.Visible = true
        FOVCircle.Radius = self.State.FOVRadius or 150

        RunService:UnbindFromRenderStep(self.State.RenderStepName)

        Context:RegisterPersistentConnection(
            RunService:BindToRenderStep(
                self.State.RenderStepName,
                Enum.RenderPriority.Camera.Value + 1,
                function()
                    local Camera = workspace.CurrentCamera
                    if not Camera or not FOVCircle then
                        return
                    end

                    FOVCircle.Position = Camera.ViewportSize / 2
                    FOVCircle.Radius = self.State.FOVRadius or 150

                    local Target = self:GetClosestPlayer()

                    if not Target then
                        return
                    end

                    local TargetPart =
                        Target:FindFirstChild(self.State.TargetPart)
                        or Target:FindFirstChild("HumanoidRootPart")

                    if not TargetPart then
                        return
                    end

                    local CameraPosition = Camera.CFrame.Position
                    local TargetPosition = TargetPart.Position

                    Camera.CFrame = CFrame.lookAt(
                        CameraPosition,
                        TargetPosition
                    )
                end
            )
        )
    else
        RunService:UnbindFromRenderStep(self.State.RenderStepName)

        if self.State.FOVCircle then
            self.State.FOVCircle.Visible = false
            self.State.FOVCircle:Remove()
            self.State.FOVCircle = nil
        end
    end
end

function Player:Init(Context)

    if Context.Values.SpeedHackKey == nil then
        Context.Values.SpeedHackKey = Enum.KeyCode.B
    end

    Context:RegisterPersistentConnection(
        Context.Services.Controls:Bind({
            GetValue = function()
                return Context.Values.SpeedHackKey
            end
        }, function(Down)

            if Down then
                Context.Values.SpeedHack = not Context.Values.SpeedHack
                self:SetSpeedHack(Context, Context.Values.SpeedHack)

                if self.State.SpeedToggle then
                    self.State.SpeedToggle:SetValue(Context.Values.SpeedHack)
                end
            end

        end)
    )

    if Context.Values.AimbotKey == nil then
        Context.Values.AimbotKey = Enum.KeyCode.V
    end

    Context:RegisterPersistentConnection(
        Context.Services.Controls:Bind({
            GetValue = function()
                return Context.Values.AimbotKey
            end
        }, function(Down)

            if Down then
                Context.Values.Aimbot = not Context.Values.Aimbot
                self:SetAimbot(Context, Context.Values.Aimbot)

                if self.State.AimbotToggle then
                    self.State.AimbotToggle:SetValue(Context.Values.Aimbot)
                end
            end

        end)
    )

end

function Player:Build(Context)

    self.State.Speed = Context.Values.PlayerSpeed or 20
    self.State.TargetPart = Context.Values.TargetPart or "HumanoidRootPart"

    Context:AddTitle({
        Text = "Player Settings"
    })

    self.State.SpeedToggle = Context:AddToggle({
        Text = "Speed Hack",
        Id = "SpeedHack",
        Callback = function(Enabled)
            self:SetSpeedHack(Context, Enabled)
        end
    })

    Context:AddKeybind({
        Text = "Speed Hack Keybind",
        Id = "SpeedHackKey",
        Default = Enum.KeyCode.B
    })

    local SpeedSlider = Context:AddSlider({

        Text = "Speed",
        Id = "PlayerSpeed",

        Min = 16,
        Max = 50,

        Default = 16,

        Callback = function(Value)

            self.State.Speed = Value

        end

    })

    self.State.AimbotToggle = Context:AddToggle({
        Text = "Aimbot",
        Id = "Aimbot",

        Callback = function(Enabled)
            self:SetAimbot(Context, Enabled)
        end
    })

    Context:AddKeybind({
        Text = "Aimbot Keybind",
        Id = "AimbotKey",
        Default = Enum.KeyCode.V
    })

    Context:AddTitle({
        Text = "Aimbot Settings"
    })

    Context:AddDropdown({

        Text = "Target Part",
        Id = "TargetPart",
        Items = {
            "Head",
            "HumanoidRootPart",
        },
        Default = "HumanoidRootPart",

        Callback = function(Value)
            self.State.TargetPart = Value
        end

    })

    local FOVSlider = Context:AddSlider({

        Text = "FOV Circle",
        Id = "FOVCircle",

        Min = 25,
        Max = 500,

        Default = 150,

        Callback = function(Value)

            self.State.FOVRadius = Value

            if self.State.FOVCircle then
                self.State.FOVCircle.Radius = Value
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

    self.State.SpeedToggle:SetValue(Context.Values.SpeedHack or false)
    self.State.AimbotToggle:SetValue(Context.Values.Aimbot or false)

end

function Player:Destroy()

    

end

return Player