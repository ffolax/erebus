local VehicleTeleport = {}

local Vehicles = game.workspace:FindFirstChild("Vehicles")

local TeleportPoints = {

	Bank = Vector3.new(-1148, 3, 3210),
	GasNGoFuel = Vector3.new(-1544, 3, 3801),
	Club = Vector3.new(-1860, 3, 3025),
	PoliceStation = Vector3.new(-1655, 3, 2733),
	ParkingGarage = Vector3.new(-1378, -25, 3691),
	FireStation = Vector3.new(-961, 3, 3889),
	Jeweler = Vector3.new(-420, 3, 3521),
	Prison = Vector3.new(-551, 3, 2815),
	AresFuel = Vector3.new(-866, 3, 1512),
	Hospital = Vector3.new(-163, 3, 1021),
	Harbor = Vector3.new(902, 3, 2157),
	TruckCompany = Vector3.new(702, 3, 1485),
	Dealership = Vector3.new(-1404, 3, 945),
	ToolShop = Vector3.new(-748, 3, 672),
	HARS = Vector3.new(-329, 3, 494),
	TuningGarage = Vector3.new(-1436, 3, 142),
	FarmShop = Vector3.new(-912, 3, -1170),
	BusCompany = Vector3.new(-1677, 3, -1331),
	OssoFuel = Vector3.new(-36, 3, -754),
	ClothingStore = Vector3.new(475, 3, -1442)

}

local Players = game:GetService("Players")
local Plr = Players.LocalPlayer
local PlrGui = Plr:WaitForChild("PlayerGui")
local StarterGui = game:GetService("StarterGui")

local CurrentlyTeleporting = false
VehicleTeleport.NavigationMap = nil
VehicleTeleport.TeleportSpeed = 100
VehicleTeleport.MapConnections = {}

function Vehicle:GetVehicle()

    local Vehicles = workspace:FindFirstChild("Vehicles")
    if not Vehicles then
        return
    end

    return Vehicles:FindFirstChild(game.Players.LocalPlayer.Name)

end

function VehicleTeleport:GetCharacter()

    local Character = game.Players.LocalPlayer.Character
    if not Character then
        return
    end

    return Character,
        Character:FindFirstChildOfClass("Humanoid"),
        Character:FindFirstChild("HumanoidRootPart")

end

function VehicleTeleport:EnterVehicle()

    local Character, Humanoid, Root = self:GetCharacter()

    local PlrVehicle = self:GetVehicle()

    if not (Character and Humanoid and Root and PlrVehicle) then
        return
    end

    local DriveSeat = PlrVehicle:FindFirstChildOfClass("Seat")

    if not DriveSeat then
        return
    end

    local Distance = (Root.Position - DriveSeat.Position).Magnitude

    if Distance > 100 then

        local Start = Root.Position
        local Goal = DriveSeat.Position + Vector3.new(0, 5, 0)

        local Steps = math.ceil(Distance / 5)

        for i = 1, Steps do

            local Alpha = i / Steps

            Root.CFrame = CFrame.new(Start:Lerp(Goal, Alpha))

            RunService.Heartbeat:Wait()

        end

    end

    DriveSeat:Sit(Humanoid)

end

function VehicleTeleport:MoveVehicle(endPosition,givenSpeed,sitPlayer)

	local speed = givenSpeed or VehicleTeleport.TeleportSpeed

	local vehicle = FindPlrVehicle()
	if not vehicle then return end

	local startPivot = vehicle:GetPivot()
	local startPosition = startPivot.Position

	local distance = (endPosition - startPosition).Magnitude
	local duration = distance / speed

	local startTime = tick()

	while true do
		local alpha = math.clamp((tick() - startTime) / duration, 0, 1)

		local position = startPosition:Lerp(endPosition, alpha)
		position = Vector3.new(position.X, 0, position.Z)

		vehicle:PivotTo(
			CFrame.new(position) * startPivot.Rotation
		)

		if alpha >= 1 then
			break
		end

		local Character = Plr.Character
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")

		if Humanoid then

			if Humanoid.Sit == false then

				if sitPlayer then

					self:EnterVehicle()

				end

			end

		end

		task.wait()
	end

	task.wait(0.25)

	vehicle:PivotTo(CFrame.new(endPosition + Vector3.new(0, 5, 0)) * startPivot.Rotation)

	CurrentlyTeleporting = false

end

function VehicleTeleport:SetupMapToMove()
    print("[EREBUS] Map To Move setting up...")

    if self.MapConnections then
        for _, Connection in ipairs(self.MapConnections) do
            if Connection then
                Connection:Disconnect()
            end
        end

        table.clear(self.MapConnections)
    else
        self.MapConnections = {}
    end

    self.NavigationMap = nil

    for _, Obj in pairs(PlrGui:GetDescendants()) do
        if Obj:IsA("ViewportFrame") and string.find(Obj.Name, "Map") then
            self.NavigationMap = Obj
            break
        end
    end

    if not self.NavigationMap then
        return
    end

    print("[EREBUS] Found navigation map!")

    local Map = self.NavigationMap

    table.insert(
        self.MapConnections,
        Map.Destroying:Connect(function()
            task.defer(function()
                self:SetupMapToMove()
            end)
        end)
    )

    local function SetupMapPoint(MapPoint)
        if not MapPoint:IsA("ImageButton") then
            return
        end

        if MapPoint:GetAttribute("ErebusConnected") then
            return
        end

        MapPoint:SetAttribute("ErebusConnected", true)

        print("[EREBUS] Connected map point:", MapPoint.Name)

        local Connection = MapPoint.Changed:Connect(function(Property)
            if Property == "Position" then
                return
            end

            if Property == "AbsolutePosition" then
                return
            end

            if MapPoint.BackgroundColor3 == Color3.fromRGB(0, 0, 0) then
                return
            end

            print("[EREBUS] Picked a map point!")

            local SelectedMapPoint = MapPoint:FindFirstChild("4")

            if not SelectedMapPoint then
                return
            end

            local LettersOnly =
                SelectedMapPoint.Text:gsub("[^%a]", "")

            if TeleportPoints[LettersOnly] and not CurrentlyTeleporting then
                CurrentlyTeleporting = true

                self:MoveVehicle(
                    TeleportPoints[LettersOnly],
                    self.TeleportSpeed,
                    true
                )
            end
        end)

        table.insert(self.MapConnections, Connection)
    end

    for _, MapPoint in ipairs(Map:GetChildren()) do
        SetupMapPoint(MapPoint)
    end

    table.insert(
        self.MapConnections,
        Map.ChildAdded:Connect(function(MapPoint)
            SetupMapPoint(MapPoint)
        end)
    )

    print("[EREBUS] Waiting for map points...")

    if not Map:FindFirstChildWhichIsA("ImageButton") then
        local FirstPoint

        repeat
            FirstPoint = Map.ChildAdded:Wait()

            if Map ~= self.NavigationMap then
                return
            end
        until FirstPoint:IsA("ImageButton")

        SetupMapPoint(FirstPoint)
    end

    print("[EREBUS] Map To Move successfully set up!")
end

VehicleTeleport:SetupMapToMove()

return VehicleTeleport