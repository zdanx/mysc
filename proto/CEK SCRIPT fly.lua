-- ========================================== --
--  MODERN FLY UI WITH +/- SPEED BUTTONS      --
-- ========================================== --

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
getgenv().C = { FlyEnabled = false, FlySpeed = 1 }
local C = getgenv().C

-- 1. Deteksi tempat aman untuk memuat UI (Support semua Executor)
local targetGui = (gethui and gethui()) or game:GetService("CoreGui") or LP:WaitForChild("PlayerGui")

-- Hapus UI lama jika script di-execute berkali-kali
if targetGui:FindFirstChild("ModernFlyUI") then
    targetGui.ModernFlyUI:Destroy()
end

-- 2. Membuat ScreenGui
local SG = Instance.new("ScreenGui")
SG.Name = "ModernFlyUI"
SG.ResetOnSpawn = false
SG.Parent = targetGui

-- ========================================== --
--  FUNGSI DRAGGABLE (AGAR UI BISA DIGESER)   --
-- ========================================== --
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
        end
    end)
    gui.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ========================================== --
--  MEMBUAT ICON KECIL MENGAMBANG (FLOAT)     --
-- ========================================== --
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "FloatIcon"
FloatBtn.Size = UDim2.new(0, 45, 0, 45)
FloatBtn.Position = UDim2.new(0, 20, 0.5, -22)
FloatBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FloatBtn.Text = "✈️"
FloatBtn.TextSize = 24
FloatBtn.Font = Enum.Font.SourceSansBold
FloatBtn.Parent = SG

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatBtn
MakeDraggable(FloatBtn)

-- ========================================== --
--  MEMBUAT MENU UTAMA (MAIN FRAME)           --
-- ========================================== --
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 135)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -67)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Visible = false
MainFrame.Parent = SG
MakeDraggable(MainFrame)

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Judul
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Terbang"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Tombol Minimize/Close
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -35, 0, 2)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "✖"
MinBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = MainFrame

-- Tombol Toggle Terbang
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 35)
ToggleBtn.Position = UDim2.new(0, 10, 0, 40)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleBtn.Text = "OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.GothamSemibold
ToggleBtn.Parent = MainFrame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

-- Teks Label Kecepatan
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0, 105, 0, 30)
SpeedLabel.Position = UDim2.new(0, 10, 0, 85)
SpeedLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SpeedLabel.Text = "Speed: 1"
SpeedLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
SpeedLabel.TextSize = 13
SpeedLabel.Font = Enum.Font.GothamSemibold
SpeedLabel.Parent = MainFrame
Instance.new("UICorner", SpeedLabel).CornerRadius = UDim.new(0, 6)

-- Tombol Kurang (-)
local MinusBtn = Instance.new("TextButton")
MinusBtn.Size = UDim2.new(0, 45, 0, 30)
MinusBtn.Position = UDim2.new(0, 120, 0, 85)
MinusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinusBtn.Text = "-"
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.TextSize = 18
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.Parent = MainFrame
Instance.new("UICorner", MinusBtn).CornerRadius = UDim.new(0, 6)

-- Tombol Tambah (+)
local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0, 45, 0, 30)
PlusBtn.Position = UDim2.new(0, 170, 0, 85)
PlusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.TextSize = 18
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.Parent = MainFrame
Instance.new("UICorner", PlusBtn).CornerRadius = UDim.new(0, 6)

-- ========================================== --
--  LOGIKA KLIK BUKA/TUTUP MENU               --
-- ========================================== --
FloatBtn.MouseButton1Click:Connect(function()
    FloatBtn.Visible = false
    MainFrame.Visible = true
end)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatBtn.Visible = true
end)

-- ========================================== --
--  LOGIKA TOMBOL - DAN + SPEED               --
-- ========================================== --
MinusBtn.MouseButton1Click:Connect(function()
    C.FlySpeed = math.clamp(C.FlySpeed - 1, 0.1, 100)
    SpeedLabel.Text = "Speed: " .. tostring(C.FlySpeed)
end)

PlusBtn.MouseButton1Click:Connect(function()
    C.FlySpeed = math.clamp(C.FlySpeed + 1, 0.1, 100)
    SpeedLabel.Text = "Speed: " .. tostring(C.FlySpeed)
end)

-- ========================================== --
--  LOGIKA TERBANG (FLY MECHANISM)            --
-- ========================================== --
local FlyDown, FlyUp, FLYING = nil, nil, false
local md = {F=0, B=0, L=0, R=0}

ToggleBtn.MouseButton1Click:Connect(function()
    C.FlyEnabled = not C.FlyEnabled
    
    if C.FlyEnabled then
        ToggleBtn.Text = "ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 160, 50) -- Hijau
        
        local LP = Players.LocalPlayer
        repeat task.wait() until LP and LP.Character and LP.Character:WaitForChild("HumanoidRootPart")
        FLYING = true
        
        local T = LP.Character.HumanoidRootPart
        local BG = Instance.new('BodyGyro', T)
        BG.P = 9e4
        BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        BG.CFrame = T.CFrame
        
        local BV = Instance.new('BodyVelocity', T)
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        
        task.spawn(function()
            while FLYING and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") do
                task.wait()
                local camFrame = Workspace.CurrentCamera.CoordinateFrame
                if md.F+md.B ~= 0 or md.L+md.R ~= 0 then
                    BV.Velocity = ((camFrame.LookVector * (md.F + md.B)) + (camFrame.RightVector * (md.L + md.R))) * (C.FlySpeed * 50)
                else
                    BV.Velocity = Vector3.new(0, 0, 0)
                end
                BG.CFrame = camFrame
            end
            if BG then BG:Destroy() end
            if BV then BV:Destroy() end
        end)
        
        FlyDown = UIS.InputBegan:Connect(function(input, gp)
            if not gp then
                local K = input.KeyCode
                if K == Enum.KeyCode.W then md.F = 1
                elseif K == Enum.KeyCode.S then md.B = -1
                elseif K == Enum.KeyCode.A then md.L = -1
                elseif K == Enum.KeyCode.D then md.R = 1
                end
            end
        end)
        
        FlyUp = UIS.InputEnded:Connect(function(input, gp)
            if not gp then
                local K = input.KeyCode
                if K == Enum.KeyCode.W then md.F = 0
                elseif K == Enum.KeyCode.S then md.B = 0
                elseif K == Enum.KeyCode.A then md.L = 0
                elseif K == Enum.KeyCode.D then md.R = 0
                end
            end
        end)
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Kembali ke abu-abu
        FLYING = false
        if FlyDown then FlyDown:Disconnect() end
        if FlyUp then FlyUp:Disconnect() end
    end
end)