local Visuals = {}

Visuals.State = {
    ShowNames = false,
    ShowTeam = false,
}

Visuals.Runtime = {
    PlayerConnections = {},
    CharacterConnections = {},
    BillboardGuis = {},
    UpdateConnection = nil,
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

function Visuals:GetPlayerCharacter(Player)
    return Player.Character
end

function Visuals:GetBillboard(Player)
    local Character = self:GetPlayerCharacter(Player)

    if not Character then
        return nil
    end

    local Head = Character:FindFirstChild("Head")
        or Character:FindFirstChild("HumanoidRootPart")

    if not Head then
        return nil
    end

    local Billboard = Head:FindFirstChild("ErebusVisuals")

    if Billboard then
        return Billboard
    end

    Billboard = Instance.new("BillboardGui")
    Billboard.Name = "ErebusVisuals"
    Billboard.Adornee = Head
    Billboard.AlwaysOnTop = true
    Billboard.Size = UDim2.new(0, 200, 0, 100)
    Billboard.StudsOffset = Vector3.new(0, 3, 0)
    Billboard.MaxDistance = 1000
    Billboard.Parent = Head

    local Layout = Instance.new("UIListLayout")
    Layout.Name = "Layout"
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 2)
    Layout.Parent = Billboard

    self.Runtime.BillboardGuis[Player] = Billboard

    return Billboard
end

function Visuals:AddLabel(Billboard, Name, Text, Order)
    local Label = Billboard:FindFirstChild(Name)

    if not Label then
        Label = Instance.new("TextLabel")
        Label.Name = Name
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.Font = Enum.Font.GothamBold
        Label.TextColor3 = Color3.new(1, 1, 1)
        Label.TextStrokeTransparency = 0
        Label.TextScaled = true
        Label.LayoutOrder = Order
        Label.Parent = Billboard
    end

    Label.Text = Text

    return Label
end

function Visuals:UpdatePlayer(Player)
    if Player == Players.LocalPlayer then
        return
    end

    local Billboard = self:GetBillboard(Player)

    if not Billboard then
        self.Runtime.BillboardGuis[Player] = nil
        return
    end

    Billboard.Enabled =
        self.State.ShowNames
        or self.State.ShowTeam

    if not Billboard.Enabled then
        return
    end

    local NameLabel = Billboard:FindFirstChild("Name")
    local TeamLabel = Billboard:FindFirstChild("Team")

    if self.State.ShowNames then
        NameLabel = self:AddLabel(
            Billboard,
            "Name",
            Player.DisplayName,
            1
        )
    elseif NameLabel then
        NameLabel:Destroy()
    end

    if self.State.ShowTeam then
        local TeamName = Player.Team and Player.Team.Name or "No Team"

        TeamLabel = self:AddLabel(
            Billboard,
            "Team",
            TeamName,
            2
        )

        if Player.Team then
            TeamLabel.TextColor3 = Player.Team.TeamColor.Color
        else
            TeamLabel.TextColor3 = Color3.new(1, 1, 1)
        end
    elseif TeamLabel then
        TeamLabel:Destroy()
    end
end

function Visuals:UpdateAll()
    for _, Player in ipairs(Players:GetPlayers()) do
        self:UpdatePlayer(Player)
    end
end

function Visuals:RemovePlayer(Player)
    local Billboard = self.Runtime.BillboardGuis[Player]

    if Billboard then
        Billboard:Destroy()
        self.Runtime.BillboardGuis[Player] = nil
    end

    local Connection = self.Runtime.PlayerConnections[Player]

    if Connection then
        Connection:Disconnect()
        self.Runtime.PlayerConnections[Player] = nil
    end

    local CharacterConnection = self.Runtime.CharacterConnections[Player]

    if CharacterConnection then
        CharacterConnection:Disconnect()
        self.Runtime.CharacterConnections[Player] = nil
    end
end

function Visuals:SetupPlayer(Player)
    if Player == Players.LocalPlayer then
        return
    end

    if self.Runtime.CharacterConnections[Player] then
        self.Runtime.CharacterConnections[Player]:Disconnect()
    end

    self.Runtime.CharacterConnections[Player] =
        Player.CharacterAdded:Connect(function()
            task.wait()
            self:UpdatePlayer(Player)
        end)

    self.Runtime.PlayerConnections[Player] =
        Player:GetPropertyChangedSignal("Team"):Connect(function()
            self:UpdatePlayer(Player)
        end)

    self:UpdatePlayer(Player)
end

function Visuals:SetShowNames(Enabled)
    self.State.ShowNames = Enabled
    self:UpdateAll()
end

function Visuals:SetShowTeam(Enabled)
    self.State.ShowTeam = Enabled
    self:UpdateAll()
end

function Visuals:Init(Context)
    for _, Player in ipairs(Players:GetPlayers()) do
        self:SetupPlayer(Player)
    end

    Context:RegisterPersistentConnection(
        Players.PlayerAdded:Connect(function(Player)
            self:SetupPlayer(Player)
        end)
    )

    Context:RegisterPersistentConnection(
        Players.PlayerRemoving:Connect(function(Player)
            self:RemovePlayer(Player)
        end)
    )

    local Timer = 0

    self.Runtime.UpdateConnection = Context:RegisterPersistentConnection(
        RunService.Heartbeat:Connect(function(DeltaTime)
            Timer += DeltaTime

            if Timer >= 2 then
                Timer = 0
                self:UpdateAll()
            end
        end)
    )
end

function Visuals:Build(Context)
    Context:AddTitle({
        Text = "Player Visuals"
    })

    Context:AddToggle({
        Text = "Show Names",
        Id = "ShowNames",

        Callback = function(Enabled)
            self:SetShowNames(Enabled)
        end
    })

    Context:AddToggle({
        Text = "Show Team",
        Id = "ShowTeam",

        Callback = function(Enabled)
            self:SetShowTeam(Enabled)
        end
    })
end

return Visuals