--[[
    ══════════════════════════════════════════════
    🔥 BFF FARM v11.0 - REAL ATTACK 🔥
    ══════════════════════════════════════════════
    - Mouse.Hit على العدو
    - Camera Lock على العدو  
    - Tool:Activate() المضبوط
    - VIM Click مع كل شي
    ══════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local VIM = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════
-- إحداثيات الجزر
-- ═══════════════════════════════════════
local ISLANDS = {
    ["Jungle"]            = CFrame.new(-1601, 40, 153),
    ["Pirate Village"]    = CFrame.new(-1181, 10, 3803),
    ["Desert"]            = CFrame.new(1094, 10, 4287),
    ["Frozen Village"]    = CFrame.new(1213, 130, -1183),
    ["Marine Fortress"]   = CFrame.new(-4842, 25, 4324),
    ["Sky Island"]        = CFrame.new(-4970, 725, -2622),
    ["Prison"]            = CFrame.new(4875, 10, 734),
    ["Colosseum"]         = CFrame.new(-1428, 15, -3014),
    ["Magma"]             = CFrame.new(-5316, 20, 8517),
}

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
    Title = "🔥 BFF v11.0";
    Text = "Real Attack - رح يضرب!";
    Duration = 3;
})

print("╔═══════════════════════════════════╗")
print("║  🔥 BFF v11.0 - REAL ATTACK     ║")
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
local function getEquippedTool()
    local char = getChar()
    if not char then return nil end
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Tool") then return item end
    end
    return nil
end

local function equipWeapon()
    local tool = getEquippedTool()
    if tool then return tool end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return nil end
    
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            local hum = getHumanoid()
            if hum then
                hum:EquipTool(item)
                wait(0.3)
                return item
            end
        end
    end
    return nil
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
-- 💥 REAL ATTACK - كل الطرق معاً
-- ═══════════════════════════════════════
local function realAttack(enemy)
    if not enemy then return end
    local eHRP = enemy:FindFirstChild("HumanoidRootPart")
    if not eHRP then return end
    
    local tool = getEquippedTool()
    if not tool then return end
    
    pcall(function()
        -- 1️⃣ حرك الـ Mouse فوق العدو (المفتاح!)
        Mouse.Hit = eHRP.CFrame
        Mouse.Target = eHRP
        
        -- 2️⃣ فعّل الأداة
        tool:Activate()
        
        -- 3️⃣ Signal للـ Activated event
        if tool:FindFirstChild("RemoteFunctionShoot") then
            tool.RemoteFunctionShoot:InvokeServer("id", eHRP.Position)
        end
    end)
    
    -- 4️⃣ Virtual Click في وسط الشاشة
    pcall(function()
        local vs = Camera.ViewportSize
        VIM:SendMouseButtonEvent(vs.X/2, vs.Y/2, 0, true, game, 0)
        VIM:SendMouseButtonEvent(vs.X/2, vs.Y/2, 0, false, game, 0)
    end)
end

-- ═══════════════════════════════════════
-- Anti-Death
-- ═══════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function()
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
                wait(2)
                return
            end
            
            local tool = equipWeapon()
            if not tool then
                print("⚠️ [BFF] لا يوجد سلاح!")
                wait(2)
                return
            end
            
            local targetName, islandName = getTarget()
            local enemy = findEnemy(targetName)
            
            if not enemy then
                local islandCF = ISLANDS[islandName]
                if islandCF then
                    local dist = (hrp.Position - islandCF.Position).Magnitude
                    if dist > 300 then
                        print("✈️ [BFF] Teleport to: " .. islandName)
                        hrp.CFrame = islandCF
                        wait(2)
                    else
                        wait(1)
                    end
                end
                return
            end
            
            print("⚔️ [BFF] هدف: " .. targetName)
            
            local eHRP = enemy:FindFirstChild("HumanoidRootPart")
            local eHum = enemy:FindFirstChildOfClass("Humanoid")
            if not eHRP or not eHum then return end
            
            -- 🎯 KILL LOOP
            local killStart = tick()
            
            while enemy and enemy.Parent and eHum and eHum.Health > 0 
                  and getgenv().BFF_FARM_ACTIVE do
                if not eHRP.Parent then break end
                if (tick() - killStart) > 20 then break end
                
                pcall(function()
                    -- 1. اللصق بجنب العدو (خلفه عشان NPC ما يشوفنا)
                    hrp.CFrame = eHRP.CFrame * CFrame.new(0, 2, -2.5)
                    
                    -- 2. وجّه الكاميرا للعدو (مهم!)
                    Camera.CFrame = CFrame.new(
                        hrp.Position + Vector3.new(0, 5, 0),
                        eHRP.Position
                    )
                    
                    -- 3. اضرب بكل الطرق
                    realAttack(enemy)
                end)
                
                RunService.Heartbeat:Wait()
            end
            
            print("💀 [BFF] Killed: " .. targetName)
        end)
        
        if not success then
            warn("⚠️ [BFF] " .. tostring(err))
        end
        
        wait(0.3)
    end
end)

print("✅ [BFF v11.0] REAL ATTACK READY!")

StarterGui:SetCore("SendNotification", {
    Title = "✅ BFF v11.0";
    Text = "Mouse.Hit + Camera + Tool = 💥";
    Duration = 5;
})
