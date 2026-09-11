local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

-- 1. Buat Layar Hitam (Loading Screen) Menutupi Seluruh Layar
local loadingScreen = Instance.new("ScreenGui")
loadingScreen.Name = "FlamesHubLoadingScreen"
loadingScreen.IgnoreGuiInset = true
loadingScreen.DisplayOrder = 999999999 -- Memastikan berada di urutan teratas dari semua UI exploit
loadingScreen.Parent = (gethui and gethui()) or CoreGui

local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
background.Parent = loadingScreen

local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.new(1, 0, 1, 0)
loadingText.BackgroundTransparency = 1
loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingText.TextSize = 35
loadingText.Font = Enum.Font.GothamBold
loadingText.Text = "Memuat Flames Hub...\n(60s)"
loadingText.Parent = background

-- 2. Sistem Penahan Suara Sementara
local originalVolumes = {}
local function muteSound(sound)
    if sound:IsA("Sound") then
        if originalVolumes[sound] == nil then
            originalVolumes[sound] = sound.Volume
        end
        sound.Volume = 0
    end
end

-- Menyembunyikan suara dari layanan utama
local targets = {workspace, SoundService, CoreGui, Players}
for _, target in ipairs(targets) do
    pcall(function()
        for _, v in ipairs(target:GetDescendants()) do
            muteSound(v)
        end
    end)
end

-- Membisukan suara notifikasi baru yang muncul saat loading
local soundConnection = game.DescendantAdded:Connect(function(v)
    pcall(function() muteSound(v) end)
end)

-- 3. Memuat Flames Hub
task.spawn(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/zdanx/flames-hub-2/refs/heads/main/Experiences/13967668166.lua'))()[span_1](start_span)[span_1](end_span)
end)

-- 4. Hitung Mundur 1 Menit (60 Detik)
task.spawn(function()
    for i = 60, 1, -1 do
        loadingText.Text = "Menyiapkan Flames Hub...\nMenyembunyikan proses (Sisa waktu: " .. i .. "s)"
        task.wait(1)
    end

    -- 5. Bersihkan Layar Hitam dan Kembalikan Suara
    soundConnection:Disconnect()
    loadingScreen:Destroy()

    for sound, vol in pairs(originalVolumes) do
        if sound and sound.Parent then
            sound.Volume = vol
        end
    end
end)

-- 6. Otomatis memindahkan tombol Toggle Flames ke Ujung Kanan Atas[span_2](start_span)[span_2](end_span)
task.spawn(function()
    local LocalPlayer = Players.LocalPlayer
    local button = nil

    -- Mencari tombol sampai ketemu[span_3](start_span)[span_3](end_span)
    repeat
        task.wait(0.5)
        local uiTargets = {CoreGui, LocalPlayer:FindFirstChild("PlayerGui")}
        for _, parent in ipairs(uiTargets) do
            if parent then
                for _, v in ipairs(parent:GetDescendants()) do
                    if (v:IsA("TextButton") or v:IsA("ImageButton")) and 
                       (v.Name:lower():find("flames") or (v:IsA("TextButton") and v.Text:find("Toggle Flames"))) then[span_4](start_span)[span_4](end_span)
                        button = v[span_5](start_span)[span_5](end_span)
                        break[span_6](start_span)[span_6](end_span)
                    end[span_7](start_span)[span_7](end_span)
                end[span_8](start_span)[span_8](end_span)
            end[span_9](start_span)[span_9](end_span)
            if button then break end[span_10](start_span)[span_10](end_span)
        end[span_11](start_span)[span_11](end_span)
    until button[span_12](start_span)[span_12](end_span)

    -- Mengubah posisi ke Ujung Kanan Atas (Margin 20px dari tepi)[span_13](start_span)[span_13](end_span)
    button.AnchorPoint = Vector2.new(1, 0)[span_14](start_span)[span_14](end_span)
    button.Position = UDim2.new(1, -10, 0, 10)[span_15](start_span)[span_15](end_span)
end)
