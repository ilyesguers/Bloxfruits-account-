--[[
    ══════════════════════════════════════════════════════════════
    🔥 BFF FARM v17.0 - QUEST + SPEED + MOVEMENT FIX 🔥
    ══════════════════════════════════════════════════════════════
    
    ✅ نظام Quest كامل (يأخذ المهمة تلقائياً)
    ✅ يرجع للعدو بعد كل قتل
    ✅ سرعة ضربات محسّنة (مش ثقيلة)
    ✅ يتحقق من الليفل المسموح للمهمة
    ✅ حركة مستمرة (لا يتوقف أبداً)
    ✅ iPhone 13 محسّن
    
    ══════════════════════════════════════════════════════════════
]]

-- ═══════════════════════════════════════════════════════════
-- 🛡️ حماية
-- ═══════════════════════════════════════════════════════════
if getgenv().BFF_FARM_ACTIVE then
    warn("⚠️ [FARM] شغال بالفعل!")
    return
end
getgenv().BFF_FARM_ACTIVE = true

-- ═══════════════════════════════════════════════════════════
-- 📦 الخدمات
-- ═══════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local VIM = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════
-- ⚙️ إعدادات
-- ═══════════════════════════════════════════════════════════
local CONFIG = {
    UNDERGROUND_OFFSET    = -5,
    ATTACK_SPEED          = 0.1,        -- أبطأ قليلاً = أخف على iPhone
    KILL_TIMEOUT          = 25,
    SPAWN_MOVE_RADIUS     = 100,
    TELEPORT_HEIGHT       = 25,
    SEARCH_WAIT           = 2,
    GC_BYPASS_INTERVAL    = 0.2,
    ANIMATION_SPEED       = 3,
    SEA_TRAVEL_WAIT       = 8,
    QUEST_DISTANCE        = 50,         -- مسافة أخذ Quest من NPC
    LOOP_DELAY            = 0.3,        -- تأخير بين كل دورة
}

-- ═══════════════════════════════════════════════════════════
-- 📢 نظام التسجيل
-- ═══════════════════════════════════════════════════════════
local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Farm",
            Text = text or "",
            Duration = duration or 5,
        })
    end)
end

local function log(msg)
    print("[" .. os.date("%H:%M:%S") .. "] ⚔️ FARM | " .. msg)
end

-- ═══════════════════════════════════════════════════════════
-- 🌊 البحر الحالي
-- ═══════════════════════════════════════════════════════════
local SEA_IDS = {
    [2753915549] = 1,
    [4442272183] = 2,
    [7449423635] = 3,
}

local function getCurrentSea()
    return SEA_IDS[game.PlaceId] or 1
end

-- ═══════════════════════════════════════════════════════════
-- 🗺️ إحداثيات الجزر (Update 24)
-- ═══════════════════════════════════════════════════════════
local ISLANDS = {
    -- Sea 1
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
    -- Sea 2
    ["Kingdom of Rose"]    = CFrame.new(-427, 72, 1836),
    ["Green Zone"]         = CFrame.new(-2842, 100, 5320),
    ["Graveyard"]          = CFrame.new(-5390, 46, -793),
    ["Snow Mountain"]      = CFrame.new(597, 401, -5371),
    ["Hot and Cold"]       = CFrame.new(-5686, 8, -5254),
    ["Cursed Ship"]        = CFrame.new(923, 125, 32844),
    ["Ice Castle"]         = CFrame.new(6148, 294, -6741),
    ["Forgotten Island"]   = CFrame.new(-3055, 250, -10147),
    -- Sea 3
    ["Port Town"]          = CFrame.new(-291, 44, 5580),
    ["Hydra Island"]       = CFrame.new(5228, 604, 345),
    ["Great Tree"]         = CFrame.new(2192, 28, -6960),
    ["Castle on Sea"]      = CFrame.new(-5087, 315, -3153),
    ["Floating Turtle"]    = CFrame.new(-13232, 332, -7626),
    ["Haunted Castle"]     = CFrame.new(-9515, 142, 5548),
    ["Tiki Outpost"]       = CFrame.new(-12038, 332, -8412),
    ["Mansion"]            = CFrame.new(-12568, 332, -7536),
}

-- ═══════════════════════════════════════════════════════════
-- 👹 قاعدة بيانات الأعداء + NPCs الـ Quest
-- ═══════════════════════════════════════════════════════════
--[[
    questNPC = اسم NPC الذي يعطيك المهمة
    questId  = رقم المهمة المستخدم في Remote
    
    ⚠️ مهم: اللاعب يجب أن يكون في نطاق الليفل المسموح
    مثال: Gorilla Quest يتطلب Level 15+
    السكربت القديم كان يرسل لـ Gorilla وهو Level 10 = لا تظهر المهمة
]]

local ENEMIES = {
    -- ══ SEA 1 ══
    {min = 1,    max = 9,    name = "Bandit",               island = "Jungle",           sea = 1, questId = 1},
    {min = 10,   max = 14,   name = "Monkey",               island = "Jungle",           sea = 1, questId = 2},
    {min = 15,   max = 29,   name = "Gorilla",              island = "Jungle",           sea = 1, questId = 3},
    {min = 30,   max = 39,   name = "Pirate",               island = "Pirate Village",   sea = 1, questId = 4},
    {min = 40,   max = 59,   name = "Brute",                island = "Pirate Village",   sea = 1, questId = 5},
    {min = 60,   max = 74,   name = "Desert Bandit",        island = "Desert",           sea = 1, questId = 6},
    {min = 75,   max = 89,   name = "Desert Officer",       island = "Desert",           sea = 1, questId = 7},
    {min = 90,   max = 104,  name = "Snow Bandit",          island = "Frozen Village",   sea = 1, questId = 8},
    {min = 105,  max = 119,  name = "Snowman",              island = "Frozen Village",   sea = 1, questId = 9},
    {min = 120,  max = 149,  name = "Chief Petty Officer",  island = "Marine Fortress",  sea = 1, questId = 10},
    {min = 150,  max = 174,  name = "Sky Bandit",           island = "Sky Island",       sea = 1, questId = 11},
    {min = 175,  max = 189,  name = "Dark Master",          island = "Sky Island",       sea = 1, questId = 12},
    {min = 190,  max = 209,  name = "Prisoner",             island = "Prison",           sea = 1, questId = 13},
    {min = 210,  max = 249,  name = "Dangerous Prisoner",   island = "Prison",           sea = 1, questId = 14},
    {min = 250,  max = 274,  name = "Toga Warrior",         island = "Colosseum",        sea = 1, questId = 15},
    {min = 275,  max = 299,  name = "Gladiator",            island = "Colosseum",        sea = 1, questId = 16},
    {min = 300,  max = 324,  name = "Military Soldier",     island = "Magma Village",    sea = 1, questId = 17},
    {min = 325,  max = 374,  name = "Military Spy",         island = "Magma Village",    sea = 1, questId = 18},
    {min = 375,  max = 399,  name = "Fishman Warrior",      island = "Underwater City",  sea = 1, questId = 19},
    {min = 400,  max = 449,  name = "Fishman Commando",     island = "Underwater City",  sea = 1, questId = 20},
    {min = 450,  max = 474,  name = "God's Guard",          island = "Upper Skylands",   sea = 1, questId = 21},
    {min = 475,  max = 524,  name = "Shanda",               island = "Upper Skylands",   sea = 1, questId = 22},
    {min = 525,  max = 549,  name = "Royal Squad",          island = "Fountain City",    sea = 1, questId = 23},
    {min = 550,  max = 624,  name = "Royal Soldier",        island = "Fountain City",    sea = 1, questId = 24},
    {min = 625,  max = 699,  name = "Galley Pirate",        island = "Fountain City",    sea = 1, questId = 25},
    
    -- ══ SEA 2 ══
    {min = 700,  max = 774,  name = "Raider",               island = "Kingdom of Rose",  sea = 2, questId = 1},
    {min = 775,  max = 824,  name = "Mercenary",            island = "Kingdom of Rose",  sea = 2, questId = 2},
    {min = 825,  max = 874,  name = "Swan Pirate",          island = "Green Zone",       sea = 2, questId = 3},
    {min = 875,  max = 924,  name = "Factory Staff",        island = "Green Zone",       sea = 2, questId = 4},
    {min = 925,  max = 949,  name = "Marine Lieutenant",    island = "Graveyard",        sea = 2, questId = 5},
    {min = 950,  max = 974,  name = "Marine Captain",       island = "Graveyard",        sea = 2, questId = 6},
    {min = 975,  max = 999,  name = "Zombie",               island = "Graveyard",        sea = 2, questId = 7},
    {min = 1000, max = 1049, name = "Vampire",              island = "Graveyard",        sea = 2, questId = 8},
    {min = 1050, max = 1099, name = "Snow Trooper",         island = "Snow Mountain",    sea = 2, questId = 9},
    {min = 1100, max = 1124, name = "Winter Warrior",       island = "Snow Mountain",    sea = 2, questId = 10},
    {min = 1125, max = 1174, name = "Lab Subordinate",      island = "Hot and Cold",     sea = 2, questId = 11},
    {min = 1175, max = 1199, name = "Horned Warrior",       island = "Hot and Cold",     sea = 2, questId = 12},
    {min = 1200, max = 1249, name = "Magma Ninja",          island = "Hot and Cold",     sea = 2, questId = 13},
    {min = 1250, max = 1299, name = "Cursed Pirate",        island = "Cursed Ship",      sea = 2, questId = 14},
    {min = 1300, max = 1349, name = "Ice Viking",           island = "Ice Castle",       sea = 2, questId = 15},
    {min = 1350, max = 1424, name = "Marine Commodore",     island = "Forgotten Island", sea = 2, questId = 16},
    {min = 1425, max = 1499, name = "Reborn Skeleton",      island = "Forgotten Island", sea = 2, questId = 17},
    
    -- ══ SEA 3 ══
    {min = 1500, max = 1524, name = "Pirate Millionaire",   island = "Port Town",        sea = 3, questId = 1},
    {min = 1525, max = 1574, name = "Pistol Billionaire",   island = "Port Town",        sea = 3, questId = 2},
    {min = 1575, max = 1624, name = "Dragon Crew Warrior",  island = "Hydra Island",     sea = 3, questId = 3},
    {min = 1625, max = 1649, name = "Dragon Crew Archer",   island = "Hydra Island",     sea = 3, questId = 4},
    {min = 1650, max = 1699, name = "Female Islander",      island = "Great Tree",       sea = 3, questId = 5},
    {min = 1700, max = 1749, name = "Giant Islander",       island = "Great Tree",       sea = 3, questId = 6},
    {min = 1750, max = 1799, name = "Marine Commodore",     island = "Castle on Sea",    sea = 3, questId = 7},
    {min = 1800, max = 1849, name = "Marine Rear Admiral",  island = "Castle on Sea",    sea = 3, questId = 8},
    {min = 1850, max = 1899, name = "Fishman Raider",       island = "Floating Turtle",  sea = 3, questId = 9},
    {min = 1900, max = 1949, name = "Fishman Captain",      island = "Floating Turtle",  sea = 3, questId = 10},
    {min = 1950, max = 1999, name = "Forest Pirate",        island = "Floating Turtle",  sea = 3, questId = 11},
    {min = 2000, max = 2074, name = "Mythological Pirate",  island = "Floating Turtle",  sea = 3, questId = 12},
    {min = 2075, max = 2099, name = "Jungle Pirate",        island = "Floating Turtle",  sea = 3, questId = 13},
    {min = 2100, max = 2149, name = "Musketeer Pirate",     island = "Floating Turtle",  sea = 3, questId = 14},
    {min = 2150, max = 2199, name = "Reborn Skeleton",      island = "Haunted Castle",   sea = 3, questId = 15},
    {min = 2200, max = 2249, name = "Living Zombie",        island = "Haunted Castle",   sea = 3, questId = 16},
    {min = 2250, max = 2299, name = "Demonic Soul",         island = "Haunted Castle",   sea = 3, questId = 17},
    {min = 2300, max = 2349, name = "Posessed Mummy",       island = "Haunted Castle",   sea = 3, questId = 18},
    {min = 2350, max = 2399, name = "Peanut Scout",         island = "Tiki Outpost",     sea = 3, questId = 19},
    {min = 2400, max = 2449, name = "Peanut President",     island = "Tiki Outpost",     sea = 3, questId = 20},
    {min = 2450, max = 2499, name = "Ice Cream Chef",       island = "Mansion",          sea = 3, questId = 21},
    {min = 2500, max = 2550, name = "Cookie Crafter",       island = "Mansion",          sea = 3, questId = 22},
}

-- ═══════════════════════════════════════════════════════════
-- 🔧 دوال أساسية
-- ═══════════════════════════════════════════════════════════
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

local function isAlive()
    local hum = getHumanoid()
    local hrp = getHRP()
    return hum and hrp and hum.Health > 0 and hrp.Parent
end

local function getLevel()
    local lvl = 1
    pcall(function()
        lvl = LocalPlayer.Data.Level.Value
    end)
    return lvl
end

local function getRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not remotes then return nil end
    return remotes:FindFirstChild("CommF_")
end

-- ═══════════════════════════════════════════════════════════
-- 🎯 اختيار العدو المناسب
-- ═══════════════════════════════════════════════════════════
local function getTargetInfo()
    local level = getLevel()
    for _, e in ipairs(ENEMIES) do
        if level >= e.min and level <= e.max then
            return e
        end
    end
    return ENEMIES[#ENEMIES]
end

-- ═══════════════════════════════════════════════════════════
-- 📜 نظام Quest الكامل
-- ═══════════════════════════════════════════════════════════
local questActive = false
local questTarget = nil
local questKillsNeeded = 0
local questKillsDone = 0

local function hasActiveQuest()
    local has = false
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return end
        
        local main = playerGui:FindFirstChild("Main")
        if not main then return end
        
        for _, obj in pairs(main:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Visible then
                local text = obj.Text or ""
                if text:find("Defeat") or text:find("defeat") 
                   or text:find("Kill") or text:find("kill")
                   or text:find("Quest") then
                    has = true
                end
            end
        end
    end)
    return has
end

local function getQuest(targetInfo)
    local commF = getRemote()
    if not commF then
        log("❌ لا يوجد Remote للـ Quest!")
        return false
    end
    
    log("📜 محاولة أخذ Quest لـ " .. targetInfo.name .. " (Quest ID: " .. targetInfo.questId .. ")")
    
    local success = false
    
    -- الطريقة 1: StartQuest مع questId
    pcall(function()
        local result = commF:InvokeServer("StartQuest", targetInfo.questId, 1)
        if result then
            success = true
            log("✅ Quest accepted via StartQuest(" .. targetInfo.questId .. ")")
        end
    end)
    
    if success then return true end
    
    -- الطريقة 2: StartQuest مع اسم العدو
    pcall(function()
        local result = commF:InvokeServer("StartQuest", targetInfo.name, 1)
        if result then
            success = true
            log("✅ Quest accepted via StartQuest('" .. targetInfo.name .. "')")
        end
    end)
    
    if success then return true end
    
    -- الطريقة 3: AcceptQuest
    pcall(function()
        commF:InvokeServer("AcceptQuest", targetInfo.questId)
        success = true
    end)
    
    if success then return true end
    
    -- الطريقة 4: Quest مع اسم NPC
    pcall(function()
        commF:InvokeServer("Quest", targetInfo.questId)
        success = true
    end)
    
    -- الطريقة 5: البحث عن NPC القريب والتفاعل معه
    if not success then
        pcall(function()
            for _, npc in pairs(Workspace:GetDescendants()) do
                if npc:IsA("Model") then
                    local nameMatch = false
                    
                    -- ابحث عن NPC باسم يحتوي على اسم العدو أو "Quest"
                    local npcName = npc.Name:lower()
                    local targetNameLower = targetInfo.name:lower()
                    
                    if npcName:find("quest") then
                        -- تحقق من الأطفال للعثور على الاسم
                        for _, child in pairs(npc:GetDescendants()) do
                            if child:IsA("TextLabel") or child:IsA("BillboardGui") then
                                pcall(function()
                                    if child.Text and child.Text:lower():find(targetNameLower:sub(1, 6)) then
                                        nameMatch = true
                                    end
                                end)
                            end
                        end
                    end
                    
                    -- تحقق مباشرة من الاسم
                    if npcName:find(targetNameLower:sub(1, 6)) and npcName:find("quest") then
                        nameMatch = true
                    end
                    
                    if nameMatch then
                        local npcPart = npc:FindFirstChild("HumanoidRootPart") 
                                       or npc:FindFirstChild("Head")
                                       or npc:FindFirstChildWhichIsA("BasePart")
                        if npcPart then
                            local hrp = getHRP()
                            if hrp then
                                -- اقترب من NPC
                                hrp.CFrame = npcPart.CFrame * CFrame.new(0, 0, 3)
                                task.wait(0.5)
                                
                                -- تفاعل
                                pcall(function()
                                    local cd = npc:FindFirstChildOfClass("ClickDetector")
                                    if cd then fireclickdetector(cd) end
                                end)
                                pcall(function()
                                    local pp = npc:FindFirstChildOfClass("ProximityPrompt")
                                    if pp then fireproximityprompt(pp) end
                                end)
                                
                                task.wait(1)
                                success = true
                                log("✅ تفاعلت مع NPC: " .. npc.Name)
                            end
                        end
                    end
                end
            end
        end)
    end
    
    return success
end

-- ═══════════════════════════════════════════════════════════
-- 🗡️ تجهيز السلاح
-- ═══════════════════════════════════════════════════════════
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
    
    -- أولوية الأسلحة
    local priority = {
        "Superhuman", "Death Step", "Electric Claw", "Dragon Talon",
        "Sharkman Karate", "Dragon Claw", "Fishman Karate",
        "Electro", "Black Leg", "Combat",
        "Cursed Dual Katana", "Yama", "Tushita",
        "True Triple Katana", "Pole v2", "Saber",
        "Katana", "Cutlass",
    }
    
    for _, weaponName in ipairs(priority) do
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item.Name == weaponName then
                local hum = getHumanoid()
                if hum then
                    hum:EquipTool(item)
                    task.wait(0.3)
                    return item
                end
            end
        end
    end
    
    -- أي سلاح
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            local hum = getHumanoid()
            if hum then
                hum:EquipTool(item)
                task.wait(0.3)
                return item
            end
        end
    end
    
    return nil
end

-- ═══════════════════════════════════════════════════════════
-- 🔍 البحث عن الأعداء
-- ═══════════════════════════════════════════════════════════
local function findEnemy(targetName)
    local hrp = getHRP()
    if not hrp then return nil, math.huge end
    
    local nearest = nil
    local nearestDist = math.huge
    
    local folder = Workspace:FindFirstChild("Enemies")
    if not folder then return nil, math.huge end
    
    for _, enemy in pairs(folder:GetChildren()) do
        if enemy.Name == targetName then
            local eHum = enemy:FindFirstChildOfClass("Humanoid")
            local eHRP = enemy:FindFirstChild("HumanoidRootPart")
            if eHum and eHRP and eHum.Health > 0 and eHRP.Parent then
                local dist = (hrp.Position - eHRP.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = enemy
                end
            end
        end
    end
    
    return nearest, nearestDist
end

-- ═══════════════════════════════════════════════════════════
-- 🚢 انتقال بين البحار
-- ═══════════════════════════════════════════════════════════
local function travelToSea(targetSea)
    if getCurrentSea() == targetSea then return true end
    
    log("🚢 انتقال إلى Sea " .. targetSea)
    notify("🚢 Traveling", "Sea " .. getCurrentSea() .. " → Sea " .. targetSea, 5)
    
    local commF = getRemote()
    if not commF then return false end
    
    local commands = {
        [1] = "TravelMain",
        [2] = "TravelDressrosa",
        [3] = "TravelZou",
    }
    
    pcall(function()
        commF:InvokeServer(commands[targetSea])
    end)
    
    task.wait(CONFIG.SEA_TRAVEL_WAIT)
    return true
end

-- ═══════════════════════════════════════════════════════════
-- 💥 نظام الهجوم (محسّن - أخف على iPhone)
-- ═══════════════════════════════════════════════════════════
local attackActive = false
local currentTarget = nil

local function startAttack()
    if attackActive then return end
    attackActive = true
    
    -- Thread 1: Mouse Click
    spawn(function()
        while attackActive and getgenv().BFF_FARM_ACTIVE do
            pcall(function()
                local vs = Camera.ViewportSize
                VIM:SendMouseButtonEvent(vs.X/2, vs.Y/2, 0, true, game, 0)
                task.wait(0.03)
                VIM:SendMouseButtonEvent(vs.X/2, vs.Y/2, 0, false, game, 0)
            end)
            task.wait(CONFIG.ATTACK_SPEED)
        end
    end)
    
    -- Thread 2: Tool Activate
    spawn(function()
        while attackActive and getgenv().BFF_FARM_ACTIVE do
            pcall(function()
                local tool = getEquippedTool()
                if tool then tool:Activate() end
            end)
            task.wait(CONFIG.ATTACK_SPEED)
        end
    end)
end

local function stopAttack()
    attackActive = false
end

-- ═══════════════════════════════════════════════════════════
-- 🎬 تسريع الأنيميشن
-- ═══════════════════════════════════════════════════════════
spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        pcall(function()
            local hum = getHumanoid()
            if hum then
                for _, track in pairs(hum:GetPlayingAnimationTracks()) do
                    local n = track.Name:lower()
                    if n:find("attack") or n:find("combat") or n:find("punch") 
                       or n:find("slash") or n:find("hit") or n:find("swing") then
                        track:AdjustSpeed(CONFIG.ANIMATION_SPEED)
                    end
                end
            end
        end)
        task.wait(0.15)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 💥 Cooldown Bypass (محسّن)
-- ═══════════════════════════════════════════════════════════
spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        pcall(function()
            if typeof(getgc) == "function" then
                for _, v in pairs(getgc(true)) do
                    if type(v) == "table" then
                        pcall(function()
                            if rawget(v, "AttackCooldown") then v.AttackCooldown = 0 end
                            if rawget(v, "timeToNextAttack") then v.timeToNextAttack = 0 end
                        end)
                    end
                end
            end
        end)
        task.wait(CONFIG.GC_BYPASS_INTERVAL)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 📷 توجيه الكاميرا
-- ═══════════════════════════════════════════════════════════
spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        pcall(function()
            if currentTarget and currentTarget.Parent then
                local eHRP = currentTarget:FindFirstChild("HumanoidRootPart")
                if eHRP and eHRP.Parent then
                    Camera.CFrame = CFrame.new(
                        eHRP.Position + Vector3.new(0, 12, 8),
                        eHRP.Position
                    )
                end
            end
        end)
        RunService.RenderStepped:Wait()
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🚶 حركة داخل الجزيرة
-- ═══════════════════════════════════════════════════════════
local function wanderInIsland(islandCF, targetName)
    local hrp = getHRP()
    if not hrp then return false end
    
    log("🚶 بحث داخل الجزيرة عن " .. targetName)
    
    local r = CONFIG.SPAWN_MOVE_RADIUS
    local dirs = {
        Vector3.new(r, 0, 0),     Vector3.new(-r, 0, 0),
        Vector3.new(0, 0, r),     Vector3.new(0, 0, -r),
        Vector3.new(r*0.7, 0, r*0.7),   Vector3.new(-r*0.7, 0, r*0.7),
        Vector3.new(r*0.7, 0, -r*0.7),  Vector3.new(-r*0.7, 0, -r*0.7),
    }
    
    for _, dir in ipairs(dirs) do
        if not getgenv().BFF_FARM_ACTIVE then return false end
        
        pcall(function()
            hrp.CFrame = CFrame.new(islandCF.Position + dir + Vector3.new(0, CONFIG.TELEPORT_HEIGHT, 0))
        end)
        
        task.wait(CONFIG.SEARCH_WAIT)
        
        local enemy = findEnemy(targetName)
        if enemy then
            log("✅ وجدت " .. targetName .. " بعد التحرك!")
            return true
        end
    end
    
    return false
end

-- ═══════════════════════════════════════════════════════════
-- 🔄 Anti-Death
-- ═══════════════════════════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function(newChar)
    stopAttack()
    currentTarget = nil
    log("🔄 Respawning...")
    newChar:WaitForChild("Humanoid", 30)
    newChar:WaitForChild("HumanoidRootPart", 30)
    task.wait(3)
    log("✅ Respawned!")
end)

-- ═══════════════════════════════════════════════════════════
-- 📊 إحصائيات
-- ═══════════════════════════════════════════════════════════
local stats = {
    kills = 0,
    startLevel = getLevel(),
    startTime = tick(),
    quests = 0,
}

spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        task.wait(300)
        local elapsed = math.floor((tick() - stats.startTime) / 60)
        local gained = getLevel() - stats.startLevel
        log(string.format("📊 Kills: %d | +%d Levels | %dm | Quests: %d", 
            stats.kills, gained, elapsed, stats.quests))
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🎯 الحلقة الرئيسية
-- ═══════════════════════════════════════════════════════════
notify("🔥 Farm v17.0", "Quest + Speed + Level " .. getLevel(), 5)

log("🎯 بدء الحلقة الرئيسية...")
log("⭐ Level: " .. getLevel() .. " | Sea: " .. getCurrentSea())

spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        local ok, err = pcall(function()
            
            -- 1. تحقق من الحياة
            if not isAlive() then
                stopAttack()
                currentTarget = nil
                task.wait(3)
                return
            end
            
            local hrp = getHRP()
            if not hrp then task.wait(2); return end
            
            -- 2. تجهيز السلاح
            local weapon = equipWeapon()
            if not weapon then
                log("⚠️ لا سلاح!")
                task.wait(3)
                return
            end
            
            -- 3. معلومات العدو
            local target = getTargetInfo()
            local currentSea = getCurrentSea()
            
            -- 4. الانتقال للبحر الصحيح
            if currentSea ~= target.sea then
                stopAttack()
                currentTarget = nil
                travelToSea(target.sea)
                return
            end
            
            -- 5. ابحث عن العدو
            local enemy, dist = findEnemy(target.name)
            
            -- 6. ما فيه عدو → روح الجزيرة + Quest
            if not enemy then
                stopAttack()
                currentTarget = nil
                
                local islandCF = ISLANDS[target.island]
                if not islandCF then
                    log("❌ جزيرة مجهولة: " .. target.island)
                    task.wait(5)
                    return
                end
                
                local distToIsland = (hrp.Position - islandCF.Position).Magnitude
                
                if distToIsland > 500 then
                    -- Teleport للجزيرة
                    log("✈️ Teleport → " .. target.island .. " | " .. target.name .. " | Lv." .. getLevel())
                    pcall(function()
                        hrp.CFrame = islandCF + Vector3.new(0, CONFIG.TELEPORT_HEIGHT, 0)
                    end)
                    task.wait(3)
                    
                    -- أخذ Quest بعد الوصول
                    if not hasActiveQuest() then
                        log("📜 أخذ Quest...")
                        getQuest(target)
                        stats.quests = stats.quests + 1
                        task.wait(1)
                    end
                else
                    -- قريب من الجزيرة → تحرك لتحفيز spawn
                    
                    -- أولاً حاول أخذ Quest
                    if not hasActiveQuest() then
                        getQuest(target)
                        stats.quests = stats.quests + 1
                        task.wait(1)
                    end
                    
                    wanderInIsland(islandCF, target.name)
                end
                return
            end
            
            -- 7. وجدنا العدو → هاجم!
            local eHRP = enemy:FindFirstChild("HumanoidRootPart")
            local eHum = enemy:FindFirstChildOfClass("Humanoid")
            if not eHRP or not eHum then task.wait(0.5); return end
            
            log(string.format("⚔️ %s | HP:%d | Lv.%d | Sea %d",
                target.name, math.floor(eHum.Health), getLevel(), currentSea))
            
            currentTarget = enemy
            startAttack()
            
            local killStart = tick()
            
            -- 8. التصق بالعدو تحت الأرض
            local conn = RunService.Heartbeat:Connect(function()
                if not (enemy and enemy.Parent and eHum and eHum.Health > 0 
                        and getgenv().BFF_FARM_ACTIVE and eHRP and eHRP.Parent) then
                    return
                end
                if (tick() - killStart) > CONFIG.KILL_TIMEOUT then return end
                
                pcall(function()
                    local myHRP = getHRP()
                    if myHRP then
                        myHRP.CFrame = eHRP.CFrame * CFrame.new(0, CONFIG.UNDERGROUND_OFFSET, 0)
                    end
                end)
            end)
            
            -- 9. انتظر الموت
            while enemy and enemy.Parent and eHum and eHum.Health > 0 
                  and getgenv().BFF_FARM_ACTIVE do
                if (tick() - killStart) > CONFIG.KILL_TIMEOUT then
                    log("⏰ Timeout!")
                    break
                end
                task.wait(0.15)
            end
            
            -- 10. تنظيف
            if conn then conn:Disconnect() end
            stopAttack()
            currentTarget = nil
            
            if not enemy or not enemy.Parent or (eHum and eHum.Health <= 0) then
                stats.kills = stats.kills + 1
                log("💀 " .. target.name .. " | Total: " .. stats.kills)
                
                -- ═══ مهم: بعد القتل، تحقق من Quest ═══
                -- إذا Quest خلص → أخذ Quest جديد فوراً
                task.wait(0.5)
                if not hasActiveQuest() then
                    log("📜 Quest انتهى! أخذ واحد جديد...")
                    getQuest(target)
                    stats.quests = stats.quests + 1
                end
            end
            
        end)
        
        if not ok then
            warn("⚠️ [FARM] " .. tostring(err))
            stopAttack()
            currentTarget = nil
        end
        
        task.wait(CONFIG.LOOP_DELAY)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🧹 تنظيف الذاكرة
-- ═══════════════════════════════════════════════════════════
spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        task.wait(180)
        pcall(collectgarbage, "collect")
    end
end)

-- ═══════════════════════════════════════════════════════════
-- ✅ جاهز
-- ═══════════════════════════════════════════════════════════
local t = getTargetInfo()
log("✅ Farm v17.0 Ready!")
log("🎯 " .. t.name .. " @ " .. t.island .. " | Sea " .. t.sea)

print("╔═══════════════════════════════════════════════╗")
print("║  ✅ BFF FARM v17.0 ACTIVE!                   ║")
print("║  🎯 " .. t.name)
print("║  🏝️ " .. t.island)
print("║  🌊 Sea " .. getCurrentSea())
print("║  ⭐ Level " .. getLevel())
print("║  📜 Quest System: ON                         ║")
print("╚═══════════════════════════════════════════════╝")
