local g = getgenv()
if (game.PlaceId == 13967668166 or game.PlaceId == 99154507657228 or game.PlaceId == 99644611200703)
    and g.Flames_Hub_Base_Loader_Currently_Shown
    and not g.LifeTogetherRP_Admin then
    if g.notify then
        return g.notify("Peringatan", "Harap muat skrip Life Together RP terlebih dahulu!", 5)
    else
        return warn("Harap muat skrip Life Together RP terlebih dahulu.")
    end
end
if getgenv().FreeEmotes_Enabled then
    if g.notify then
        return g.notify("Peringatan", "Flames Emotes GUI sudah berjalan! Tunggu hingga proses memuat selesai.", 6.5)
    else
        return warn("Flames Emotes GUI sudah berjalan!")
    end
end
getgenv().FreeEmotes_Enabled = true

local Workspace = cloneref and cloneref(game:GetService("Workspace")) or game:GetService("Workspace")
local UserInputService = cloneref and cloneref(game:GetService("UserInputService")) or game:GetService("UserInputService")
local TweenService = cloneref and cloneref(game:GetService("TweenService")) or game:GetService("TweenService")
local Players = cloneref and cloneref(game:GetService("Players")) or game:GetService("Players")
local RunService = cloneref and cloneref(game:GetService("RunService")) or game:GetService("RunService")
local AvatarEditorService = cloneref and cloneref(game:GetService("AvatarEditorService")) or game:GetService("AvatarEditorService")
local HttpService = cloneref and cloneref(game:GetService("HttpService")) or game:GetService("HttpService")
local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")

local view_port_size = setmetatable({}, {
    __index = function(_, key)
        local cam = Workspace.CurrentCamera
        local size = cam and cam.ViewportSize or Vector2.new(1920, 1080)
        if key == "X" then return size.X
        elseif key == "Y" then return size.Y end
    end
})

local all_clipboards = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)

function scale(axis, value)
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local baseWidth, baseHeight = 1920, 1080
    local scaleFactor = isMobile and 1.8 or 1.2

    if axis == "X" then
        return value * (view_port_size.X / baseWidth) * scaleFactor
    elseif axis == "Y" then
        return value * (view_port_size.Y / baseHeight) * scaleFactor
    end
end

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChild("Humanoid") or character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 50)
local lastPosition = character.PrimaryPart and character.PrimaryPart.Position or Vector3.new()

if not getgenv().character_added_conn_watcher then
    getgenv().character_added_conn_watcher = true
    task.wait(0.1)
    player.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
        humanoid = newCharacter:WaitForChild("Humanoid")
        lastPosition = character.PrimaryPart and character.PrimaryPart.Position or Vector3.new()
    end)
end

-- ==================== PENGATURAN & TEMA ====================
getgenv().Settings = getgenv().Settings or {}
getgenv().Settings["Stop Emote When Moving"] = true
getgenv().Settings["Fade In"]     = 0.1
getgenv().Settings["Fade Out"]    = 0.1
getgenv().Settings["Weight"]      = 1
getgenv().Settings["Speed"]       = 1
getgenv().Settings["Allow Invisible  "] = true
getgenv().Settings["Time Position"] = 0
getgenv().Settings["Freeze On Finish"] = false
getgenv().Settings["Looped"] = true
getgenv().Settings["Stop Other Animations On Play"] = true

local THEME = {
    Background = Color3.fromRGB(18, 18, 24),
    Sidebar = Color3.fromRGB(24, 24, 32),
    Card = Color3.fromRGB(28, 28, 38),
    Accent = Color3.fromRGB(108, 92, 231),
    AccentHover = Color3.fromRGB(129, 115, 255),
    Text = Color3.fromRGB(240, 240, 245),
    TextSub = Color3.fromRGB(160, 160, 175),
    Border = Color3.fromRGB(45, 45, 60),
    Success = Color3.fromRGB(46, 213, 115),
    Danger = Color3.fromRGB(255, 71, 87)
}

local savedEmotes = {}
local SAVE_FILE = "FlamesEmotes_NewNEWN3WSaved.json"

local function loadSavedEmotes()
    local success, data = pcall(function()
        if readfile and isfile and isfile(SAVE_FILE) then
            return HttpService:JSONDecode(readfile(SAVE_FILE))
        end
        return {}
    end)
    savedEmotes = (success and typeof(data) == "table") and data or {}

    for _, v in ipairs(savedEmotes) do
        if not v.AnimationId then
            v.AnimationId = "rbxassetid://" .. tostring(v.AssetId or v.Id)
        end
        if v.Favorite == nil then v.Favorite = false end
    end
end

getgenv().saveEmotesToData = function()
    pcall(function()
        if writefile then
            writefile(SAVE_FILE, HttpService:JSONDecode(savedEmotes))
        end
    end)
end

loadSavedEmotes()
getgenv().currently_saved_emotes_list = savedEmotes

-- ==================== SISTEM ANIMASI ====================
local CurrentTrack = nil
local function LoadTrack(id)
    if CurrentTrack then CurrentTrack:Stop(getgenv().Settings["Fade Out"]) end
    
    local animId
    local ok, result = pcall(function() return game:GetObjects("rbxassetid://" .. tostring(id)) end)
    if ok and result and #result > 0 then
        local anim = result[1]
        animId = anim:IsA("Animation") and anim.AnimationId or ("rbxassetid://" .. tostring(id))
    else
        animId = "rbxassetid://" .. tostring(id)
    end
    
    local newAnim = Instance.new("Animation")
    newAnim.AnimationId = animId
    local newTrack = humanoid:LoadAnimation(newAnim)
    newTrack.Priority = Enum.AnimationPriority.Action4
    
    local weight = getgenv().Settings["Weight"]
    if weight == 0 then weight = 0.001 end
    
    if getgenv().Settings["Stop Other Animations On Play"] then
        for _, t in pairs(humanoid.Animator:GetPlayingAnimationTracks()) do
            if t.Priority ~= Enum.AnimationPriority.Action4 then t:Stop() end
        end
    end
    
    newTrack:Play(getgenv().Settings["Fade In"], weight, getgenv().Settings["Speed"])
    CurrentTrack = newTrack 
    CurrentTrack.TimePosition = math.clamp(getgenv().Settings["Time Position"], 0, 1) * (CurrentTrack.Length or 1)
    CurrentTrack.Priority = Enum.AnimationPriority.Action4
    CurrentTrack.Looped = getgenv().Settings["Looped"]
    return newTrack
end

if not getgenv().run_service_gaze_emotes_check then
    getgenv().run_service_gaze_emotes_check = true
    RunService.RenderStepped:Connect(function()
        if getgenv().Settings["Looped"] and CurrentTrack and CurrentTrack.IsPlaying then
            CurrentTrack.Looped = getgenv().Settings["Looped"]
        end

        if character:FindFirstChild("HumanoidRootPart") then
            local root = character.HumanoidRootPart
            if getgenv().Settings["Stop Emote When Moving"] and CurrentTrack and CurrentTrack.IsPlaying then
                local moved = (root.Position - lastPosition).Magnitude > 0.1
                local jumped = humanoid and humanoid:GetState() == Enum.HumanoidStateType.Jumping
                if moved or jumped then
                    CurrentTrack:Stop(getgenv().Settings["Fade Out"])
                    CurrentTrack = nil
                end
            end
            lastPosition = root.Position
        end
    end)
end

-- ==================== ELEMEN DESAIN UI ====================
local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function addStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or THEME.Border
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local gui = Instance.new("ScreenGui")
gui.Name = "FlamesEmoteGUI"
gui.Parent = CoreGui
gui.Enabled = false
gui.DisplayOrder = 999

local mainContainer = Instance.new("Frame")
mainContainer.Size = UDim2.new(0, scale("X", 680), 0, scale("Y", 440))
mainContainer.Position = UDim2.new(0.5, -scale("X", 340), 0.5, -scale("Y", 220))
mainContainer.BackgroundColor3 = THEME.Background
mainContainer.Active = true
mainContainer.Draggable = true
mainContainer.ClipsDescendants = true
mainContainer.Parent = gui
addCorner(mainContainer, 14)
addStroke(mainContainer, THEME.Border, 1.5)

-- Header Bar
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, scale("Y", 45))
header.BackgroundColor3 = THEME.Sidebar
header.Parent = mainContainer
addCorner(header, 14)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.5, 0, 1, 0)
title.Position = UDim2.new(0, scale("X", 16), 0, 0)
title.BackgroundTransparency = 1
title.Text = "✨ SaZam Emotes"
title.TextColor3 = THEME.Text
title.Font = Enum.Font.GothamBold
title.TextSize = scale("Y", 18)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Tab Container
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -scale("X", 20), 0, scale("Y", 36))
tabContainer.Position = UDim2.new(0, scale("X", 10), 0, scale("Y", 52))
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainContainer

local function createTabBtn(text, pos, sizeX)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(sizeX, -scale("X", 6), 1, 0)
    btn.Position = pos
    btn.BackgroundColor3 = THEME.Sidebar
    btn.Text = text
    btn.TextColor3 = THEME.TextSub
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = scale("Y", 13)
    btn.Parent = tabContainer
    addCorner(btn, 8)
    addStroke(btn, THEME.Border, 1)
    return btn
end

local catalogTabBtn = createTabBtn("🛒 Katalog Emote", UDim2.new(0, 0, 0, 0), 0.33)
local savedTabBtn = createTabBtn("⭐ Tersimpan", UDim2.new(0.33, scale("X", 3), 0, 0), 0.33)
local settingsTabBtn = createTabBtn("⚙️ Pengaturan", UDim2.new(0.66, scale("X", 6), 0, 0), 0.34)

local function setTabActive(activeBtn)
    for _, btn in ipairs({catalogTabBtn, savedTabBtn, settingsTabBtn}) do
        local isActive = (btn == activeBtn)
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = isActive and THEME.Accent or THEME.Sidebar,
            TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or THEME.TextSub
        }):Play()
    end
end
setTabActive(catalogTabBtn)

-- Content Frames
local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1, -scale("X", 20), 1, -scale("Y", 100))
contentHolder.Position = UDim2.new(0, scale("X", 10), 0, scale("Y", 94))
contentHolder.BackgroundTransparency = 1
contentHolder.Parent = mainContainer

local catalogFrame = Instance.new("Frame", contentHolder)
catalogFrame.Size = UDim2.new(1, 0, 1, 0)
catalogFrame.BackgroundTransparency = 1

local savedFrame = Instance.new("Frame", contentHolder)
savedFrame.Size = UDim2.new(1, 0, 1, 0)
savedFrame.BackgroundTransparency = 1
savedFrame.Visible = false

local settingsFrame = Instance.new("Frame", contentHolder)
settingsFrame.Size = UDim2.new(1, 0, 1, 0)
settingsFrame.BackgroundTransparency = 1
settingsFrame.Visible = false

-- ==================== TAB KATALOG ====================
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(0.5, -scale("X", 5), 0, scale("Y", 32))
searchBox.PlaceholderText = "🔍 Cari emote..."
searchBox.BackgroundColor3 = THEME.Sidebar
searchBox.TextColor3 = THEME.Text
searchBox.PlaceholderColor3 = THEME.TextSub
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = scale("Y", 13)
searchBox.ClearTextOnFocus = false
searchBox.Text = ""
searchBox.Parent = catalogFrame
addCorner(searchBox, 8)
addStroke(searchBox, THEME.Border, 1)

local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(0.2, -scale("X", 5), 0, scale("Y", 32))
refreshBtn.Position = UDim2.new(0.5, scale("X", 5), 0, 0)
refreshBtn.BackgroundColor3 = THEME.Accent
refreshBtn.Text = "🔄 Muat Ulang"
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = scale("Y", 12)
refreshBtn.TextColor3 = THEME.Text
refreshBtn.Parent = catalogFrame
addCorner(refreshBtn, 8)

local sortBtn = Instance.new("TextButton")
sortBtn.Size = UDim2.new(0.3, -scale("X", 5), 0, scale("Y", 32))
sortBtn.Position = UDim2.new(0.7, scale("X", 5), 0, 0)
sortBtn.BackgroundColor3 = THEME.Sidebar
sortBtn.Text = "📊 Urutan: Relevansi"
sortBtn.Font = Enum.Font.GothamMedium
sortBtn.TextSize = scale("Y", 11)
sortBtn.TextColor3 = THEME.Text
sortBtn.Parent = catalogFrame
addCorner(sortBtn, 8)
addStroke(sortBtn, THEME.Border, 1)

local catalogScroll = Instance.new("ScrollingFrame")
catalogScroll.Size = UDim2.new(1, 0, 1, -scale("Y", 75))
catalogScroll.Position = UDim2.new(0, 0, 0, scale("Y", 38))
catalogScroll.ScrollBarThickness = 4
catalogScroll.ScrollBarImageColor3 = THEME.Accent
catalogScroll.BackgroundTransparency = 1
catalogScroll.Parent = catalogFrame

local catalogLayout = Instance.new("UIGridLayout")
catalogLayout.CellSize = UDim2.new(0, scale("X", 122), 0, scale("Y", 170))
catalogLayout.CellPadding = UDim2.new(0, scale("X", 10), 0, scale("Y", 10))
catalogLayout.Parent = catalogScroll

local emptyLabel = Instance.new("TextLabel")
emptyLabel.Size = UDim2.new(1, 0, 0, scale("Y", 36))
emptyLabel.Position = UDim2.new(0, 0, 0.4, 0)
emptyLabel.BackgroundTransparency = 1
emptyLabel.Text = "Tidak ada emote ditemukan :3"
emptyLabel.TextColor3 = THEME.TextSub
emptyLabel.Font = Enum.Font.GothamMedium
emptyLabel.TextSize = scale("Y", 14)
emptyLabel.Visible = false
emptyLabel.Parent = catalogScroll

-- Navigasi Halaman
local prevBtn = Instance.new("TextButton", catalogFrame)
prevBtn.Size = UDim2.new(0.3, 0, 0, scale("Y", 30))
prevBtn.Position = UDim2.new(0, 0, 1, -scale("Y", 30))
prevBtn.BackgroundColor3 = THEME.Sidebar
prevBtn.Text = "◀ Sebelum"
prevBtn.Font = Enum.Font.GothamBold
prevBtn.TextSize = scale("Y", 12)
prevBtn.TextColor3 = THEME.Text
addCorner(prevBtn, 8)

local nextBtn = Instance.new("TextButton", catalogFrame)
nextBtn.Size = UDim2.new(0.3, 0, 0, scale("Y", 30))
nextBtn.Position = UDim2.new(0.7, 0, 1, -scale("Y", 30))
nextBtn.BackgroundColor3 = THEME.Sidebar
nextBtn.Text = "Lanjut ▶"
nextBtn.Font = Enum.Font.GothamBold
nextBtn.TextSize = scale("Y", 12)
nextBtn.TextColor3 = THEME.Text
addCorner(nextBtn, 8)

local pageBox = Instance.new("TextBox", catalogFrame)
pageBox.Size = UDim2.new(0.38, 0, 0, scale("Y", 30))
pageBox.Position = UDim2.new(0.31, 0, 1, -scale("Y", 30))
pageBox.BackgroundTransparency = 1
pageBox.Font = Enum.Font.GothamMedium
pageBox.TextSize = scale("Y", 12)
pageBox.TextColor3 = THEME.TextSub
pageBox.Text = "Halaman 1"

-- ==================== TAB TERSIMPAN ====================
local savedSearch = Instance.new("TextBox")
savedSearch.Size = UDim2.new(1, 0, 0, scale("Y", 32))
savedSearch.PlaceholderText = "🔍 Cari emote tersimpan..."
savedSearch.BackgroundColor3 = THEME.Sidebar
savedSearch.TextColor3 = THEME.Text
savedSearch.PlaceholderColor3 = THEME.TextSub
savedSearch.Font = Enum.Font.Gotham
savedSearch.TextSize = scale("Y", 13)
savedSearch.ClearTextOnFocus = false
savedSearch.Text = ""
savedSearch.Parent = savedFrame
addCorner(savedSearch, 8)
addStroke(savedSearch, THEME.Border, 1)

local savedScroll = Instance.new("ScrollingFrame")
savedScroll.Size = UDim2.new(1, 0, 1, -scale("Y", 38))
savedScroll.Position = UDim2.new(0, 0, 0, scale("Y", 38))
savedScroll.ScrollBarThickness = 4
savedScroll.ScrollBarImageColor3 = THEME.Accent
savedScroll.BackgroundTransparency = 1
savedScroll.Parent = savedFrame

local savedEmptyLabel = Instance.new("TextLabel")
savedEmptyLabel.Size = UDim2.new(1, 0, 0, scale("Y", 36))
savedEmptyLabel.Position = UDim2.new(0, 0, 0.4, 0)
savedEmptyLabel.BackgroundTransparency = 1
savedEmptyLabel.Text = "Belum ada emote yang disimpan 😅"
savedEmptyLabel.TextColor3 = THEME.TextSub
savedEmptyLabel.Font = Enum.Font.GothamMedium
savedEmptyLabel.TextSize = scale("Y", 14)
savedEmptyLabel.Visible = false
savedEmptyLabel.Parent = savedScroll

local savedLayout = Instance.new("UIGridLayout")
savedLayout.CellSize = UDim2.new(0, scale("X", 122), 0, scale("Y", 170))
savedLayout.CellPadding = UDim2.new(0, scale("X", 10), 0, scale("Y", 10))
savedLayout.Parent = savedScroll

-- ==================== TAB PENGATURAN ====================
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = THEME.Accent
scrollFrame.Parent = settingsFrame

local listLayout = Instance.new("UIListLayout", scrollFrame)
listLayout.Padding = UDim.new(0, scale("Y", 8))
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

-- Komponen UI Pengaturan Modern
getgenv().Settings._sliders = {}
getgenv().Settings._toggles = {}

local function createToggle(name, displayName)
    getgenv().Settings[name] = getgenv().Settings[name] or false

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -scale("X", 6), 0, scale("Y", 42))
    container.BackgroundColor3 = THEME.Sidebar
    container.Parent = scrollFrame
    addCorner(container, 8)
    addStroke(container, THEME.Border, 1)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, -scale("X", 10), 1, 0)
    label.Position = UDim2.new(0, scale("X", 12), 0, 0)
    label.BackgroundTransparency = 1
    label.Text = displayName or name
    label.TextColor3 = THEME.Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = scale("Y", 12)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, scale("X", 44), 0, scale("Y", 22))
    toggleBg.Position = UDim2.new(1, -scale("X", 54), 0.5, -scale("Y", 11))
    toggleBg.BackgroundColor3 = getgenv().Settings[name] and THEME.Success or Color3.fromRGB(50, 50, 65)
    toggleBg.Parent = container
    addCorner(toggleBg, 12)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, scale("X", 16), 0, scale("Y", 16))
    circle.Position = getgenv().Settings[name] and UDim2.new(1, -scale("X", 19), 0.5, -scale("Y", 8)) or UDim2.new(0, scale("X", 3), 0.5, -scale("Y", 8))
    circle.BackgroundColor3 = THEME.Text
    circle.Parent = toggleBg
    addCorner(circle, 10)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = container

    local function applyVisual(state)
        getgenv().Settings[name] = state
        TweenService:Create(toggleBg, TweenInfo.new(0.2), {
            BackgroundColor3 = state and THEME.Success or Color3.fromRGB(50, 50, 65)
        }):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -scale("X", 19), 0.5, -scale("Y", 8)) or UDim2.new(0, scale("X", 3), 0.5, -scale("Y", 8))
        }):Play()
    end

    btn.MouseButton1Click:Connect(function()
        applyVisual(not getgenv().Settings[name])
    end)

    getgenv().Settings._toggles[name] = applyVisual
end

local function createSlider(name, displayName, min, max, default)
    getgenv().Settings[name] = default or min

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -scale("X", 6), 0, scale("Y", 52))
    container.BackgroundColor3 = THEME.Sidebar
    container.Parent = scrollFrame
    addCorner(container, 8)
    addStroke(container, THEME.Border, 1)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, scale("Y", 20))
    label.Position = UDim2.new(0, scale("X", 12), 0, scale("Y", 6))
    label.BackgroundTransparency = 1
    label.Text = string.format("%s: %.2f", displayName or name, getgenv().Settings[name])
    label.TextColor3 = THEME.Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = scale("Y", 12)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -scale("X", 24), 0, scale("Y", 6))
    sliderBar.Position = UDim2.new(0, scale("X", 12), 0, scale("Y", 34))
    sliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    sliderBar.Parent = container
    addCorner(sliderBar, 4)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = THEME.Accent
    sliderFill.Parent = sliderBar
    addCorner(sliderFill, 4)

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, scale("X", 14), 0, scale("Y", 14))
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(0, 0, 0.5, 0)
    thumb.BackgroundColor3 = THEME.Text
    thumb.Parent = sliderBar
    addCorner(thumb, 10)

    local function applyValue(value)
        getgenv().Settings[name] = math.clamp(value, min, max)
        label.Text = string.format("%s: %.2f", displayName or name, getgenv().Settings[name])
        local rel = (getgenv().Settings[name] - min) / (max - min)
        sliderFill.Size = UDim2.new(rel, 0, 1, 0)
        thumb.Position = UDim2.new(rel, 0, 0.5, 0)

        if CurrentTrack and CurrentTrack.IsPlaying then
            if name == "Speed" then CurrentTrack:AdjustSpeed(getgenv().Settings["Speed"])
            elseif name == "Weight" then CurrentTrack:AdjustWeight(math.max(getgenv().Settings["Weight"], 0.001))
            elseif name == "Time Position" and CurrentTrack.Length > 0 then
                CurrentTrack.TimePosition = math.clamp(value, 0, 1) * CurrentTrack.Length
            end
        end
    end

    local dragging = false
    local function updateInput(input)
        local relX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        applyValue(math.floor((min + (max - min) * relX) * 100) / 100)
    end

    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; updateInput(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateInput(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    getgenv().Settings._sliders[name] = applyValue
    applyValue(getgenv().Settings[name])
end

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, -scale("X", 6), 0, scale("Y", 36))
resetBtn.BackgroundColor3 = THEME.Danger
resetBtn.Text = "🔄 Riset Pengaturan"
resetBtn.TextColor3 = THEME.Text
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = scale("Y", 12)
resetBtn.Parent = scrollFrame
addCorner(resetBtn, 8)

-- Membuat Item Pengaturan
createToggle("Stop Emote When Moving", "Hentikan Saat Bergerak")
createToggle("Looped", "Putar Berulang (Loop)")
createSlider("Speed", "Kecepatan", 0, 5, getgenv().Settings["Speed"])
createSlider("Time Position", "Posisi Waktu", 0, 1, getgenv().Settings["Time Position"])
createSlider("Weight", "Bobot Gerakan", 0, 1, getgenv().Settings["Weight"])
createSlider("Fade In", "Durasi Transisi Masuk", 0, 2, getgenv().Settings["Fade In"])
createSlider("Fade Out", "Durasi Transisi Keluar", 0, 2, getgenv().Settings["Fade Out"])
createToggle("Allow Invisible  ", "Mode Transparan")
createToggle("Stop Other Animations On Play", "Hentikan Animasi Lain")



resetBtn.MouseButton1Click:Connect(function()
    if getgenv().Settings._toggles["Stop Emote When Moving"] then getgenv().Settings._toggles["Stop Emote When Moving"](true) end
    if getgenv().Settings._toggles["Stop Other Animations On Play"] then getgenv().Settings._toggles["Stop Other Animations On Play"](true) end
    if getgenv().Settings._toggles["Looped"] then getgenv().Settings._toggles["Looped"](true) end
    if getgenv().Settings._sliders["Fade In"] then getgenv().Settings._sliders["Fade In"](0.1) end
    if getgenv().Settings._sliders["Fade Out"] then getgenv().Settings._sliders["Fade Out"](0.1) end
    if getgenv().Settings._sliders["Weight"] then getgenv().Settings._sliders["Weight"](1) end
    if getgenv().Settings._sliders["Speed"] then getgenv().Settings._sliders["Speed"](1) end
    if getgenv().Settings._sliders["Time Position"] then getgenv().Settings._sliders["Time Position"](0) end
end)

-- ==================== SISTEM TAB SWITCHING ====================
catalogTabBtn.MouseButton1Click:Connect(function()
    catalogFrame.Visible = true; savedFrame.Visible = false; settingsFrame.Visible = false
    setTabActive(catalogTabBtn)
end)

savedTabBtn.MouseButton1Click:Connect(function()
    catalogFrame.Visible = false; savedFrame.Visible = true; settingsFrame.Visible = false
    setTabActive(savedTabBtn)
    refreshSavedTab()
end)

settingsTabBtn.MouseButton1Click:Connect(function()
    catalogFrame.Visible = false; savedFrame.Visible = false; settingsFrame.Visible = true
    setTabActive(settingsTabBtn)
end)

-- ==================== PREVIEW CARD GENERATOR ====================
local function createCard(item)
    local card = Instance.new("Frame")
    card.BackgroundColor3 = THEME.Card
    addCorner(card, 8)
    addStroke(card, THEME.Border, 1)

    local thumbId = item.AssetId or item.Id
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(1, -scale("X", 10), 0, scale("Y", 80))
    img.Position = UDim2.new(0, scale("X", 5), 0, scale("Y", 5))
    img.BackgroundTransparency = 1
    img.ScaleType = Enum.ScaleType.Fit
    pcall(function() img.Image = "rbxthumb://type=Asset&id=" .. tonumber(thumbId) .. "&w=150&h=150" end)
    img.Parent = card
    addCorner(img, 6)

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -scale("X", 10), 0, scale("Y", 24))
    name.Position = UDim2.new(0, scale("X", 5), 0, scale("Y", 88))
    name.BackgroundTransparency = 1
    name.Text = item.Name or "Tanpa Nama"
    name.TextScaled = true
    name.Font = Enum.Font.GothamBold
    name.TextColor3 = THEME.Text
    name.Parent = card

    local playBtn = Instance.new("TextButton")
    playBtn.Size = UDim2.new(0.48, -scale("X", 4), 0, scale("Y", 24))
    playBtn.Position = UDim2.new(0, scale("X", 4), 1, -scale("Y", 28))
    playBtn.BackgroundColor3 = THEME.Success
    playBtn.Text = "▶ Putar"
    playBtn.Font = Enum.Font.GothamBold
    playBtn.TextSize = scale("Y", 10)
    playBtn.TextColor3 = THEME.Text
    playBtn.Parent = card
    addCorner(playBtn, 6)

    playBtn.MouseButton1Click:Connect(function() LoadTrack(thumbId) end)

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.48, -scale("X", 4), 0, scale("Y", 24))
    saveBtn.Position = UDim2.new(0.52, 0, 1, -scale("Y", 28))
    saveBtn.BackgroundColor3 = THEME.Accent
    saveBtn.Text = "⭐ Simpan"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = scale("Y", 10)
    saveBtn.TextColor3 = THEME.Text
    saveBtn.Parent = card
    addCorner(saveBtn, 6)

    saveBtn.MouseButton1Click:Connect(function()
        local alreadySaved = false
        for _, saved in ipairs(savedEmotes) do
            if saved.Id == item.Id then alreadySaved = true; break end
        end

        if not alreadySaved then
            local function GetReal(id)
                local ok, obj = pcall(function() return game:GetObjects("rbxassetid://"..tostring(id)) end)
                if ok and obj and #obj > 0 then
                    local target = obj[1]
                    if target:IsA("Animation") and target.AnimationId ~= "" then
                        return tonumber(target.AnimationId:match("%d+"))
                    end
                end
            end
            table.insert(savedEmotes, {
                Id = item.Id, AssetId = thumbId, Name = item.Name or "Tanpa Nama",
                AnimationId = "rbxassetid://" .. (GetReal(thumbId) or thumbId), Favorite = false
            })
            saveEmotesToData()
            saveBtn.Text = "✔ Tersimpan"
            task.wait(1)
            saveBtn.Text = "⭐ Simpan"
        else
            saveBtn.Text = "Sudah Ada"
            task.wait(0.8)
            saveBtn.Text = "⭐ Simpan"
        end
    end)

    return card
end

-- ==================== INTEGRASI KATALOG ====================
local sortModes = {
    {Enum.CatalogSortType.Relevance, "📊 Urutan: Relevansi"},
    {Enum.CatalogSortType.PriceHighToLow, "📊 Harga Tinggi→Rendah"},
    {Enum.CatalogSortType.PriceLowToHigh, "📊 Harga Rendah→Tinggi"},
    {Enum.CatalogSortType.MostFavorited, "📊 Paling Difavoritkan"},
    {Enum.CatalogSortType.RecentlyCreated, "📊 Baru Dibuat"},
    {Enum.CatalogSortType.Bestselling, "📊 Terlaris"}
}
local currentSortIndex = 1
local currentKeyword = ""
local currentPages = nil
local currentPageNumber = 1

local function getPages(keyword)
    local params = CatalogSearchParams.new()
    params.SearchKeyword = keyword or ""
    params.CategoryFilter = Enum.CatalogCategoryFilter.None
    params.SalesTypeFilter = Enum.SalesTypeFilter.All
    params.AssetTypes = { Enum.AvatarAssetType.EmoteAnimation }
    params.IncludeOffSale = true
    params.SortType = sortModes[currentSortIndex][1]
    params.Limit = 10
    local ok, pages = pcall(function() return AvatarEditorService:SearchCatalog(params) end)
    return ok and pages or nil
end

local function showPage(pages)
    pageBox.Text = "Memuat..."
    for _, child in ipairs(catalogScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local ok, currentList = pcall(function() return pages:GetCurrentPage() end)
    if ok and currentList and #currentList > 0 then
        emptyLabel.Visible = false
        for _, item in ipairs(currentList) do
            createCard(item).Parent = catalogScroll
        end
    else
        emptyLabel.Visible = true
    end

    catalogScroll.CanvasSize = UDim2.new(0, 0, 0, catalogLayout.AbsoluteContentSize.Y + 10)
    pageBox.Text = "Halaman " .. tostring(currentPageNumber)
end

local function doNewSearch(keyword)
    currentKeyword = keyword or ""
    currentPageNumber = 1
    currentPages = getPages(currentKeyword)
    if currentPages then showPage(currentPages) end
end

refreshBtn.MouseButton1Click:Connect(function() doNewSearch(searchBox.Text) end)
searchBox.FocusLost:Connect(function(enter) if enter then doNewSearch(searchBox.Text) end end)
sortBtn.MouseButton1Click:Connect(function()
    currentSortIndex = currentSortIndex % #sortModes + 1
    sortBtn.Text = sortModes[currentSortIndex][2]
    doNewSearch(currentKeyword)
end)

nextBtn.MouseButton1Click:Connect(function()
    if currentPages and not currentPages.IsFinished then
        pcall(function() currentPages:AdvanceToNextPageAsync() end)
        currentPageNumber = currentPageNumber + 1
        showPage(currentPages)
    end
end)

prevBtn.MouseButton1Click:Connect(function()
    if currentPageNumber > 1 then
        currentPageNumber = currentPageNumber - 1
        doNewSearch(currentKeyword)
    end
end)

-- ==================== INTEGRASI SAVED TAB ====================
function refreshSavedTab()
    for _, child in ipairs(savedScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    local text = (savedSearch.Text or ""):lower()
    local results = {}
    for _, item in ipairs(savedEmotes) do
        if text == "" or (item.Name and item.Name:lower():find(text)) then
            table.insert(results, item)
        end
    end

    if #results > 0 then
        savedEmptyLabel.Visible = false
        for _, item in ipairs(results) do
            local card = Instance.new("Frame")
            card.BackgroundColor3 = THEME.Card
            addCorner(card, 8)
            addStroke(card, THEME.Border, 1)

            local img = Instance.new("ImageLabel", card)
            img.Size = UDim2.new(1, -scale("X", 10), 0, scale("Y", 80))
            img.Position = UDim2.new(0, scale("X", 5), 0, scale("Y", 5))
            img.BackgroundTransparency = 1
            img.ScaleType = Enum.ScaleType.Fit
            img.Image = "rbxthumb://type=Asset&id=" .. tostring(item.AssetId or item.Id) .. "&w=150&h=150"
            addCorner(img, 6)

            local name = Instance.new("TextLabel", card)
            name.Size = UDim2.new(1, -scale("X", 10), 0, scale("Y", 24))
            name.Position = UDim2.new(0, scale("X", 5), 0, scale("Y", 88))
            name.BackgroundTransparency = 1
            name.Text = item.Name or "Tanpa Nama"
            name.TextScaled = true
            name.Font = Enum.Font.GothamBold
            name.TextColor3 = THEME.Text

            local playBtn = Instance.new("TextButton", card)
            playBtn.Size = UDim2.new(0.48, -scale("X", 4), 0, scale("Y", 24))
            playBtn.Position = UDim2.new(0, scale("X", 4), 1, -scale("Y", 28))
            playBtn.BackgroundColor3 = THEME.Success
            playBtn.Text = "▶ Putar"
            playBtn.Font = Enum.Font.GothamBold
            playBtn.TextSize = scale("Y", 10)
            playBtn.TextColor3 = THEME.Text
            addCorner(playBtn, 6)
            playBtn.MouseButton1Click:Connect(function() LoadTrack(item.Id) end)

            local removeBtn = Instance.new("TextButton", card)
            removeBtn.Size = UDim2.new(0.48, -scale("X", 4), 0, scale("Y", 24))
            removeBtn.Position = UDim2.new(0.52, 0, 1, -scale("Y", 28))
            removeBtn.BackgroundColor3 = THEME.Danger
            removeBtn.Text = "🗑 Hapus"
            removeBtn.Font = Enum.Font.GothamBold
            removeBtn.TextSize = scale("Y", 10)
            removeBtn.TextColor3 = THEME.Text
            addCorner(removeBtn, 6)

            removeBtn.MouseButton1Click:Connect(function()
                for idx, saved in ipairs(savedEmotes) do
                    if saved.Id == item.Id then
                        table.remove(savedEmotes, idx)
                        saveEmotesToData()
                        refreshSavedTab()
                        break
                    end
                end
            end)

            card.Parent = savedScroll
        end
    else
        savedEmptyLabel.Visible = true
    end
    savedScroll.CanvasSize = UDim2.new(0, 0, 0, savedLayout.AbsoluteContentSize.Y + 10)
end

savedSearch:GetPropertyChangedSignal("Text"):Connect(refreshSavedTab)

-- ==================== TOMBOL TOGGLE FLOATING ====================
local toggleGui = Instance.new("ScreenGui", CoreGui)
toggleGui.Name = "EmoteToggleButtonGui"

local floatBtn = Instance.new("TextButton", toggleGui)
-- floatBtn.BackgroundColor3 = THEME.Accent
floatBtn.BackgroundTransparency = 1 -- Latar belakang dibuat transparan penuh
floatBtn.Text = "🔥"
floatBtn.TextSize = 15
floatBtn.Size = UDim2.new(0, 48, 0, 48)
floatBtn.Position = UDim2.new(0, 20, 0.5, -24)
floatBtn.Active = true
pcall(function() floatBtn.Draggable = true end)
addCorner(floatBtn, 24)
-- addStroke(floatBtn, Color3.fromRGB(255, 255, 255), 1.5)

local function toggleUI()
    gui.Enabled = not gui.Enabled
end

floatBtn.MouseButton1Click:Connect(toggleUI)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.F then
        toggleUI()
    end
end)

doNewSearch("")
gui.Enabled = true
refreshSavedTab()