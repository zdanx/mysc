-- LocalScript | StarterPlayerScripts/CinematicUI

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local playerGui   = localPlayer:WaitForChild("PlayerGui")

repeat task.wait() until _G.CinematicCamera
local CC    = _G.CinematicCamera
local State = CC.State

-- ── Opsi open/close ──────────────────────────────────────────
local USE_ICON   = false   -- true = pakai TopbarPlus (butuh Icon di ReplicatedStorage)
local USE_TOGGLE = true    -- true = buat toggle button dari script

-- ── Warna ────────────────────────────────────────────────────
local C = {
	white    = Color3.fromRGB(255,255,255),
	light    = Color3.fromRGB(220,220,220),
	dark     = Color3.fromRGB(30,30,30),
	dark2    = Color3.fromRGB(38,38,38),
	dark3    = Color3.fromRGB(22,22,22),
	text     = Color3.fromRGB(230,230,235),
	muted    = Color3.fromRGB(140,140,152),
	green    = Color3.fromRGB(100,200,120),
	red      = Color3.fromRGB(200,80,80),
	accent   = Color3.fromRGB(120,100,220),
	accentHi = Color3.fromRGB(150,130,255),
}

-- ── ScreenGui ────────────────────────────────────────────────
local gui = Instance.new("ScreenGui")
gui.Name           = "CinematicDirectorUI"
gui.ResetOnSpawn   = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder   = 250
gui.Parent         = playerGui

-- ── Letterbox frames ─────────────────────────────────────────
local lbTop = Instance.new("Frame")
lbTop.Name = "LBTop"; lbTop.BackgroundColor3 = Color3.new(0,0,0)
lbTop.BorderSizePixel = 0; lbTop.ZIndex = 300
lbTop.Size = UDim2.new(1,0,0,0); lbTop.Position = UDim2.new(0,0,0,0)
lbTop.Parent = gui

local lbBot = Instance.new("Frame")
lbBot.Name = "LBBot"; lbBot.BackgroundColor3 = Color3.new(0,0,0)
lbBot.BorderSizePixel = 0; lbBot.ZIndex = 300
lbBot.Size = UDim2.new(1,0,0,0); lbBot.Position = UDim2.new(0,0,1,0)
lbBot.Parent = gui

local function setLetterbox(on)
	local sz = State.LetterboxSize
	TweenService:Create(lbTop, TweenInfo.new(0.35), {
		Size = UDim2.new(1,0,on and sz or 0,0)
	}):Play()
	TweenService:Create(lbBot, TweenInfo.new(0.35), {
		Size = UDim2.new(1,0,on and sz or 0,0),
		Position = UDim2.new(0,0,on and (1-sz) or 1,0)
	}):Play()
end

-- ── Helper: UICorner ─────────────────────────────────────────
local function corner(parent, rad)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, rad or 8)
	c.Parent = parent
end
local function stroke(parent, col, thick, transp)
	local s = Instance.new("UIStroke")
	s.Color = col or C.white; s.Thickness = thick or 1
	s.Transparency = transp or 0.6
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
end

-- ════════════════════════════════════════════════════════════
--  MAIN PANEL
-- ════════════════════════════════════════════════════════════
local panel = Instance.new("Frame")
panel.Name = "DirectorPanel"
panel.Size = UDim2.new(0,290,0,480)
panel.Position = UDim2.new(0,8,0.5,-240)
panel.BackgroundColor3 = C.dark
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Visible = false
panel.ZIndex = 51
panel.Parent = gui
corner(panel, 12)
stroke(panel, C.white, 1, 0.55)

-- responsive layout
local function adaptLayout()
	local vp = workspace.CurrentCamera.ViewportSize
	if vp.X > vp.Y then
		panel.Size = UDim2.new(0,290,0,320)
		panel.Position = UDim2.new(0,8,0.5,-160)
	else
		panel.Size = UDim2.new(0,290,0,480)
		panel.Position = UDim2.new(0,8,0.5,-240)
	end
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adaptLayout)
adaptLayout()

-- ── Header ───────────────────────────────────────────────────
local header = Instance.new("Frame")
header.Name = "Header"; header.Size = UDim2.new(1,0,0,42)
header.BackgroundColor3 = C.dark3; header.BackgroundTransparency = 0.15
header.BorderSizePixel = 0; header.ZIndex = 52; header.Parent = panel
corner(header, 12)
local headerFill = Instance.new("Frame")
headerFill.Size = UDim2.new(1,0,0,12); headerFill.Position = UDim2.new(0,0,1,-12)
headerFill.BackgroundColor3 = C.dark3; headerFill.BackgroundTransparency = 0.15
headerFill.BorderSizePixel = 0; headerFill.ZIndex = 52; headerFill.Parent = header
local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1,-16,0,1); headerLine.Position = UDim2.new(0,8,1,0)
headerLine.BackgroundColor3 = C.white; headerLine.BackgroundTransparency = 0.7
headerLine.BorderSizePixel = 0; headerLine.ZIndex = 53; headerLine.Parent = header
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1,-110,1,0); titleLabel.Position = UDim2.new(0,12,0,0)
titleLabel.BackgroundTransparency = 1; titleLabel.Text = "CINEMATIC DIRECTOR"
titleLabel.TextColor3 = C.white; titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 11; titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 53; titleLabel.Parent = header

local btnMin = Instance.new("TextButton")
btnMin.Size = UDim2.new(0,28,0,28); btnMin.Position = UDim2.new(1,-70,0,7)
btnMin.BackgroundColor3 = C.dark2; btnMin.BackgroundTransparency = 0.2
btnMin.Text = "—"; btnMin.TextColor3 = C.text
btnMin.Font = Enum.Font.GothamBold; btnMin.TextSize = 13
btnMin.AutoButtonColor = false; btnMin.ZIndex = 53; btnMin.Parent = header
corner(btnMin, 7); stroke(btnMin, C.white, 1, 0.75)

local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.new(0,28,0,28); btnClose.Position = UDim2.new(1,-36,0,7)
btnClose.BackgroundColor3 = C.dark2; btnClose.BackgroundTransparency = 0.2
btnClose.Text = "✕"; btnClose.TextColor3 = C.text
btnClose.Font = Enum.Font.GothamBold; btnClose.TextSize = 14
btnClose.AutoButtonColor = false; btnClose.ZIndex = 53; btnClose.Parent = header
corner(btnClose, 7); stroke(btnClose, C.white, 1, 0.75)

-- ── Drag panel ───────────────────────────────────────────────
local dragging, dragStart, startPos = false, nil, nil
header.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
		dragging = true; dragStart = inp.Position; startPos = panel.Position
	end
end)
UserInputService.InputChanged:Connect(function(inp)
	if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
		local delta = inp.Position - dragStart
		panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- ── Status bar ───────────────────────────────────────────────
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1,-14,0,24); statusBar.Position = UDim2.new(0,7,0,50)
statusBar.BackgroundColor3 = C.dark3; statusBar.BackgroundTransparency = 0.2
statusBar.BorderSizePixel = 0; statusBar.ZIndex = 52; statusBar.Parent = panel
corner(statusBar, 8); stroke(statusBar, C.white, 1, 0.75)

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0,7,0,7); statusDot.Position = UDim2.new(0,9,0.5,-3.5)
statusDot.BackgroundColor3 = C.red; statusDot.BorderSizePixel = 0
statusDot.ZIndex = 53; statusDot.Parent = statusBar
corner(statusDot, 4)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1,-26,1,0); statusLabel.Position = UDim2.new(0,20,0,0)
statusLabel.BackgroundTransparency = 1; statusLabel.Text = "INACTIVE  —  press [C] to start"
statusLabel.TextColor3 = C.muted; statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 9; statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.ZIndex = 53; statusLabel.Parent = statusBar

-- ── Tab bar ──────────────────────────────────────────────────
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1,-14,0,28); tabBar.Position = UDim2.new(0,7,0,82)
tabBar.BackgroundColor3 = C.dark3; tabBar.BackgroundTransparency = 0.2
tabBar.BorderSizePixel = 0; tabBar.ZIndex = 52; tabBar.Parent = panel
corner(tabBar, 8)
local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0,2)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Parent = tabBar

local tabNames = {"Modes","Settings","FX","Presets"}
local tabBtns  = {}
local currentTab = "Modes"

-- ── Content area (scroll) ─────────────────────────────────────
local contentArea = Instance.new("ScrollingFrame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1,-14,1,-148)
contentArea.Position = UDim2.new(0,7,0,118)
contentArea.BackgroundTransparency = 1
contentArea.BorderSizePixel = 0
contentArea.ScrollBarThickness = 3
contentArea.ScrollBarImageColor3 = C.accent
contentArea.CanvasSize = UDim2.new(0,0,0,0)
contentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentArea.ZIndex = 52
contentArea.Parent = panel

local contentLayout = Instance.new("UIListLayout")
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Padding = UDim.new(0,6)
contentLayout.Parent = contentArea
local contentPad = Instance.new("UIPadding")
contentPad.PaddingTop = UDim.new(0,4); contentPad.PaddingBottom = UDim.new(0,8)
contentPad.Parent = contentArea

-- ── Bottom bar (START / RESET ALL) ───────────────────────────
local bottomBar = Instance.new("Frame")
bottomBar.Size = UDim2.new(1,-14,0,38); bottomBar.Position = UDim2.new(0,7,1,-44)
bottomBar.BackgroundTransparency = 1; bottomBar.BorderSizePixel = 0
bottomBar.ZIndex = 52; bottomBar.Parent = panel
local bottomLayout = Instance.new("UIListLayout")
bottomLayout.FillDirection = Enum.FillDirection.Horizontal
bottomLayout.SortOrder = Enum.SortOrder.LayoutOrder
bottomLayout.Padding = UDim.new(0,8)
bottomLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
bottomLayout.VerticalAlignment = Enum.VerticalAlignment.Center
bottomLayout.Parent = bottomBar

local btnStart = Instance.new("TextButton")
btnStart.Size = UDim2.new(0,128,0,32); btnStart.BackgroundColor3 = C.dark2
btnStart.BackgroundTransparency = 0.05; btnStart.Text = "START"
btnStart.TextColor3 = C.white; btnStart.Font = Enum.Font.GothamBold
btnStart.TextSize = 12; btnStart.AutoButtonColor = false
btnStart.ZIndex = 53; btnStart.Parent = bottomBar
corner(btnStart, 8); stroke(btnStart, C.white, 1, 0.55)

local btnReset = Instance.new("TextButton")
btnReset.Size = UDim2.new(0,128,0,32); btnReset.BackgroundColor3 = C.dark2
btnReset.BackgroundTransparency = 0.05; btnReset.Text = "RESET ALL"
btnReset.TextColor3 = C.muted; btnReset.Font = Enum.Font.GothamBold
btnReset.TextSize = 12; btnReset.AutoButtonColor = false
btnReset.ZIndex = 53; btnReset.Parent = bottomBar
corner(btnReset, 8); stroke(btnReset, C.white, 1, 0.75)

-- ════════════════════════════════════════════════════════════
--  TOGGLE BUTTON (pojok kanan tengah)
-- ════════════════════════════════════════════════════════════
local toggleBtn
if USE_TOGGLE then
	toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "CinematicToggle"
	toggleBtn.Size = UDim2.new(0,28,0,72)
	toggleBtn.Position = UDim2.new(1,-28,0.5,-36)
	toggleBtn.BackgroundColor3 = C.dark3
	toggleBtn.BackgroundTransparency = 0.1
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Text = "🎬"
	toggleBtn.TextColor3 = C.white
	toggleBtn.Font = Enum.Font.GothamBold
	toggleBtn.TextSize = 14
	toggleBtn.AutoButtonColor = false
	toggleBtn.ZIndex = 60
	toggleBtn.Parent = gui
	corner(toggleBtn, 8)
	stroke(toggleBtn, C.accent, 1, 0.4)

	toggleBtn.MouseButton1Click:Connect(function()
		panel.Visible = not panel.Visible
	end)
end

-- panel open/close
local function showPanel(v)
	panel.Visible = v
end

btnMin.MouseButton1Click:Connect(function()
	panel.Visible = false
end)
btnClose.MouseButton1Click:Connect(function()
	if State.Active then CC.Stop() end
	panel.Visible = false
end)

-- ════════════════════════════════════════════════════════════
--  HELPER: section header
-- ════════════════════════════════════════════════════════════
local function makeSection(label, order)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1,0,0,16); lbl.BackgroundTransparency = 1
	lbl.Text = label; lbl.TextColor3 = C.muted
	lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 9
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.LayoutOrder = order; lbl.ZIndex = 53; lbl.Parent = contentArea
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0,4); pad.Parent = lbl
	return lbl
end

-- ════════════════════════════════════════════════════════════
--  TAB: MODES
-- ════════════════════════════════════════════════════════════
local modePhaseOrder = {"Intro","Groove","Drop","Beat","Ramp","Cinematic","FX","Static","Auto"}
local modeHighlightFn

local function buildModesTab()
	local order = 0
	local highlightMap = {}

	for _, phase in ipairs(modePhaseOrder) do
		local hasAny = false
		for _, n in ipairs(CC.ModeOrder) do
			if CC.ModeMeta[n] and CC.ModeMeta[n].phase == phase then hasAny = true break end
		end
		if not hasAny then continue end

		order += 1
		makeSection(phase:upper(), order)

		local grid = Instance.new("Frame")
		grid.Size = UDim2.new(1,0,0,0)
		grid.BackgroundTransparency = 1
		grid.AutomaticSize = Enum.AutomaticSize.Y
		grid.LayoutOrder = order + 1
		grid.ZIndex = 53; grid.Parent = contentArea
		order += 1

		local gridLayout = Instance.new("UIGridLayout")
		gridLayout.CellSize = UDim2.new(0,82,0,26)
		gridLayout.CellPadding = UDim2.new(0,4,0,4)
		gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		gridLayout.Parent = grid

		for _, name in ipairs(CC.ModeOrder) do
			local meta = CC.ModeMeta[name]
			if not meta or meta.phase ~= phase then continue end

			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(0,82,0,26)
			btn.BackgroundColor3 = C.dark2; btn.BackgroundTransparency = 0.2
			btn.Text = meta.label; btn.TextColor3 = C.muted
			btn.Font = Enum.Font.GothamMedium; btn.TextSize = 9
			btn.AutoButtonColor = false; btn.ZIndex = 54; btn.Parent = grid
			corner(btn, 7); stroke(btn, C.white, 1, 0.8)

			highlightMap[name] = btn

			btn.MouseButton1Click:Connect(function()
				CC.SetMode(name)
				if not State.Active then CC.Start() end
			end)
		end
	end

	modeHighlightFn = function(modeName)
		for n, b in pairs(highlightMap) do
			if n == modeName then
				b.BackgroundColor3 = C.accent
				b.BackgroundTransparency = 0.1
				b.TextColor3 = C.white
			else
				b.BackgroundColor3 = C.dark2
				b.BackgroundTransparency = 0.2
				b.TextColor3 = C.muted
			end
		end
	end
	modeHighlightFn(State.CurrentMode)
end

-- ════════════════════════════════════════════════════════════
--  TAB: SETTINGS
-- ════════════════════════════════════════════════════════════
local function makeSlider(label, min, max, getValue, setValue, order)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1,0,0,44); row.BackgroundColor3 = C.dark2
	row.BackgroundTransparency = 0.25; row.BorderSizePixel = 0
	row.LayoutOrder = order; row.ZIndex = 53; row.Parent = contentArea
	corner(row, 8)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.55,0,0,18); lbl.Position = UDim2.new(0,10,0,4)
	lbl.BackgroundTransparency = 1; lbl.Text = label
	lbl.TextColor3 = C.text; lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 54; lbl.Parent = row

	local valLbl = Instance.new("TextLabel")
	valLbl.Size = UDim2.new(0.4,0,0,18); valLbl.Position = UDim2.new(0.58,0,0,4)
	valLbl.BackgroundTransparency = 1
	valLbl.Text = tostring(math.round(getValue()*100)/100)
	valLbl.TextColor3 = C.accentHi; valLbl.Font = Enum.Font.GothamBold
	valLbl.TextSize = 10; valLbl.TextXAlignment = Enum.TextXAlignment.Right
	valLbl.ZIndex = 54; valLbl.Parent = row

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1,-20,0,6); track.Position = UDim2.new(0,10,0,30)
	track.BackgroundColor3 = C.dark3; track.BackgroundTransparency = 0.1
	track.BorderSizePixel = 0; track.ZIndex = 54; track.Parent = row
	corner(track, 3)

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = C.accent; fill.BorderSizePixel = 0
	fill.ZIndex = 55; fill.Parent = track
	corner(fill, 3)

	local function updateFill()
		local ratio = math.clamp((getValue()-min)/(max-min),0,1)
		fill.Size = UDim2.new(ratio,0,1,0)
		valLbl.Text = tostring(math.round(getValue()*100)/100)
	end
	updateFill()

	local sliding = false
	track.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			sliding = true
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if sliding and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			local absPos = track.AbsolutePosition
			local absSize = track.AbsoluteSize
			local ratio = math.clamp((inp.Position.X - absPos.X) / absSize.X, 0, 1)
			setValue(min + (max-min)*ratio)
			updateFill()
		end
	end)
	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			sliding = false
		end
	end)

	return { update = updateFill }
end

local function buildSettingsTab()
	local o = 0
	local function next() o += 1 return o end

	makeSection("GLOBAL", next())
	makeSlider("Master FOV",    30, 120, function() return State.MasterFOV end,    function(v) State.MasterFOV = v end, next())
	makeSlider("Smoothness",    1,  12,  function() return State.Smoothness end,   function(v) State.Smoothness = v end, next())
	makeSlider("Master Speed",  0.1,4,   function() return State.MasterSpeed end,  function(v) State.MasterSpeed = v end, next())
	makeSlider("Distance Mult", 0.3,3,   function() return State.DistanceMult end, function(v) State.DistanceMult = v end, next())
	makeSlider("Height Offset", -8, 15,  function() return State.HeightOffset end, function(v) State.HeightOffset = v end, next())
	makeSection("AUTO SWITCH", next())
	makeSlider("Interval (s)",  1,  30,  function() return State.AutoInterval end,  function(v) State.AutoInterval = v end, next())
	makeSection("CURRENT MODE", next())
	makeSlider("Radius",  1, 50,  function() return (State.ModeSettings[State.CurrentMode] or {radius=12}).radius end, function(v) if State.ModeSettings[State.CurrentMode] then State.ModeSettings[State.CurrentMode].radius = v end end, next())
	makeSlider("Height",  0, 30,  function() return (State.ModeSettings[State.CurrentMode] or {height=4}).height end,  function(v) if State.ModeSettings[State.CurrentMode] then State.ModeSettings[State.CurrentMode].height = v end end, next())
	makeSlider("Speed",   0, 5,   function() return (State.ModeSettings[State.CurrentMode] or {speed=0.5}).speed end,  function(v) if State.ModeSettings[State.CurrentMode] then State.ModeSettings[State.CurrentMode].speed = v end end, next())
	makeSlider("FOV",     20,120, function() return (State.ModeSettings[State.CurrentMode] or {fov=60}).fov end,     function(v) if State.ModeSettings[State.CurrentMode] then State.ModeSettings[State.CurrentMode].fov = v end end, next())
end

-- ════════════════════════════════════════════════════════════
--  TAB: FX
-- ════════════════════════════════════════════════════════════
local function makeToggleRow(label, getValue, setValue, order)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1,0,0,34); row.BackgroundColor3 = C.dark2
	row.BackgroundTransparency = 0.25; row.BorderSizePixel = 0
	row.LayoutOrder = order; row.ZIndex = 53; row.Parent = contentArea
	corner(row, 8)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1,-60,1,0); lbl.Position = UDim2.new(0,10,0,0)
	lbl.BackgroundTransparency = 1; lbl.Text = label
	lbl.TextColor3 = C.text; lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 54; lbl.Parent = row

	local tog = Instance.new("TextButton")
	tog.Size = UDim2.new(0,44,0,22); tog.Position = UDim2.new(1,-52,0.5,-11)
	tog.BackgroundColor3 = getValue() and C.accent or C.dark3
	tog.BackgroundTransparency = 0.1; tog.Text = getValue() and "ON" or "OFF"
	tog.TextColor3 = C.white; tog.Font = Enum.Font.GothamBold
	tog.TextSize = 10; tog.AutoButtonColor = false
	tog.ZIndex = 54; tog.Parent = row
	corner(tog, 11)

	tog.MouseButton1Click:Connect(function()
		setValue(not getValue())
		tog.BackgroundColor3 = getValue() and C.accent or C.dark3
		tog.Text = getValue() and "ON" or "OFF"
		CC.UpdateFX()
	end)
end

local function makeDropRow(label, options, getValue, setValue, order)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1,0,0,34); row.BackgroundColor3 = C.dark2
	row.BackgroundTransparency = 0.25; row.BorderSizePixel = 0
	row.LayoutOrder = order; row.ZIndex = 53; row.Parent = contentArea
	corner(row, 8)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.5,0,1,0); lbl.Position = UDim2.new(0,10,0,0)
	lbl.BackgroundTransparency = 1; lbl.Text = label
	lbl.TextColor3 = C.text; lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 54; lbl.Parent = row

	local idx = 1
	for i, v in ipairs(options) do if v == getValue() then idx = i break end end

	local valBtn = Instance.new("TextButton")
	valBtn.Size = UDim2.new(0,90,0,24); valBtn.Position = UDim2.new(1,-98,0.5,-12)
	valBtn.BackgroundColor3 = C.dark3; valBtn.BackgroundTransparency = 0.1
	valBtn.Text = getValue(); valBtn.TextColor3 = C.accentHi
	valBtn.Font = Enum.Font.GothamBold; valBtn.TextSize = 10
	valBtn.AutoButtonColor = false; valBtn.ZIndex = 54; valBtn.Parent = row
	corner(valBtn, 7)

	valBtn.MouseButton1Click:Connect(function()
		idx = idx % #options + 1
		setValue(options[idx])
		valBtn.Text = options[idx]
		CC.UpdateFX()
	end)
end

local function buildFXTab()
	local o = 0
	local function next() o += 1 return o end
	makeSection("OVERLAYS", next())
	makeToggleRow("Letterbox",   function() return State.Letterbox   end, function(v) State.Letterbox = v; setLetterbox(v) end, next())
	makeToggleRow("Vignette",    function() return State.Vignette    end, function(v) State.Vignette = v end, next())
	makeToggleRow("Film Grain",  function() return State.FilmGrain   end, function(v) State.FilmGrain = v end, next())
	makeSection("LIGHTING FX", next())
	makeToggleRow("Bloom",       function() return State.Bloom       end, function(v) State.Bloom = v end, next())
	makeSlider("Bloom Intensity",0.1,3, function() return State.BloomIntensity end, function(v) State.BloomIntensity=v; CC.UpdateFX() end, next())
	makeToggleRow("Depth of Field", function() return State.DOF      end, function(v) State.DOF = v end, next())
	makeSlider("DOF Distance",5,80, function() return State.DOFDistance end, function(v) State.DOFDistance=v; CC.UpdateFX() end, next())
	makeSection("COLOR", next())
	makeDropRow("Color Grade", {"Off","Warm","Cool","Noir","Vivid"}, function() return State.ColorGrade end, function(v) State.ColorGrade=v end, next())
	makeSection("TRANSITIONS", next())
	makeToggleRow("Flash Cuts",  function() return State.FlashTransitions end, function(v) State.FlashTransitions=v end, next())
	makeToggleRow("Fade Cuts",   function() return State.FadeTransitions  end, function(v) State.FadeTransitions=v  end, next())
end

-- ════════════════════════════════════════════════════════════
--  TAB: PRESETS
-- ════════════════════════════════════════════════════════════
local presetData = {
	{ name="Hype",     desc="Fast cuts, strobe, high energy" },
	{ name="Chill",    desc="Slow float, cool grade, relaxed" },
	{ name="Cinematic",desc="Noir, vignette, film grain, moody" },
}

local function buildPresetsTab()
	local o = 0
	makeSection("PRESETS", o)
	for i, pd in ipairs(presetData) do
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1,0,0,54); card.BackgroundColor3 = C.dark2
		card.BackgroundTransparency = 0.25; card.BorderSizePixel = 0
		card.LayoutOrder = i; card.ZIndex = 53; card.Parent = contentArea
		corner(card, 8); stroke(card, C.white, 1, 0.8)

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(1,-90,0,20); nameLbl.Position = UDim2.new(0,10,0,8)
		nameLbl.BackgroundTransparency = 1; nameLbl.Text = pd.name
		nameLbl.TextColor3 = C.white; nameLbl.Font = Enum.Font.GothamBold
		nameLbl.TextSize = 13; nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.ZIndex = 54; nameLbl.Parent = card

		local descLbl = Instance.new("TextLabel")
		descLbl.Size = UDim2.new(1,-90,0,18); descLbl.Position = UDim2.new(0,10,0,28)
		descLbl.BackgroundTransparency = 1; descLbl.Text = pd.desc
		descLbl.TextColor3 = C.muted; descLbl.Font = Enum.Font.Gotham
		descLbl.TextSize = 9; descLbl.TextXAlignment = Enum.TextXAlignment.Left
		descLbl.ZIndex = 54; descLbl.Parent = card

		local loadBtn = Instance.new("TextButton")
		loadBtn.Size = UDim2.new(0,62,0,28); loadBtn.Position = UDim2.new(1,-76,0.5,-14)
		loadBtn.BackgroundColor3 = C.dark2; loadBtn.BackgroundTransparency = 0.05
		loadBtn.Text = "LOAD"; loadBtn.TextColor3 = C.white
		loadBtn.Font = Enum.Font.GothamBold; loadBtn.TextSize = 11
		loadBtn.AutoButtonColor = false; loadBtn.ZIndex = 54; loadBtn.Parent = card
		corner(loadBtn, 8); stroke(loadBtn, C.white, 1, 0.55)

		loadBtn.MouseButton1Click:Connect(function()
			CC.LoadPreset(pd.name)
			if not State.Active then CC.Start() end
		end)
	end
end

-- ════════════════════════════════════════════════════════════
--  TAB SWITCHING
-- ════════════════════════════════════════════════════════════
local tabBuilt = {}

local function clearContent()
	for _, c in ipairs(contentArea:GetChildren()) do
		if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
			c:Destroy()
		end
	end
end

local function switchTab(name)
	currentTab = name
	for n, btn in pairs(tabBtns) do
		if n == name then
			btn.BackgroundColor3 = C.dark3
			btn.BackgroundTransparency = 0.05
			btn.TextColor3 = C.white
		else
			btn.BackgroundColor3 = C.dark2
			btn.BackgroundTransparency = 0.4
			btn.TextColor3 = C.muted
		end
	end
	clearContent()
	if name == "Modes" and not tabBuilt.Modes then
		buildModesTab(); tabBuilt.Modes = true
	elseif name == "Settings" and not tabBuilt.Settings then
		buildSettingsTab(); tabBuilt.Settings = true
	elseif name == "FX" and not tabBuilt.FX then
		buildFXTab(); tabBuilt.FX = true
	elseif name == "Presets" and not tabBuilt.Presets then
		buildPresetsTab(); tabBuilt.Presets = true
	else
		if name == "Modes" then buildModesTab()
		elseif name == "Settings" then buildSettingsTab()
		elseif name == "FX" then buildFXTab()
		elseif name == "Presets" then buildPresetsTab()
		end
	end
end

for i, name in ipairs(tabNames) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,60,0,22); btn.LayoutOrder = i
	btn.BackgroundColor3 = C.dark2; btn.BackgroundTransparency = 0.4
	btn.Text = name; btn.TextColor3 = C.muted
	btn.Font = Enum.Font.GothamMedium; btn.TextSize = 10
	btn.AutoButtonColor = false; btn.ZIndex = 53; btn.Parent = tabBar
	corner(btn, 7)
	tabBtns[name] = btn
	btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

switchTab("Modes")

-- ════════════════════════════════════════════════════════════
--  START / RESET ALL BUTTONS
-- ════════════════════════════════════════════════════════════
btnStart.MouseButton1Click:Connect(function()
	CC.Toggle()
	task.defer(function()
		if State.Active then
			btnStart.Text = "STOP"
			btnStart.BackgroundColor3 = C.red
			btnStart.BackgroundTransparency = 0.05
		else
			btnStart.Text = "START"
			btnStart.BackgroundColor3 = C.dark2
			btnStart.BackgroundTransparency = 0.05
		end
	end)
end)

btnReset.MouseButton1Click:Connect(function()
	local prev = btnReset.BackgroundColor3
	btnReset.BackgroundColor3 = C.white
	btnReset.BackgroundTransparency = 0.2
	btnReset.TextColor3 = C.dark
	CC.ResetAll()
	task.delay(0.18, function()
		if btnReset.Parent then
			btnReset.BackgroundColor3 = prev
			btnReset.BackgroundTransparency = 0.05
			btnReset.TextColor3 = C.muted
		end
	end)
end)

-- ════════════════════════════════════════════════════════════
--  TOPBAR ICON (opsional)
-- ════════════════════════════════════════════════════════════
if USE_ICON then
	local ok, Icon = pcall(function()
		return require(ReplicatedStorage:WaitForChild("Icon", 3))
	end)
	if ok and Icon then
		local icon = Icon.new()
		pcall(function() icon:setImage("rbxassetid://77425709273161") end)
		pcall(function() icon:setLabel("") end)
		pcall(function() icon:setOrder(3) end)
		icon.selected:Connect(function()
			panel.Visible = not panel.Visible
			pcall(function() icon:deselect() end)
		end)
	end
end

-- ════════════════════════════════════════════════════════════
--  GLOBAL CinematicUI CALLBACKS
-- ════════════════════════════════════════════════════════════
_G.CinematicUI = {
	OnStart = function()
		btnStart.Text = "STOP"; btnStart.BackgroundColor3 = C.red
		btnStart.BackgroundTransparency = 0.05; btnStart.TextColor3 = C.white
		statusDot.BackgroundColor3 = C.green
		local meta = CC.ModeMeta[State.CurrentMode]
		statusLabel.Text = "ACTIVE  —  " .. (meta and meta.label or State.CurrentMode)
		statusLabel.TextColor3 = C.text
		if State.Letterbox then setLetterbox(true) end
	end,
	OnStop = function()
		btnStart.Text = "START"; btnStart.BackgroundColor3 = C.dark2
		btnStart.BackgroundTransparency = 0.05; btnStart.TextColor3 = C.white
		statusDot.BackgroundColor3 = C.red
		statusLabel.Text = "INACTIVE  —  press [C] to start"
		statusLabel.TextColor3 = C.muted
		setLetterbox(false)
	end,
	OnModeChange = function(modeName)
		if modeHighlightFn then modeHighlightFn(modeName) end
		if State.Active then
			local meta = CC.ModeMeta[modeName]
			statusLabel.Text = "ACTIVE  —  " .. (meta and meta.label or modeName)
		end
	end,
	SetLetterbox = setLetterbox,
}

-- ── Timer update ─────────────────────────────────────────────
task.spawn(function()
	while gui.Parent do
		if State.Active then
			local elapsed = os.clock() - State.StartTime
			local mins = math.floor(elapsed / 60)
			local secs = math.floor(elapsed % 60)
			local meta  = CC.ModeMeta[State.CurrentMode]
			statusLabel.Text = string.format("ACTIVE — %s — %02d:%02d", meta and meta.label or State.CurrentMode, mins, secs)
		end
		task.wait(1)
	end
end)

-- ── V key toggle UI ──────────────────────────────────────────
UserInputService.InputBegan:Connect(function(inp, gpe)
	if not gpe and inp.KeyCode == Enum.KeyCode.V then
		gui.Enabled = not gui.Enabled
	end
end)
