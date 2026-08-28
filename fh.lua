-- Memuat Flames Hub
loadstring(game:HttpGet('https://raw.githubusercontent.com/zdanx/flames-hub-2/refs/heads/main/Experiences/13967668166.lua'))()

-- Otomatis memindahkan tombol Toggle Flames ke Ujung Kanan Atas
task.spawn(function()
    local CoreGui = game:GetService("CoreGui")
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local button = nil

    -- Mencari tombol sampai ketemu
    repeat
        task.wait(0.5)
        local targets = {CoreGui, LocalPlayer:FindFirstChild("PlayerGui")}
        for _, parent in ipairs(targets) do
            if parent then
                for _, v in ipairs(parent:GetDescendants()) do
                    if (v:IsA("TextButton") or v:IsA("ImageButton")) and 
                       (v.Name:lower():find("flames") or (v:IsA("TextButton") and v.Text:find("Toggle Flames"))) then
                        button = v
                        break
                    end
                end
            end
            if button then break end
        end
    until button

    -- Mengubah posisi ke Ujung Kanan Atas (Margin 20px dari tepi)
    button.AnchorPoint = Vector2.new(1, 0)
    button.Position = UDim2.new(1, -20, 0, 20)
end)
