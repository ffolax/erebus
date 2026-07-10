-- UI.lua

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local CurrentTab

local UI = {}

local Theme = {
	BG = Color3.fromRGB(14, 14, 18),
	Panel = Color3.fromRGB(20, 20, 28),
	Topbar = Color3.fromRGB(24, 24, 35),
	Sidebar = Color3.fromRGB(18, 18, 26),

	Accent = Color3.fromRGB(160, 90, 255), -- main purple
	AccentDark = Color3.fromRGB(120, 60, 220),
	AccentGlow = Color3.fromRGB(190, 120, 255),

	Text = Color3.fromRGB(235, 235, 245),
	SubText = Color3.fromRGB(170, 170, 185)
}

function UI:Destroy()

    -- Disconnect all connections
    if self.Connections then
        for _, connection in ipairs(self.Connections) do
            if connection.Connected then
                connection:Disconnect()
            end
        end
    end

    -- Destroy the GUI
    if self.Screen then
        self.Screen:Destroy()
    end

end

function UI:Connect(signal, callback)

	local connection = signal:Connect(callback)
	table.insert(self.Connections, connection)

	return connection

end

function UI:Init(Context, Icons)

	getgenv().Erebus = getgenv().Erebus or {}

	if getgenv().Erebus.Instance then
	    getgenv().Erebus.Instance:Destroy()
	end
	
	getgenv().Erebus.Instance = self

	self.Context = Context
	self.Icons = Icons
	self.Theme = Theme
	self.Connections = {}
	self.TabCallbacks = {}

	-- ScreenGui
	local screen = Instance.new("ScreenGui")
	screen.Name = "erebusUi"
	screen.ResetOnSpawn = false
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.Parent = game.CoreGui

	local intro = Instance.new("TextLabel")
	intro.Name = "Intro"
	intro.Parent = screen
	intro.AnchorPoint = Vector2.new(0.5, 0.5)
	intro.Position = UDim2.new(0.5, 0, 0.5, 0)
	intro.Size = UDim2.fromScale(1,0)
	intro.BackgroundTransparency = 1
	intro.Text = "EREBUS"
	intro.Font = Enum.Font.GothamBlack
	intro.TextScaled = true
	intro.TextColor3 = Theme.Accent
	intro.TextTransparency = 1

	-- Main Window
	local main = Instance.new("Frame")
	main.Visible = false
	main.Name = "Main"
	main.Size = UDim2.new(0, 650, 0, 420)
	main.Position = UDim2.new(0.5, -325, 0.5, -210)
	main.BackgroundColor3 = Theme.BG
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
	main.Parent = screen

	local Stroke = Instance.new("UIStroke")
	Stroke.Thickness = 1
	Stroke.Transparency = 0.65
	Stroke.Color = Theme.AccentDark
	Stroke.Parent = main

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 10)
	mainCorner.Parent = main
	
	----------------------------------------------------
	-- TOPBAR
	----------------------------------------------------

	local topbar = Instance.new("Frame")
	topbar.Name = "Topbar"
	topbar.Size = UDim2.new(1, 0, 0, 36)
	topbar.BackgroundColor3 = Theme.Topbar
	topbar.BackgroundTransparency = 0.15
	topbar.BorderSizePixel = 0
	topbar.Parent = main
	topbar.ZIndex = 2

	local topCorner = Instance.new("UICorner")
	topCorner.CornerRadius = UDim.new(0, 10)
	topCorner.Parent = topbar

	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.Topbar),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 25, 45))
	})
	grad.Rotation = 90
	grad.Parent = topbar

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
	
		self:Connect(Button.MouseEnter,function()
	
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
	
		self:Connect(Button.MouseLeave,function()
	
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
		Color3.fromRGB(255, 80, 90)
	)
	
	local Maximize = CreateWindowButton(
		self.Icons.Window.Maximize,
		Color3.fromRGB(190, 120, 255)
	)
	
	local Minimize = CreateWindowButton(
		self.Icons.Window.Minimize,
		Color3.fromRGB(140, 100, 255)
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

	self:Connect(Exit.MouseButton1Click,function()

		screen:Destroy()

	end)

	local GoalPosition = main.Position
	local GoalSize = main.Size
	
	local Minimized = false
	local SavedSize = GoalSize
	
	self:Connect(Minimize.MouseButton1Click,function()
	
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
	
	self:Connect(Maximize.MouseButton1Click,function()
	
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
	
	self:Connect(topbar.InputBegan,function(input)
	
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
	
			Dragging = true
			DragStart = input.Position
			StartPos = GoalPosition
	
		end
	
	end)
	
	self:Connect(topbar.InputEnded,function(input)
	
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
	
			Dragging = false
	
		end
	
	end)
	
	self:Connect(UserInputService.InputChanged, function(input)
	
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
	
	local function LerpUDim2(a, b, t)
		return UDim2.new(
			a.X.Scale + (b.X.Scale - a.X.Scale) * t,
			a.X.Offset + (b.X.Offset - a.X.Offset) * t,
			a.Y.Scale + (b.Y.Scale - a.Y.Scale) * t,
			a.Y.Offset + (b.Y.Offset - a.Y.Offset) * t
		)
	end
	
	local SMOOTHNESS = 14

	self:Connect(RunService.RenderStepped, function(dt)

		local alpha = 1 - math.exp(-SMOOTHNESS * dt)
	
		main.Position = LerpUDim2(main.Position, GoalPosition, alpha)
		main.Size = LerpUDim2(main.Size, GoalSize, alpha)
	
	end)

	----------------------------------------------------
	-- SIDEBAR
	----------------------------------------------------

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0,170,1,-25)
	sidebar.Position = UDim2.new(0,0,0,25)
	sidebar.BackgroundColor3 = Theme.Sidebar
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

	local Divider = Instance.new("Frame")
	Divider.Size = UDim2.new(0,1,1,0)
	Divider.Position = UDim2.new(1,0,0,0)
	Divider.BackgroundColor3 = Theme.AccentDark
	Divider.BorderSizePixel = 0
	Divider.BackgroundTransparency = 0.65
	Divider.Parent = sidebar

	----------------------------------------------------
	-- CONTENT
	----------------------------------------------------

	local content = Instance.new("ScrollingFrame")
	content.Size = UDim2.new(1,-170,1,-46)
	content.Position = UDim2.new(0,170,0,46)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0

	content.CanvasSize = UDim2.new(0,0,0,0)
	content.AutomaticCanvasSize = Enum.AutomaticSize.Y

	content.ScrollBarThickness = 5

	content.Parent = main

	local Layout = Instance.new("UIListLayout")

	Layout.Padding = UDim.new(0,10)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	Layout.Parent = content

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

	self:Connect(ResizeHandle.MouseEnter,function()
	
		TweenService:Create(
		    ResizeHandle,
		    TweenInfo.new(.15, Enum.EasingStyle.Quad),
		    {
		        Rotation = 90,
		        Size = UDim2.fromOffset(22,22),
		    	ImageColor3 = Theme.AccentGlow
		    }
		):Play()
	
	end)
	
	self:Connect(ResizeHandle.MouseLeave,function()
	
		if Resizing then
			return
		end
	
		TweenService:Create(
			ResizeHandle,
			TweenInfo.new(.15, Enum.EasingStyle.Quad),
			{
				ImageColor3 = Theme.Accent,
				Size = UDim2.fromOffset(18,18),
				Rotation = 0
			}
		):Play()
	
	end)

	self:Connect(ResizeHandle.InputBegan,function(input)

		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end
	
		Resizing = true
	
		ResizeStart = input.Position
		StartSize = main.AbsoluteSize
	
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
	
	self:Connect(UserInputService.InputChanged,function(input)
	
		if not Resizing then
			return
		end
	
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
	
		local delta = input.Position - ResizeStart
	
		local width = math.clamp(StartSize.X + delta.X, MIN_WIDTH, MAX_WIDTH)
		local height = math.clamp(StartSize.Y + delta.Y, MIN_HEIGHT, MAX_HEIGHT)
	
		GoalSize = UDim2.fromOffset(width, height)
	
	end)
	
	self:Connect(UserInputService.InputEnded,function(input)
	
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
	self.TabOrder = { "Home", "Player", "Vehicle", "Visuals", "Misc" }

	for _, tabName in ipairs(self.TabOrder) do
		self:CreateTab(tabName, function(contentFrame)
	
			-- clear old UI
			self:ClearContent()
	
			-- run tab logic
			if self.TabCallbacks[tabName] then
				self.TabCallbacks[tabName](contentFrame)
			end
	
		end)
	end

	task.defer(function()

		local homeButton = self.Tabs["Home"]

		if homeButton then

			self:SetActiveTab(homeButton)

			if self.TabCallbacks["Home"] then

				self:ClearContent()

				self.Context:SetParent(self.Content)

				self.TabCallbacks["Home"](self.Context)

			end

		end

	end)

	----------------------------------------------------
	-- INTRO
	----------------------------------------------------

	task.spawn(function()

		TweenService:Create(intro, TweenInfo.new(0.4), {
			TextTransparency = 0
		}):Play()

		intro.AnchorPoint = Vector2.new(0.5, 0.5)
	
		task.wait(0.3)

		TweenService:Create(intro, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(1,0.05),
		}):Play()
	
		task.wait(4.5)
	
		main.Visible = true
	
		task.wait(0.2)
	
		TweenService:Create(intro, TweenInfo.new(0.25), {
			TextTransparency = 1
		}):Play()
	
		task.wait(0.3)
	
		intro:Destroy()
	
	end)

	print("[EREBUS] UI Initialized")
end

----------------------------------------------------
-- TAB CREATION
----------------------------------------------------

function UI:CreateTab(name, callback)

	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(1,0,0,38)
	button.BackgroundColor3 = Color3.fromRGB(25,25,35)
	button.BorderSizePixel = 0
	button.Text = name
	button.TextColor3 = Color3.fromRGB(200,200,200)
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.Parent = self.TabHolder

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,6)
	corner.Parent = button

	AddGlow(self, button)

	self:Connect(button.MouseEnter,function()

		if self.ActiveTab ~= button then

			TweenService:Create(
				button,
				TweenInfo.new(.15),
				{
					BackgroundColor3 = Color3.fromRGB(40,35,60)
				}
			):Play()

		end

	end)

	self:Connect(button.MouseLeave,function()

		if self.ActiveTab ~= button then

			TweenService:Create(
				button,
				TweenInfo.new(.15),
				{
					BackgroundColor3 = Color3.fromRGB(25,25,35)
				}
			):Play()

		end

	end)

	self:Connect(button.MouseButton1Click,function()

		self:SetActiveTab(button)

		if callback then

			self:ClearContent()

			self.Context:SetParent(self.Content)

			callback(self.Context)

		end

	end)

	self.Tabs[name] = button

	return button

end

----------------------------------------------------
-- ACTIVE TAB
----------------------------------------------------

function AddGlow(self, obj)
	if obj:FindFirstChild("GlowStroke") then
		obj.GlowStroke:Destroy()
	end

	local stroke = Instance.new("UIStroke")
	stroke.Name = "GlowStroke"
	stroke.Thickness = 1
	stroke.Transparency = 0.6
	stroke.Color = self.Theme.Accent
	stroke.Parent = obj

	return stroke
end

function UI:SetActiveTab(button)

	if self.ActiveTab then

		TweenService:Create(
			self.ActiveTab,
			TweenInfo.new(.15),
			{
				BackgroundColor3 = Color3.fromRGB(25,25,35)
			}
		):Play()

		AddGlow(self, button)

	end

	self.ActiveTab = button

	TweenService:Create(
		button,
		TweenInfo.new(.15),
		{
			BackgroundColor3 = Theme.AccentDark
		}
	):Play()

end

function UI:LoadTab(Module)

    if CurrentTab and CurrentTab.Destroy then
        CurrentTab:Destroy()
    end

    CurrentTab = Module

    if type(CurrentTab) == "function" then
        CurrentTab(self.Context)
    elseif CurrentTab.Build then
        CurrentTab:Build(self.Context)
    end

end

function UI:OpenTab(name)

    local Button = self.Tabs[name]
    local Callback = self.TabCallbacks[name]

    if not Button or not Callback then
        return
    end

    self:SetActiveTab(Button)
    self:ClearContent()

    self.Context:SetParent(self.Content)
    Callback(self.Context)

end

function UI:ClearContent()

	for _,v in ipairs(self.Content:GetChildren()) do

		if not v:IsA("UIListLayout") then
			v:Destroy()
		end

	end

end

function UI:RegisterTab(Name, Module)

    self.TabCallbacks[Name] = function(Context)
        self:LoadTab(Module)
    end

end

return UI
