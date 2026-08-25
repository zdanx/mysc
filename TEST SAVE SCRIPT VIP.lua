-- ==========================================
-- SISTEM WHITELIST & SMOOTH FADE UI (CLEAN)
-- ==========================================
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- URL database JSON Anda di GitHub
local WhitelistURL = "https://raw.githubusercontent.com/zdanx/mysc/refs/heads/main/data.json"

-- 1. Membuat Tampilan Custom UI (Tanpa Background Hitam)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptArchiveWhitelist"

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

-- Kotak Utama (Transparan penuh di awal untuk efek Fade In)
local MainBox = Instance.new("Frame")
MainBox.Size = UDim2.new(0, 320, 0, 140)
MainBox.Position = UDim2.new(0.5, -160, 0.5, -70)
MainBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainBox.BackgroundTransparency = 1 
MainBox.BorderSizePixel = 0
MainBox.Parent = ScreenGui

-- Sudut Melengkung Halus
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainBox

-- Garis Tepi Tipis
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(45, 45, 55)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 1 
UIStroke.Parent = MainBox

-- Judul
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.Position = UDim2.new(0, 0, 0, 20)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "SCRIPT ARCHIVE"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleLabel.TextTransparency = 1 
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = MainBox

-- Teks Status
local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -40, 0, 30)
StatusText.Position = UDim2.new(0, 20, 0, 65)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Memeriksa database..."
StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusText.TextTransparency = 1 
StatusText.TextSize = 13
StatusText.Font = Enum.Font.Gotham
StatusText.Parent = MainBox


-- Fungsi Animasi Mulus (Fade In / Fade Out) Tanpa Backdrop
local function FadeUI(isEntering, callback)
    local info = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    local targetAlpha = isEntering and 0 or 1
    
    TweenService:Create(MainBox, info, {BackgroundTransparency = targetAlpha}):Play()
    TweenService:Create(UIStroke, info, {Transparency = targetAlpha}):Play()
    TweenService:Create(TitleLabel, info, {TextTransparency = targetAlpha}):Play()
    TweenService:Create(StatusText, info, {TextTransparency = targetAlpha}):Play()
    
    task.wait(0.4)
    if callback then callback() end
end

-- Jalankan Efek Muncul (Fade In)
FadeUI(true)


-- 2. Fungsi Pengecekan Whitelist
local function CheckWhitelist()
    task.wait(0.6)
    
    local success, result = pcall(function()
        local response = game:HttpGet(WhitelistURL)
        return HttpService:JSONDecode(response)
    end)

    if not success then
        StatusText.TextColor3 = Color3.fromRGB(255, 90, 90)
        StatusText.Text = "Gagal memuat database."
        task.wait(1.5)
        FadeUI(false, function()
            ScreenGui:Destroy()
        end)
        LocalPlayer:Kick("\n[Script Archive] Gagal memuat database whitelist! Periksa koneksi internet Anda.")
        return false
    end

    local isAllowed = false
    for _, username in ipairs(result.Users) do
        if string.lower(username) == string.lower(LocalPlayer.Name) then
            isAllowed = true
            break
        end
    end

    return isAllowed
end

-- 3. Eksekusi & Hasil dengan Transisi Memudar Mulus
local isValid = CheckWhitelist()

if isValid then
    -- Jika Berhasil (Hijau Kalem)
    StatusText.TextColor3 = Color3.fromRGB(90, 220, 130)
    StatusText.Text = "Akses diberikan. Selamat datang, " .. LocalPlayer.Name .. "!"
    
    task.wait(1.2)
    
    -- Efek Menghilang Memudar (Fade Out) yang Rapi
    FadeUI(false, function()
        ScreenGui:Destroy()
    end)
    
    -- ==========================================
    -- LANJUTKAN SCRIPT RAYFIELD UI UTAMA DI SINI
    -- ==========================================

    -- ==========================================
-- SISTEM PENYIMPANAN SCRIPT LOKAL (DELTA)
-- ==========================================
local FolderName = "ScriptArchive_Custom"
if not isfolder(FolderName) then
    makefolder(FolderName)
end

local function GetSavedScripts()
    local scripts = {}
    for _, file in ipairs(listfiles(FolderName)) do
        if file:sub(-4) == ".lua" then
            local name = file:match("([^/]+)$"):gsub("%.lua$", "")
            table.insert(scripts, name)
        end
    end
    return scripts
end

    print("Script Utama Dijalankan...")

else
    -- Jika Gagal (Merah Kalem)
    StatusText.TextColor3 = Color3.fromRGB(255, 90, 90)
    StatusText.Text = "Username tidak terdaftar."
    
    task.wait(1.5)
    
    FadeUI(false, function()
        ScreenGui:Destroy()
    end)
    
    -- Pesan Kick Profesional
    LocalPlayer:Kick([[
========================================
[ SCRIPT ARCHIVE - ACCESS DENIED ]
========================================
Status : Tidak terdaftar di database
Akun   : ]] .. LocalPlayer.Name .. [[

Silahkan hubungi pembuat untuk akses:
TikTok : @muhzdann
========================================]])
    return
end

-- ==========================================
-- LANJUTAN SCRIPT RAYFIELD UI ANDA
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/zdanx/mysc/refs/heads/main/cstm/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "🔥 Script Archive",
   LoadingTitle = "Life Together",
   LoadingSubtitle = "Script Archive by Zami",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, 
      FileName = "Script Archive"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink", 
      RememberJoins = true 
   },
   KeySystem = false, 
   KeySettings = {
      Title = "Key | Youtube Hub",
      Subtitle = "Key System",
      Note = "Key In Discord Server",
      FileName = "YoutubeHubKey1", 
      SaveKey = false, 
      GrabKeyFromSite = true, 
      Key = {"https://pastebin.com/raw/AtgzSPWK"} 
   }
})

local MainTab = Window:CreateTab("🏠 Home (Free Script)", nil) 
local MainSection = MainTab:CreateSection("Main")

Rayfield:Notify({
   Title = "Akses Diterima!",
   Content = "Selamat datang, " .. LocalPlayer.Name .. "!",
   Duration = 5,
   Image = 13047715178,
})

local InfYieldButton = MainTab:CreateButton({
   Name = "Infinite Yield",
   Callback = function()
      loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
      Rayfield:Notify({
         Title = "Infinite Yield",
         Content = "Script Infinite Yield berhasil diaktifkan!",
         Duration = 4,
         --Image = 13047715178,
      })
   end,
})

local CrypticButton = MainTab:CreateButton({
   Name = "Cryptic",
   Callback = function()
      loadstring(game:HttpGet('https://raw.githubusercontent.com/OnlyCryptic/Cryptic/main/main.lua'))()
      Rayfield:Notify({
         Title = "Cryptic",
         Content = "Script Cryptic berhasil diaktifkan!",
         Duration = 4,
         --Image = 13047715178,
      })
   end,
})

local FlamesButton = MainTab:CreateButton({
   Name = "Flames Hub",
   Callback = function()
      loadstring(game:HttpGet('https://raw.githubusercontent.com/zdanx/flames-hub-2/refs/heads/main/Experiences/13967668166.lua'))()
      Rayfield:Notify({
         Title = "Flames Hub",
         Content = "Script Flames Hub berhasil diaktifkan!",
         Duration = 4,
         --Image = 13047715178,
      })
   end,
})

local VIPTab = Window:CreateTab("💎 VIP Script", nil)
local VIPSection = VIPTab:CreateSection("Custom User Scripts")

-- Input untuk nama script baru
local customName = ""
VIPTab:CreateInput({
   Name = "Nama Script",
   PlaceholderText = "Contoh: ScriptFlyUFO",
   RemoveTextAfterFocusLost = false,
   Callback = function(text)
      customName = text
   end,
})

-- Input untuk kode loadstring atau isi script
local customCode = ""
VIPTab:CreateInput({
   Name = "Kode / Loadstring Script",
   PlaceholderText = "loadstring(game:HttpGet('...'))()",
   RemoveTextAfterFocusLost = false,
   Callback = function(text)
      customCode = text
   end,
})

-- Tombol untuk Menyimpan Script ke Folder Lokal Delta
VIPTab:CreateButton({
   Name = "💾 Simpan Script Ini",
   Callback = function()
      if customName ~= "" and customCode ~= "" then
          local fileName = FolderName .. "/" .. customName .. ".lua"
          writefile(fileName, customCode)
          
          Rayfield:Notify({
             Title = "Berhasil Disimpan!",
             Content = "Script tersimpan di folder lokal: " .. customName,
             Duration = 4,
          })
      else
          Rayfield:Notify({
             Title = "Gagal",
             Content = "Nama dan Kode script tidak boleh kosong!",
             Duration = 4,
          })
      end
   end,
})

VIPTab:CreateSection("Daftar Script Tersimpan")

-- Memuat otomatis script yang sudah pernah disimpan di HP pengguna
for _, scriptName in ipairs(GetSavedScripts()) do
    VIPTab:CreateButton({
        Name = "📂 " .. scriptName,
        Callback = function()
            local success, err = pcall(function()
                local filePath = FolderName .. "/" .. scriptName .. ".lua"
                local content = readfile(filePath)
                loadstring(content)()
            end)
            
            if success then
                Rayfield:Notify({
                   Title = "VIP Script",
                   Content = "Berhasil menjalankan: " .. scriptName,
                   Duration = 4,
                })
            else
                Rayfield:Notify({
                   Title = "Error",
                   Content = "Gagal menjalankan script tersebut.",
                   Duration = 4,
                })
            end
        end,
    })
end

local TPTab = Window:CreateTab("VIP Scipt (Custom)", nil) 
TPTab:CreateButton({ Name = "Starter Island", Callback = function() end })
TPTab:CreateButton({ Name = "Pirate Island", Callback = function() end })
TPTab:CreateButton({ Name = "Pineapple Paradise", Callback = function() end })

local MiscTab = Window:CreateTab("🎲 Misc", nil)
