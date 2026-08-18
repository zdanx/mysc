-- [[ ==================================================================== ]] --
-- [[                     AETHER HUB - MINIGAME CORE SYSTEM               ]] --
-- [[ ==================================================================== ]] --

if not game:IsLoaded() then
    local loadingMsg = Instance.new("Message")
    local loadingHint = Instance.new("Hint")
    loadingMsg.Text = "Aether Hub: Waiting for the game to finish loading..."
    loadingHint.Text = "Loading environment, please wait..."
    loadingMsg.Parent = workspace
    loadingHint.Parent = workspace
    game.Loaded:Wait()
    task.wait(0.1)
    loadingMsg:Destroy()
    loadingHint:Destroy()
end

local env = getgenv()
local HUB_VERSION = "V1.0.0"
env.Aether_ScriptVersion = tostring(HUB_VERSION) .. "-AetherHub"

local PlayersService = env.Players or (cloneref and cloneref(game:GetService("Players"))) or game:GetService("Players")
local LocalPlayer = PlayersService.LocalPlayer or PlayersService:GetPropertyChangedSignal("LocalPlayer"):Wait()

env.Minigame_Input_Disabled = env.Minigame_Input_Disabled or false
env.LocalPlayer = env.LocalPlayer or LocalPlayer

env.ColorPalette = env.ColorPalette or {
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(128, 128, 128),
    Color3.fromRGB(0, 0, 0),
    Color3.fromRGB(0, 120, 255),
    Color3.fromRGB(0, 255, 120),
    Color3.fromRGB(0, 255, 255),
    Color3.fromRGB(255, 165, 0),
    Color3.fromRGB(139, 69, 19),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(50, 205, 50),
    Color3.fromRGB(255, 50, 50),
    Color3.fromRGB(255, 155, 172),
    Color3.fromRGB(128, 0, 128)
}

if not env.Aether_Framework_Loaded then
    pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/T25mDhBZ"))()
    end)
    task.wait(0.1)
    env.Aether_Framework_Loaded = true
end
task.wait(0.25)

if not env.AetherHub_IsRunning then
    if env.notify and type(env.notify) == "function" then
        env.notify("Aether Hub", "Client Initialized: " .. tostring(env.LocalPlayer), 5)
    end
end

local RunService = (cloneref and cloneref(game:GetService("RunService"))) or game:GetService("RunService")
local CoreGui = env.CoreGui or (cloneref and cloneref(game:GetService("CoreGui"))) or game:GetService("CoreGui")

local hasGetHui = (type(get_hui) == "function") or (type(env.get_hui) == "function")
local hasGetHidden = (type(get_hidden_gui) == "function") or (type(env.get_hidden_gui) == "function")

if not hasGetHui and not hasGetHidden and not env.Aether_HiddenGuiLocation then
    if RunService:IsStudio() then
        local lp = env.LocalPlayer or game.Players.LocalPlayer or game:GetService("Players").LocalPlayer
        local pGui = lp and lp:FindFirstChildWhichIsA("PlayerGui")
        env.Aether_HiddenGuiLocation = pGui or CoreGui
    else
        for _, child in ipairs(CoreGui:GetChildren()) do
            if child:IsA("ScreenGui") and child.Name == "RobloxGui" then
                env.Aether_HiddenGuiLocation = child
                break
            end
        end
    end
    
    local function resolveContainer()
        if env.Aether_HiddenGuiLocation and env.Aether_HiddenGuiLocation.Parent and env.Aether_HiddenGuiLocation:IsA("ScreenGui") then
            return env.Aether_HiddenGuiLocation
        end
        return CoreGui
    end
    
    env.get_hui = resolveContainer
    env.get_hidden_gui = resolveContainer
end

local VERIFY_FILENAME = "aether_hub_verification.txt"
local TableInsert = table.insert

env.IsIntegerInString = env.IsIntegerInString or function(val)
    if type(val) == "number" then return val % 1 == 0 end
    if type(val) == "string" then return val:match("^-?%d+$") ~= nil end
    return false
end

env._aether_attr_cache = env._aether_attr_cache or {}
env.GetAttributeFuzzy = env.GetAttributeFuzzy or function(targetObj, searchTerm)
    if not targetObj or not targetObj.Parent then return nil end
    local cached = env._aether_attr_cache[targetObj]

    if cached then
        for k, v in pairs(cached) do
            if k:lower():find(searchTerm:lower(), 1, true) then return v end
        end
        return nil
    end

    local success, attributes = pcall(function() return targetObj:GetAttributes() end)
    if not success or not attributes then return nil end

    env._aether_attr_cache[targetObj] = attributes
    for k, v in pairs(attributes) do
        if k:lower():find(searchTerm:lower(), 1, true) then return v end
    end
    return nil
end

env.CheckAttributeValue = env.CheckAttributeValue or function(targetObj, attrName, expectedValue)
    local success, result = pcall(function() return targetObj:GetAttribute(attrName) end)
    return success and result == expectedValue
end

env.IsPropertyValid = env.IsPropertyValid or function(instanceObj, propertyName)
    local success, val = pcall(function() return instanceObj[propertyName] end)
    if not success then return nil end
    return val
end

env.HasProperty = env.HasProperty or function(instanceObj, propertyName)
    return instanceObj and env.IsPropertyValid(instanceObj, propertyName) ~= nil
end

env.SetPropertySafe = env.SetPropertySafe or function(instanceObj, propertyName, val)
    if instanceObj and env.HasProperty(instanceObj, propertyName) then
        pcall(function() instanceObj[propertyName] = val end)
    end
end

local function isUserVerified()
    if not isfile or not isfile(VERIFY_FILENAME) then return false end
    local data = readfile(VERIFY_FILENAME)
    return type(data) == "string" and data:lower():find("true") ~= nil
end

local function saveUserVerification()
    if writefile then writefile(VERIFY_FILENAME, "true") end
end

local function awaitGuiRemoval()
    while CoreGui:FindFirstChild("MemoryMinigameGUI") do
        task.wait()
    end
end

env.AetherHub_IsRunning = true

local currentUserId = game.Players.LocalPlayer.UserId
local HttpService = env.HttpService or (cloneref and cloneref(game:GetService("HttpService"))) or game:GetService("HttpService")

local UI_Library = env.AetherLibrary or getgenv().AetherLibrary
local loadAttempts, maxAttempts = 0, 15

while (not UI_Library or type(UI_Library) ~= "table") and loadAttempts < maxAttempts do
    task.wait(0.5)
    loadAttempts = loadAttempts + 1
    UI_Library = env.AetherLibrary or getgenv().AetherLibrary
end

local function createMaskedId(rawId)
    if not rawId then return nil end
    local segments = string.split(rawId, "-")
    local result = {}
    for i, seg in ipairs(segments) do
        if i <= 2 then
            result[i] = seg
        else
            result[i] = string.rep("*", #seg)
        end
    end
    return table.concat(result, "-")
end

function GenerateAetherUniqueID(targetUserId)
    local fileName = "aether_hub_uid.txt"
    if currentUserId ~= targetUserId then return nil end

    if isfile and isfile(fileName) then
        local savedId = readfile(fileName)
        if savedId and savedId ~= "" then return savedId end
    end

    local generated = HttpService:GenerateGUID(false)
    pcall(function() writefile(fileName, generated) end)
    return generated
end

function GetAetherUniqueID()
    local fileName = "aether_hub_uid.txt"
    if isfile and isfile(fileName) then
        local savedId = readfile(fileName)
        if savedId and savedId ~= "" then return savedId end
    end
    return nil
end

function GetMaskedAetherID()
    local raw = GetAetherUniqueID()
    return createMaskedId(raw)
end

local ChatService = (cloneref and cloneref(game:GetService("Chat"))) or game:GetService("Chat")
local Me = env.LocalPlayer or PlayersService.LocalPlayer

env.IsTextFiltered = env.IsTextFiltered or function(inputString)
    local filteredText
    local ok, err = pcall(function()
        filteredText = ChatService:FilterStringForBroadcast(inputString, Me)
    end)
    if not ok then print(tostring(err)) return true end
    return filteredText ~= inputString
end

-- [[ Minigame Difficulty System ]] --
env.minigame_difficulty = {
    memory = "Medium",
    reaction = "Medium",
    keypad = "Medium",
    hacking = "Medium",
    safe = "Medium",
    wire = "Medium",
    simon = "Medium",
    lockpick = "Medium",
    laser = "Medium",
    signal = "Medium",
    pipe = "Medium",
    steady = "Medium",
    rhythm = "Medium",
    recall = "Medium",
}

env.minigame_difficulty_presets = {
    memory = {
        Easy   = {show_time = 14, max_mistakes = 5, pattern_min = 4, pattern_max = 6},
        Medium = {show_time = 10, max_mistakes = 3, pattern_min = 6, pattern_max = 9},
        Hard   = {show_time = 6,  max_mistakes = 2, pattern_min = 9, pattern_max = 12},
    },
    reaction = {
        Easy   = {max_wins = 4, max_misses = 5, start_speed = 0.4, speed_step = 0.08, perfect_window = 0.03},
        Medium = {max_wins = 5, max_misses = 3, start_speed = 0.6, speed_step = 0.15, perfect_window = 0.02},
        Hard   = {max_wins = 7, max_misses = 2, start_speed = 0.9, speed_step = 0.22, perfect_window = 0.012},
    },
    keypad = {
        Easy   = {code_length = 3, max_attempts = 7},
        Medium = {code_length = 4, max_attempts = 5},
        Hard   = {code_length = 5, max_attempts = 4},
    },
    hacking = {
        Easy   = {sequence_length = 3, time_limit = 28, grid_cols = 6, grid_rows = 5},
        Medium = {sequence_length = 4, time_limit = 20, grid_cols = 8, grid_rows = 6},
        Hard   = {sequence_length = 6, time_limit = 14, grid_cols = 10, grid_rows = 7},
    },
    safe = {
        Easy   = {sequence_count = 2, time_limit = 40, dial_speed = 60, target_window = 2},
        Medium = {sequence_count = 3, time_limit = 30, dial_speed = 90, target_window = 1},
        Hard   = {sequence_count = 4, time_limit = 22, dial_speed = 130, target_window = 0.5},
    },
    wire = {
        Easy   = {wire_count = 4, time_limit = 32, clue_count = 3},
        Medium = {wire_count = 5, time_limit = 25, clue_count = 2},
        Hard   = {wire_count = 6, time_limit = 18, clue_count = 1},
    },
    simon = {
        Easy   = {rounds_to_win = 3, flash_duration = 0.5, gap_duration = 0.25},
        Medium = {rounds_to_win = 5, flash_duration = 0.4, gap_duration = 0.15},
        Hard   = {rounds_to_win = 8, flash_duration = 0.25, gap_duration = 0.08},
    },
    lockpick = {
        Easy   = {pin_count = 3, sweet_width = 26, tension_max = 140, tension_rate = 6, dial_speed = 70},
        Medium = {pin_count = 4, sweet_width = 18, tension_max = 120, tension_rate = 9, dial_speed = 100},
        Hard   = {pin_count = 5, sweet_width = 12, tension_max = 100, tension_rate = 13, dial_speed = 140},
    },
    laser = {
        Easy   = {row_count = 4, beam_speed = 1.0, hazard_margin = 0.10, time_limit = 35},
        Medium = {row_count = 6, beam_speed = 1.5, hazard_margin = 0.16, time_limit = 25},
        Hard   = {row_count = 8, beam_speed = 2.2, hazard_margin = 0.24, time_limit = 18},
    },
    signal = {
        Easy   = {tolerance = 8, time_limit = 35, drift_speed = 0},
        Medium = {tolerance = 5, time_limit = 25, drift_speed = 6},
        Hard   = {tolerance = 3, time_limit = 18, drift_speed = 12},
    },
    pipe = {
        Easy   = {grid_size = 3, locked_count = 1, time_limit = 40},
        Medium = {grid_size = 4, locked_count = 2, time_limit = 30},
        Hard   = {grid_size = 5, locked_count = 3, time_limit = 22},
    },
    steady = {
        Easy   = {drift_force = 40, zone_width = 0.30, hold_duration = 3, time_limit = 30},
        Medium = {drift_force = 70, zone_width = 0.20, hold_duration = 4, time_limit = 25},
        Hard   = {drift_force = 110, zone_width = 0.12, hold_duration = 5, time_limit = 20},
    },
    rhythm = {
        Easy   = {note_count = 10, note_speed = 220, hit_window = 0.14, max_misses = 4},
        Medium = {note_count = 14, note_speed = 300, hit_window = 0.10, max_misses = 3},
        Hard   = {note_count = 18, note_speed = 400, hit_window = 0.07, max_misses = 2},
    },
    recall = {
        Easy   = {card_count = 4, show_time = 0.8, grid_cols = 4},
        Medium = {card_count = 6, show_time = 0.6, grid_cols = 4},
        Hard   = {card_count = 8, show_time = 0.45, grid_cols = 4},
    }
}

env.minigame_reward_multiplier = {Easy = 0.7, Medium = 1.0, Hard = 1.5}

local DIFFICULTY_ORDER = {"Easy", "Medium", "Hard"}
local DIFFICULTY_COLOR = {
    Easy = Color3.fromRGB(60, 180, 100),
    Medium = Color3.fromRGB(220, 160, 30),
    Hard = Color3.fromRGB(200, 70, 70),
}

local function fetchPreset(gameKey)
    local selectedDiff = env.minigame_difficulty[gameKey] or "Medium"
    local config = env.minigame_difficulty_presets[gameKey]
    return config[selectedDiff] or config.Medium, selectedDiff
end

-- [[ Minigame: Memory Grid ]] --
env.Memory_Mini_Game_GUI = function()
    local preset = fetchPreset("memory")
    local GRID_SIZE = 5
    local TILE_COUNT = GRID_SIZE * GRID_SIZE
    local SHOW_TIME = preset.show_time
    local MAX_MISTAKES = preset.max_mistakes

    local COLOR_GREEN = Color3.fromRGB(0, 255, 120)
    local COLOR_BLUE = Color3.fromRGB(30, 70, 120)
    local COLOR_DARK = Color3.fromRGB(20, 20, 20)
    local COLOR_WHITE = Color3.fromRGB(240, 240, 240)
    local COLOR_RED = Color3.fromRGB(180, 40, 40)

    if env.memory_cooldown and tick() - env.memory_cooldown < 30 then
        local cd = math.ceil(30 - (tick() - env.memory_cooldown))
        if env.notify then env.notify("Aether", "Please wait " .. cd .. "s before retrying.", 5) end
        return
    end

    if CoreGui:FindFirstChild("AetherMemoryGUI") then CoreGui.AetherMemoryGUI:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "AetherMemoryGUI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    getgenv().Minigame_Input_Disabled = true

    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.fromScale(0.5, 0.5)
    frame.Size = UDim2.fromScale(0.85, 0.85)
    frame.BackgroundColor3 = COLOR_DARK
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 18)

    local aspect = Instance.new("UIAspectRatioConstraint")
    aspect.AspectRatio = 1
    aspect.Parent = frame

    local sizeConstraint = Instance.new("UISizeConstraint")
    sizeConstraint.MaxSize = Vector2.new(520, 520)
    sizeConstraint.Parent = frame

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0.08, 0)
    padding.PaddingBottom = UDim.new(0.04, 0)
    padding.PaddingLeft = UDim.new(0.04, 0)
    padding.PaddingRight = UDim.new(0.04, 0)
    padding.Parent = frame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromScale(0.18, 0.08)
    closeBtn.Position = UDim2.fromScale(0.99, 0.02)
    closeBtn.AnchorPoint = Vector2.new(1, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    closeBtn.Text = "Cancel"
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextColor3 = COLOR_WHITE
    closeBtn.Parent = frame
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 12)

    local gridFrame = Instance.new("Frame")
    gridFrame.BackgroundTransparency = 1
    gridFrame.Size = UDim2.fromScale(1, 0.88)
    gridFrame.Position = UDim2.fromScale(0, 0.12)
    gridFrame.Parent = frame

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellPadding = UDim2.fromScale(0.03, 0.03)
    gridLayout.CellSize = UDim2.fromScale(1 / GRID_SIZE - 0.03, 1 / GRID_SIZE - 0.03)
    gridLayout.Parent = gridFrame

    local tiles, pattern, found = {}, {}, {}
    local mistakes = 0
    local isLocked = true

    local function destroyGUI()
        getgenv().Minigame_Input_Disabled = false
        if gui then gui:Destroy() end
    end

    closeBtn.MouseButton1Click:Connect(function()
        if env.notify then env.notify("Aether", "Minigame cancelled.", 3) end
        destroyGUI()
    end)

    for i = 1, TILE_COUNT do
        local btn = Instance.new("TextButton")
        btn.Text = ""
        btn.BackgroundColor3 = COLOR_BLUE
        btn.AutoButtonColor = false
        btn.Parent = gridFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        tiles[i] = btn
    end

    local function generatePattern()
        local amount = math.random(preset.pattern_min, preset.pattern_max)
        local picked = {}
        while #pattern < amount do
            local idx = math.random(1, TILE_COUNT)
            if not picked[idx] then
                picked[idx] = true
                TableInsert(pattern, idx)
            end
        end
    end

    local function verifyWin()
        for _, idx in ipairs(pattern) do
            if not found[idx] then return end
        end
        task.delay(0.02, function()
            env.memory_cooldown = tick()
            if env.notify then env.notify("Success", "Memory puzzle cleared!", 5) end
            destroyGUI()
        end)
    end

    local function displayPattern()
        for _, idx in ipairs(pattern) do tiles[idx].BackgroundColor3 = COLOR_GREEN end
    end

    local function hidePattern()
        for i, btn in ipairs(tiles) do
            if not found[i] then btn.BackgroundColor3 = COLOR_BLUE end
        end
        isLocked = false
    end

    local function triggerFail()
        if env.notify then env.notify("Failed", "You failed the memory puzzle.", 5) end
        destroyGUI()
    end

    local function handleTileClick(index)
        if isLocked or found[index] then return end

        if table.find(pattern, index) then
            found[index] = true
            tiles[index].BackgroundColor3 = COLOR_GREEN
            verifyWin()
        else
            mistakes = mistakes + 1
            tiles[index].BackgroundColor3 = COLOR_RED
            if mistakes >= MAX_MISTAKES then triggerFail() end
        end
    end

    for i, btn in ipairs(tiles) do
        btn.MouseButton1Click:Connect(function() handleTileClick(i) end)
    end

    generatePattern()
    displayPattern()
    task.delay(SHOW_TIME, hidePattern)
end

-- [[ Difficulty Manager GUI ]] --
env.open_difficulty_editor = function()
    if CoreGui:FindFirstChild("AetherDifficultyGUI") then
        CoreGui.AetherDifficultyGUI.Frame.Visible = true
        return
    end

    local DARK_BG = Color3.fromRGB(18, 18, 18)
    local PANEL_BG = Color3.fromRGB(26, 26, 26)
    local BORDER_CLR = Color3.fromRGB(50, 50, 50)
    local TEXT_MAIN = Color3.fromRGB(240, 240, 240)
    local TEXT_MUTED = Color3.fromRGB(140, 140, 140)

    local GAMES_LIST = {
        {key = "memory", name = "Memory Grid"},
        {key = "reaction", name = "Reaction Time"},
        {key = "keypad", name = "Keypad Hack"},
        {key = "hacking", name = "Breach Protocol"},
        {key = "safe", name = "Safe Cracker"},
        {key = "wire", name = "Wire Cutter"},
        {key = "simon", name = "Simon Says"},
        {key = "lockpick", name = "Lockpick"},
        {key = "laser", name = "Laser Grid"},
        {key = "signal", name = "Signal Triangulation"},
        {key = "pipe", name = "Pipe Reroute"},
        {key = "steady", name = "Steady Hand"},
        {key = "rhythm", name = "Rhythm Splice"},
        {key = "recall", name = "Vault Recall"},
    }

    local gui = Instance.new("ScreenGui")
    gui.Name = "AetherDifficultyGUI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Name = "Frame"
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.fromScale(0.5, 0.5)
    frame.Size = UDim2.new(0, 340, 0, 470)
    frame.BackgroundColor3 = DARK_BG
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
    Instance.new("UIStroke", frame).Color = BORDER_CLR

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 42)
    header.BackgroundColor3 = PANEL_BG
    header.BorderSizePixel = 0
    header.Parent = frame
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 14, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Aether - Difficulty Settings"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = TEXT_MAIN
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 34, 0, 24)
    close.Position = UDim2.new(1, -42, 0.5, -12)
    close.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    close.Text = "X"
    close.TextColor3 = TEXT_MUTED
    close.Font = Enum.Font.GothamBold
    close.TextSize = 13
    close.BorderSizePixel = 0
    close.Parent = header
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)
    close.MouseButton1Click:Connect(function() frame.Visible = false end)

    if dragify then dragify(frame) end

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, -92)
    scrollFrame.Position = UDim2.new(0, 0, 0, 42)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scrollFrame

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    pad.Parent = scrollFrame

    local refreshRow
    local function randomizeSingle(key)
        env.minigame_difficulty[key] = DIFFICULTY_ORDER[math.random(1, #DIFFICULTY_ORDER)]
        refreshRow(key)
    end

    local rowButtons = {}

    local function createRow(entry, orderIdx)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 62)
        card.BackgroundColor3 = PANEL_BG
        card.BorderSizePixel = 0
        card.LayoutOrder = orderIdx
        card.Parent = scrollFrame
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", card).Color = BORDER_CLR

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -20, 0, 18)
        nameLabel.Position = UDim2.new(0, 10, 0, 6)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = entry.name
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 12
        nameLabel.TextColor3 = TEXT_MAIN
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card

        local btnRow = Instance.new("Frame")
        btnRow.Size = UDim2.new(1, -20, 0, 28)
        btnRow.Position = UDim2.new(0, 10, 0, 26)
        btnRow.BackgroundTransparency = 1
        btnRow.Parent = card

        local btnLayout = Instance.new("UIListLayout")
        btnLayout.FillDirection = Enum.FillDirection.Horizontal
        btnLayout.Padding = UDim.new(0, 6)
        btnLayout.Parent = btnRow

        rowButtons[entry.key] = {}

        for _, diff in ipairs(DIFFICULTY_ORDER) do
            local diffBtn = Instance.new("TextButton")
            diffBtn.Size = UDim2.new(0, 68, 1, 0)
            diffBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
            diffBtn.Text = diff
            diffBtn.Font = Enum.Font.GothamBold
            diffBtn.TextSize = 11
            diffBtn.TextColor3 = TEXT_MUTED
            diffBtn.BorderSizePixel = 0
            diffBtn.Parent = btnRow
            Instance.new("UICorner", diffBtn).CornerRadius = UDim.new(0, 6)

            rowButtons[entry.key][diff] = diffBtn

            diffBtn.MouseButton1Click:Connect(function()
                env.minigame_difficulty[entry.key] = diff
                refreshRow(entry.key)
            end)
        end

        local dice = Instance.new("TextButton")
        dice.Size = UDim2.new(0, 28, 1, 0)
        dice.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
        dice.Text = "🎲"
        dice.TextSize = 13
        dice.BorderSizePixel = 0
        dice.Parent = btnRow
        Instance.new("UICorner", dice).CornerRadius = UDim.new(0, 6)
        dice.MouseButton1Click:Connect(function() randomizeSingle(entry.key) end)
    end

    refreshRow = function(key)
        local current = env.minigame_difficulty[key] or "Medium"
        for diffName, btn in pairs(rowButtons[key]) do
            if diffName == current then
                btn.BackgroundColor3 = DIFFICULTY_COLOR[diffName]
                btn.TextColor3 = Color3.fromRGB(20, 20, 20)
            else
                btn.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
                btn.TextColor3 = TEXT_MUTED
            end
        end
    end

    for i, item in ipairs(GAMES_LIST) do createRow(item, i) end
    for _, item in ipairs(GAMES_LIST) do refreshRow(item.key) end

    local footer = Instance.new("Frame")
    footer.Size = UDim2.new(1, 0, 0, 50)
    footer.Position = UDim2.new(0, 0, 1, -50)
    footer.BackgroundColor3 = PANEL_BG
    footer.BorderSizePixel = 0
    footer.Parent = frame

    local randAll = Instance.new("TextButton")
    randAll.Size = UDim2.new(1, -20, 0, 32)
    randAll.Position = UDim2.new(0, 10, 0, 9)
    randAll.BackgroundColor3 = Color3.fromRGB(60, 50, 90)
    randAll.Text = "🎲 Randomize All Settings"
    randAll.Font = Enum.Font.GothamBold
    randAll.TextSize = 13
    randAll.TextColor3 = TEXT_MAIN
    randAll.BorderSizePixel = 0
    randAll.Parent = footer
    Instance.new("UICorner", randAll).CornerRadius = UDim.new(0, 8)

    randAll.MouseButton1Click:Connect(function()
        for _, item in ipairs(GAMES_LIST) do randomizeSingle(item.key) end
    end)
end