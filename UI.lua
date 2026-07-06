local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local UI = {}

function UI:Init(Context)
	self.Context = Context

	-- ScreenGui
	local screen = Instance.new("ScreenGui")
	screen.Name = "ModernHub"
	screen.ResetOnSpawn = false
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.Parent = game.CoreGui

	-- Main Window
	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0, 650, 0, 420)
	main.Position = UDim2.new(0.5, -325, 0.5, -210)
	main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	main.BorderSizePixel = 0
	main.Parent = screen

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 10)
	mainCorner.Parent = main

	----------------------------------------------------
	-- TOPBAR
	----------------------------------------------------

	local topbar = Instance.new("Frame")
	topbar.Name = "Topbar"
	topbar.Size = UDim2.new(1, 0, 0, 36)
	topbar.BackgroundColor3 = Color3.fromRGB(28,30,36)
	topbar.BorderSizePixel = 0
	topbar.Parent = main

	local topCorner = Instance.new("UICorner")
	topCorner.CornerRadius = UDim.new(0, 10)
	topCorner.Parent = topbar

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.AnchorPoint = Vector2.new(0,0.5)
	title.Position = UDim2.new(0,12,0.5,0)
	title.Size = UDim2.new(1,-120,1,0)
	title.BackgroundTransparency = 1
	title.Text = "EREBUS"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 15
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Color3.fromRGB(245,245,245)
	title.Parent = topbar

	local function CreateWindowButton(text)

		local button = Instance.new("TextButton")
		button.Size = UDim2.fromOffset(28,28)
		button.BackgroundTransparency = 1
		button.Text = text
		button.Font = Enum.Font.GothamBold
		button.TextSize = 16
		button.TextColor3 = Color3.fromRGB(220,220,220)
	
		button.MouseEnter:Connect(function()
	
			TweenService:Create(button,TweenInfo.new(.15),{
				TextColor3 = Color3.fromRGB(255,255,255)
			}):Play()
	
		end)
	
		button.MouseLeave:Connect(function()
	
			TweenService:Create(button,TweenInfo.new(.15),{
				TextColor3 = Color3.fromRGB(220,220,220)
			}):Play()
	
		end)
	
		return button
	
	end
	
	local Exit = CreateWindowButton("✕")
	local Maximize = CreateWindowButton("□")
	local Minimize = CreateWindowButton("─")
	
	Exit.Parent = topbar
	Maximize.Parent = topbar
	Minimize.Parent = topbar
	
	Exit.AnchorPoint = Vector2.new(1,.5)
	Exit.Position = UDim2.new(1,-8,.5,0)
	
	Maximize.AnchorPoint = Vector2.new(1,.5)
	Maximize.Position = UDim2.new(1,-38,.5,0)
	
	Minimize.AnchorPoint = Vector2.new(1,.5)
	Minimize.Position = UDim2.new(1,-68,.5,0)

	Exit.MouseButton1Click:Connect(function()

		screen:Destroy()

	end)

	local Minimized = false
	local SavedSize = main.Size
	
	Minimize.MouseButton1Click:Connect(function()
	
		Minimized = not Minimized
	
		if Minimized then
	
			TweenService:Create(main,TweenInfo.new(.25),{
				Size = UDim2.new(
					SavedSize.X.Scale,
					SavedSize.X.Offset,
					0,
					36
				)
			}):Play()
	
		else
	
			TweenService:Create(main,TweenInfo.new(.25),{
				Size = SavedSize
			}):Play()
	
		end
	
	end)

	local Maximized = false
	local OldPosition = main.Position
	local OldSize = main.Size
	
	Maximize.MouseButton1Click:Connect(function()
	
		Maximized = not Maximized
	
		if Maximized then
	
			OldPosition = main.Position
			OldSize = main.Size
	
			TweenService:Create(main,TweenInfo.new(.3),{
	
				Position = UDim2.new(0.05,0,0.05,0),
				Size = UDim2.new(.9,0,.9,0)
	
			}):Play()
	
		else
	
			TweenService:Create(main,TweenInfo.new(.3),{
	
				Position = OldPosition,
				Size = OldSize
	
			}):Play()
	
		end
	
	end)

	local Dragging = false

	local DragStart
	local StartPos
	
	local GoalPosition = main.Position
	
	topbar.InputBegan:Connect(function(input)
	
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
	
			Dragging = true
			DragStart = input.Position
			StartPos = GoalPosition
	
		end
	
	end)
	
	topbar.InputEnded:Connect(function(input)
	
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
	
			Dragging = false
	
		end
	
	end)
	
	UserInputService.InputChanged:Connect(function(input)
	
		if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
	
			local Delta = input.Position - DragStart
	
			GoalPosition = UDim2.new(
				StartPos.X.Scale,
				StartPos.X.Offset + Delta.X,
				StartPos.Y.Scale,
				StartPos.Y.Offset + Delta.Y
			)
	
		end
	
	end)
	
	RunService.RenderStepped:Connect(function()
	
		main.Position = main.Position:Lerp(GoalPosition,.22)
	
	end)

	----------------------------------------------------
	-- SIDEBAR
	----------------------------------------------------

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 170, 1, -36)
	sidebar.Position = UDim2.new(0,0,0,36)
	sidebar.BackgroundColor3 = Color3.fromRGB(23,25,31)
	sidebar.BorderSizePixel = 0
	sidebar.Parent = main

	local sideCorner = Instance.new("UICorner")
	sideCorner.CornerRadius = UDim.new(0,10)
	sideCorner.Parent = sidebar

	local tabHolder = Instance.new("Frame")
	tabHolder.Name = "TabHolder"
	tabHolder.BackgroundTransparency = 1
	tabHolder.Size = UDim2.new(1,-10,1,-10)
	tabHolder.Position = UDim2.new(0,5,0,5)
	tabHolder.Parent = sidebar

	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0,5)
	list.FillDirection = Enum.FillDirection.Vertical
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = tabHolder

	----------------------------------------------------
	-- CONTENT
	----------------------------------------------------

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1,-170,1,-36)
	content.Position = UDim2.new(0,170,0,36)
	content.BackgroundTransparency = 1
	content.Parent = main

	----------------------------------------------------
	-- STORE REFERENCES
	----------------------------------------------------

	self.Screen = screen
	self.Main = main
	self.Topbar = topbar
	self.Sidebar = sidebar
	self.Content = content
	self.TabHolder = tabHolder

	self.Tabs = {}
	self.ActiveTab = nil

	print("[UI] Modern UI Initialized")
end

----------------------------------------------------
-- TAB CREATION
----------------------------------------------------

function UI:CreateTab(name, callback)

	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(1,0,0,38)
	button.BackgroundColor3 = Color3.fromRGB(30,30,35)
	button.BorderSizePixel = 0
	button.Text = name
	button.TextColor3 = Color3.fromRGB(200,200,200)
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.Parent = self.TabHolder

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,6)
	corner.Parent = button

	button.MouseEnter:Connect(function()

		if self.ActiveTab ~= button then

			TweenService:Create(
				button,
				TweenInfo.new(.15),
				{
					BackgroundColor3 = Color3.fromRGB(45,45,55)
				}
			):Play()

		end

	end)

	button.MouseLeave:Connect(function()

		if self.ActiveTab ~= button then

			TweenService:Create(
				button,
				TweenInfo.new(.15),
				{
					BackgroundColor3 = Color3.fromRGB(30,30,35)
				}
			):Play()

		end

	end)

	button.MouseButton1Click:Connect(function()

		self:SetActiveTab(button)

		if callback then

			self:ClearContent()
			callback(self.Content)

		end

	end)

	self.Tabs[name] = button

	return button

end

----------------------------------------------------
-- ACTIVE TAB
----------------------------------------------------

function UI:SetActiveTab(button)

	if self.ActiveTab then

		TweenService:Create(
			self.ActiveTab,
			TweenInfo.new(.15),
			{
				BackgroundColor3 = Color3.fromRGB(30,30,35)
			}
		):Play()

	end

	self.ActiveTab = button

	TweenService:Create(
		button,
		TweenInfo.new(.15),
		{
			BackgroundColor3 = Color3.fromRGB(70,70,90)
		}
	):Play()

end

----------------------------------------------------
-- CLEAR CONTENT
----------------------------------------------------

function UI:ClearContent()

	for _,v in ipairs(self.Content:GetChildren()) do

		if v:IsA("GuiObject") then
			v:Destroy()
		end

	end

end

return UI
