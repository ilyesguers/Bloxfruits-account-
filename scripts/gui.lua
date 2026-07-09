--[[
    ══════════════════════════════════════
    🔥 BLOX FRUIT FURY - لوحة التحكم
    ══════════════════════════════════════
]]

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════
-- جمع بيانات اللاعب
-- ═══════════════════════════════════════
local function GetPlayerData()
    local data = {}
    
    pcall(function()
        data.Name = LocalPlayer.Name
        data.DisplayName = LocalPlayer.DisplayName
    end)
    
    -- الليفل
    pcall(function()
        local stats = LocalPlayer:FindFirstChild("Data")
        if stats then
            data.Level = stats:FindFirstChild("Level") 
                and stats.Level.Value or "?"
            data.Beli = stats:FindFirstChild("Beli") 
                and stats.Beli.Value or "?"
            data.Fragments = stats:FindFirstChild("Fragments") 
                and stats.Fragments.Value or "?"
        end
    end)
    
    -- الفاكهة الحالية
    pcall(function()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        data.Fruits = {}
        if backpack then
            for _, item in pairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    table.insert(data.Fruits, item.Name)
                end
            end
        end
        -- أيضاً في اليد
        local char = LocalPlayer.Character
        if char then
            for _, item in pairs(char:GetChildren()) do
                if item:IsA("Tool") then
                    table.insert(data.Fruits, item.Name)
                end
            end
        end
    end)
    
    -- العالم الحالي (Sea 1, 2, 3)
    pcall(function()
        local placeId = game.PlaceId
        if placeId == 2753915549 then
            data.Sea = "Sea 1 (Old World)"
        elseif placeId == 4442272183 then
            data.Sea = "Sea 2 (New World)"
        elseif placeId == 7449423635 then
            data.Sea = "Sea 3 (Third Sea)"
        else
            data.Sea = "Unknown"
        end
    end)
    
    return data
end

-- ═══════════════════════════════════════
-- إنشاء لوحة التحكم (GUI)
-- ═══════════════════════════════════════
local function CreateDashboard()
    -- حذف أي لوحة قديمة
    local old = game:GetService("CoreGui"):FindFirstChild("BFF_Dashboard")
    if old then old:Destroy() end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BFF_Dashboard"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- ═══════════════════════════════════
    -- الإطار الرئيسي
    -- ═══════════════════════════════════
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 320, 0, 420)
    MainFrame.Position = UDim2.new(0, 10, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 100, 0)
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame
    
    -- ═══════════════════════════════════
    -- العنوان
    -- ═══════════════════════════════════
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(255, 80, 0)
    Title.Text = "🔥 BLOX FRUIT FURY 🔥"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = Title
    
    -- ═══════════════════════════════════
    -- حالة السكربت
    -- ═══════════════════════════════════
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "Status"
    StatusLabel.Size = UDim2.new(1, -20, 0, 25)
    StatusLabel.Position = UDim2.new(0, 10, 0, 45)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "🟢 الحالة: نشط"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    StatusLabel.TextSize = 14
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = MainFrame
    
    -- ═══════════════════════════════════
    -- دالة إنشاء صف معلومات
    -- ═══════════════════════════════════
    local function CreateInfoRow(name, icon, yPos)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, -20, 0, 30)
        Row.Position = UDim2.new(0, 10, 0, yPos)
        Row.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
        Row.BorderSizePixel = 0
        Row.Parent = MainFrame
        
        local RowCorner = Instance.new("UICorner")
        RowCorner.CornerRadius = UDim.new(0, 6)
        RowCorner.Parent = Row
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.5, 0, 1, 0)
        Label.Position = UDim2.new(0, 8, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = icon .. " " .. name
        Label.TextColor3 = Color3.fromRGB(180, 180, 200)
        Label.TextSize = 12
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Row
        
        local Value = Instance.new("TextLabel")
        Value.Name = "Value"
        Value.Size = UDim2.new(0.5, -8, 1, 0)
        Value.Position = UDim2.new(0.5, 0, 0, 0)
        Value.BackgroundTransparency = 1
        Value.Text = "جاري التحميل..."
        Value.TextColor3 = Color3.fromRGB(255, 255, 255)
        Value.TextSize = 12
        Value.Font = Enum.Font.GothamBold
        Value.TextXAlignment = Enum.TextXAlignment.Right
        Value.Parent = Row
        
        return Value
    end
    
    -- ═══════════════════════════════════
    -- إنشاء صفوف المعلومات
    -- ═══════════════════════════════════
    local NameValue = CreateInfoRow("الحساب", "👤", 80)
    local LevelValue = CreateInfoRow("الليفل", "⭐", 115)
    local BeliValue = CreateInfoRow("المال", "💰", 150)
    local FragValue = CreateInfoRow("الفراقمنت", "💎", 185)
    local SeaValue = CreateInfoRow("العالم", "🌊", 220)
    local FruitValue = CreateInfoRow("الفاكهة", "🍎", 255)
    local TaskValue = CreateInfoRow("التسك الحالي", "📜", 290)
    
    -- ═══════════════════════════════════
    -- زر إخفاء/إظهار
    -- ═══════════════════════════════════
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 30, 0, 30)
    ToggleBtn.Position = UDim2.new(0, 10, 0.5, -230)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 0)
    ToggleBtn.Text = "◀"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 16
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Parent = ScreenGui
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = ToggleBtn
    
    local visible = true
    ToggleBtn.MouseButton1Click:Connect(function()
        visible = not visible
        MainFrame.Visible = visible
        ToggleBtn.Text = visible and "◀" or "▶"
    end)
    
    -- ═══════════════════════════════════
    -- تحديث البيانات كل 2 ثانية
    -- ═══════════════════════════════════
    spawn(function()
        while true do
            pcall(function()
                local data = GetPlayerData()
                
                NameValue.Text = tostring(data.Name or "?")
                LevelValue.Text = tostring(data.Level or "?")
                BeliValue.Text = tostring(data.Beli or "?")
                FragValue.Text = tostring(data.Fragments or "?")
                SeaValue.Text = tostring(data.Sea or "?")
                
                if data.Fruits and #data.Fruits > 0 then
                    FruitValue.Text = table.concat(data.Fruits, ", ")
                else
                    FruitValue.Text = "لا يوجد"
                end
                
                -- التسك الحالي
                local currentTask = "لا يوجد"
                pcall(function()
                    local pData = LocalPlayer:FindFirstChild("Data")
                    if pData then
                        local quest = pData:FindFirstChild("Quest")
                        if quest then
                            currentTask = quest.Value
                        end
                    end
                end)
                TaskValue.Text = currentTask
                
                -- تحديث الحالة
                StatusLabel.Text = "🟢 نشط | " .. os.date("%H:%M:%S")
            end)
            
            wait(2)
        end
    end)
    
    return ScreenGui
end

-- ═══════════════════════════════════════
-- تشغيل لوحة التحكم
-- ═══════════════════════════════════════
CreateDashboard()

-- إشعار
StarterGui:SetCore("SendNotification", {
    Title = "🔥 BFF Dashboard";
    Text = "لوحة التحكم جاهزة!";
    Duration = 5;
})
