-- =======================================================
-- 1. CLEANUP UI LAMA (AUTO-REPLACE)
-- =======================================================
if getgenv().Zami_ActiveUI then
    pcall(function() getgenv().Zami_ActiveUI:Destroy() end)
    getgenv().Zami_ActiveUI = nil
end

local TargetParent = (gethui and gethui()) or game:GetService("CoreGui")
local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/zdanx/mysc/refs/heads/main/src/source.luau"))();

-- Create Notification --
local Notifier = Compkiller.newNotify();

-- Create Config Manager --
local ConfigManager = Compkiller:ConfigManager({
	Directory = "Compkiller-UI",
	Config = "Example-Configs"
});

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

Watermark:AddText({
	Icon = "server",
	Text = Compkiller.Version,
});

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
	Name = "Section",
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

local DrawElements = function(Tab,Position)
	do
		local NormalSectionRight = Tab:DrawSection({
			Name = "Section",
			Position = Position
		});

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

		NormalSectionRight:AddButton({
			Name = "Button",
			Callback = function()
				print('PRINT!')
			end,
		})

		NormalSectionRight:AddParagraph({
			Title = "Paragraph",
			Content = "Very cool paragraph\nAll elements in this section\nwill not be save to the config"
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
	Name = "UI Settings",
});

Settings:AddToggle({
	Name = "Alway Show Frame",
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