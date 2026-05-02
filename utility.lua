-- Memuat UI Library Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Membuat Window Utama
local Window = Rayfield:CreateWindow({
   Name = "Aero Exploits",
   LoadingTitle = "Aero Exploits",
   LoadingSubtitle = "Menjalankan Script",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
   Theme = "Ocean",
})

-- Variabel Global & Services
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Variabel Penyimpanan Status Asli (Backup untuk Reset)
local OriginalSettings = {
     FogEnd = Lighting.FogEnd,
     FogStart = Lighting.FogStart,
     Brightness = Lighting.Brightness,
     ClockTime = Lighting.ClockTime,
     GlobalShadows = Lighting.GlobalShadows,
     Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
}

-- ==========================================
-- TAB UTILITY
-- ==========================================
local UtilityTab = Window:CreateTab("Utility", 4483362458) 

-- 1. Fly GUI
UtilityTab:CreateButton({
   Name = "Fly GUI",
   Callback = function()
       loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
       Rayfield:Notify({Title = "Fly GUI", Content = "Fly GUI Berhasil Dimuat!", Duration = 3})
   end,
})

-- 2. WalkSpeed Controls
local speed = 16
local walkSpeedLoop
UtilityTab:CreateInput({
   Name = "WalkSpeed Value",
   PlaceholderText = "16-200",
   Callback = function(Text) speed = tonumber(Text) or 16 end,
})

UtilityTab:CreateButton({
   Name = "Apply WalkSpeed",
   Callback = function()
         if walkSpeedLoop then walkSpeedLoop:Disconnect() end
         walkSpeedLoop = RunService.RenderStepped:Connect(function()
             if player.Character and player.Character:FindFirstChild("Humanoid") then
                 player.Character.Humanoid.WalkSpeed = speed
             end
         end)
         Rayfield:Notify({Title = "WalkSpeed", Content = "Speed Aktif: " .. speed, Duration = 2})
   end,
})

UtilityTab:CreateButton({
   Name = "Reset WalkSpeed",
   Callback = function()
         if walkSpeedLoop then walkSpeedLoop:Disconnect() end
         if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = 16 end
         Rayfield:Notify({Title = "WalkSpeed", Content = "Speed Reset ke 16", Duration = 2})
   end,
})

-- 3. Infinite Jump
local InfJumpEnabled = false
UtilityTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Callback = function(Value) 
        InfJumpEnabled = Value 
        Rayfield:Notify({Title = "Inf Jump", Content = Value and "Aktif" or "Nonaktif", Duration = 2})
   end,
})

UserInputService.JumpRequest:Connect(function()
    if InfJumpEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- 4. No Clip (FIXED)
local NoclipLoop
UtilityTab:CreateToggle({
   Name = "No Clip",
   CurrentValue = false,
   Callback = function(Value)
       if Value then
           NoclipLoop = RunService.Stepped:Connect(function()
               if player.Character then
                   for _, part in pairs(player.Character:GetDescendants()) do
                       if part:IsA("BasePart") then part.CanCollide = false end
                   end
               end
           end)
       else
           if NoclipLoop then NoclipLoop:Disconnect() end
           -- Kembalikan collision ke true pada bagian tubuh utama saat dimatikan
           if player.Character then
               for _, part in pairs(player.Character:GetChildren()) do
                   if part:IsA("BasePart") then 
                       part.CanCollide = true 
                   end
               end
           end
       end
       Rayfield:Notify({Title = "No Clip", Content = Value and "Aktif" or "Nonaktif", Duration = 2})
   end,
})

-- 5. Click TP
local ClickTPEnabled = false
UtilityTab:CreateToggle({
    Name = "Click TP (Ctrl + LClick)",
    CurrentValue = false,
    Callback = function(Value) 
        ClickTPEnabled = Value 
        Rayfield:Notify({Title = "Click TP", Content = Value and "Aktif (Ctrl+Klik)" or "Nonaktif", Duration = 2})
    end,
})

mouse.Button1Down:Connect(function()
    if ClickTPEnabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and mouse.Target and player.Character then
        player.Character:MoveTo(mouse.Hit.p)
    end
end)

-- 6. God Mode
local GodModeEnabled = false
UtilityTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Callback = function(Value) 
        GodModeEnabled = Value 
        Rayfield:Notify({Title = "God Mode", Content = Value and "Aktif" or "Nonaktif", Duration = 2})
    end,
})

RunService.Stepped:Connect(function()
    if GodModeEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.MaxHealth, player.Character.Humanoid.Health = math.huge, math.huge
    end
end)

-- 7. No Delay Button
local NoDelayEnabled = false
local NoDelayConnection

UtilityTab:CreateToggle({
   Name = "No Delay Button",
   CurrentValue = false,
   Callback = function(Value)
        NoDelayEnabled = Value
        
        if Value then
            -- Fungsi untuk instan delay
            local function removeDelay(v)
                if v:IsA("ProximityPrompt") then
                    v.HoldDuration = 0
                end
            end

            -- Terapkan ke yang sudah ada di Workspace
            for _, v in pairs(workspace:GetDescendants()) do
                removeDelay(v)
            end

            -- Pantau item baru yang masuk (misal item drop atau ganti map)
            NoDelayConnection = workspace.DescendantAdded:Connect(function(descendant)
                if NoDelayEnabled then
                    removeDelay(descendant)
                end
            end)

            -- Loop pengaman (Mencegah script game mereset durasi)
            task.spawn(function()
                while NoDelayEnabled do
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") and v.HoldDuration ~= 0 then
                            v.HoldDuration = 0
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            if NoDelayConnection then NoDelayConnection:Disconnect() end
        end
        Rayfield:Notify({Title = "No Delay", Content = Value and "Aktif" or "Nonaktif", Duration = 2})
   end,
})

-- 8. Anti AFK
local AntiAfkEnabled = false
UtilityTab:CreateToggle({
   Name = "Anti AFK",
   CurrentValue = false,
   Callback = function(Value) 
        AntiAfkEnabled = Value 
        Rayfield:Notify({Title = "Anti AFK", Content = Value and "Aktif" or "Nonaktif", Duration = 2})
   end,
})

player.Idled:Connect(function()
    if AntiAfkEnabled then VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end
end)

-- ==========================================
-- TAB VISUAL
-- ==========================================
local VisualTab = Window:CreateTab("Visual", 4483362458)

-- 1. FIXED PLAYER ESP
local ESPEnabled = false
local ESPMode = "Fill"
local ESPColor = Color3.fromRGB(255, 0, 0)

VisualTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Callback = function(Value)
        ESPEnabled = Value
        if not Value then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("AeroHighlight") then
                    p.Character.AeroHighlight:Destroy()
                end
            end
        end
        Rayfield:Notify({Title = "ESP", Content = Value and "Aktif" or "Nonaktif", Duration = 2})
    end,
})

VisualTab:CreateDropdown({
   Name = "ESP Mode",
   Options = {"Fill", "Outline"},
   CurrentOption = "Fill",
   Callback = function(Option) ESPMode = Option end,
})

VisualTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(Value) ESPColor = Value end
})

RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character then
                local hl = p.Character:FindFirstChild("AeroHighlight")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "AeroHighlight"
                    hl.Parent = p.Character
                end
                hl.OutlineColor = ESPColor
                hl.OutlineTransparency = 0
                if ESPMode == "Outline" then
                    hl.FillTransparency = 1
                else
                    hl.FillTransparency = 0.5
                    hl.FillColor = ESPColor
                end
            end
        end
    end
end)

-- 2. SPECTATE SYSTEM
local spectateIndex = 1
local specScreen = Instance.new("ScreenGui", game.CoreGui)
specScreen.Enabled = false

local specFrame = Instance.new("Frame", specScreen)
specFrame.Size, specFrame.Position = UDim2.new(0, 300, 0, 130), UDim2.new(0.5, -150, 0.82, 0)
specFrame.BackgroundColor3, specFrame.BorderSizePixel = Color3.fromRGB(20, 20, 25), 0
Instance.new("UICorner", specFrame)

local displayLabel = Instance.new("TextLabel", specFrame)
displayLabel.Size, displayLabel.Position = UDim2.new(1, 0, 0.35, 0), UDim2.new(0, 0, 0.05, 0)
displayLabel.BackgroundTransparency, displayLabel.TextColor3, displayLabel.TextScaled = 1, Color3.new(1,1,1), true
displayLabel.Font = Enum.Font.SourceSansBold

local userLabel = Instance.new("TextLabel", specFrame)
userLabel.Size, userLabel.Position = UDim2.new(1, 0, 0.2, 0), UDim2.new(0, 0, 0.35, 0)
userLabel.BackgroundTransparency, userLabel.TextColor3, userLabel.TextSize = 1, Color3.fromRGB(180, 180, 180), 14

local function updateSpectate()
    local players = {}
    for _, p in pairs(game.Players:GetPlayers()) do if p ~= player then table.insert(players, p) end end
    if #players > 0 then
        if spectateIndex > #players then spectateIndex = 1 end
        if spectateIndex < 1 then spectateIndex = #players end
        local target = players[spectateIndex]
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = target.Character.Humanoid
            displayLabel.Text, userLabel.Text = target.DisplayName, "@" .. target.Name
        end
    end
end

local tpBtn = Instance.new("TextButton", specFrame)
tpBtn.Size, tpBtn.Position, tpBtn.Text = UDim2.new(0.25, 0, 0.2, 0), UDim2.new(0.375, 0, 0.55, 0), "Teleport"
tpBtn.BackgroundColor3, tpBtn.TextColor3 = Color3.fromRGB(0, 150, 255), Color3.new(1,1,1)
Instance.new("UICorner", tpBtn)

tpBtn.MouseButton1Click:Connect(function()
    local targetName = userLabel.Text:sub(2)
    local target = game.Players:FindFirstChild(targetName)
    if target and target.Character and player.Character then
        player.Character:MoveTo(target.Character.PrimaryPart.Position)
        Rayfield:Notify({Title = "Spectate", Content = "Teleport ke " .. target.DisplayName, Duration = 2})
    end
end)

local stopBtn = Instance.new("TextButton", specFrame)
stopBtn.Size, stopBtn.Position, stopBtn.Text = UDim2.new(0, 60, 0, 25), UDim2.new(0.4, 0, 0.78, 0), "Stop"
stopBtn.BackgroundColor3, stopBtn.TextColor3 = Color3.fromRGB(150, 0, 0), Color3.new(1,1,1)
Instance.new("UICorner", stopBtn)

stopBtn.MouseButton1Click:Connect(function() 
    specScreen.Enabled = false 
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        Camera.CameraSubject = player.Character.Humanoid 
    end
    Rayfield:Notify({Title = "Spectate", Content = "Spectate Dimatikan", Duration = 2})
end)

local nextBtn = Instance.new("TextButton", specFrame)
nextBtn.Size, nextBtn.Position, nextBtn.Text = UDim2.new(0.3, 0, 0.25, 0), UDim2.new(0.65, 0, 0.65, 0), "Next >>"
nextBtn.BackgroundColor3, nextBtn.TextColor3 = Color3.fromRGB(40, 40, 50), Color3.new(1,1,1)
Instance.new("UICorner", nextBtn)
nextBtn.MouseButton1Click:Connect(function() spectateIndex = spectateIndex + 1; updateSpectate() end)

local backBtn = Instance.new("TextButton", specFrame)
backBtn.Size, backBtn.Position, backBtn.Text = UDim2.new(0.3, 0, 0.25, 0), UDim2.new(0.05, 0, 0.65, 0), "<< Back"
backBtn.BackgroundColor3, backBtn.TextColor3 = Color3.fromRGB(40, 40, 50), Color3.new(1,1,1)
Instance.new("UICorner", backBtn)
backBtn.MouseButton1Click:Connect(function() spectateIndex = spectateIndex - 1; updateSpectate() end)

VisualTab:CreateButton({
    Name = "Open Spectate GUI",
    Callback = function() 
        specScreen.Enabled = true 
        updateSpectate() 
        Rayfield:Notify({Title = "Spectate", Content = "Spectate GUI Dibuka", Duration = 2})
    end,
})

-- 3. NO FOG
local NoFogEnabled = false
VisualTab:CreateToggle({
   Name = "No Fog",
   Callback = function(Value)
        NoFogEnabled = Value
        if not Value then
            Lighting.FogEnd = OriginalSettings.FogEnd
            Lighting.FogStart = OriginalSettings.FogStart
            if OriginalSettings.Atmosphere then OriginalSettings.Atmosphere.Parent = Lighting end
        end
        Rayfield:Notify({Title = "No Fog", Content = Value and "Aktif" or "Reset ke Default", Duration = 2})
   end,
})

-- 4. FULL BRIGHT
local FullBrightEnabled = false
VisualTab:CreateToggle({
   Name = "Full Bright",
   Callback = function(Value) 
        FullBrightEnabled = Value 
        if not Value then
            Lighting.Brightness = OriginalSettings.Brightness
            Lighting.ClockTime = OriginalSettings.ClockTime
            Lighting.GlobalShadows = OriginalSettings.GlobalShadows
        end
        Rayfield:Notify({Title = "Full Bright", Content = Value and "Aktif" or "Reset ke Default", Duration = 2})
   end,
})

-- LOOP UNTUK VISUAL
RunService.RenderStepped:Connect(function()
    if NoFogEnabled then
        Lighting.FogEnd = 1000000
        Lighting.FogStart = 0
        local atm = Lighting:FindFirstChildOfClass("Atmosphere")
        if atm then atm.Parent = nil end 
    end
    if FullBrightEnabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
    end
end)

Rayfield:Notify({Title = "Aero Exploits", Content = "Script Berhasil Dimuat!", Duration = 3})
