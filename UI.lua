local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local UI = {}

function UI:Init(Context, Icons)

	self.Context = Context
	self.Icons = Icons

	-- ScreenGui
	local screen = Instance.new("ScreenGui")
	screen.Name = "erebusUi"
	screen.ResetOnSpawn = false
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.Parent = game.CoreGui

	-- Main Window
	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0, 650, 0, 420)
	main.Position = UDim2.new(0.5, -325, 0.5, -210)
	main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	main.BackgroundTransparency = 0.05
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
	main.Parent = screen

	local Stroke = Instance.new("UIStroke")
	Stroke.Thickness = 1
	Stroke.Transparency = 0.6
	Stroke.Color = Color3.fromRGB(255,255,255)
	Stroke.Parent = main

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 10)
	mainCorner.Parent = main

	local Acrylic = Instance.new("Frame")
	Acrylic.Name = "Acrylic"
	Acrylic.Size = UDim2.new(1,0,1,0)
	Acrylic.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Acrylic.BackgroundTransparency = 0.97
	Acrylic.BorderSizePixel = 0
	Acrylic.ZIndex = 0
	Acrylic.Parent = main
	
	----------------------------------------------------
	-- TOPBAR
	----------------------------------------------------

	local topbar = Instance.new("Frame")
	topbar.Name = "Topbar"
	topbar.Size = UDim2.new(1, 0, 0, 36)
	topbar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	topbar.BackgroundTransparency = 0.15
	topbar.BorderSizePixel = 0
	topbar.Parent = main
	topbar.ZIndex = 2

	local topCorner = Instance.new("UICorner")
	topCorner.CornerRadius = UDim.new(0, 10)
	topCorner.Parent = topbar

	local TopGrad = Instance.new("UIGradient")
	TopGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(35,35,45)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(20,20,25))
	})
	TopGrad.Rotation = 90
	TopGrad.Parent = topbar

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

	local ResizeHandle

	local function CreateWindowButton(Image, HoverColor)

		local Button = Instance.new("ImageButton")
	
		Button.BackgroundTransparency = 1
		Button.Size = UDim2.fromOffset(26,26)
	
		Button.Image = Image
		Button.ImageColor3 = Color3.fromRGB(185,185,185)
	
		Button.MouseEnter:Connect(function()
	
			TweenService:Create(
				Button,
				TweenInfo.new(.15),
				{
					ImageColor3 = HoverColor
				}
			):Play()

			TweenService:Create(
				Button,
				TweenInfo.new(.15, Enum.EasingStyle.Quad),
				{
					Size = UDim2.fromOffset(28,28),
					ImageColor3 = HoverColor
				}
			):Play()
	
		end)
	
		Button.MouseLeave:Connect(function()
	
			TweenService:Create(
				Button,
				TweenInfo.new(.15),
				{
					ImageColor3 = Color3.fromRGB(185,185,185)
				}
			):Play()

			TweenService:Create(
				Button,
				TweenInfo.new(.15, Enum.EasingStyle.Quad),
				{
					Size = UDim2.fromOffset(26,26),
					ImageColor3 = Color3.fromRGB(185,185,185)
				}
			):Play()
	
		end)
	
		return Button
	
	end
	
	local Exit = CreateWindowButton(
		self.Icons.Window.Close,
		Color3.fromRGB(255,80,80)
	)
	
	local Maximize = CreateWindowButton(
		self.Icons.Window.Maximize,
		Color3.fromRGB(255,205,70)
	)
	
	local Minimize = CreateWindowButton(
		self.Icons.Window.Minimize,
		Color3.fromRGB(70,220,110)
	)
	
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

	local GoalPosition = main.Position
	local GoalSize = main.Size
	
	local Minimized = false
	local SavedSize = GoalSize
	
	Minimize.MouseButton1Click:Connect(function()
	
		if not Minimized then
			SavedSize = GoalSize
		end
	
		Minimized = not Minimized

		if ResizeHandle then

			if Minimized then
			    ResizeHandle.Visible = false
			else
			    ResizeHandle.Visible = true
			end

		end
	
		if Minimized then
	
			GoalSize = UDim2.new(
				SavedSize.X.Scale,
				SavedSize.X.Offset,
				0,
				36
			)
	
		else
	
			GoalSize = SavedSize
	
		end
	
	end)

	local Maximized = false
	local OldPosition = GoalPosition
	local OldSize = GoalSize
	
	Maximize.MouseButton1Click:Connect(function()
	
		Maximized = not Maximized
	
		if Maximized then
	
			OldPosition = GoalPosition
			OldSize = GoalSize
	
			GoalPosition = UDim2.new(0.05,0,0.05,0)
			GoalSize = UDim2.new(0.9,0,0.9,0)
	
		else
	
			GoalPosition = OldPosition
			GoalSize = OldSize
	
		end
	
	end)

	local Dragging = false
	local Resizing = false
	
	local DragStart
	local StartPos
	
	local ResizeStart
	local StartSize
	
	local MIN_WIDTH = 550
	local MIN_HEIGHT = 350
	
	local MAX_WIDTH = 1200
	local MAX_HEIGHT = 800
	
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
	
	RunService.RenderStepped:Connect(function(dt)

		local alpha = math.clamp(dt * 18, 0, 1)
	
		main.Position = main.Position:Lerp(GoalPosition, alpha)
		main.Size = main.Size:Lerp(GoalSize, alpha)
	
	end)

	----------------------------------------------------
	-- SIDEBAR
	----------------------------------------------------

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0,170,1,-25)
	sidebar.Position = UDim2.new(0,0,0,25)
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
	tabHolder.Position = UDim2.new(0,5,0,15)
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
	-- RESIZE HANDLE
	----------------------------------------------------
	
	ResizeHandle = Instance.new("ImageButton")
	ResizeHandle.Name = "ResizeHandle"
	ResizeHandle.Parent = main
	
	ResizeHandle.AnchorPoint = Vector2.new(1,1)
	ResizeHandle.Position = UDim2.new(1,-6,1,-6)
	ResizeHandle.Size = UDim2.fromOffset(18,18)
	
	ResizeHandle.BackgroundTransparency = 1
	ResizeHandle.Image = self.Icons.Controls.Resize
	ResizeHandle.ImageColor3 = Color3.fromRGB(170,170,170)
	ResizeHandle.ScaleType = Enum.ScaleType.Fit
	ResizeHandle.ZIndex = 10

	ResizeHandle.MouseEnter:Connect(function()
	
		TweenService:Create(
		    ResizeHandle,
		    TweenInfo.new(.15, Enum.EasingStyle.Quad),
		    {
		        Rotation = 90,
		        Size = UDim2.fromOffset(22,22),
		        ImageColor3 = Color3.fromRGB(255,255,255)
		    }
		):Play()
	
	end)
	
	ResizeHandle.MouseLeave:Connect(function()
	
		if Resizing then
			return
		end
	
		TweenService:Create(
			ResizeHandle,
			TweenInfo.new(.15, Enum.EasingStyle.Quad),
			{
				ImageColor3 = Color3.fromRGB(170,170,170),
				Size = UDim2.fromOffset(18,18),
				Rotation = 0
			}
		):Play()
	
	end)

	ResizeHandle.InputBegan:Connect(function(input)

		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
	
		Resizing = true
	
		ResizeStart = input.Position
		StartSize = GoalSize
	
		TweenService:Create(
			ResizeHandle,
			TweenInfo.new(.15),
			{
				Rotation = 90,
				Size = UDim2.fromOffset(22,22),
				ImageColor3 = Color3.fromRGB(255,255,255)
			}
		):Play()
	
	end)
	
	UserInputService.InputChanged:Connect(function(input)
	
		if not Resizing then
			return
		end
	
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
	
		local delta = input.Position - ResizeStart
	
		local width = math.clamp(
			StartSize.X.Offset + delta.X,
			MIN_WIDTH,
			MAX_WIDTH
		)
	
		local height = math.clamp(
			StartSize.Y.Offset + delta.Y,
			MIN_HEIGHT,
			MAX_HEIGHT
		)
	
		GoalSize = UDim2.fromOffset(width, height)
	
	end)
	
	UserInputService.InputEnded:Connect(function(input)
	
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
	
		if not Resizing then
			return
		end
	
		Resizing = false
	
		TweenService:Create(
			ResizeHandle,
			TweenInfo.new(.15),
			{
				Rotation = 0,
				Size = UDim2.fromOffset(18,18),
				ImageColor3 = Color3.fromRGB(170,170,170)
			}
		):Play()
	
	end)

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
