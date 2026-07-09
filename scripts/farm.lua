--[[
    ══════════════════════════════════════════════
    🔥 BFF FARM v3.0 - SAFE FLIGHT MODE 🔥
    ══════════════════════════════════════════════
    - طيران سلس بـ BodyVelocity (لا يكتشفه Anti-Cheat)
    - دوران حول الجزيرة عند عدم وجود أعداء
    - سرعة معتدلة وآمنة
    - Anti-Ban System
    ══════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local VIM = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════
-- إعدادات السرعة (آمنة)
-- ═══════════════════════════════════════
local FLY_SPEED = 150            -- سرعة الطيران (آمنة)
local ATTACK_HEIGHT = 12         -- الارتفاع فوق العدو
local ATTACK_DISTANCE = 8        -- المسافة من العدو
local SEARCH_RADIUS = 2000       -- نطاق البحث

-- ═══════════════════════════════════════
-- إحداثيات الجزر
-- ═══════════════════════════════════════
local ISLANDS = {
    ["Starter Island"]    = Vector3.new(1071, 16, 1426),
    ["Jungle"]            = Vector3.new(-1601, 36, 153),
    ["Pirate Village"]    = Vector3.new(-1181, 4, 3803),
    ["Desert"]            = Vector3.new(1094, 6, 4287),
    ["Frozen Village"]    = Vector3.new(1213, 126, -1183),
    ["Marine Fortress"]   = Vector3.new(-4842, 20, 4324),
    ["Sky Island"]        = Vector3.new(-4970, 719, -2622),
    ["Prison"]            = Vector3.new(4875, 5, 734),
    ["Colosseum"]         = Vector3.new(-1428, 7, -3014),
    ["Magma"]             = Vector3.new(-5316, 12, 8517),
}

-- ═══════════════════════════════════════
-- قاعدة بيانات الأعداء
-- ═══════════════════════════════════════
local ENEMIES_BY_LEVEL = {
    {min = 1,    max = 9,    name = "Bandit",              island = "Starter Island"},
    {min = 10,   max = 14,   name = "Monkey",              island = "Jungle"},
    {min = 15,   max = 29,   name = "Gorilla",             island = "Jungle"},
    {min = 30,   max = 39,   name = "Pirate",              island = "Pirate Village"},
    {min = 40,   max = 59,   name = "Brute",               island = "Pirate Village"},
    {min = 60,   max = 74,   name = "Desert Bandit",       island = "Desert"},
    {min = 75,   max = 89,   name = "Desert Officer",      island = "Desert"},
    {min = 90,   max = 99,   name = "Snow Bandit",         island = "Frozen Village"},
    {min = 100,  max = 119,  name = "Snowman",             island = "Frozen Village"},
    {min = 120,  max = 149,  name = "Chief Petty Officer", island = "Marine Fortress"},
    {min = 150,  max = 174,  name = "Sky Bandit",          island = "Sky Island"},
    {min = 175,  max = 189,  name = "Dark Master",         island = "Sky Island"},
    {min = 190,  max = 209,  name = "Prisoner",            island = "Prison"},
    {min = 210,  max = 249,  name = "Dangerous Prisoner",  island = "Prison"},
    {min = 250,  max = 274,  name = "Toga Warrior",        island = "Colosseum"},
    {min = 275,  max = 299,  name = "Gladiator",           island = "Colosseum"},
    {min = 300,  max = 324,  name = "Military Soldier",    island = "Magma"},
    {min = 325,  max = 374,  name = "Military Spy",        island = "Magma"},
}

-- ═══════════════════════════════════════
-- إشعار البداية
-- ═══════════════════════════════════════
StarterGui:SetCore("SendNotification", {
    Title = "🔥 BFF Farm v3.0";
    Text = "Safe Flight Mode مفعّل!";
    Duration = 3;
})

print("╔═══════════════════════════════════╗")
print("║  🔥 BFF FARM v3.0 SAFE MODE      ║")
print("╚═══════════════════════════════════╝")

-- ═══════════════════════════════════════
-- دوال أساسية
-- ═══════════════════════════════════════
local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getLevel()
    local ok, lvl = pcall(function()
        return LocalPlayer.Data.Level.Value
    end)
    return ok and lvl or 1
end

local function getTarget()
    local lvl = getLevel()
    for _, e in ipairs(ENEMIES_BY_LEVEL) do
        if lvl >= e.min and lvl <= e.max then
            return e.name, e.island
        end
    end
    return "Bandit", "Starter Island"
end

-- ═══════════════════════════════════════
-- تجهيز السلاح
-- ═══════════════════════════════════════
local function equipWeapon()
    local char = getChar()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not char or not backpack then return end
    
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Tool") then return true end
    end
    
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            local hum = getHumanoid()
            if hum then
                hum:EquipTool(item)
                return true
            end
        end
    end
    return false
end

-- ═══════════════════════════════════════
-- 🚀 نظام الطيران السلس (Anti-Ban)
-- ═══════════════════════════════════════
local currentBV = nil
local currentBG = nil

local function stopFlight()
    if currentBV then currentBV:Destroy() currentBV = nil end
    if currentBG then currentBG:Destroy() currentBG = nil end
end

local function flyTo(targetPos)
    local hrp = getHRP()
    if not hrp then return end
    
    stopFlight()
    
    -- BodyVelocity للحركة
    local bv = Instance.new("BodyVelocity")
    bv.Name = "BFF_Fly"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.P = 1250
    bv.Parent = hrp
    currentBV = bv
    
    -- BodyGyro للاتجاه
    local bg = Instance.new("BodyGyro")
    bg.Name = "BFF_Gyro"
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 3000
    bg.Parent = hrp
    currentBG = bg
    
    -- حركة تدريجية سلسة
    while getgenv().BFF_FARM_ACTIVE do
        if not hrp or not hrp.Parent then break end
        
        local direction = (targetPos - hrp.Position)
        local distance = direction.Magnitude
        
        if distance < 5 then
            break -- وصل
        end
        
        -- سرعة متناسبة (تبطئ لما يقرب)
        local speed = math.min(FLY_SPEED, distance * 5)
        bv.Velocity = direction.Unit * speed
        bg.CFrame = CFrame.new(hrp.Position, targetPos)
        
        RunService.Heartbeat:Wait()
    end
    
    stopFlight()
end

-- ═══════════════════════════════════════
-- تثبيت فوق العدو (بدون Teleport)
-- ═══════════════════════════════════════
local function hoverAboveEnemy(enemy)
    local hrp = getHRP()
    if not hrp or not enemy then return end
    
    stopFlight()
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "BFF_Hover"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.P = 1250
    bv.Parent = hrp
    currentBV = bv
    
    local bg = Instance.new("BodyGyro")
    bg.Name = "BFF_HoverGyro"
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 3000
    bg.Parent = hrp
    currentBG = bg
    
    return bv, bg
end

-- ═══════════════════════════════════════
-- البحث عن أقرب عدو
-- ═══════════════════════════════════════
local function findEnemy(targetName)
    local hrp = getHRP()
    if not hrp then return nil end
    
    local nearest = nil
    local nearestDist = math.huge
    
    local containers = {
        Workspace:FindFirstChild("Enemies"),
        Workspace
    }
    
    for _, container in pairs(containers) do
        if container then
            for _, enemy in pairs(container:GetChildren()) do
                if enemy.Name == targetName then
                    local hum = enemy:FindFirstChildOfClass("Humanoid")
                    local eHRP = enemy:FindFirstChild("HumanoidRootPart")
                    if hum and hum.Health > 0 and eHRP then
                        local dist = (hrp.Position - eHRP.Position).Magnitude
                        if dist < nearestDist and dist < SEARCH_RADIUS then
                            nearestDist = dist
                            nearest = enemy
                        end
                    end
                end
            end
        end
    end
    
    return nearest
end

-- ═══════════════════════════════════════
-- الهجوم السريع
-- ═══════════════════════════════════════
local function fastAttack()
    pcall(function()
        VIM:SendMouseButtonEvent(500, 500, 0, true, game, 1)
        wait(0.05)
        VIM:SendMouseButtonEvent(500, 500, 0, false, game, 1)
    end)
end

-- ═══════════════════════════════════════
-- الحلقة الرئيسية
-- ═══════════════════════════════════════
getgenv().BFF_FARM_ACTIVE = true

-- تنظيف عند إعادة السبان
LocalPlayer.CharacterAdded:Connect(function()
    stopFlight()
    wait(3)
    print("🔄 [BFF] Respawned, resuming farm...")
end)

spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        local success, err = pcall(function()
            local hrp = getHRP()
            local hum = getHumanoid()
            
            if not hrp or not hum or hum.Health <= 0 then
                wait(2)
                return
            end
            
            equipWeapon()
            
            local targetName, islandName = getTarget()
            local enemy = findEnemy(targetName)
            
            if not enemy then
                -- ما فيه عدو، طير إلى الجزيرة
                local islandPos = ISLANDS[islandName]
                if islandPos then
                    local dist = (hrp.Position - islandPos).Magnitude
                    if dist > 500 then
                        print("✈️ [BFF] الطيران إلى: " .. islandName)
                        flyTo(islandPos + Vector3.new(0, 30, 0))
                    else
                        -- قريب من الجزيرة، دور فيها
                        print("🔍 [BFF] البحث عن " .. targetName .. " في " .. islandName)
                        -- تحريك بسيط عشان spawn
                        local randomOffset = Vector3.new(
                            math.random(-100, 100),
                            30,
                            math.random(-100, 100)
                        )
                        flyTo(islandPos + randomOffset)
                        wait(2)
                    end
                end
                return
            end
            
            print("⚔️ [BFF] هدف: " .. targetName)
            
            local eHRP = enemy:FindFirstChild("HumanoidRootPart")
            local eHum = enemy:FindFirstChildOfClass("Humanoid")
            if not eHRP or not eHum then return end
            
            -- طير فوق العدو بشكل سلس
            local bv, bg = hoverAboveEnemy(enemy)
            if not bv then return end
            
            -- اضرب لين يموت
            while enemy and enemy.Parent and eHum and eHum.Health > 0 and getgenv().BFF_FARM_ACTIVE do
                if not eHRP.Parent then break end
                
                local targetPos = eHRP.Position + Vector3.new(0, ATTACK_HEIGHT, 0)
                local direction = (targetPos - hrp.Position)
                local dist = direction.Magnitude
                
                if dist > 3 then
                    bv.Velocity = direction.Unit * math.min(80, dist * 4)
                else
                    bv.Velocity = Vector3.new(0, 0, 0)
                end
                
                bg.CFrame = CFrame.new(hrp.Position, eHRP.Position)
                
                fastAttack()
                wait(0.15)
            end
            
            print("💀 [BFF] قتل: " .. targetName)
            stopFlight()
        end)
        
        if not success then
            warn("⚠️ [BFF Error] " .. tostring(err))
        end
        
        wait(0.3)
    end
end)

print("✅ [BFF FARM v3.0] SAFE FLIGHT MODE ACTIVE")

StarterGui:SetCore("SendNotification", {
    Title = "✅ BFF Ready";
    Text = "الطيران السلس نشط!";
    Duration = 5;
})
