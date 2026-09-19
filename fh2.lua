-- Memuat Flames Hub
loadstring(game:HttpGet('https://raw.githubusercontent.com/zdanx/flames-hub-2/refs/heads/main/Experiences/13967668166.lua'))()

-- Loop pemantauan berkelanjutan
task.spawn(function()
    local CoreGui = game:GetService("CoreGui")
    local LocalPlayer = game:GetService("Players").LocalPlayer

    while task.wait(0.5) do
        local targets = {CoreGui, LocalPlayer:FindFirstChild("PlayerGui")}
        for _, parent in ipairs(targets) do
            if parent then
                for _, v in ipairs(parent:GetDescendants()) do
                    -- 1. Mengunci posisi tombol Toggle Flames di Ujung Kanan Atas
                    if (v:IsA("TextButton") or v:IsA("ImageButton")) and 
                       (v.Name:lower():find("flames") or (v:IsA("TextButton") and v.Text:find("Toggle Flames"))) then
                        if v.Position ~= UDim2.new(1, -10, 0, 10) then
                            v.AnchorPoint = Vector2.new(1, 0)
                            v.Position = UDim2.new(1, -10, 0, 10)
                        end
                    end
                    
                    -- 2. Menghilangkan Watermark UUID & Bar Background Ungu/Magenta
                    if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                        local txt = v.Text:lower()
                        if txt:find("uuid") or txt:find("lifehub") or txt:find("made by") then
                            v.Visible = false
                            -- Sembunyikan bingkai/box latar belakang tempat teks berada
                            if v.Parent and v.Parent:IsA("GuiObject") and not v.Parent:IsA("ScreenGui") then
                                v.Parent.Visible = false
                            end
                        end
                    end
                end
            end
        end
    end
end)
