local TweenService = game:GetService("TweenService")

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
	topbar.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
	topbar.BorderSizePixel = 0
	topbar.Parent = main

	local topCorner = Instance.new("UICorner")
	topCorner.CornerRadius = UDim.new(0, 10)
	topCorner.Parent = topbar

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -20, 1, 0)
	title.Position = UDim2.new(0, 10, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "Modern Hub"
	title.Font = Enum.Font.GothamSemibold
	title.TextSize = 14
	title.TextColor3 = Color3.fromRGB(255,255,255)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = topbar

	----------------------------------------------------
	-- SIDEBAR
	----------------------------------------------------

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 170, 1, -36)
	sidebar.Position = UDim2.new(0,0,0,36)
	sidebar.BackgroundColor3 = Color3.fromRGB(22,22,26)
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
