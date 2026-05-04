-- Aero Exploits - Rayfield Edition
-- Developer: AeroXyraa

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Aero Exploits",
   LoadingTitle = "Aero Exploits",
   LoadingSubtitle = "By AeroXyraa",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
   Theme = "Ocean",
})

-- ==========================================
-- SERVICES & VARIABLES
-- ==========================================
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

_G.InfJumpEnabled = false
_G.ClickTP = false
_G.NoDelay = false
_G.AntiAfkEnabled = false

local selectedPlayerName = ""
local currentTargetFOV = 70
local zoomFOV = 20

-- Backup Lighting
local OriginalSettings = {
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows
}

-- ==========================================
-- CUSTOM AVATAR PREVIEW UI (DRAG, MIN, CLOSE)
-- ==========================================
local PreviewGui = Instance.new("ScreenGui")
local PreviewFrame = Instance.new("Frame")
local PreviewImage = Instance.new("ImageLabel")
local PreviewLabel = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local MinBtn = Instance.new("TextButton")
local TitleBar = Instance.new("Frame")

PreviewGui.Name = "AeroPreview"
PreviewGui.Parent = game:GetService("CoreGui")
PreviewGui.ResetOnSpawn = false

PreviewFrame.Name = "MainFrame"
PreviewFrame.Parent = PreviewGui
PreviewFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
PreviewFrame.Position = UDim2.new(0.5, 180, 0.5, -100)
PreviewFrame.Size = UDim2.new(0, 150, 0, 180)
PreviewFrame.Visible = false
PreviewFrame.ClipsDescendants = true
Instance.new("UICorner", PreviewFrame)
Instance.new("UIStroke", PreviewFrame).Color = Color3.fromRGB(0, 120, 215)

TitleBar.Name = "TitleBar"
TitleBar.Parent = PreviewFrame
TitleBar.Size = UDim2.new(1, 0, 0, 25)
TitleBar.BackgroundTransparency = 1

CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = TitleBar
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -22, 0, 2)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold

MinBtn.Name = "MinBtn"
MinBtn.Parent = TitleBar
MinBtn.Size = UDim2.new(0, 20, 0, 20)
MinBtn.Position = UDim2.new(1, -42, 0, 2)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.BackgroundTransparency = 1
MinBtn.Font = Enum.Font.GothamBold

PreviewImage.Parent = PreviewFrame
PreviewImage.BackgroundTransparency = 1
PreviewImage.Position = UDim2.new(0, 10, 0, 30)
PreviewImage.Size = UDim2.new(0, 130, 0, 130)
Instance.new("UICorner", PreviewImage)

PreviewLabel.Parent = PreviewFrame
PreviewLabel.BackgroundTransparency = 1
PreviewLabel.Position = UDim2.new(0, 0, 0.85, 0)
PreviewLabel.Size = UDim2.new(1, 0, 0.1, 0)
PreviewLabel.Font = Enum.Font.GothamBold
PreviewLabel.TextColor3 = Color3.new(1, 1, 1)
PreviewLabel.TextSize = 12

-- Dragging Logic
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = PreviewFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        PreviewFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

CloseBtn.MouseButton1Click:Connect(function() PreviewFrame.Visible = false end)
local previewMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    previewMinimized = not previewMinimized
    PreviewFrame:TweenSize(previewMinimized and UDim2.new(0, 150, 0, 25) or UDim2.new(0, 150, 0, 180), "Out", "Quad", 0.3, true)
end)

local function updateAvatar(userId, displayName)
    local content = game.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size150x150)
    PreviewImage.Image = content
    PreviewLabel.Text = displayName
    PreviewFrame.Visible = true
end

-- ==========================================
-- SPECTATE INTERNAL SYSTEM
-- ==========================================
local spectateIndex = 1
local specScreen = Instance.new("ScreenGui", game.CoreGui)
specScreen.Enabled = false

local specFrame = Instance.new("Frame", specScreen)
specFrame.Size, specFrame.Position = UDim2.new(0, 300, 0, 130), UDim2.new(0.5, -150, 0.82, 0)
specFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UICorner", specFrame)

local displayLabel = Instance.new("TextLabel", specFrame)
displayLabel.Size, displayLabel.Position = UDim2.new(1, 0, 0.35, 0), UDim2.new(0, 0, 0.05, 0)
displayLabel.BackgroundTransparency, displayLabel.TextColor3, displayLabel.TextScaled = 1, Color3.new(1,1,1), true
displayLabel.Font = Enum.Font.GothamBold

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

local specTpBtn = Instance.new("TextButton", specFrame)
specTpBtn.Size, specTpBtn.Position, specTpBtn.Text = UDim2.new(0.25, 0, 0.2, 0), UDim2.new(0.375, 0, 0.55, 0), "Teleport"
specTpBtn.BackgroundColor3, specTpBtn.TextColor3 = Color3.fromRGB(0, 150, 255), Color3.new(1,1,1)
Instance.new("UICorner", specTpBtn)
specTpBtn.MouseButton1Click:Connect(function()
    local targetName = userLabel.Text:sub(2)
    local target = game.Players:FindFirstChild(targetName)
    if target and target.Character and player.Character then
        player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        Rayfield:Notify({ Title = "Spectate", Content = "✓ Teleport ke " .. target.DisplayName .. " berhasil!", Duration = 2 })
    else
        Rayfield:Notify({ Title = "Spectate", Content = "✗ Gagal teleport ke target!", Duration = 2 })
    end
end)

local stopBtn = Instance.new("TextButton", specFrame)
stopBtn.Size, stopBtn.Position, stopBtn.Text = UDim2.new(0, 60, 0, 25), UDim2.new(0.4, 0, 0.78, 0), "Stop"
stopBtn.BackgroundColor3, stopBtn.TextColor3 = Color3.fromRGB(150, 0, 0), Color3.new(1,1,1)
Instance.new("UICorner", stopBtn)
stopBtn.MouseButton1Click:Connect(function()
    specScreen.Enabled = false
    if player.Character then Camera.CameraSubject = player.Character.Humanoid end
    Rayfield:Notify({ Title = "Spectate", Content = "⛔ Spectate dihentikan!", Duration = 2 })
end)

local nextBtn = Instance.new("TextButton", specFrame)
nextBtn.Size, nextBtn.Position, nextBtn.Text = UDim2.new(0.3, 0, 0.25, 0), UDim2.new(0.65, 0, 0.65, 0), "Next >>"
nextBtn.BackgroundColor3, nextBtn.TextColor3 = Color3.fromRGB(40, 40, 50), Color3.new(1,1,1)
Instance.new("UICorner", nextBtn)
nextBtn.MouseButton1Click:Connect(function()
    spectateIndex = spectateIndex + 1
    updateSpectate()
    Rayfield:Notify({ Title = "Spectate", Content = "▶ Spectate: " .. displayLabel.Text, Duration = 1 })
end)

local backBtn = Instance.new("TextButton", specFrame)
backBtn.Size, backBtn.Position, backBtn.Text = UDim2.new(0.3, 0, 0.25, 0), UDim2.new(0.05, 0, 0.65, 0), "<< Back"
backBtn.BackgroundColor3, backBtn.TextColor3 = Color3.fromRGB(40, 40, 50), Color3.new(1,1,1)
Instance.new("UICorner", backBtn)
backBtn.MouseButton1Click:Connect(function()
    spectateIndex = spectateIndex - 1
    updateSpectate()
    Rayfield:Notify({ Title = "Spectate", Content = "◀ Spectate: " .. displayLabel.Text, Duration = 1 })
end)

-- ==========================================
-- TAB UTILITY
-- ==========================================
local UtilityTab = Window:CreateTab("⚒  Utility")
UtilityTab:CreateSection("Main  🛡")

UtilityTab:CreateButton({
   Name = "Fly GUI",
   Callback = function()
       Rayfield:Notify({ Title = "Fly GUI", Content = "⏳ Memuat Fly GUI...", Duration = 2 })
       loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
       Rayfield:Notify({ Title = "Fly GUI", Content = "✓ Fly GUI berhasil dimuat!", Duration = 3 })
   end,
})

local speed = 16
local walkSpeedLoop
UtilityTab:CreateInput({
   Name = "WalkSpeed Value",
   PlaceholderText = "16",
   Callback = function(Text)
       speed = tonumber(Text) or 16
       Rayfield:Notify({ Title = "WalkSpeed", Content = "✓ WalkSpeed diatur ke: " .. speed, Duration = 2 })
   end,
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
       Rayfield:Notify({ Title = "WalkSpeed", Content = "✓ WalkSpeed " .. speed .. " diaktifkan!", Duration = 2 })
   end,
})

UtilityTab:CreateButton({
   Name = "Reset WalkSpeed",
   Callback = function()
       if walkSpeedLoop then walkSpeedLoop:Disconnect() end
       if player.Character then player.Character.Humanoid.WalkSpeed = 16 end
       Rayfield:Notify({ Title = "WalkSpeed", Content = "🔄 WalkSpeed direset ke 16!", Duration = 2 })
   end,
})

UtilityTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Callback = function(Value)
       _G.InfJumpEnabled = Value
       if Value then
           Rayfield:Notify({ Title = "Infinite Jump", Content = "✓ Infinite Jump diaktifkan!", Duration = 2 })
       else
           Rayfield:Notify({ Title = "Infinite Jump", Content = "⛔ Infinite Jump dinonaktifkan!", Duration = 2 })
       end
   end,
})

local NoclipLoop
UtilityTab:CreateToggle({
   Name = "No Clip",
   CurrentValue = false,
   Callback = function(Value)
       if Value then
           NoclipLoop = RunService.Stepped:Connect(function()
               if player.Character then
                   for _, v in pairs(player.Character:GetDescendants()) do
                       if v:IsA("BasePart") then v.CanCollide = false end
                   end
               end
           end)
           Rayfield:Notify({ Title = "No Clip", Content = "✓ No Clip diaktifkan! Kamu bisa menembus objek.", Duration = 3 })
       else
           if NoclipLoop then NoclipLoop:Disconnect() end
           Rayfield:Notify({ Title = "No Clip", Content = "⛔ No Clip dinonaktifkan!", Duration = 2 })
       end
   end,
})

UtilityTab:CreateSection("Teleport  🧲")

local function getFormattedPlayerList()
    local tbl = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player then table.insert(tbl, p.DisplayName .. " (@" .. p.Name .. ")") end
    end
    return tbl
end

local PlayerDropdown
UtilityTab:CreateInput({
   Name = "Search Player",
   PlaceholderText = "Username...",
   Callback = function(Text)
       local matches = {}
       for _, p in pairs(game.Players:GetPlayers()) do
           if p ~= player and (string.find(p.Name:lower(), Text:lower()) or string.find(p.DisplayName:lower(), Text:lower())) then
               table.insert(matches, p.DisplayName .. " (@" .. p.Name .. ")")
           end
       end
       PlayerDropdown:Refresh(matches, true)
       Rayfield:Notify({ Title = "Teleport", Content = "🔍 Hasil pencarian diperbarui: " .. #matches .. " player ditemukan", Duration = 2 })
   end,
})

PlayerDropdown = UtilityTab:CreateDropdown({
   Name = "Select Player",
   Options = getFormattedPlayerList(),
   CurrentOption = "",
   Callback = function(Option)
       if type(Option) == "table" then Option = Option[1] end
       local username = string.match(Option, "@([%w_%.]+)")
       if username then
           selectedPlayerName = username
           local target = game.Players:FindFirstChild(username)
           if target then
               updateAvatar(target.UserId, target.DisplayName)
               Rayfield:Notify({ Title = "Teleport", Content = "👤 Player dipilih: " .. target.DisplayName .. " (@" .. username .. ")", Duration = 2 })
           end
       end
   end,
})

UtilityTab:CreateButton({
    Name = "Teleport Now",
    Callback = function()
        local target = game.Players:FindFirstChild(selectedPlayerName)
        if target and target.Character then
            player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
            Rayfield:Notify({ Title = "Teleport", Content = "✓ Teleport ke " .. target.DisplayName .. " berhasil!", Duration = 2 })
        else
            Rayfield:Notify({ Title = "Teleport", Content = "✗ Gagal! Pilih player terlebih dahulu.", Duration = 3 })
        end
    end
})

UtilityTab:CreateToggle({
    Name = "Click TP (Ctrl + Click)",
    CurrentValue = false,
    Callback = function(V)
        _G.ClickTP = V
        if V then
            Rayfield:Notify({ Title = "Click TP", Content = "✓ Click TP aktif! Tahan Ctrl + Klik untuk teleport.", Duration = 3 })
        else
            Rayfield:Notify({ Title = "Click TP", Content = "⛔ Click TP dinonaktifkan!", Duration = 2 })
        end
    end
})

UtilityTab:CreateSection("Other  ⚙️")

-- ==========================================
-- NO DELAY BUTTON (FIXED)
-- ==========================================
local noDelayDescConn

UtilityTab:CreateToggle({
   Name = "No Delay Button",
   CurrentValue = false,
   Callback = function(Value)
        _G.NoDelay = Value
        if Value then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    v.HoldDuration = 0
                end
            end
            noDelayDescConn = workspace.DescendantAdded:Connect(function(desc)
                if desc:IsA("ProximityPrompt") then
                    desc.HoldDuration = 0
                end
            end)
            Rayfield:Notify({ Title = "No Delay", Content = "✓ No Delay aktif! Semua ProximityPrompt instan.", Duration = 3 })
        else
            if noDelayDescConn then
                noDelayDescConn:Disconnect()
                noDelayDescConn = nil
            end
            Rayfield:Notify({ Title = "No Delay", Content = "⛔ No Delay dinonaktifkan!", Duration = 2 })
        end
   end,
})

UtilityTab:CreateToggle({
   Name = "Anti AFK",
   CurrentValue = false,
   Callback = function(V)
       _G.AntiAfkEnabled = V
       if V then
           Rayfield:Notify({ Title = "Anti AFK", Content = "✓ Anti AFK diaktifkan! Kamu tidak akan di-kick.", Duration = 3 })
       else
           Rayfield:Notify({ Title = "Anti AFK", Content = "⛔ Anti AFK dinonaktifkan!", Duration = 2 })
       end
   end
})

-- ==========================================
-- TAB VISUAL
-- ==========================================
local VisualTab = Window:CreateTab("👀  Visual")
VisualTab:CreateSection("ESP  👁️️")

local ESPEnabled = false
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
            Rayfield:Notify({ Title = "Player ESP", Content = "⛔ ESP dinonaktifkan!", Duration = 2 })
        else
            Rayfield:Notify({ Title = "Player ESP", Content = "✓ ESP diaktifkan! Semua player terlihat.", Duration = 2 })
        end
    end,
})

VisualTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(V)
        ESPColor = V
        Rayfield:Notify({ Title = "ESP Color", Content = "🎨 Warna ESP berhasil diubah!", Duration = 2 })
    end
})

VisualTab:CreateSection("Spectate  🎥")
VisualTab:CreateButton({
    Name = "Open Spectate GUI",
    Callback = function()
        specScreen.Enabled = true
        updateSpectate()
        Rayfield:Notify({ Title = "Spectate", Content = "✓ Spectate GUI dibuka! Gunakan Next/Back untuk berpindah.", Duration = 3 })
    end,
})

VisualTab:CreateSection("Environment  ☁️")

local FOVSlider = VisualTab:CreateSlider({
   Name = "FOV Changer (Max 500)",
   Range = {30, 500},
   Increment = 1,
   Suffix = "FOV",
   CurrentValue = 70,
   Callback = function(Value)
      currentTargetFOV = Value
      Rayfield:Notify({ Title = "FOV Changer", Content = "🔭 FOV diatur ke: " .. Value, Duration = 1 })
   end,
})

VisualTab:CreateButton({
   Name = "Reset FOV",
   Callback = function()
      currentTargetFOV = 70
      FOVSlider:Set(70)
      Rayfield:Notify({ Title = "FOV Changer", Content = "🔄 FOV direset ke 70 (default)!", Duration = 2 })
   end,
})

-- ==========================================
-- NO FOG (FIXED)
-- ==========================================
local NoFogEnabled = false
local atmosphereBackup = {}

VisualTab:CreateToggle({
   Name = "No Fog",
   CurrentValue = false,
   Callback = function(Value)
        NoFogEnabled = Value
        if Value then
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("Atmosphere") then
                    atmosphereBackup[v] = {
                        Density = v.Density,
                        Haze = v.Haze,
                        Glare = v.Glare
                    }
                    v.Density = 0
                    v.Haze = 0
                    v.Glare = 0
                end
            end
            Lighting.FogEnd = 1e9
            Lighting.FogStart = 1e9
            Rayfield:Notify({ Title = "No Fog", Content = "✓ No Fog diaktifkan! Kabut dihilangkan.", Duration = 2 })
        else
            for atmo, data in pairs(atmosphereBackup) do
                if atmo and atmo.Parent then
                    atmo.Density = data.Density
                    atmo.Haze = data.Haze
                    atmo.Glare = data.Glare
                end
            end
            atmosphereBackup = {}
            Lighting.FogEnd = OriginalSettings.FogEnd
            Lighting.FogStart = OriginalSettings.FogStart
            Rayfield:Notify({ Title = "No Fog", Content = "⛔ No Fog dinonaktifkan! Kabut dikembalikan.", Duration = 2 })
        end
   end,
})

local FullBrightEnabled = false
VisualTab:CreateToggle({
   Name = "Full Bright",
   CurrentValue = false,
   Callback = function(Value)
        FullBrightEnabled = Value
        if not Value then
            Lighting.Brightness = OriginalSettings.Brightness
            Lighting.ClockTime = OriginalSettings.ClockTime
            Lighting.GlobalShadows = OriginalSettings.GlobalShadows
            Rayfield:Notify({ Title = "Full Bright", Content = "⛔ Full Bright dinonaktifkan! Pencahayaan dikembalikan.", Duration = 2 })
        else
            Rayfield:Notify({ Title = "Full Bright", Content = "✓ Full Bright diaktifkan! Peta jadi terang benderang.", Duration = 2 })
        end
   end,
})

VisualTab:CreateSection("Camera Control  📷")

local guiStates = {}
local isGuiHidden = false
VisualTab:CreateButton({
   Name = "Hide GUI | All Game",
   Callback = function()
      isGuiHidden = not isGuiHidden
      local playerGui = player:WaitForChild("PlayerGui")
      if isGuiHidden then
          for _, v in pairs(playerGui:GetChildren()) do
              if v:IsA("ScreenGui") and v.Name ~= "RayfieldGui" and v.Name ~= "AeroPreview" then
                  guiStates[v] = v.Enabled; v.Enabled = false
              end
          end
          Rayfield:Notify({ Title = "Hide GUI", Content = "🙈 Semua GUI game disembunyikan!", Duration = 2 })
      else
          for gui, originalState in pairs(guiStates) do
              if gui and gui.Parent then gui.Enabled = originalState end
          end
          guiStates = {}
          Rayfield:Notify({ Title = "Hide GUI", Content = "👁️ Semua GUI game ditampilkan kembali!", Duration = 2 })
      end
   end,
})

-- ==========================================
-- TAB FUN - AVATAR COPY
-- ==========================================
local FunTab = Window:CreateTab("👥  Copy Avatar")

local lastCopiedUsername = nil

local function applyAvatarFun(username, notifTitle)
    task.spawn(function()
        Rayfield:Notify({ Title = notifTitle or "Avatar Copy", Content = "⏳ Mencari karakter...", Duration = 2 })

        local char = player.Character or player.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid", 10)
        if not hum then
            Rayfield:Notify({ Title = "Avatar Copy", Content = "✗ Humanoid tidak ditemukan!", Duration = 3 })
            return
        end

        local targetPlayer = nil
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p.Name:lower() == username:lower() or p.DisplayName:lower() == username:lower() then
                targetPlayer = p
                break
            end
        end

        local desc
        if targetPlayer and targetPlayer.Character then
            local tHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            if tHum then
                desc = tHum:GetAppliedDescription()
                Rayfield:Notify({ Title = "Avatar Copy", Content = "✓ Deskripsi diambil dari game", Duration = 2 })
            end
        end

        if not desc then
            Rayfield:Notify({ Title = "Avatar Copy", Content = "🌐 Mengambil dari server Roblox...", Duration = 2 })
            local ok, userId = pcall(game.Players.GetUserIdFromNameAsync, game.Players, username)
            if not ok or not userId then
                Rayfield:Notify({ Title = "Avatar Copy", Content = "✗ User tidak ditemukan: " .. username, Duration = 4 })
                return
            end
            local ok2, d = pcall(game.Players.GetHumanoidDescriptionFromUserId, game.Players, userId)
            if not ok2 or not d then
                Rayfield:Notify({ Title = "Avatar Copy", Content = "✗ Gagal ambil deskripsi avatar", Duration = 4 })
                return
            end
            desc = d
        end

        for _, c in ipairs(char:GetChildren()) do
            if c:IsA("Accessory") or c:IsA("Hat") or
               c:IsA("BodyColors") or c:IsA("CharacterMesh") or
               c:IsA("Shirt") or c:IsA("Pants") or
               c:IsA("ShirtGraphic") then
                c:Destroy()
            end
        end

        pcall(function()
            if hum.ApplyDescriptionClientServer then
                hum:ApplyDescriptionClientServer(desc)
            else
                hum:ApplyDescription(desc)
            end
        end)

        local bc = char:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors")
        bc.Parent         = char
        bc.HeadColor3     = desc.HeadColor
        bc.TorsoColor3    = desc.TorsoColor
        bc.LeftArmColor3  = desc.LeftArmColor
        bc.RightArmColor3 = desc.RightArmColor
        bc.LeftLegColor3  = desc.LeftLegColor
        bc.RightLegColor3 = desc.RightLegColor

        lastCopiedUsername = username
        Rayfield:Notify({ Title = "Avatar Copy", Content = "✓ Avatar berhasil diterapkan! → " .. username, Duration = 3 })
    end)
end

FunTab:CreateSection("Avatar Global  🌐")

local manualUsernameInput = ""
FunTab:CreateInput({
    Name = "Username Player",
    PlaceholderText = "Ketik username Roblox...",
    Callback = function(Text)
        manualUsernameInput = Text:match("^%s*(.-)%s*$") or ""
        if manualUsernameInput ~= "" then
            Rayfield:Notify({ Title = "Avatar Copy", Content = "✏️ Username diset: " .. manualUsernameInput, Duration = 2 })
        end
    end,
})

FunTab:CreateButton({
    Name = "Copy Avatar",
    Callback = function()
        if manualUsernameInput == "" then
            Rayfield:Notify({ Title = "Avatar Copy", Content = "✗ Username tidak boleh kosong!", Duration = 3 })
            return
        end
        applyAvatarFun(manualUsernameInput, "Copy Avatar Manual")
    end,
})

FunTab:CreateSection("Avatar Server  🧭")

local function getServerPlayerList()
    local list = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        table.insert(list, p.DisplayName .. " (@" .. p.Name .. ")")
    end
    return list
end

local selectedFunPlayer = ""
local FunPlayerDropdown

FunTab:CreateInput({
    Name = "Cari Player di Server",
    PlaceholderText = "Nama / username...",
    Callback = function(Text)
        local matches = {}
        for _, p in ipairs(game.Players:GetPlayers()) do
            if string.find(p.Name:lower(), Text:lower()) or string.find(p.DisplayName:lower(), Text:lower()) then
                table.insert(matches, p.DisplayName .. " (@" .. p.Name .. ")")
            end
        end
        FunPlayerDropdown:Refresh(matches, true)
        Rayfield:Notify({ Title = "Avatar Copy", Content = "🔍 " .. #matches .. " player ditemukan di server!", Duration = 2 })
    end,
})

FunPlayerDropdown = FunTab:CreateDropdown({
    Name = "Pilih Player di Server",
    Options = getServerPlayerList(),
    CurrentOption = "",
    Callback = function(Option)
        if type(Option) == "table" then Option = Option[1] end
        local username = string.match(Option, "@([%w_%.]+)")
        if username then
            selectedFunPlayer = username
            local target = game.Players:FindFirstChild(username)
            if target then
                Rayfield:Notify({ Title = "Avatar Copy", Content = "👤 Player dipilih: " .. target.DisplayName .. " (@" .. username .. ")", Duration = 2 })
            end
        end
    end,
})

FunTab:CreateButton({
    Name = "🔄  Refresh Daftar Player",
    Callback = function()
        FunPlayerDropdown:Refresh(getServerPlayerList(), true)
        Rayfield:Notify({ Title = "Avatar Copy", Content = "✓ Daftar player diperbarui!", Duration = 2 })
    end,
})

FunTab:CreateButton({
    Name = "Copy Avatar",
    Callback = function()
        if selectedFunPlayer == "" then
            Rayfield:Notify({ Title = "Avatar Copy", Content = "✗ Pilih player terlebih dahulu!", Duration = 3 })
            return
        end
        applyAvatarFun(selectedFunPlayer, "Copy Avatar Server")
    end,
})

FunTab:CreateSection("Reset Avatar  🔁")

FunTab:CreateButton({
    Name = "Reset ke Avatar Asli",
    Callback = function()
        lastCopiedUsername = nil
        Rayfield:Notify({ Title = "Avatar Copy", Content = "🔄 Mereset karakter ke avatar asli...", Duration = 2 })
        task.spawn(function()
            local ok, desc = pcall(game.Players.GetHumanoidDescriptionFromUserId, game.Players, player.UserId)
            if not ok or not desc then
                player:LoadCharacter()
                task.wait(1.5)
                Rayfield:Notify({ Title = "Avatar Copy", Content = "✓ Karakter direset (respawn)!", Duration = 3 })
                return
            end

            local char = player.Character or player.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid", 10)
            if not hum then player:LoadCharacter(); return end

            for _, c in ipairs(char:GetChildren()) do
                if c:IsA("Accessory") or c:IsA("Hat") or
                   c:IsA("BodyColors") or c:IsA("CharacterMesh") or
                   c:IsA("Shirt") or c:IsA("Pants") or
                   c:IsA("ShirtGraphic") then
                    c:Destroy()
                end
            end

            pcall(function()
                if hum.ApplyDescriptionClientServer then
                    hum:ApplyDescriptionClientServer(desc)
                else
                    hum:ApplyDescription(desc)
                end
            end)

            local bc = char:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors")
            bc.Parent         = char
            bc.HeadColor3     = desc.HeadColor
            bc.TorsoColor3    = desc.TorsoColor
            bc.LeftArmColor3  = desc.LeftArmColor
            bc.RightArmColor3 = desc.RightArmColor
            bc.LeftLegColor3  = desc.LeftLegColor
            bc.RightLegColor3 = desc.RightLegColor

            Rayfield:Notify({ Title = "Avatar Copy", Content = "✓ Avatar asli berhasil dikembalikan!", Duration = 3 })
        end)
    end,
})

player.CharacterAdded:Connect(function(char)
    if lastCopiedUsername then
        char:WaitForChild("Humanoid", 10)
        task.wait(0.65)
        applyAvatarFun(lastCopiedUsername, "Auto Re-Apply")
    end
end)

-- ==========================================
-- LOOPS & FINAL LOGIC
-- ==========================================
RunService.RenderStepped:Connect(function()
    -- ESP Logic
    if ESPEnabled then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character then
                local hl = p.Character:FindFirstChild("AeroHighlight") or Instance.new("Highlight", p.Character)
                hl.Name = "AeroHighlight"
                hl.FillColor = ESPColor
                hl.FillTransparency = 0.5
            end
        end
    end

    -- FOV Logic
    if _G.ClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        Camera.FieldOfView = math.lerp(Camera.FieldOfView, zoomFOV, 0.1)
    else
        Camera.FieldOfView = math.lerp(Camera.FieldOfView, currentTargetFOV, 0.1)
    end

    -- No Fog Logic (terus di-enforce agar tidak di-override game)
    if NoFogEnabled then
        Lighting.FogEnd = 1e9
        Lighting.FogStart = 1e9
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") then
                v.Density = 0
                v.Haze = 0
            end
        end
    end

    -- Full Bright Logic
    if FullBrightEnabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
    end
end)

UserInputService.JumpRequest:Connect(function()
    if _G.InfJumpEnabled and player.Character then
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

mouse.Button1Down:Connect(function()
    if _G.ClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0, 3, 0))
        Rayfield:Notify({ Title = "Click TP", Content = "✓ Teleport ke posisi kursor!", Duration = 1 })
    end
end)

player.Idled:Connect(function()
    if _G.AntiAfkEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        Rayfield:Notify({ Title = "Anti AFK", Content = "🔄 Anti AFK aktif! Input dikirim otomatis.", Duration = 2 })
    end
end)

Rayfield:Notify({Title = "Aero Exploits", Content = "Script Ready!", Duration = 3})
