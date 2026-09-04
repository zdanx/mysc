-- =======================================================
-- 1. CLEANUP UI LAMA (AUTO-REPLACE)
-- =======================================================
if getgenv().Zami_ActiveUI then
    pcall(function() getgenv().Zami_ActiveUI:Destroy() end)
    getgenv().Zami_ActiveUI = nil
end

local TargetParent = (gethui and gethui()) or game:GetService("CoreGui")
-- ori local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/zdanx/mysc/refs/heads/main/src/source.luau"))();
local Compkiller = loadstring(readfile("source.lua"))()

-- Create Notification --
local Notifier = Compkiller.newNotify();

-- Create Config Manager --
local ConfigManager = Compkiller:ConfigManager({
	Directory = "Compkiller-UI",
	Config = "Example-Configs"
});

-- =======================================================
-- MEMUTAR AUDIO LOADING
-- =======================================================
local LoadingSound = Instance.new("Sound")
LoadingSound.SoundId = "rbxassetid://78213408919197" -- Ganti dengan ID Asset Roblox Anda
LoadingSound.Volume = 10 -- Atur volume suara (0.1 sampai 10)
LoadingSound.Parent = (gethui and gethui()) or game:GetService("CoreGui")

-- Putar audio
LoadingSound:Play()

-- Loading UI (Script akan tertahan di sini selama 2.5 detik) --
Compkiller:Loader("rbxassetid://75680508301013" , 2.5).yield();

-- =======================================================
-- 2. SNAPSHOT DIAMBIL SETELAH LOADER SELESAI
-- =======================================================
local UIBefore = {}
for _, ui in ipairs(TargetParent:GetChildren()) do
    UIBefore[ui] = true
end

-- Creating Window --
local Window = Compkiller.new({
	Name = "SA-2 HUB",
	Keybind = "LeftAlt",
	Logo = "rbxassetid://116526595864004",
	--Scale = Compkiller.Scale.Window, 
	TextSize = 15,
});

-- =======================================================
-- 3. TANGKAP UI UTAMA LALU SIMPAN KE MEMORI
-- =======================================================
for _, ui in ipairs(TargetParent:GetChildren()) do
    if not UIBefore[ui] then
        getgenv().Zami_ActiveUI = ui
        break
    end
end

-- Notification --
Notifier.new({
	Title = "Notification",
	Content = "Thanks yaww udaa pake script zami!... :D",
	Duration = 10,
	Icon = "rbxassetid://116526595864004"
});


-- Watermark --
local Watermark = Window:Watermark();

Watermark:AddText({
	Icon = "clock",
	Text = Compkiller:GetDate(),
});

local Time = Watermark:AddText({
	Icon = "timer",
	Text = "TIME",
});

task.spawn(function()
	while true do task.wait()
		Time:SetText(Compkiller:GetTimeNow());
	end
end)

--[[
Watermark:AddText({
	Icon = "server",
	Text = Compkiller.Version,
});
]]
-- Creating Tab Category --
Window:DrawCategory({
	Name = "Menu"
});

-- Creating Tab --
local NormalTab = Window:DrawTab({
	Name = "Life Together",
	Icon = "home",
	EnableScrolling = true
});

-- Creating Section --
local NormalSection = NormalTab:DrawSection({
	Name = "Fitur Utama",
	Position = 'left'	
});
--[[
local Toggle = NormalSection:AddToggle({
	Name = "Toggle",
	Flag = "Toggle_Example", 
	Default = false,
	Callback = print,
});
]]

-- Variabel global untuk status Anti AFK
getgenv().AntiAFK = false

-- Script utama Anti AFK (Hanya akan bekerja jika getgenv().AntiAFK = true)
local VirtualUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    if getgenv().AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Membuat Toggle di UI
local Toggle = NormalSection:AddToggle({
    Name = "Anti AFK",
    Flag = "Toggle_AntiAFK", 
    Default = false,
    Callback = function(Value)
        getgenv().AntiAFK = Value 
        
        if getgenv().AntiAFK then
            -- Notification saat ON --
            Notifier.new({
                Title = "Notifikasi",
                Content = "Fitur Anti AFK telah diaktifkan!",
                Duration = 10,
                Icon = "rbxassetid://116526595864004"
            });
        else
            -- Notification saat OFF --
            Notifier.new({
                Title = "Notifikasi",
                Content = "Fitur Anti AFK telah dimatikan!",
                Duration = 10,
                Icon = "rbxassetid://116526595864004"
            });
        end
    end,
});
--[[
-- Add Keybind To Toggle --
local Keybind = Toggle.Link:AddKeybind({
	Default = "E",
	Flag = "Option_Keybind",
	Callback = print
});
]]
-- Helper --
Toggle.Link:AddHelper({
	Text = "Mencegah game mengeluarkan Anda karena tidak aktif/AFK."
})

-- Fitur Anti Lag
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local AntilagConnection = nil

local Toggle = NormalSection:AddToggle({
    Name = "Anti Lag (Smooth FPS)",
    Flag = "Toggle_AntiLag", 
    Default = false,
	Risky = true,
    Callback = function(Value)
        if Value then
            -- Notifikasi ON
            Notifier.new({
                Title = "Notification",
                Content = "Fitur Anti Lag telah diaktifkan!",
                Duration = 10,
                Icon = "rbxassetid://116526595864004"
            });

            -- Eksekusi Anti Lag
            local Terrain = workspace:FindFirstChildWhichIsA("Terrain")
            if Terrain then
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 1
            end
            
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.FogStart = 9e9
            settings().Rendering.QualityLevel = 1
            
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CastShadow = false
                    v.Material = Enum.Material.Plastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") then
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Lifetime = NumberRange.new(0)
                end
            end
            
            for _, v in pairs(Lighting:GetDescendants()) do
                if v:IsA("PostEffect") then
                    v.Enabled = false
                end
            end
            
            -- Mematikan efek visual baru yang muncul di map
            if not AntilagConnection then
                AntilagConnection = workspace.DescendantAdded:Connect(function(child)
                    task.spawn(function()
                        if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
                            RunService.Heartbeat:Wait()
                            child:Destroy()
                        elseif child:IsA("BasePart") then
                            child.CastShadow = false
                        end
                    end)
                end)
            end

        else
            -- Notifikasi OFF
            Notifier.new({
                Title = "Notification",
                Content = "Anti Lag dimatikan (Sebagian grafik dikembalikan)",
                Duration = 10,
                Icon = "rbxassetid://116526595864004"
            });

            -- Menghentikan script penghapus efek baru
            if AntilagConnection then
                AntilagConnection:Disconnect()
                AntilagConnection = nil
            end
            
            -- Mengembalikan pengaturan dasar yang memungkinkan
            Lighting.GlobalShadows = true
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
    end,
});

-- Helper --
Toggle.Link:AddHelper({
	Text = "Menurunkan kualitas game untuk meningkatkan FPS."
})

-- =======================================================
-- FITUR ANTI FLING (MENGGUNAKAN TOGGLE COMPKILLER)
-- =======================================================
local LocalPlayer = game:GetService("Players").LocalPlayer
local AntiFlingEnabled = false
local AntiFlingConnection = nil

local function SetAntiFling(state)
    AntiFlingEnabled = state

    if AntiFlingConnection then
        AntiFlingConnection:Disconnect()
        AntiFlingConnection = nil
    end

    if state then
        AntiFlingConnection = RunService.Heartbeat:Connect(function()
            local character = LocalPlayer.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")

            if root and root.Parent then
                root.AssemblyAngularVelocity = Vector3.zero

                if root.AssemblyLinearVelocity.Magnitude > 100 then
                    root.AssemblyLinearVelocity = Vector3.zero
                end
            end
        end)
    end
end

-- Toggle Anti Fling di dalam Section Compkiller
local AntiFlingToggle = NormalSection:AddToggle({
    Name = "Anti Fling",
    Flag = "Toggle_AntiFling", 
    Default = false,
    Callback = function(Value)
        SetAntiFling(Value)
        
        if Value then
            Notifier.new({
                Title = "Notifikasi",
                Content = "Anda sekarang Unflingable (Anti Fling Aktif)!",
                Duration = 5,
                Icon = "rbxassetid://116526595864004"
            });
        else
            Notifier.new({
                Title = "Notifikasi",
                Content = "Anti Fling dimatikan.",
                Duration = 5,
                Icon = "rbxassetid://116526595864004"
            });
        end
    end,
});

-- Helper untuk Anti Fling
AntiFlingToggle.Link:AddHelper({
    Text = "Melindungi karakter dari serangan lemparan/fling player lain."
})

-- Mempertahankan status Anti Fling saat karakter respawn
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    task.wait(0.5)
    if AntiFlingEnabled then
        SetAntiFling(true)
    end
end)

-- =======================================================
-- FITUR WALKSPEED (MENGGUNAKAN SLIDER COMPKILLER)
-- =======================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local SpeedEnabled = false
local SpeedValue = 32
local OriginalWalkSpeed = 16

local function ApplySpeed()
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            if SpeedEnabled then
                humanoid.WalkSpeed = SpeedValue
            else
                humanoid.WalkSpeed = OriginalWalkSpeed
            end
        end
    end
end

-- Toggle untuk mengaktifkan/menonaktifkan WalkSpeed
local SpeedToggle = NormalSection:AddToggle({
    Name = "Walk Speed",
    Flag = "Toggle_WalkSpeed", 
    Default = false,
    Callback = function(Value)
        SpeedEnabled = Value
        ApplySpeed()
        
        -- Menambahkan notifikasi di sini
        if Value then
            Notifier.new({
                Title = "Notifikasi",
                Content = "Fitur Walk Speed telah diaktifkan!",
                Duration = 5,
                Icon = "rbxassetid://116526595864004"
            });
        else
            Notifier.new({
                Title = "Notifikasi",
                Content = "Walk Speed dimatikan (Kecepatan normal).",
                Duration = 5,
                Icon = "rbxassetid://116526595864004"
            });
        end
    end,
});

-- Helper --
SpeedToggle.Link:AddHelper({
    Text = "Ubah kecepatan jalan Anda (standarnya adalah 16)."
})

-- Slider Compkiller untuk mengatur kecepatan (WalkSpeed)
NormalSection:AddSlider({
    Name = " Kecepatan Berlari",
    Min = 16,
    Max = 150,
    Default = 32,
    Round = 0,
    Flag = "Slider_WalkSpeed",
    Callback = function(Value)
        SpeedValue = Value
        ApplySpeed()
    end
});

-- Memperbarui kecepatan secara otomatis saat karakter respawn (mati/hidup kembali)
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    local humanoid = newCharacter:WaitForChild("Humanoid")
    OriginalWalkSpeed = humanoid.WalkSpeed
    ApplySpeed()
end)

-- =======================================================
-- FITUR FLY (TERINTEGRASI COMPKILLER UI + CAMERA TRACKING)
-- =======================================================
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local FlyPlayer = game:GetService("Players").LocalPlayer

local FlyCharacter = FlyPlayer.Character or FlyPlayer.CharacterAdded:Wait()
local FlyHumanoid = FlyCharacter:WaitForChild("Humanoid")
local FlyRoot = FlyCharacter:WaitForChild("HumanoidRootPart")

local FlightSpeed = 60
local FlightEnabled = false
local FlightConnection
local FlightVelocity
local FlightGyro -- Tambahan variabel untuk rotasi
local FlightControls
local FlyScreenGui

local upPressed = false
local downPressed = false

-- Ambil ControlModule bawaan Roblox untuk analog standar
local PlayerModule = require(FlyPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
local ControlModule = PlayerModule:GetControls()

local function StopFlight()
	if FlightConnection then
		FlightConnection:Disconnect()
		FlightConnection = nil
	end
	if FlightVelocity then
		FlightVelocity:Destroy()
		FlightVelocity = nil
	end
	if FlightGyro then
		FlightGyro:Destroy()
		FlightGyro = nil
	end
	if FlyHumanoid and FlyHumanoid.Parent then
		FlyHumanoid.PlatformStand = false
		FlyHumanoid.AutoRotate = true
	end
	upPressed = false
	downPressed = false
	if FlightControls then
		FlightControls:Destroy()
		FlightControls = nil
	end
	if FlyScreenGui then
		FlyScreenGui:Destroy()
		FlyScreenGui = nil
	end
end

local function CreateFlightControls()
	FlyScreenGui = Instance.new("ScreenGui")
	FlyScreenGui.Name = "FlyMobileUI"
	FlyScreenGui.ResetOnSpawn = false
	FlyScreenGui.Parent = FlyPlayer:WaitForChild("PlayerGui")

	FlightControls = Instance.new("Frame")
	FlightControls.Parent = FlyScreenGui
	FlightControls.Size = UDim2.new(1, 0, 1, 0)
	FlightControls.BackgroundTransparency = 1
	FlightControls.Active = false

	local function MakeVerticalButton(text, position, callback)
		local btn = Instance.new("TextButton")
		btn.Parent = FlightControls
		btn.Size = UDim2.new(0, 65, 0, 55)
		btn.Position = position
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
		btn.BackgroundTransparency = 0.4
		btn.Text = text
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.TextSize = 15
		btn.Font = Enum.Font.GothamBold
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = btn

		btn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				callback(true)
			end
		end)
		btn.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				callback(false)
			end
		end)
	end

    -- Posisi Tombol Naik/Turun
	MakeVerticalButton("NAIK", UDim2.new(1, -85, 1, -165), function(state) upPressed = state end)
	MakeVerticalButton("TURUN", UDim2.new(1, -85, 1, -95), function(state) downPressed = state end)
end

local function StartFlight()
	StopFlight()

	if FlyHumanoid then
		FlyHumanoid.PlatformStand = true
		FlyHumanoid.AutoRotate = false -- Mematikan rotasi otomatis jalan kaki
	end

    -- Kecepatan pergerakan terbang
	FlightVelocity = Instance.new("BodyVelocity")
	FlightVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	FlightVelocity.Velocity = Vector3.zero
	FlightVelocity.Parent = FlyRoot

    -- Rotasi karakter agar menghadap kamera
	FlightGyro = Instance.new("BodyGyro")
	FlightGyro.P = 9e4
	FlightGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
	FlightGyro.cframe = FlyRoot.CFrame
	FlightGyro.Parent = FlyRoot

	CreateFlightControls()

	FlightConnection = RunService.RenderStepped:Connect(function()
		if not FlightEnabled or not FlyRoot or not FlyRoot.Parent then
			StopFlight()
			return
		end

		local Camera = workspace.CurrentCamera
		local direction = Vector3.zero
		
		-- Buat rotasi karakter terus mengikuti kemana kamera menghadap
		if FlightGyro then
		    FlightGyro.cframe = Camera.CFrame
		end

		if upPressed then direction += Vector3.new(0, 1, 0) end
		if downPressed then direction -= Vector3.new(0, 1, 0) end

		local moveVector = ControlModule:GetMoveVector()
		if moveVector.Magnitude > 0 then
			direction += Camera.CFrame.RightVector * moveVector.X
			direction += Camera.CFrame.LookVector * (-moveVector.Z)
		end

		if direction.Magnitude > 0 then
			direction = direction.Unit * FlightSpeed
		end

		FlightVelocity.Velocity = direction
	end)
end

FlyPlayer.CharacterAdded:Connect(function(newCharacter)
	FlyCharacter = newCharacter
	FlyHumanoid = FlyCharacter:WaitForChild("Humanoid")
	FlyRoot = FlyCharacter:WaitForChild("HumanoidRootPart")
	if FlightEnabled then
		StartFlight()
	end
end)

-- Toggle Terbang untuk UI
local FlyToggle = NormalSection:AddToggle({
    Name = "Fly",
    Flag = "Toggle_Fly", 
    Default = false,
    Callback = function(Value)
        FlightEnabled = Value
        if FlightEnabled then
            StartFlight()
            
            -- Notifikasi saat Fly ON
            Notifier.new({
                Title = "Notifikasi",
                Content = "Fitur Fly telah diaktifkan!",
                Duration = 5,
                Icon = "rbxassetid://116526595864004"
            });
        else
            StopFlight()
            
            -- Notifikasi saat Fly OFF
            Notifier.new({
                Title = "Notifikasi",
                Content = "Fitur Fly dimatikan.",
                Duration = 5,
                Icon = "rbxassetid://116526595864004"
            });
        end
    end,
})

-- Helper Deskripsi
FlyToggle.Link:AddHelper({
    Text = "Terbang bebas di udara."
})

-- Slider Pengatur Kecepatan Terbang untuk UI
NormalSection:AddSlider({
    Name = "Kecepatan Terbang",
    Min = 5,
    Max = 200,
    Default = 60,
    Round = 0,
    Flag = "Slider_FlySpeed",
    Callback = function(Value)
        FlightSpeed = Value
    end
});

-- =======================================================
-- FITUR NOCLIP (FULL BODY) MENGGUNAKAN TOGGLE COMPKILLER
-- =======================================================
local noclipEnabled = false

-- Membuat Toggle Noclip di dalam Section Compkiller
local NoclipToggle = NormalSection:AddToggle({
    Name = "Noclip",
    Flag = "Toggle_FullNoclip", 
    Default = false,
    Callback = function(Value)
        noclipEnabled = Value
        
        -- Menambahkan notifikasi di sini
        if Value then
            Notifier.new({
                Title = "Notifikasi",
                Content = "Fitur Noclip telah diaktifkan!",
                Duration = 5,
                Icon = "rbxassetid://116526595864004"
            });
        else
            Notifier.new({
                Title = "Notifikasi",
                Content = "Noclip dimatikan (Karakter kembali normal).",
                Duration = 5,
                Icon = "rbxassetid://116526595864004"
            });
        end
    end,
});

-- Helper untuk penjelasan fitur Noclip
NoclipToggle.Link:AddHelper({
    Text = "Membuat karakter dapat menembus seluruh dinding/objek."
})

-- Loop otomatis untuk mematikan collision (CanCollide = false) pada seluruh bagian karakter
RunService.Stepped:Connect(function()
    if not noclipEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)

-- =======================================================
-- FITUR X-RAY (HIGHLIGHT PLAYERS)
-- =======================================================
local XRayEnabled = false
local Highlights = {}

local function RemoveHighlight(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end
end

local function AddHighlight(player)
    -- Jangan menyorot diri sendiri atau player yang belum spawn karakternya
    if player == LocalPlayer or not player.Character then
        return
    end

    RemoveHighlight(player)

    local highlight = Instance.new("Highlight")
    highlight.Name = "SA2_XRay"
    highlight.Adornee = player.Character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.65
    highlight.OutlineTransparency = 0
    -- Memasukkan Highlight ke dalam CoreGui agar lebih aman
    highlight.Parent = (gethui and gethui()) or game:GetService("CoreGui")

    Highlights[player] = highlight
end

local function SetXRay(state)
    XRayEnabled = state
    if state then
        -- Tambahkan highlight ke semua pemain yang sedang ada
        for _, player in ipairs(Players:GetPlayers()) do
            AddHighlight(player)
        end
    else
        -- Hapus semua highlight jika fitur dimatikan
        for player, highlight in pairs(Highlights) do
            if highlight then
                highlight:Destroy()
            end
            Highlights[player] = nil
        end
    end
end

-- Deteksi jika ada pemain baru yang join atau respawn
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if XRayEnabled then
            AddHighlight(player)
        end
    end)
end)

-- Hapus highlight jika pemain keluar dari game
Players.PlayerRemoving:Connect(function(player)
    RemoveHighlight(player)
end)

-- Toggle X-Ray untuk UI Compkiller
local XRayToggle = NormalSection:AddToggle({
    Name = "X-Ray ESP",
    Flag = "Toggle_XRay", 
    Default = false,
    Callback = function(Value)
        SetXRay(Value)
        
        if Value then
            Notifier.new({
                Title = "Notifikasi",
                Content = "X-Ray telah diaktifkan!",
                Duration = 5,
                Icon = "rbxassetid://116526595864004"
            });
        else
            Notifier.new({
                Title = "Notifikasi",
                Content = "X-Ray dimatikan.",
                Duration = 5,
                Icon = "rbxassetid://116526595864004"
            });
        end
    end,
});

-- Helper untuk X-Ray
XRayToggle.Link:AddHelper({
    Text = "Melihat pemain lain menembus dinding."
})

-- =======================================================
-- FITUR NAME ESP (DISPLAY NAME & USERNAME)
-- =======================================================
local NameESPEnabled = false
local NameESPs = {}

local function RemoveNameESP(player)
    if NameESPs[player] then
        NameESPs[player]:Destroy()
        NameESPs[player] = nil
    end
end

local function AddNameESP(player)
    -- Jangan memunculkan nama pada diri sendiri atau jika karakter belum ada
    if player == LocalPlayer or not player.Character then 
        return 
    end
    
    local head = player.Character:FindFirstChild("Head")
    if not head then return end
    
    RemoveNameESP(player)
    
    -- Membuat BillboardGui di atas kepala
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "SA2_NameESP"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.ExtentsOffset = Vector3.new(0, 2.5, 0) -- Mengatur posisi teks agar di atas kepala
    billboard.AlwaysOnTop = true
    billboard.Parent = (gethui and gethui()) or game:GetService("CoreGui")
    
    -- Membuat teks (TextLabel)
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboard
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    
    -- Format: DisplayName (Baris baru) @Username
    textLabel.Text = player.DisplayName .. "\n(@" .. player.Name .. ")"
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 13
    textLabel.TextColor3 = Color3.new(1, 1, 1) -- Warna teks putih
    textLabel.TextStrokeTransparency = 0 -- Outline hitam penuh agar teks selalu terbaca
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    
    NameESPs[player] = billboard
end

local function SetNameESP(state)
    NameESPEnabled = state
    if state then
        -- Munculkan nama untuk semua player yang sedang ada
        for _, player in ipairs(Players:GetPlayers()) do
            AddNameESP(player)
        end
    else
        -- Hapus semua nama jika dimatikan
        for player, esp in pairs(NameESPs) do
            if esp then esp:Destroy() end
            NameESPs[player] = nil
        end
    end
end

-- Deteksi saat player baru masuk atau respawn
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if NameESPEnabled then
            AddNameESP(player)
        end
    end)
end)

-- Hapus teks saat player keluar
Players.PlayerRemoving:Connect(function(player)
    RemoveNameESP(player)
end)

-- Toggle Name ESP untuk UI Compkiller
local NameESPToggle = NormalSection:AddToggle({
    Name = "Name ESP",
    Flag = "Toggle_NameESP", 
    Default = false,
    Callback = function(Value)
        SetNameESP(Value)
        
        if Value then
            Notifier.new({
                Title = "Notifikasi",
                Content = "Name ESP telah diaktifkan!",
                Duration = 5,
                Icon = "rbxassetid://116526595864004"
            });
        else
            Notifier.new({
                Title = "Notifikasi",
                Content = "Name ESP dimatikan.",
                Duration = 5,
                Icon = "rbxassetid://116526595864004"
            });
        end
    end,
});

-- Helper untuk Name ESP
NameESPToggle.Link:AddHelper({
    Text = "Menampilkan Display Name dan Username pemain lain di atas kepala mereka."
})
--[[
-- ==================== --
-- Add Option To Toggle --
local Toggle2 = NormalSection:AddToggle({
	Name = "Toggle",
	Flag = "Toggle_Example2", 
	Default = false,
	Callback = print,
});

local Option = Toggle2.Link:AddOption()

Option:AddToggle({
	Name= "Example",
	Flag = "Toggle_Example3",
	Callback = print
});

do
	local Toggle2 = NormalSection:AddToggle({
		Name = "Fitur Spesial",
		Flag = "Toggle_Example5", 
		Default = false,
		Risky = true,
		Callback = print,
	});

	local Option = Toggle2.Link:AddOption()

	Option:AddToggle({
		Risky = true,
		Name= "Fitur Spesial",
		Flag = "Toggle_Example6",
		Callback = print
	});
end

NormalSection:AddKeybind({
	Name = "Keybind",
	Default = "LeftAlt",
	Flag = "Keybind_Example",
	Callback = print,
});

NormalSection:AddSlider({
	Name = "Slider",
	Min = 0,
	Max = 100,
	Default = 50,
	Round = 0,
	Flag = "Slider_Example",
	Callback = print
});

NormalSection:AddColorPicker({
	Name = "ColorPicker",
	Default = Color3.fromRGB(0, 255, 140),
	Flag = "Color_Picker_Example",
	Callback = print
})

NormalSection:AddDropdown({
	Name = "Single Dropdown",
	Default = "Head",
	Flag = "Single_Dropdown",
	Values = {"Head","Body","Arms","Legs"},
	Callback = print
})

NormalSection:AddDropdown({
	Name = "Multi Dropdown",
	Default = {"Head"},
	Multi = true,
	Flag = "Multi_Dropdown",
	Values = {"Head","Body","Arms","Legs"},
	Callback = print
})

NormalSection:AddButton({
	Name = "Button",
	Callback = function()
		print('PRINT!')
	end,
})

NormalSection:AddParagraph({
	Title = "Paragraph",
	Content = "Very cool paragraph\nAll element in this scrtion\nwill be saved to the config!"
})

NormalSection:AddTextBox({
	Name = "Textbox",
	Placeholder = "Placeholder",
	Default = "Hello, World",
	Callback = print
})
]]


local DrawElements = function(Tab,Position)
	do
		local NormalSectionRight = Tab:DrawSection({
			Name = "Utilitas UI",
			Position = Position
		});

NormalSectionRight:AddParagraph({
			Title = "Paragraph",
			Content = "Tekan tombol di atas untuk\nmembuka jendela atau antarmuka\nfitur tambahan secara terpisah."
		})
--[[
		local Toggle = NormalSectionRight:AddToggle({
			Name = "Toggle",
			Default = false,
			Callback = print,
		});

		local Keybind = Toggle.Link:AddKeybind({
			Default = "E",
			Callback = print
		});

		local Toggle2 = NormalSectionRight:AddToggle({
			Name = "Toggle",
			Default = false,
			Callback = print,
		});

		local Option = Toggle2.Link:AddOption()

		Option:AddToggle({
			Name= "Example",
			Callback = print
		});

		NormalSectionRight:AddKeybind({
			Name = "Keybind",
			Default = "LeftAlt",
			Callback = print,
		});

		NormalSectionRight:AddSlider({
			Name = "Slider",
			Min = 0,
			Max = 100,
			Default = 50,
			Round = 0,
			Callback = print
		});

		NormalSectionRight:AddColorPicker({
			Name = "ColorPicker",
			Default = Color3.fromRGB(0, 255, 140),
			Callback = print
		})

		NormalSectionRight:AddDropdown({
			Name = "Single Dropdown",
			Default = "Head",
			Values = {"Head","Body","Arms","Legs"},
			Callback = print
		})

		NormalSectionRight:AddDropdown({
			Name = "Multi Dropdown",
			Default = {"Head"},
			Multi = true,
			Values = {"Head","Body","Arms","Legs"},
			Callback = print
		})
]]
		NormalSectionRight:AddButton({
			Name = "Button",
			Callback = function()
				print('PRINT!')
			end,
		})

	end;
end;

DrawElements(NormalTab,'right')


-- Single Tab --
local SingleTab = Window:DrawTab({
	Name = "Script Archive",
	Icon = "banana",
	Type = "Single"
});

DrawElements(SingleTab,'left')
--[[
-- Container Tab --
local ContainerTab = Window:DrawContainerTab({
	Name = "Extract Tabs",
	Icon = "contact",
});

local ExtractTab = ContainerTab:DrawTab({
	Name = "Tab 1",
	Type = "Double"
});

local SingleExtractTab = ContainerTab:DrawTab({
	Name = "Tab 2",
	Type = "Single",
	EnableScrolling = true, 
});

DrawElements(ExtractTab,"left");
DrawElements(ExtractTab,"right");

DrawElements(SingleExtractTab,"left");
DrawElements(SingleExtractTab,"right");
]]

Window:DrawCategory({
	Name = "Lainnya"
});

local SettingTab = Window:DrawTab({
	Icon = "settings-3",
	Name = "Pengaturan",
	Type = "Single",
	EnableScrolling = true
});

local ThemeTab = Window:DrawTab({
	Icon = "paintbrush",
	Name = "Tema",
	Type = "Single"
});

local Settings = SettingTab:DrawSection({
	Name = "Pengaturan Tampilan",
});

-- isi pengaturan
Settings:AddToggle({
	Name = "Selalu Tampilkan Bingkai",
	Default = false,
	Callback = function(v)
		Window.AlwayShowTab = v;
	end,
});

--[[
Settings:AddColorPicker({
	Name = "Highlight",
	Default = Compkiller.Colors.Highlight,
	Callback = function(v)
		Compkiller.Colors.Highlight = v;
		Compkiller:RefreshCurrentColor();
	end,
});

Settings:AddColorPicker({
	Name = "Toggle Color",
	Default = Compkiller.Colors.Toggle,
	Callback = function(v)
		Compkiller.Colors.Toggle = v;
		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddColorPicker({
	Name = "Drop Color",
	Default = Compkiller.Colors.DropColor,
	Callback = function(v)
		Compkiller.Colors.DropColor = v;
		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddColorPicker({
	Name = "Risky",
	Default = Compkiller.Colors.Risky,
	Callback = function(v)
		Compkiller.Colors.Risky = v;
		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddColorPicker({
	Name = "Mouse Enter",
	Default = Compkiller.Colors.MouseEnter,
	Callback = function(v)
		Compkiller.Colors.MouseEnter = v;
		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddColorPicker({
	Name = "Block Color",
	Default = Compkiller.Colors.BlockColor,
	Callback = function(v)
		Compkiller.Colors.BlockColor = v;
		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddColorPicker({
	Name = "Background Color",
	Default = Compkiller.Colors.BGDBColor,
	Callback = function(v)
		Compkiller.Colors.BGDBColor = v;
		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddColorPicker({
	Name = "Block Background Color",
	Default = Compkiller.Colors.BlockBackground,
	Callback = function(v)
		Compkiller.Colors.BlockBackground = v;
		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddColorPicker({
	Name = "Stroke Color",
	Default = Compkiller.Colors.StrokeColor,
	Callback = function(v)
		Compkiller.Colors.StrokeColor = v;
		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddColorPicker({
	Name = "High Stroke Color",
	Default = Compkiller.Colors.HighStrokeColor,
	Callback = function(v)
		Compkiller.Colors.HighStrokeColor = v;
		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddColorPicker({
	Name = "Switch Color",
	Default = Compkiller.Colors.SwitchColor,
	Callback = function(v)
		Compkiller.Colors.SwitchColor = v;
		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddColorPicker({
	Name = "Line Color",
	Default = Compkiller.Colors.LineColor,
	Callback = function(v)
		Compkiller.Colors.LineColor = v;
		Compkiller:RefreshCurrentColor(v);
	end,
});

Settings:AddButton({
	Name = "Get Theme",
	Callback = function()
		print(Compkiller:GetTheme())
		
		Notifier.new({
			Title = "Notification",
			Content = "Copied Them Color to your clipboard",
			Duration = 5,
			Icon = "rbxassetid://120245531583106"
		});
	end,
});
]]

ThemeTab:DrawSection({
	Name = "UI Themes"
}):AddDropdown({
	Name = "Select Theme",
	Default = "Default",
	Values = {
		"Default",
		"Dark Green",
		"Dark Blue",
		"Purple Rose",
		"Skeet"
	},
	Callback = function(v)
		Compkiller:SetTheme(v)
	end,
})

-- Creating Config Tab --
local ConfigUI = Window:DrawConfig({
	Name = "Config",
	Icon = "folder",
	Config = ConfigManager
});

ConfigUI:Init();