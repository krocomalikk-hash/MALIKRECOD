-- =====================================================
-- SCRIPT AUTO SUMMIT + RECORDER (PASTI MUNCUL)
-- =====================================================

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Key System
local Window = Rayfield:CreateWindow({
   Name = "🔥 AUTO SUMMIT VIP",
   LoadingTitle = "Smooth Teleport",
   LoadingSubtitle = "Anti Geter",
   ConfigurationSaving = { Enabled = false },
   KeySystem = true,
   KeySettings = {
      Title = "VIP RECODMALIK",
      Subtitle = "Masukkan Key Premium",
      Note = "silahkan minta key ke onwer",
      FileName = "RecodeMalik_Key",
      SaveKey = true,
      Key = {"VIP2024", "MALIKVIP"}
   }
})

-- Variables
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local TeleportSpeed = 0.3
local SmoothTeleport = true
local InvisibleEnabled = false
local AntiAFKEnabled = true
local LoopEnabled = {}
local FinalMounts = {}
local FileName = "Mountains.json"
local TempRecording = {}
local SavedParts = {}

-- =====================================================
-- SMOOTH TELEPORT
-- =====================================================
local function TeleportSmooth(targetCF)
    local character = LocalPlayer.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not root or not humanoid then return end
    
    root.Anchored = true
    humanoid.PlatformStand = true
    root.CFrame = targetCF
    task.wait(0.03)
    root.Anchored = false
    humanoid.PlatformStand = false
end

local function TeleportCepat(targetCF)
    local character = LocalPlayer.Character
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = targetCF
    end
end

local function TeleportToCF(targetCF)
    if SmoothTeleport then
        TeleportSmooth(targetCF)
    else
        TeleportCepat(targetCF)
    end
end

-- =====================================================
-- INVISIBLE MODE
-- =====================================================
local InvisibleLoop = nil

local function SetInvisible(state)
    local character = LocalPlayer.Character
    if not character then return end
    
    if state then
        if InvisibleLoop then InvisibleLoop:Disconnect() end
        
        for _, v in pairs(character:GetDescendants()) do
            pcall(function()
                if v:IsA("BasePart") then
                    v.Transparency = 1
                end
            end)
        end
        
        InvisibleLoop = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Transparency = 1
                    end
                end
            end
        end)
        
        Rayfield:Notify({Title="Invisible", Content="ON - Kamu hilang", Duration=2})
    else
        if InvisibleLoop then InvisibleLoop:Disconnect() end
        
        for _, v in pairs(character:GetDescendants()) do
            pcall(function()
                if v:IsA("BasePart") then
                    v.Transparency = 0
                end
            end)
        end
        
        Rayfield:Notify({Title="Invisible", Content="OFF - Kamu terlihat", Duration=2})
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if InvisibleEnabled then
        SetInvisible(true)
    end
end)

LocalPlayer.Idled:Connect(function()
    if AntiAFKEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- =====================================================
-- AUTO SUMMIT LOOP
-- =====================================================
local function StartLoop(name, path)
    task.spawn(function()
        while LoopEnabled[name] do
            for _, cf in ipairs(path) do
                if not LoopEnabled[name] then break end
                TeleportToCF(cf)
                task.wait(TeleportSpeed)
            end
        end
    end)
end

-- =====================================================
-- SAVE/LOAD
-- =====================================================
local function SaveData()
    local data = {}
    for name, path in pairs(FinalMounts) do
        local encoded = {}
        for _, cf in ipairs(path) do
            table.insert(encoded, {cf.X, cf.Y, cf.Z})
        end
        data[name] = encoded
    end
    writefile(FileName, HttpService:JSONEncode(data))
end

if isfile(FileName) then
    pcall(function()
        local data = HttpService:JSONDecode(readfile(FileName))
        for name, pathData in pairs(data) do
            local path = {}
            for _, v in ipairs(pathData) do
                table.insert(path, CFrame.new(v[1], v[2], v[3]))
            end
            FinalMounts[name] = path
        end
    end)
end

-- =====================================================
-- MAIN TAB
-- =====================================================
local Tab = Window:CreateTab("Auto Summit", 4483362458)
local ListSection

Tab:CreateSection("⚙️ PENGATURAN")

-- Slider Kecepatan (0.1 - 2.0)
Tab:CreateSlider({
   Name = "⏱️ Kecepatan Teleport",
   Range = {0.1, 2.0},
   Increment = 0.1,
   CurrentValue = TeleportSpeed,
   Callback = function(v) TeleportSpeed = v end
})

-- Toggle Smooth Teleport
Tab:CreateToggle({
   Name = "✨ SMOOTH TELEPORT",
   CurrentValue = true,
   Callback = function(v)
      SmoothTeleport = v
      Rayfield:Notify({
         Title = "Smooth Teleport",
         Content = v and "✅ AKTIF - Anti geter" or "⚡ NONAKTIF - Cepat",
         Duration = 2
      })
   end
})

-- Toggle Invisible
Tab:CreateToggle({
   Name = "👻 INVISIBLE",
   CurrentValue = false,
   Callback = function(v)
      InvisibleEnabled = v
      SetInvisible(v)
   end
})

Tab:CreateToggle({
   Name = "Anti AFK",
   CurrentValue = true,
   Callback = function(v) AntiAFKEnabled = v end
})

-- Daftar Gunung
Tab:CreateSection("🔥 DAFTAR GUNUNG")

local function RefreshList()
    if ListSection then pcall(function() ListSection:Destroy() end) end
    ListSection = Tab:CreateSection("📋 Gunung Tersimpan")
    for name, path in pairs(FinalMounts) do
        Tab:CreateToggle({
           Name = "🚀 " .. name .. " (" .. #path .. " CP)",
           CurrentValue = false,
           Callback = function(v)
              LoopEnabled[name] = v
              if v then StartLoop(name, path) end
           end
        })
    end
end

Tab:CreateButton({
   Name = "🔄 Stop Semua",
   Callback = function()
      for name, _ in pairs(LoopEnabled) do LoopEnabled[name] = false end
   end
})

Tab:CreateSection("🗑️ Hapus Rute")
Tab:CreateInput({
   Name = "Ketik Nama",
   PlaceholderText = "Nama gunung...",
   Callback = function(Text)
       if FinalMounts[Text] then
           FinalMounts[Text] = nil
           SaveData()
           RefreshList()
           Rayfield:Notify({Title="Hapus", Content="Rute dihapus!"})
       end
   end
})

RefreshList()

-- =====================================================
-- RECORDER GUI (ORIGINAL + MINIMIZE)
-- =====================================================
task.spawn(function()
    task.wait(1.5)
    
    -- Buat GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "RecorderOriginal"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Frame utama
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 240, 0, 450)
    frame.Position = UDim2.new(0.02, 0, 0.2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.Active = true
    frame.Draggable = true
    frame.ClipsDescendants = true
    frame.Parent = gui
    
    -- Rounded
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 100, 0)
    stroke.Thickness = 2
    stroke.Parent = frame
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 35)
    header.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    header.Parent = frame
    
    local headCorner = Instance.new("UICorner")
    headCorner.CornerRadius = UDim.new(0, 8)
    headCorner.Parent = header
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = "🔥 RECORDER ORIGINAL"
    title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = header
    
    -- Minimize button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 30, 0, 35)
    minBtn.Position = UDim2.new(1, -65, 0, 0)
    minBtn.Text = "−"
    minBtn.TextColor3 = Color3.new(1,1,1)
    minBtn.BackgroundTransparency = 1
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 20
    minBtn.Parent = header
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 35)
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Parent = header
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
    
    -- Content
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, -35)
    content.Position = UDim2.new(0, 0, 0, 35)
    content.BackgroundTransparency = 1
    content.Parent = frame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content
    
    -- INPUT NAMA GUNUNG (seperti original)
    local nameBox = Instance.new("TextBox")
    nameBox.Size = UDim2.new(0.9, 0, 0, 38)
    nameBox.PlaceholderText = "📝 NAMA GUNUNG..."
    nameBox.Text = ""
    nameBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    nameBox.TextColor3 = Color3.new(1,1,1)
    nameBox.PlaceholderColor3 = Color3.fromRGB(150,150,150)
    nameBox.Font = Enum.Font.Gotham
    nameBox.TextSize = 14
    nameBox.Parent = content
    
    local nameCorner = Instance.new("UICorner")
    nameCorner.CornerRadius = UDim.new(0, 6)
    nameCorner.Parent = nameBox
    
    -- INPUT NAMA CP (seperti original)
    local cpBox = Instance.new("TextBox")
    cpBox.Size = UDim2.new(0.9, 0, 0, 38)
    cpBox.PlaceholderText = "📍 NAMA CP..."
    cpBox.Text = ""
    cpBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    cpBox.TextColor3 = Color3.new(1,1,1)
    cpBox.PlaceholderColor3 = Color3.fromRGB(150,150,150)
    cpBox.Font = Enum.Font.Gotham
    cpBox.TextSize = 14
    cpBox.Parent = content
    
    local cpCorner = Instance.new("UICorner")
    cpCorner.CornerRadius = UDim.new(0, 6)
    cpCorner.Parent = cpBox
    
    -- STATUS (seperti original)
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0.9, 0, 0, 28)
    status.Text = "⏳ Queue: 0 CP"
    status.TextColor3 = Color3.fromRGB(255, 150, 0)
    status.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    status.Font = Enum.Font.GothamBold
    status.TextSize = 14
    status.Parent = content
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = status
    
    -- Slider kecepatan record
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0.9, 0, 0, 20)
    speedLabel.Text = "⚡ Record Speed: 0.3s"
    speedLabel.TextColor3 = Color3.fromRGB(200,200,200)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 12
    speedLabel.Parent = content
    
    -- Function buat tombol
    local function makeBtn(txt, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 38)
        btn.Text = txt
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Parent = content
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        return btn
    end
    
    -- Buat semua tombol (sesuai original)
    local recordBtn = makeBtn("🔴 MULAI RECORD", Color3.fromRGB(255, 50, 50))
    local stopBtn = makeBtn("⏹️ STOP RECORD", Color3.fromRGB(100, 100, 100))
    local saveBtn = makeBtn("💾 SIMPAN CP", Color3.fromRGB(50, 150, 255))
    local publishBtn = makeBtn("🔀 MERGE & PUBLISH", Color3.fromRGB(255, 150, 0))
    local resetBtn = makeBtn("🗑️ RESET QUEUE", Color3.fromRGB(200, 50, 50))
    
    -- ===== FUNGSI RECORDER =====
    local isRecording = false
    
    recordBtn.MouseButton1Click:Connect(function()
        isRecording = true
        TempRecording = {}
        Rayfield:Notify({Title="Recorder", Content="🎥 Merekam..."})
        
        task.spawn(function()
            while isRecording do
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    table.insert(TempRecording, root.CFrame)
                end
                task.wait(0.3)
            end
        end)
    end)
    
    stopBtn.MouseButton1Click:Connect(function()
        isRecording = false
        Rayfield:Notify({Title="Recorder", Content="⏹️ Stop: "..#TempRecording.." titik"})
    end)
    
    saveBtn.MouseButton1Click:Connect(function()
        if #TempRecording == 0 then
            Rayfield:Notify({Title="Error", Content="❌ Tidak ada data!"})
            return
        end
        
        local cpName = cpBox.Text
        if cpName == "" then cpName = "CP_" .. #SavedParts + 1 end
        
        table.insert(SavedParts, {Name = cpName, Path = TempRecording})
        cpBox.Text = ""
        status.Text = "⏳ Queue: "..#SavedParts.." CP"
        Rayfield:Notify({Title="Sukses", Content="✅ CP tersimpan"})
    end)
    
    publishBtn.MouseButton1Click:Connect(function()
        local name = nameBox.Text
        if name == "" then
            Rayfield:Notify({Title="Error", Content="❌ Isi nama gunung!"})
            return
        end
        
        if #SavedParts == 0 then
            Rayfield:Notify({Title="Error", Content="❌ Tidak ada CP!"})
            return
        end
        
        local fullPath = {}
        for _, data in ipairs(SavedParts) do
            for _, cf in ipairs(data.Path) do
                table.insert(fullPath, cf)
            end
        end
        
        FinalMounts[name] = fullPath
        SaveData()
        RefreshList()
        
        Rayfield:Notify({Title="Sukses", Content="🎉 Gunung dipublish!"})
        
        SavedParts = {}
        TempRecording = {}
        status.Text = "⏳ Queue: 0 CP"
        nameBox.Text = ""
        cpBox.Text = ""
    end)
    
    resetBtn.MouseButton1Click:Connect(function()
        SavedParts = {}
        TempRecording = {}
        status.Text = "⏳ Queue: 0 CP"
        Rayfield:Notify({Title="Reset", Content="✅ Queue bersih"})
    end)
    
    -- MINIMIZE FUNCTION
    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        content.Visible = not minimized
        frame.Size = minimized and UDim2.new(0, 240, 0, 35) or UDim2.new(0, 240, 0, 450)
        minBtn.Text = minimized and "□" or "−"
    end)
end)

-- Notifikasi
Rayfield:Notify({
   Title = "✅ READY",
   Content = "Kecepatan 0.1-2.0 | Recorder Original | Smooth Teleport",
   Duration = 5
})
