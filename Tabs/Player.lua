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
                        - self.State.FOVCircle.Position
                    ).Magnitude

                if distance < minDistance
                and distance <= self.State.FOVCircle.Radius then

                    minDistance = distance
                    closestPlayer = character

                end
            end
        end
    end

    return closestPlayer

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
            Context:RegisterObject(self.State.FOVCircle)
        end

        self.State.FOVCircle.Visible = true
        self.State.FOVCircle.Filled = false
        self.State.FOVCircle.Thickness = 2
        self.State.FOVCircle.Radius = 150
        self.State.FOVCircle.NumSides = 64
        self.State.FOVCircle.Position = workspace.CurrentCamera.ViewportSize / 2

        RunService:UnbindFromRenderStep(self.State.RenderStepName)

        Context:RegisterPersistentConnection(
            RunService:BindToRenderStep(
                self.State.RenderStepName,
                10000,
                function()

                    self.State.FOVCircle.Position =
                        workspace.CurrentCamera.ViewportSize / 2

                    local closestPlayer = self:GetClosestPlayer()

                    if closestPlayer then

                        local target =
                            closestPlayer:FindFirstChild(self.State.TargetPart)
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
        )

    else

        if self.State.FOVCircle then
            self.State.FOVCircle:Remove()
            self.State.FOVCircle = nil
        end

        RunService:UnbindFromRenderStep(self.State.RenderStepName)

    end
    
end

function Player:Init(Context)

    local SpeedHackKey = Context:AddKeybind({
        Text = "Speed Hack Keybind",
        Default = Enum.KeyCode.B
    })

    Context:RegisterPersistentConnection(
        Context.Services.Controls:Bind(SpeedHackKey,function(Down)

            if Down then
                Context.Values.SpeedHack = not Context.Values.SpeedHack
                self:SetSpeedHack(Context, Context.Values.SpeedHack)

                if self.State.SpeedToggle then
                    self.State.SpeedToggle:SetValue(Context.Values.SpeedHack)
                end
            end

        end)
    )

    local AimbotKey = Context:AddKeybind({
        Text = "Aimbot Keybind",
        Default = Enum.KeyCode.V
    })

    Context:RegisterPersistentConnection(
        Context.Services.Controls:Bind(AimbotKey,function(Down)

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