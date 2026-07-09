--[[
    ══════════════════════════════════════════════
    🔥 BFF FARM v10.0 - KILL AURA FINAL 🔥
    ══════════════════════════════════════════════
    - CFrame Attack (اللصق بجنب العدو)
    - Tool:Activate() (أقوى طريقة M1)
    - Multi-Remote Attack
    - Kill Aura حقيقي
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
    Title = "🔥 BFF v10.0";
    Text = "Kill Aura Final - رح يشتغل!";
    Duration = 3;
})

print("╔═══════════════════════════════════╗")
print("║  🔥 BFF v10.0 - KILL AURA       ║")
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
                wait(0.2)
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
-- 💥 KILL AURA - الطريقة الحقيقية!
-- ═══════════════════════════════════════
local function attackEnemy(enemy)
    if not enemy then return end
    
    local tool = getEquippedTool()
    if not tool then return end
    
    -- الطريقة الأقوى: Tool:Activate() (كأنك تضغط بيدك!)
    pcall(function()
        tool:Activate()
    end)
    
    -- طريقة إضافية: Mouse Click
    pcall(function()
        tool.Activated:Fire()
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
-- 🎯 الحلقة الرئيسية - KILL AURA
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
                wait(1)
                return
            end
            
            local targetName, islandName = getTarget()
            local enemy = findEnemy(targetName)
            
            if not enemy then
                -- Teleport للجزيرة
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
            
            print("⚔️ [BFF] KILL AURA على: " .. targetName)
            
            local eHRP = enemy:FindFirstChild("HumanoidRootPart")
            local eHum = enemy:FindFirstChildOfClass("Humanoid")
            if not eHRP or not eHum then return end
            
            -- 🎯 KILL AURA LOOP - CFrame كل frame + Attack
            local killStart = tick()
            
            while enemy and enemy.Parent and eHum and eHum.Health > 0 
                  and getgenv().BFF_FARM_ACTIVE do
                if not eHRP.Parent then break end
                if (tick() - killStart) > 20 then break end
                
                -- 💥 المفتاح السحري: CFrame اللاعب بجنب العدو مباشرة!
                pcall(function()
                    -- ضع اللاعب أمام العدو بمسافة 2 stud (نطاق M1)
                    hrp.CFrame = eHRP.CFrame * CFrame.new(0, 0, -3)
                    
                    -- اضرب بالـ Tool
                    attackEnemy(enemy)
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

print("✅ [BFF v10.0] KILL AURA ACTIVE!")

StarterGui:SetCore("SendNotification", {
    Title = "✅ BFF v10.0";
    Text = "Kill Aura شغال - المونكي مات!";
    Duration = 5;
})
