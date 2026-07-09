--[[
    ══════════════════════════════════════════════
    🔥 BFF FARM v7.0 - M1 SPAMMER 🔥
    ══════════════════════════════════════════════
    - M1 سريع جداً (كل 0.05 ثانية!)
    - نطاق ضربة موسّع للماكس
    - Hitbox Expander للأعداء
    - بعيد وآمن من NPCs
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
-- الإعدادات
-- ═══════════════════════════════════════
local FLY_SPEED = 200
local FLY_HEIGHT = 100
local ATTACK_HEIGHT = 20      -- فوق العدو مباشرة
local HITBOX_SIZE = 80        -- ← حجم Hitbox الكبير (المفتاح!)
local M1_SPEED = 0.05         -- سرعة الـ M1 (كل 50 ملي ثانية!)

-- ═══════════════════════════════════════
-- إحداثيات الجزر
-- ═══════════════════════════════════════
local ISLANDS = {
    ["Jungle"]            = Vector3.new(-1601, 100, 153),
    ["Pirate Village"]    = Vector3.new(-1181, 100, 3803),
    ["Desert"]            = Vector3.new(1094, 100, 4287),
    ["Frozen Village"]    = Vector3.new(1213, 200, -1183),
    ["Marine Fortress"]   = Vector3.new(-4842, 100, 4324),
    ["Sky Island"]        = Vector3.new(-4970, 800, -2622),
    ["Prison"]            = Vector3.new(4875, 100, 734),
    ["Colosseum"]         = Vector3.new(-1428, 100, -3014),
    ["Magma"]             = Vector3.new(-5316, 100, 8517),
}

-- ═══════════════════════════════════════
-- الأعداء
-- ═══════════════════════════════════════
local ENEMIES_BY_LEVEL = {
    {min = 1,    max = 14,   name = "Monkey",              island = "Jungle"},
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

StarterGui:SetCore("SendNotification", {
    Title = "🔥 BFF v7.0";
    Text = "M1 Spammer نشط - جنوني!";
    Duration = 3;
})

print("╔═══════════════════════════════════╗")
print("║  🔥 BFF v7.0 - M1 SPAMMER       ║")
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
    return "Monkey", "Jungle"
end

-- ═══════════════════════════════════════
-- 🎯 HITBOX EXPANDER (المفتاح السحري!)
-- ═══════════════════════════════════════
local originalSizes = {}

local function expandHitbox(enemy)
    if not enemy then return end
    local eHRP = enemy:FindFirstChild("HumanoidRootPart")
    if not eHRP then return end
    
    pcall(function()
        -- احفظ الحجم الأصلي
        if not originalSizes[enemy] then
            originalSizes[enemy] = eHRP.Size
        end
        
        -- وسّع Hitbox
        eHRP.Size = Vector3.new(HITBOX_SIZE, HITBOX_SIZE, HITBOX_SIZE)
        eHRP.Transparency = 0.8
        eHRP.CanCollide = false
        eHRP.Massless = true
    end)
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
-- الطيران
-- ═══════════════════════════════════════
local currentBV = nil
local currentBG = nil

local function stopFlight()
    if currentBV then pcall(function() currentBV:Destroy() end) currentBV = nil end
    if currentBG then pcall(function() currentBG:Destroy() end) currentBG = nil end
    
    local hrp = getHRP()
    if hrp then
        for _, obj in pairs(hrp:GetChildren()) do
            if obj.Name:find("BFF_") then obj:Destroy() end
        end
    end
end

local function createFlight()
    local hrp = getHRP()
    if not hrp then return nil, nil end
    
    stopFlight()
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "BFF_Fly"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.P = 1250
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp
    currentBV = bv
    
    local bg = Instance.new("BodyGyro")
    bg.Name = "BFF_Gyro"
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 3000
    bg.Parent = hrp
    currentBG = bg
    
    return bv, bg
end

local function flyToIsland(targetPos)
    local hrp = getHRP()
    if not hrp then return end
    
    local bv, bg = createFlight()
    if not bv then return end
    
    local startTime = tick()
    while getgenv().BFF_FARM_ACTIVE and (tick() - startTime) < 30 do
        if not hrp or not hrp.Parent then break end
        
        local currentPos = hrp.Position
        
        if currentPos.Y < FLY_HEIGHT - 20 then
            bv.Velocity = Vector3.new(0, FLY_SPEED, 0)
            bg.CFrame = CFrame.new(currentPos, currentPos + Vector3.new(0, 1, 0))
        else
            local highTarget = Vector3.new(targetPos.X, math.max(targetPos.Y, FLY_HEIGHT), targetPos.Z)
            local direction = (highTarget - currentPos)
            local distance = direction.Magnitude
            
            if distance < 30 then break end
            
            bv.Velocity = direction.Unit * FLY_SPEED
            bg.CFrame = CFrame.new(currentPos, highTarget)
        end
        
        RunService.Heartbeat:Wait()
    end
    
    if currentBV then currentBV.Velocity = Vector3.new(0, 0, 0) end
end

-- ═══════════════════════════════════════
-- البحث عن العدو
-- ═══════════════════════════════════════
local function findEnemy(targetName)
    local hrp = getHRP()
    if not hrp then return nil end
    
    local nearest = nil
    local nearestDist = math.huge
    
    local enemiesFolder = Workspace:FindFirstChild("Enemies")
    if enemiesFolder then
        for _, enemy in pairs(enemiesFolder:GetChildren()) do
            if enemy.Name == targetName then
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                local eHRP = enemy:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and eHRP then
                    local dist = (hrp.Position - eHRP.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = enemy
                    end
                end
            end
        end
    end
    
    return nearest
end

-- ═══════════════════════════════════════
-- 💥 M1 SPAM (نقر متواصل جنوني)
-- ═══════════════════════════════════════
local m1Active = false

local function startM1Spam()
    if m1Active then return end
    m1Active = true
    
    spawn(function()
        while m1Active and getgenv().BFF_FARM_ACTIVE do
            pcall(function()
                -- 1. Virtual Click (اللي تسويه أنت بيدك)
                VIM:SendMouseButtonEvent(683, 384, 0, true, game, 1)
                VIM:SendMouseButtonEvent(683, 384, 0, false, game, 1)
                
                -- 2. Remote M1 (احتياطي)
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if remotes then
                    local commE = remotes:FindFirstChild("CommE")
                    if commE then
                        commE:FireServer("Combat")
                    end
                end
            end)
            wait(M1_SPEED)
        end
    end)
end

local function stopM1Spam()
    m1Active = false
end

-- ═══════════════════════════════════════
-- السكيلات
-- ═══════════════════════════════════════
local skills = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C}

local function useSkills()
    for _, key in ipairs(skills) do
        pcall(function()
            VIM:SendKeyEvent(true, key, false, game)
            wait(0.05)
            VIM:SendKeyEvent(false, key, false, game)
        end)
        wait(0.1)
    end
end

-- ═══════════════════════════════════════
-- Anti-Death
-- ═══════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function()
    stopFlight()
    stopM1Spam()
    wait(3)
    print("🔄 [BFF] Respawned")
end)

-- ═══════════════════════════════════════
-- 🎯 الحلقة الرئيسية
-- ═══════════════════════════════════════
getgenv().BFF_FARM_ACTIVE = true

spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        local success, err = pcall(function()
            local hrp = getHRP()
            local hum = getHumanoid()
            
            if not hrp or not hum or hum.Health <= 0 then
                stopM1Spam()
                wait(2)
                return
            end
            
            equipWeapon()
            
            local targetName, islandName = getTarget()
            local enemy = findEnemy(targetName)
            
            if not enemy then
                stopM1Spam()
                local islandPos = ISLANDS[islandName]
                if islandPos then
                    local dist = (hrp.Position - islandPos).Magnitude
                    if dist > 500 then
                        print("✈️ [BFF] Fly to: " .. islandName)
                        flyToIsland(islandPos)
                    else
                        wait(2)
                    end
                end
                return
            end
            
            print("⚔️ [BFF] Target: " .. targetName)
            
            local eHRP = enemy:FindFirstChild("HumanoidRootPart")
            local eHum = enemy:FindFirstChildOfClass("Humanoid")
            if not eHRP or not eHum then return end
            
            -- 🎯 وسّع Hitbox
            expandHitbox(enemy)
            
            -- 🚀 طير فوق العدو
            local bv, bg = createFlight()
            if not bv then return end
            
            -- 💥 ابدأ M1 Spam
            startM1Spam()
            
            local killStart = tick()
            local skillCounter = 0
            
            while enemy and enemy.Parent and eHum and eHum.Health > 0 
                  and getgenv().BFF_FARM_ACTIVE do
                if not eHRP.Parent then break end
                if (tick() - killStart) > 15 then break end
                
                -- ثبت فوق العدو مباشرة
                local targetPos = eHRP.Position + Vector3.new(0, ATTACK_HEIGHT, 0)
                local myPos = hrp.Position
                local diff = (targetPos - myPos)
                
                if diff.Magnitude > 2 then
                    bv.Velocity = diff.Unit * math.min(150, diff.Magnitude * 10)
                else
                    bv.Velocity = Vector3.new(0, 0, 0)
                end
                
                -- وجّه اللاعب والكاميرا للعدو
                bg.CFrame = CFrame.new(myPos, eHRP.Position)
                Workspace.CurrentCamera.CFrame = CFrame.new(
                    myPos, eHRP.Position
                )
                
                -- Hitbox يعيد كل مرة (اللعبة تعيده)
                expandHitbox(enemy)
                
                -- سكيلات كل 15 ملي ثانية
                skillCounter = skillCounter + 1
                if skillCounter % 30 == 0 then
                    useSkills()
                end
                
                wait(0.03)
            end
            
            stopM1Spam()
            print("💀 [BFF] Killed: " .. targetName)
        end)
        
        if not success then
            warn("⚠️ [BFF] " .. tostring(err))
        end
        
        wait(0.2)
    end
end)

print("✅ [BFF v7.0] M1 SPAMMER READY!")

StarterGui:SetCore("SendNotification", {
    Title = "✅ BFF v7.0";
    Text = "M1 كل 50ms + Hitbox 80!";
    Duration = 5;
})
