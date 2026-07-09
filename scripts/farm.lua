--[[
    ══════════════════════════════════════════════
    🔥 BFF FARM v4.0 - MARINES EDITION 🔥
    ══════════════════════════════════════════════
    - يطير فوق المباني (ارتفاع عالي)
    - يستخدم Remote للهجوم (سريع + بعيد)
    - يتجنب Safe Zones
    - يفرم Bandits/Monkeys من ليفل 1
    ══════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════
-- الإعدادات
-- ═══════════════════════════════════════
local FLY_SPEED = 180              -- سرعة الطيران
local FLY_HEIGHT = 100             -- ارتفاع الطيران (فوق المباني)
local ATTACK_HEIGHT = 15           -- ارتفاع فوق العدو أثناء الضرب
local ATTACK_RANGE = 80            -- مسافة الضرب

-- ═══════════════════════════════════════
-- إحداثيات الجزر (نقاط آمنة فوق)
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
-- الأعداء حسب الليفل (تخطي Starter Island!)
-- ═══════════════════════════════════════
local ENEMIES_BY_LEVEL = {
    -- من ليفل 1 نبدأ في Jungle (لأن Marines في Starter = Safe Zone)
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

-- ═══════════════════════════════════════
-- إشعار
-- ═══════════════════════════════════════
StarterGui:SetCore("SendNotification", {
    Title = "🔥 BFF Farm v4.0";
    Text = "Marines Farm بدأ!";
    Duration = 3;
})

print("╔═══════════════════════════════════╗")
print("║  🔥 BFF FARM v4.0 - MARINES     ║")
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
-- 🚀 نظام الطيران (Anti-Ban + Anti-Building)
-- ═══════════════════════════════════════
local currentBV = nil
local currentBG = nil

local function stopFlight()
    if currentBV then pcall(function() currentBV:Destroy() end) currentBV = nil end
    if currentBG then pcall(function() currentBG:Destroy() end) currentBG = nil end
    
    -- تنظيف كل BV/BG قديمة
    local hrp = getHRP()
    if hrp then
        for _, obj in pairs(hrp:GetChildren()) do
            if obj.Name:find("BFF_") then
                obj:Destroy()
            end
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

-- ═══════════════════════════════════════
-- الطيران لنقطة بشكل ذكي (يرفع فوق المباني)
-- ═══════════════════════════════════════
local function flyToPosition(targetPos, stopDist)
    stopDist = stopDist or 10
    local hrp = getHRP()
    if not hrp then return end
    
    local bv, bg = createFlight()
    if not bv then return end
    
    local startTime = tick()
    local maxTime = 30 -- 30 ثانية كحد أقصى
    
    while getgenv().BFF_FARM_ACTIVE and (tick() - startTime) < maxTime do
        if not hrp or not hrp.Parent then break end
        
        -- ارفع اللاعب فوق المستوى الآمن أول شي
        local currentPos = hrp.Position
        local safeHeight = math.max(targetPos.Y, FLY_HEIGHT)
        
        -- إذا مو مرتفع كفاية، ارفعه أولاً
        if currentPos.Y < safeHeight - 20 then
            bv.Velocity = Vector3.new(0, FLY_SPEED, 0)
            bg.CFrame = CFrame.new(currentPos, currentPos + Vector3.new(0, 1, 0))
            RunService.Heartbeat:Wait()
        else
            -- طير أفقياً للهدف
            local highTarget = Vector3.new(targetPos.X, safeHeight, targetPos.Z)
            local direction = (highTarget - currentPos)
            local distance = direction.Magnitude
            
            if distance < stopDist then
                -- انزل للهدف
                local downDir = (targetPos - currentPos)
                if downDir.Magnitude < stopDist then
                    break
                end
                bv.Velocity = downDir.Unit * math.min(FLY_SPEED, downDir.Magnitude * 3)
            else
                bv.Velocity = direction.Unit * FLY_SPEED
            end
            
            bg.CFrame = CFrame.new(currentPos, highTarget)
            RunService.Heartbeat:Wait()
        end
    end
    
    -- توقف عند الوصول
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
-- 💥 الهجوم عبر Remote (سريع + بعيد + مضمون)
-- ═══════════════════════════════════════
local function damageEnemy(enemy)
    if not enemy then return end
    
    local eHum = enemy:FindFirstChildOfClass("Humanoid")
    local eHRP = enemy:FindFirstChild("HumanoidRootPart")
    if not eHum or not eHRP then return end
    
    local myHRP = getHRP()
    if not myHRP then return end
    
    -- Method 1: Direct damage via Blox Fruits Remote
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if not remotes then return end
        
        local commE = remotes:FindFirstChild("CommE")
        if commE then
            -- طريقة Blox Fruits الرسمية للهجوم
            commE:FireServer("Combat", enemy, "Slash")
            commE:FireServer("Combat", enemy)
            commE:FireServer("KillLegacy", enemy, 999999)
        end
        
        local commF = remotes:FindFirstChild("CommF_")
        if commF then
            commF:InvokeServer("Damage", enemy, 999)
        end
    end)
end

-- ═══════════════════════════════════════
-- Anti-Death
-- ═══════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function()
    stopFlight()
    wait(3)
    print("🔄 [BFF] Respawned")
end)

-- ═══════════════════════════════════════
-- الحلقة الرئيسية
-- ═══════════════════════════════════════
getgenv().BFF_FARM_ACTIVE = true

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
                local islandPos = ISLANDS[islandName]
                if islandPos then
                    local dist = (hrp.Position - islandPos).Magnitude
                    if dist > 300 then
                        print("✈️ [BFF] الطيران إلى: " .. islandName)
                        flyToPosition(islandPos, 100)
                    else
                        print("🔍 [BFF] البحث في " .. islandName .. " (لا يوجد " .. targetName .. ")")
                        wait(3)
                    end
                end
                return
            end
            
            print("⚔️ [BFF] استهداف: " .. targetName)
            
            local eHRP = enemy:FindFirstChild("HumanoidRootPart")
            local eHum = enemy:FindFirstChildOfClass("Humanoid")
            if not eHRP or not eHum then return end
            
            -- طير فوق العدو
            local bv, bg = createFlight()
            if not bv then return end
            
            local killStart = tick()
            
            while enemy and enemy.Parent and eHum and eHum.Health > 0 
                  and getgenv().BFF_FARM_ACTIVE do
                if not eHRP.Parent then break end
                if (tick() - killStart) > 15 then break end -- timeout
                
                -- ثبت فوق العدو
                local targetPos = eHRP.Position + Vector3.new(0, ATTACK_HEIGHT, 0)
                local myPos = hrp.Position
                local diff = (targetPos - myPos)
                
                if diff.Magnitude > 3 then
                    bv.Velocity = diff.Unit * math.min(100, diff.Magnitude * 6)
                else
                    bv.Velocity = Vector3.new(0, 0, 0)
                end
                
                bg.CFrame = CFrame.new(myPos, eHRP.Position)
                
                -- اضرب!
                damageEnemy(enemy)
                
                wait(0.1)
            end
            
            print("💀 [BFF] Killed: " .. targetName)
        end)
        
        if not success then
            warn("⚠️ [BFF] " .. tostring(err))
        end
        
        wait(0.3)
    end
end)

print("✅ [BFF FARM v4.0] READY")

StarterGui:SetCore("SendNotification", {
    Title = "✅ BFF v4.0";
    Text = "الفرم بدأ - Marines Mode!";
    Duration = 5;
})
