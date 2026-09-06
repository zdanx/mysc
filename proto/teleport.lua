-- =======================================================
-- FITUR TELEPORT PLAYER (ARCHIVE UI STYLE)
-- =======================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local ArchiveTeleportUI = nil

local function CreateTeleportUI()
    -- Hapus UI lama jika masih ada
    if ArchiveTeleportUI then
        ArchiveTeleportUI:Destroy()
    end

    ArchiveTeleportUI = Instance.new("ScreenGui")
    ArchiveTeleportUI.Name = "ArciveTeleportUI"
    ArchiveTeleportUI.ResetOnSpawn = false

    -- Injeksi CoreGui
    if gethui then
        ArchiveTeleportUI.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ArchiveTeleportUI)
        ArchiveTeleportUI.Parent = CoreGui
    else
        ArchiveTeleportUI.Parent = CoreGui:FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
    end

    local function addCorner(parent, radius)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, radius)
        corner.Parent = parent
        return corner
    end

    -- ===========================
    -- UI SETUP (ARCIVE STYLE)
    -- ===========================
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Parent = ArchiveTeleportUI
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(1, -250, 0.5, -140)
    MainFrame.Size = UDim2.new(0, 200, 0, 280)
    MainFrame.Active = true
    MainFrame.Draggable = true
    addCorner(MainFrame, 8)

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(5, 69, 223)
    MainStroke.Thickness = 1.5
    MainStroke.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = MainFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Size = UDim2.new(1, -60, 0, 30)
    TitleLabel.Font = Enum.Font.GothamBlack
    TitleLabel.Text = "ARCHIVE TELEPORT"
    TitleLabel.TextColor3 = Color3.fromRGB(5, 69, 223)
    TitleLabel.TextSize = 12
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local MinButton = Instance.new("TextButton")
    MinButton.Parent = MainFrame
    MinButton.BackgroundTransparency = 1
    MinButton.Position = UDim2.new(1, -55, 0, 5)
    MinButton.Size = UDim2.new(0, 20, 0, 20)
    MinButton.Font = Enum.Font.GothamBold
    MinButton.Text = "-"
    MinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinButton.TextSize = 16

    local CloseButton = Instance.new("TextButton")
    CloseButton.Parent = MainFrame
    CloseButton.BackgroundTransparency = 1
    CloseButton.Position = UDim2.new(1, -30, 0, 5)
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(5, 69, 223)
    CloseButton.TextSize = 14

    -- Logo Bulat untuk Buka UI (IMAGE BUTTON)
    local LogoButton = Instance.new("ImageButton")
    LogoButton.Name = "OpenLogo"
    LogoButton.Parent = ArchiveTeleportUI
    LogoButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    LogoButton.Position = UDim2.new(1, -60, 0.5, -20)
    LogoButton.Size = UDim2.new(0, 40, 0, 40)
    LogoButton.Image = "rbxassetid://0000000000" -- GANTI ANGKA INI DENGAN ASSET ID GAMBAR KAMU
    LogoButton.Visible = false
    LogoButton.Active = true
    LogoButton.Draggable = true
    addCorner(LogoButton, 40)
    
    local LogoStroke = Instance.new("UIStroke")
    LogoStroke.Color = Color3.fromRGB(5, 69, 223)
    LogoStroke.Thickness = 1.5
    LogoStroke.Parent = LogoButton

    -- Fitur Cari Player (Search Bar)
    local SearchBox = Instance.new("TextBox")
    SearchBox.Parent = MainFrame
    SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SearchBox.Position = UDim2.new(0.05, 0, 0, 35)
    SearchBox.Size = UDim2.new(0.9, 0, 0, 25)
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.PlaceholderText = "Cari Player..."
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.TextSize = 12
    SearchBox.ClearTextOnFocus = false
    addCorner(SearchBox, 4)

    local SearchStroke = Instance.new("UIStroke")
    SearchStroke.Color = Color3.fromRGB(5, 69, 223)
    SearchStroke.Thickness = 1
    SearchStroke.Parent = SearchBox

    -- Frame Scroll untuk daftar pemain
    local PlayerScroll = Instance.new("ScrollingFrame")
    PlayerScroll.Parent = MainFrame
    PlayerScroll.Active = true
    PlayerScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    PlayerScroll.BorderSizePixel = 0
    PlayerScroll.Position = UDim2.new(0.05, 0, 0, 68)
    PlayerScroll.Size = UDim2.new(0.9, 0, 1, -78)
    PlayerScroll.ScrollBarThickness = 3
    PlayerScroll.ScrollBarImageColor3 = Color3.fromRGB(5, 69, 223)
    addCorner(PlayerScroll, 4)

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = PlayerScroll
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- ===========================
    -- LOGIC & FUNCTIONS
    -- ===========================
    local function RefreshTeleportList(filter)
        filter = filter and string.lower(filter) or ""

        -- Bersihkan daftar tombol lama (kecuali layout)
        for _, child in ipairs(PlayerScroll:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        local ySize = 0

        for _, target in ipairs(Players:GetPlayers()) do
            if target ~= LocalPlayer then
                local displayName = string.lower(target.DisplayName)
                local username = string.lower(target.Name)

                -- Jika sesuai kata kunci pencarian, buatkan tombolnya
                if filter == "" or string.find(displayName, filter) or string.find(username, filter) then
                    local btn = Instance.new("TextButton")
                    btn.Parent = PlayerScroll
                    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    btn.Size = UDim2.new(1, -8, 0, 30)
                    btn.Font = Enum.Font.GothamSemibold
                    btn.Text = target.DisplayName
                    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
                    btn.TextSize = 12
                    addCorner(btn, 4)

                    -- Logika Teleport
                    btn.MouseButton1Click:Connect(function()
                        if target.Character and LocalPlayer.Character then
                            local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                            local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if targetRoot and myRoot then
                                myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
                            end
                        end
                    end)
                    ySize = ySize + 35
                end
            end
        end
        PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, ySize)
    end

    -- Event Listener Pencarian 
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        RefreshTeleportList(SearchBox.Text)
    end)
    
    -- Auto refresh jika player masuk/keluar
    Players.PlayerAdded:Connect(function() RefreshTeleportList(SearchBox.Text) end)
    Players.PlayerRemoving:Connect(function() RefreshTeleportList(SearchBox.Text) end)

    -- Aksi Tombol UI
    CloseButton.MouseButton1Click:Connect(function()
        if ArchiveTeleportUI then
            ArchiveTeleportUI:Destroy()
            ArchiveTeleportUI = nil
        end
    end)

    MinButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        LogoButton.Visible = true
    end)

    LogoButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        LogoButton.Visible = false
    end)

    -- Panggil daftar pertama kali
    RefreshTeleportList("")
end

-- ===========================
-- INTEGRASI KE TAB COMPKILLER
-- ===========================
local TeleportToggle = NormalSection:AddToggle({
    Name = "Menu Teleport (UI)",
    Flag = "Toggle_ArchiveTeleport", 
    Default = false,
    Callback = function(Value)
        
        -- Suara Notifikasi
        local notifSound = Instance.new("Sound")
        notifSound.SoundId = "rbxassetid://77762138861672"
        notifSound.Volume = 1
        notifSound.Parent = game:GetService("SoundService")
        notifSound:Play()
        notifSound.Ended:Connect(function() notifSound:Destroy() end)

        if Value then
            CreateTeleportUI()
            Notifier.new({
                Title = "Notifikasi",
                Content = "Jendela Teleport berhasil dibuka!",
                Duration = 5,
                Icon = "rbxassetid://116526595864004"
            });
        else
            if ArchiveTeleportUI then
                ArchiveTeleportUI:Destroy()
                ArchiveTeleportUI = nil
            end
            Notifier.new({
                Title = "Notifikasi",
                Content = "Jendela Teleport ditutup.",
                Duration = 5,
                Icon = "rbxassetid://116526595864004"
            });
        end
    end,
})

TeleportToggle.Link:AddHelper({
    Text = "Membuka UI khusus bertema Archive untuk mencari dan teleportasi ke pemain lain."
})
