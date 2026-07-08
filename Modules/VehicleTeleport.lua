local VehicleTeleport = {}

local Vehicles = game.workspace:FindFirstChild("Vehicles")
local Robberies = game.workspace:FindFirstChild("Robberies")

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

local Plr = Players.LocalPlayer
local PlrGui = Plr:WaitForChild("PlayerGui")

local CurrentlyTeleporting = false
VehicleTeleport.TeleportSpeed = 100

function FindPlrVehicle()

    local car = Vehicles:FindFirstChild(tostring(Plr))

    if car then

        return car

    end

end

function EnterVehicle()

	local car = FindPlrVehicle()

	if car then

		local DriveSeat = car:FindFirstChildOfClass("Seat")

		if DriveSeat then

			if Plr.Character and Plr.Character:FindFirstChild("Humanoid") then

				DriveSeat:Sit(Plr.Character.Humanoid)

			end

		end

	end

end

function MoveVehicle(endPosition)

	local speed = VehicleTeleport.TeleportSpeed

	local vehicle = FindPlrVehicle()
	if not vehicle then return end

	local startPivot = vehicle:GetPivot()
	local startPosition = startPivot.Position

	local distance = (endPosition - startPosition).Magnitude
	local duration = distance / speed

	local startTime = tick()

	EnterVehicle()

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

				EnterVehicle()

			end

		end

		task.wait()
	end

	task.wait(0.25)

	vehicle:PivotTo(CFrame.new(endPosition + Vector3.new(0, 5, 0)) * startPivot.Rotation)

	CurrentlyTeleporting = false

end

return function(Context)

	local function SetupMapToMove()

		local NavigationMap

		for _, obj in pairs(PlrGui:GetDescendants()) do
			if obj:IsA("ViewportFrame") and string.find(obj.Name, "Map") then
				NavigationMap = obj
				break
			end
		end

		if not NavigationMap then
			return
		end

		NavigationMap.Destroying:Once(function()
			task.wait()
			SetupMapToMove()
		end)

		local conns = {}

		for _, MapPoints in pairs(NavigationMap:GetChildren()) do
			if MapPoints:IsA("ImageButton") then
				local conn
				conn = MapPoints:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()

					if MapPoints.BackgroundColor3 ~= Color3.fromRGB(0,0,0) then

						local SelectedMapPoint = MapPoints:FindFirstChild("3")
						local LettersOnly = SelectedMapPoint.Text:gsub("[^%a]", "")

						if TeleportPoints[LettersOnly] then

							if not CurrentlyTeleporting then
								CurrentlyTeleporting = true
								MoveVehicle(TeleportPoints[LettersOnly], TeleportSpeed)
							end
						end

					end
				end)

				table.insert(conns,conn)
			end
		end

		getgenv().Erebus = getgenv().Erebus or {}

		if getgenv().Erebus.Instance then
			getgenv().Erebus.Instance.Destroying:Connect(function()
				for _,v in pairs(conns) do
					v:Disconnect()
				end
			end)
		end

	end

	SetupMapToMove()

end