-- ==========================================
-- SISTEM WHITELIST & SMOOTH FADE UI (CLEAN)
-- ==========================================
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- URL database JSON Anda di GitHub
-- ori local WhitelistURL = "https://raw.githubusercontent.com/Zami-X/Script-Archive/refs/heads/main/data.json"
local WhitelistURL = "https://raw.githubusercontent.com/zdanx/mysc/refs/heads/main/cstm/data.json"

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
--========================================
--[ SCRIPT ARCHIVE - ACCESS DENIED ]
--========================================
--Status : Tidak terdaftar di database
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

-- ==========================================
-- TAB MAIN (FREE SCRIPT DINAMIS)
-- ==========================================
local MainTab = Window:CreateTab("🏠 Home (Free Script)", nil) 
local MainSection = MainTab:CreateSection("Free Scripts")

Rayfield:Notify({
    Title = "Akses Diterima!",
    Content = "Selamat datang, " .. LocalPlayer.Name .. "!",
    Duration = 5,
    Image = 13047715178,
})

-- Ambil data FreeScripts dari URL JSON
local freeSuccess, freeResult = pcall(function()
    local response = game:HttpGet(WhitelistURL)
    return HttpService:JSONDecode(response)
end)

if freeSuccess and freeResult and freeResult.FreeScripts then
    for _, scriptData in ipairs(freeResult.FreeScripts) do
        local scriptTitle = scriptData.ScriptName or "Free Script"
        local scriptURL = scriptData.ScriptURL

        MainTab:CreateButton({
            Name = scriptTitle,
            Callback = function()
                local execSuccess = pcall(function()
                    loadstring(game:HttpGet(scriptURL))()
                end)
                
                if execSuccess then
                    Rayfield:Notify({
                        Title = scriptTitle,
                        Content = "Script " .. scriptTitle .. " berhasil diaktifkan!",
                        Duration = 4,
                    })
                else
                    Rayfield:Notify({
                        Title = "Error Script",
                        Content = "Gagal menjalankan " .. scriptTitle,
                        Duration = 4,
                    })
                end
            end,
        })
    end
else
    Rayfield:Notify({
        Title = "Gagal Memuat",
        Content = "Gagal mengambil daftar Free Script dari database.",
        Duration = 5,
    })
end

-- ==========================================
-- VIP SCRIPT TAB (MULTIPLE DYNAMIC SCRIPTS)
-- ==========================================
local VIPTab = Window:CreateTab("💎 VIP Script", nil)

local isUnlocked = false
local LoginSection = VIPTab:CreateSection("Verifikasi Akses VIP")

local inputPassword = ""
local PasswordInput = VIPTab:CreateInput({
   Name = "Masukkan Password VIP Anda",
   PlaceholderText = "Ketik password dari Zami...",
   RemoveTextAfterFocusLost = false,
   Callback = function(text)
      inputPassword = text
   end,
})

local VIPContentSection = VIPTab:CreateSection("Script VIP Anda")

local UnlockButton = VIPTab:CreateButton({
   Name = "🔓 Unlock VIP Script",
   Callback = function()
      if isUnlocked then return end

      local success, result = pcall(function()
          local response = game:HttpGet(WhitelistURL)
          return HttpService:JSONDecode(response)
      end)

      if not success or not result.VIPScripts then
          Rayfield:Notify({
             Title = "Error",
             Content = "Gagal memverifikasi database.",
             Duration = 4,
          })
          return
      end

      local currentUsername = string.lower(LocalPlayer.Name)
      local foundData = nil

      for user, data in pairs(result.VIPScripts) do
          if string.lower(user) == currentUsername then
              foundData = data
              break
          end
      end

      if foundData then
          -- Cek apakah datanya berupa banyak script (Array) atau 1 script (Object tunggal)
          local firstData = foundData[1] or foundData
          local passwordValid = (inputPassword == firstData.Password)

          if passwordValid then
              isUnlocked = true
              
              Rayfield:Notify({
                 Title = "Berhasil Unlocked!",
                 Content = "Password benar. Semua script VIP Anda dimuat.",
                 Duration = 5,
              })
              
              -- Sembunyikan form input dan tombol unlock
              pcall(function()
                  PasswordInput.Visible = false
                  UnlockButton.Visible = false
                  LoginSection.Visible = false
              end)

              -- Fungsi untuk meload daftar script (mendukung format banyak script atau 1 script)
              local function loadScriptList(listData)
                  if type(listData[1]) == "table" then
                      -- Jika bentuknya array (banyak script)
                      for _, scriptInfo in ipairs(listData) do
                          local scriptTitle = scriptInfo.ScriptName or "Custom VIP Script"
                          local scriptURL = scriptInfo.ScriptURL
                          
                          VIPTab:CreateButton({
                             Name = "🚀 " .. scriptTitle,
                             Callback = function()
                                local execSuccess = pcall(function()
                                    loadstring(game:HttpGet(scriptURL))()
                                end)
                                
                                if execSuccess then
                                    Rayfield:Notify({
                                       Title = "Berhasil",
                                       Content = scriptTitle .. " berhasil dieksekusi!",
                                       Duration = 4,
                                    })
                                else
                                    Rayfield:Notify({
                                       Title = "Error Script",
                                       Content = "Gagal mengeksekusi link script.",
                                       Duration = 4,
                                    })
                                end
                             end,
                          })
                      end
                  else
                      -- Jika formatnya hanya 1 script (objek tunggal)
                      local scriptTitle = listData.ScriptName or "Custom VIP Script"
                      local scriptURL = listData.ScriptURL
                      
                      VIPTab:CreateButton({
                         Name = "🚀 " .. scriptTitle,
                         Callback = function()
                            local execSuccess = pcall(function()
                                loadstring(game:HttpGet(scriptURL))()
                            end)
                            
                            if execSuccess then
                                Rayfield:Notify({
                                   Title = "Berhasil",
                                   Content = scriptTitle .. " berhasil dieksekusi!",
                                   Duration = 4,
                                })
                            end
                         end,
                      })
                  end
              end

              -- Jalankan pemanggilan tombol script
              loadScriptList(foundData)
              
          else
              Rayfield:Notify({
                 Title = "Akses Ditolak",
                 Content = "Password salah!",
                 Duration = 4,
              })
          end
      else
          Rayfield:Notify({
             Title = "Tidak Terdaftar",
             Content = "Akun Anda tidak memiliki data VIP Script.",
             Duration = 4,
          })
      end
   end,
})

VIPTab:CreateSection("Informasi Bantuan")
VIPTab:CreateButton({
   Name = "ℹ️ Cara Memasukkan VIP Script Milik Anda Sendiri!",
   Callback = function()
      pcall(function() setclipboard("https://discord.gg/noinvitelink") end)
      Rayfield:Notify({
         Title = "Info VIP",
         Content = "Link Discord disalin! DM Zami untuk pasang script VIP & minta password.",
         Duration = 5,
      })
   end,
})

local MiscTab = Window:CreateTab("COMING SOON 🚀", nil)
