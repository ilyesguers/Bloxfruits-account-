--[[
    ══════════════════════════════════════════════
    🔥 BFF FARM v15.0 - ALL WORLDS FINAL 🔥
    ══════════════════════════════════════════════
    ✅ كل الأعداء (Level 1 → 2450)
    ✅ 3 عوالم (Sea 1, 2, 3)
    ✅ حركة داخل الجزيرة (Spawn Trigger)
    ✅ انتقال تلقائي بين البحار
    ✅ Zero Cooldown M1 (20 ضربة/ثانية)
    ✅ Underground Safe Mode
    ══════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local VIM = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════
-- 🎯 إعدادات
-- ═══════════════════════════════════════
local UNDERGROUND_OFFSET = -5
local ATTACK_SPEED = 0.05
local SPAWN_MOVE_RADIUS = 80  -- نطاق الحركة داخل الجزيرة

-- ═══════════════════════════════════════
-- 🌊 معرف كل بحر
-- ═══════════════════════════════════════
local SEA_IDS = {
    [1] = 2753915549,   -- Sea 1
    [2] = 4442272183,   -- Sea 2  
    [3] = 7449423635,   -- Sea 3
}

local function getCurrentSea()
    local pid = game.PlaceId
    if pid == SEA_IDS[1] then return 1
    elseif pid == SEA_IDS[2] then return 2
    elseif pid == SEA_IDS[3] then return 3 end
    return 1
end

-- ═══════════════════════════════════════
-- 🗺️ الجزر لكل بحر
-- ═══════════════════════════════════════
local ISLANDS = {
    -- ══ SEA 1 ══
    ["Starter Island"]     = CFrame.new(1071, 16, 1426),
    ["Jungle"]             = CFrame.new(-1601, 40, 153),
    ["Pirate Village"]     = CFrame.new(-1181, 10, 3803),
    ["Desert"]             = CFrame.new(1094, 10, 4287),
    ["Frozen Village"]     = CFrame.new(1213, 130, -1183),
    ["Marine Fortress"]    = CFrame.new(-4842, 25, 4324),
    ["Sky Island"]         = CFrame.new(-4970, 725, -2622),
    ["Prison"]             = CFrame.new(4875, 10, 734),
    ["Colosseum"]          = CFrame.new(-1428, 15, -3014),
    ["Magma Village"]      = CFrame.new(-5316, 20, 8517),
    ["Underwater City"]    = CFrame.new(61163, 11, 1819),
    ["Upper Skylands"]     = CFrame.new(-7862, 5545, -380),
    ["Fountain City"]      = CFrame.new(5127, 4, 4105),
    
    -- ══ SEA 2 ══
    ["Kingdom of Rose"]    = CFrame.new(-386, 74, 1191),
    ["Green Zone"]         = CFrame.new(-2842, 100, 5320),
    ["Graveyard"]          = CFrame.new(-5390, 46, -793),
    ["Snow Mountain"]      = CFrame.new(597, 401, -5371),
    ["Hot Beach"]          = CFrame.new(-5686, 8, -5254),
    ["Cursed Ship"]        = CFrame.new(923, 125, 32844),
    ["Ice Castle"]         = CFrame.new(6148, 294, -6741),
    ["Forgotten Island"]   = CFrame.new(-3055, 250, -10147),
    
    -- ══ SEA 3 ══
    ["Port Town"]          = CFrame.new(-291, 44, 5580),
    ["Hydra Island"]       = CFrame.new(5228, 604, 345),
    ["Great Tree"]         = CFrame.new(2192, 28, -6960),
    ["Castle on Sea"]      = CFrame.new(-5087, 315, -3153),
    ["Floating Turtle"]    = CFrame.new(-13232, 332, -7626),
    ["Haunted Castle"]     = CFrame.new(-9515, 142, 5548),
}

-- ═══════════════════════════════════════
-- 👹 قاعدة بيانات الأعداء الكاملة
-- ═══════════════════════════════════════
local ENEMIES = {
    -- ══════════ SEA 1 (Level 1-700) ══════════
    {min = 1,    max = 9,    name = "Bandit",              island = "Jungle",             sea = 1},
    {min = 10,   max = 14,   name = "Monkey",              island = "Jungle",             sea = 1},
    {min = 15,   max = 29,   name = "Gorilla",             island = "Jungle",             sea = 1},
    {min = 30,   max = 39,   name = "Pirate",              island = "Pirate Village",     sea = 1},
    {min = 40,   max = 59,   name = "Brute",               island = "Pirate Village",     sea = 1},
    {min = 60,   max = 74,   name = "Desert Bandit",       island = "Desert",             sea = 1},
    {min = 75,   max = 89,   name = "Desert Officer",      island = "Desert",             sea = 1},
    {min = 90,   max = 99,   name = "Snow Bandit",         island = "Frozen Village",     sea = 1},
    {min = 100,  max = 119,  name = "Snowman",             island = "Frozen Village",     sea = 1},
    {min = 120,  max = 149,  name = "Chief Petty Officer", island = "Marine Fortress",    sea = 1},
    {min = 150,  max = 174,  name = "Sky Bandit",          island = "Sky Island",         sea = 1},
    {min = 175,  max = 189,  name = "Dark Master",         island = "Sky Island",         sea = 1},
    {min = 190,  max = 209,  name = "Prisoner",            island = "Prison",             sea = 1},
    {min = 210,  max = 249,  name = "Dangerous Prisoner",  island = "Prison",             sea = 1},
    {min = 250,  max = 274,  name = "Toga Warrior",        island = "Colosseum",          sea = 1},
    {min = 275,  max = 299,  name = "Gladiator",           island = "Colosseum",          sea = 1},
    {min = 300,  max = 324,  name = "Military Soldier",    island = "Magma Village",      sea = 1},
    {min = 325,  max = 374,  name = "Military Spy",        island = "Magma Village",      sea = 1},
    {min = 375,  max = 399,  name = "Fishman Warrior",     island = "Underwater City",    sea = 1},
    {min = 400,  max = 449,  name = "Fishman Commando",    island = "Underwater City",    sea = 1},
    {min = 450,  max = 474,  name = "God's Guard",         island = "Upper Skylands",     sea = 1},
    {min = 475,  max = 524,  name = "Shanda",              island = "Upper Skylands",     sea = 1},
    {min = 525,  max = 549,  name = "Royal Squad",         island = "Fountain City",      sea = 1},
    {min = 550,  max = 624,  name = "Royal Soldier",       island = "Fountain City",      sea = 1},
    {min = 625,  max = 700,  name = "Galley Pirate",       island = "Fountain City",      sea = 1},
    
    -- ══════════ SEA 2 (Level 700-1500) ══════════
    {min = 701,  max = 774,  name = "Raider",              island = "Kingdom of Rose",    sea = 2},
    {min = 775,  max = 824,  name = "Mercenary",           island = "Kingdom of Rose",    sea = 2},
    {min = 825,  max = 874,  name = "Swan Pirate",         island = "Green Zone",         sea = 2},
    {min = 875,  max = 924,  name = "Factory Staff",       island = "Green Zone",         sea = 2},
    {min = 925,  max = 949,  name = "Marine Lieutenant",   island = "Graveyard",          sea = 2},
    {min = 950,  max = 974,  name = "Marine Captain",      island = "Graveyard",          sea = 2},
    {min = 975,  max = 999,  name = "Zombie",              island = "Graveyard",          sea = 2},
    {min = 1000, max = 1049, name = "Vampire",             island = "Graveyard",          sea = 2},
    {min = 1050, max = 1099, name = "Snow Trooper",        island = "Snow Mountain",      sea = 2},
    {min = 1100, max = 1124, name = "Winter Warrior",      island = "Snow Mountain",      sea = 2},
    {min = 1125, max = 1174, name = "Lab Subordinate",     island = "Hot Beach",          sea = 2},
    {min = 1175, max = 1199, name = "Horned Warrior",      island = "Hot Beach",          sea = 2},
    {min = 1200, max = 1249, name = "Magma Ninja",         island = "Hot Beach",          sea = 2},
    {min = 1250, max = 1274, name = "Cursed Pirate",       island = "Cursed Ship",        sea = 2},
    {min = 1275, max = 1299, name = "Cyborg",              island = "Ice Castle",         sea = 2},
    {min = 1300, max = 1349, name = "Ice Admiral",         island = "Ice Castle",         sea = 2},
    {min = 1350, max = 1424, name = "Sea Beast",           island = "Forgotten Island",   sea = 2},
    {min = 1425, max = 1499, name = "Reborn Skeleton",     island = "Forgotten Island",   sea = 2},
    
    -- ══════════ SEA 3 (Level 1500-2450) ══════════
    {min = 1500, max = 1524, name = "Pirate Millionaire",  island = "Port Town",          sea = 3},
    {min = 1525, max = 1574, name = "Pistol Billionaire",  island = "Port Town",          sea = 3},
    {min = 1575, max = 1624, name = "Dragon Crew Warrior", island = "Hydra Island",       sea = 3},
    {min = 1625, max = 1649, name = "Dragon Crew Archer",  island = "Hydra Island",       sea = 3},
    {min = 1650, max = 1699, name = "Female Islander",     island = "Great Tree",         sea = 3},
    {min = 1700, max = 1724, name = "Giant Islander",      island = "Great Tree",         sea = 3},
    {min = 1725, max = 1774, name = "Marine Commodore",    island = "Castle on Sea",      sea = 3},
    {min = 1775, max = 1799, name = "Marine Rear Admiral", island = "Castle on Sea",      sea = 3},
    {min = 1800, max = 1824, name = "Fishman Raider",      island = "Floating Turtle",    sea = 3},
    {min = 1825, max = 1874, name = "Fishman Captain",     island = "Floating Turtle",    sea = 3},
    {min = 1875, max = 1924, name = "Forest Pirate",       island = "Floating Turtle",    sea = 3},
    {min = 1925, max = 1974, name = "Mythological Pirate", island = "Floating Turtle",    sea = 3},
    {min = 1975, max = 1999, name = "Jungle Pirate",       island = "Floating Turtle",    sea = 3},
    {min = 2000, max = 2074, name = "Musketeer Pirate",    island = "Floating Turtle",    sea = 3},
    {min = 2075, max = 2099, name = "Reborn Skeleton",     island = "Haunted Castle",     sea = 3},
    {min = 2100, max = 2124, name = "Living Zombie",       island = "Haunted Castle",     sea = 3},
    {min = 2125, max = 2174, name = "Demonic Soul",        island = "Haunted Castle",     sea = 3},
    {min = 2175, max = 2199, name = "Posessed Mummy",      island = "Haunted Castle",     sea = 3},
    {min = 2200, max = 2249, name = "Peanut Scout",        island = "Haunted Castle",     sea = 3},
    {min = 2250, max = 2299, name = "Ice Cream Chef",      island = "Haunted Castle",     sea = 3},
    {min = 2300, max = 2324, name = "Cookie Crafter",      island = "Haunted Castle",     sea = 3},
    {min = 2325, max = 2349, name = "Cake Guard",          island = "Haunted Castle",     sea = 3},
    {min = 2350, max = 2374, name = "Baby Cyborg",         island = "Haunted Castle",     sea = 3},
    {min = 2375, max = 2399, name = "Cyborg Soldier",      island = "Haunted Castle",     sea = 3},
    {min = 2400, max = 2450, name = "Cyborg Officer",      island = "Haunted Castle",     sea = 3},
}

StarterGui:SetCore("SendNotification", {
    Title = "🔥 BFF v15.0 - FINAL";
    Text = "All Worlds - Level 1 → 2450!";
    Duration = 5;
})

print("╔═══════════════════════════════════╗")
print("║  🔥 BFF v15.0 - ALL WORLDS      ║")
print("║  Level 1 → 2450 (Sea 1,2,3)     ║")
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
    local currentSea = getCurrentSea()
    
    for _, e in ipairs(ENEMIES) do
        if lvl >= e.min and lvl <= e.max then
            return e.name, e.island, e.sea
        end
    end
    return "Bandit", "Jungle", 1
end

-- ═══════════════════════════════════════
-- 🚢 الانتقال بين البحار
-- ═══════════════════════════════════════
local function travelToSea(targetSea)
    local currentSea = getCurrentSea()
    if currentSea == targetSea then return end
    
    print("🚢 [BFF] الانتقال إلى Sea " .. targetSea)
    StarterGui:SetCore("SendNotification", {
        Title = "🚢 Traveling";
        Text = "Sea " .. currentSea .. " → Sea " .. targetSea;
        Duration = 5;
    })
    
    pcall(function()
        -- استخدام Remote للانتقال
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local commF = remotes:FindFirstChild("CommF_")
            if commF then
                if targetSea == 2 then
                    commF:InvokeServer("TravelDressrosa")
                elseif targetSea == 3 then
                    commF:InvokeServer("TravelZou")
                elseif targetSea == 1 then
                    commF:InvokeServer("TravelMain")
                end
            end
        end
    end)
    
    wait(5)
end

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
-- 💥 COOLDOWN BYPASS
-- ═══════════════════════════════════════
spawn(function()
    while wait(0.05) do
        pcall(function()
            for _, v in pairs(getgc(true)) do
                if type(v) == "table" then
                    if rawget(v, "activeController") and v.activeController then
                        v.activeController.AttackCooldown = 0
                        v.activeController.hitboxMagnitude = 100
                        v.activeController.timeToNextAttack = 0
                    end
                    if rawget(v, "AttackCooldown") then v.AttackCooldown = 0 end
                    if rawget(v, "timeToNextAttack") then v.timeToNextAttack = 0 end
                end
            end
        end)
    end
end)

-- ═══════════════════════════════════════
-- 💥 CAMERA + MOUSE HOOK
-- ═══════════════════════════════════════
local currentTarget = nil

spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        pcall(function()
            if currentTarget and currentTarget.Parent then
                local eHRP = currentTarget:FindFirstChild("HumanoidRootPart")
                if eHRP then
                    Camera.CFrame = CFrame.new(
                        eHRP.Position + Vector3.new(0, 15, 10),
                        eHRP.Position
                    )
                    Mouse.Hit = eHRP.CFrame
                    Mouse.Target = eHRP
                end
            end
        end)
        RunService.RenderStepped:Wait()
    end
end)

-- ═══════════════════════════════════════
-- 💥 ULTRA M1 SPAMMER
-- ═══════════════════════════════════════
local clickActive = false

local function startUltraM1()
    if clickActive then return end
    clickActive = true
    
    spawn(function()
        while clickActive and getgenv().BFF_FARM_ACTIVE do
            pcall(function()
                local vs = Camera.ViewportSize
                VIM:SendMouseButtonEvent(vs.X/2, vs.Y/2, 0, true, game, 0)
                VIM:SendMouseButtonEvent(vs.X/2, vs.Y/2, 0, false, game, 0)
            end)
            wait(ATTACK_SPEED)
        end
    end)
    
    spawn(function()
        while clickActive and getgenv().BFF_FARM_ACTIVE do
            pcall(function()
                local tool = getEquippedTool()
                if tool then tool:Activate() end
            end)
            wait(ATTACK_SPEED)
        end
    end)
    
    spawn(function()
        while clickActive and getgenv().BFF_FARM_ACTIVE do
            pcall(function()
                for _, v in pairs(getgc(true)) do
                    if type(v) == "table" and rawget(v, "attack") 
                       and rawget(v, "activeController") then
                        if v.activeController and v.activeController.attack then
                            v.activeController:attack()
                        end
                    end
                end
            end)
            wait(ATTACK_SPEED)
        end
    end)
end

local function stopUltraM1()
    clickActive = false
end

-- ═══════════════════════════════════════
-- 🎬 Animation Speed
-- ═══════════════════════════════════════
spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        pcall(function()
            local hum = getHumanoid()
            if hum then
                for _, track in pairs(hum:GetPlayingAnimationTracks()) do
                    local n = track.Name:lower()
                    if n:find("attack") or n:find("combat") or n:find("punch") 
                       or n:find("slash") or n:find("hit") or n:find("swing") then
                        track:AdjustSpeed(5)
                    end
                end
            end
        end)
        wait(0.05)
    end
end)

-- ═══════════════════════════════════════
-- 🚶 حركة داخل الجزيرة (لتحفيز الـ Spawn)
-- ═══════════════════════════════════════
local function wanderInIsland(islandPos)
    local hrp = getHRP()
    if not hrp then return end
    
    print("🚶 [BFF] البحث داخل الجزيرة...")
    
    -- تحرك في 4 اتجاهات لتحفيز الـ Spawn
    local directions = {
        Vector3.new(SPAWN_MOVE_RADIUS, 0, 0),
        Vector3.new(-SPAWN_MOVE_RADIUS, 0, 0),
        Vector3.new(0, 0, SPAWN_MOVE_RADIUS),
        Vector3.new(0, 0, -SPAWN_MOVE_RADIUS),
    }
    
    for _, dir in ipairs(directions) do
        pcall(function()
            hrp.CFrame = islandPos + dir + Vector3.new(0, 20, 0)
        end)
        wait(1.5) -- انتظر spawn
        
        -- تحقق من الأعداء
        local targetName = select(1, getTarget())
        if findEnemy(targetName) then
            print("✅ [BFF] لقيت أعداء!")
            return true
        end
    end
    
    return false
end

-- ═══════════════════════════════════════
-- Anti-Death
-- ═══════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function()
    stopUltraM1()
    currentTarget = nil
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
                stopUltraM1()
                currentTarget = nil
                wait(2)
                return
            end
            
            local tool = equipWeapon()
            if not tool then wait(2); return end
            
            local targetName, islandName, requiredSea = getTarget()
            local currentSea = getCurrentSea()
            
            -- ═══ الانتقال للبحر الصحيح ═══
            if currentSea ~= requiredSea then
                stopUltraM1()
                currentTarget = nil
                travelToSea(requiredSea)
                return
            end
            
            local enemy = findEnemy(targetName)
            
            if not enemy then
                stopUltraM1()
                currentTarget = nil
                
                local islandCF = ISLANDS[islandName]
                if islandCF then
                    local dist = (hrp.Position - islandCF.Position).Magnitude
                    
                    if dist > 500 then
                        -- الطيران للجزيرة
                        print("✈️ [BFF] Teleport → " .. islandName .. " | Target: " .. targetName)
                        hrp.CFrame = islandCF + Vector3.new(0, 20, 0)
                        wait(2)
                    else
                        -- داخل الجزيرة، تحرك لتحفيز spawn
                        wanderInIsland(islandCF)
                    end
                end
                return
            end
            
            print("⚔️ [BFF] " .. targetName .. " | Lvl: " .. getLevel() .. " | Sea " .. currentSea)
            
            local eHRP = enemy:FindFirstChild("HumanoidRootPart")
            local eHum = enemy:FindFirstChildOfClass("Humanoid")
            if not eHRP or not eHum then return end
            
            currentTarget = enemy
            startUltraM1()
            
            local killStart = tick()
            
            local positionConnection
            positionConnection = RunService.Heartbeat:Connect(function()
                if not (enemy and enemy.Parent and eHum and eHum.Health > 0 
                        and getgenv().BFF_FARM_ACTIVE and eHRP.Parent) then
                    if positionConnection then positionConnection:Disconnect() end
                    return
                end
                
                if (tick() - killStart) > 15 then
                    if positionConnection then positionConnection:Disconnect() end
                    return
                end
                
                pcall(function()
                    hrp.CFrame = eHRP.CFrame * CFrame.new(0, UNDERGROUND_OFFSET, 0)
                end)
            end)
            
            while enemy and enemy.Parent and eHum and eHum.Health > 0 
                  and getgenv().BFF_FARM_ACTIVE do
                if (tick() - killStart) > 15 then break end
                wait(0.1)
            end
            
            if positionConnection then positionConnection:Disconnect() end
            stopUltraM1()
            currentTarget = nil
            print("💀 [BFF] Killed: " .. targetName)
        end)
        
        if not success then
            warn("⚠️ [BFF] " .. tostring(err))
        end
        
        wait(0.2)
    end
end)

print("✅ [BFF v15.0] ALL WORLDS READY!")

StarterGui:SetCore("SendNotification", {
    Title = "✅ BFF v15.0";
    Text = "Level 1 → 2450 | Sea 1,2,3";
    Duration = 5;
})
