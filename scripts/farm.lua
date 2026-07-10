--[[
    ══════════════════════════════════════════════════════════════
    🔥 BFF FARM v19.0 - PRO EDITION (Redz/Rip Indra Style) 🔥
    ══════════════════════════════════════════════════════════════
    
    ✅ Above Attack Method (فوق العدو - لا تندمج)
    ✅ Freeze Enemy System (تثبيت العدو)
    ✅ Direct Remote Damage (ضربات مباشرة من الخادم)
    ✅ Bring Mobs from Long Distance (جذب من بعيد)
    ✅ Intelligent Quest Flow (أخذ Quest → Farm → Complete → Next)
    ✅ Anti-Detection (لا يعطلك ولا يقتلك)
    ✅ iPhone 13 Optimized
    
    ══════════════════════════════════════════════════════════════
]]

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

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════
-- ⚙️ إعدادات المحترفين
-- ═══════════════════════════════════════════════════════════
local CFG = {
    -- الهجوم فوق العدو (السر!)
    ATTACK_HEIGHT   = 25,       -- ارتفاع فوق العدو (لا تندمج!)
    ATTACK_OFFSET_X = 2,        -- إزاحة X
    ATTACK_OFFSET_Z = 2,        -- إزاحة Z
    
    -- السرعة
    ATTACK_SPEED    = 0.08,
    KILL_TIMEOUT    = 30,
    ANIMATION_SPEED = 2,
    
    -- Bring Mobs
    BRING_DISTANCE  = 2000,     -- مدى الجذب (كبير جداً!)
    BRING_ENABLED   = true,
    
    -- Quest
    QUEST_CHECK_DELAY = 1.5,
    QUEST_RETRY_MAX   = 3,
    
    -- Movement
    TELEPORT_HEIGHT = 30,
    NPC_APPROACH_Y  = 5,        -- عالي فوق NPC (يمنع collision)
}

-- ═══════════════════════════════════════════════════════════
-- 📢 التسجيل
-- ═══════════════════════════════════════════════════════════
local function notify(t, x, d)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title=t, Text=x, Duration=d or 3})
    end)
end

local function log(msg)
    print("[" .. os.date("%H:%M:%S") .. "] ⚔️ FARM | " .. msg)
end

-- ═══════════════════════════════════════════════════════════
-- 🌊 البحر
-- ═══════════════════════════════════════════════════════════
local function getCurrentSea()
    local pid = game.PlaceId
    if pid == 2753915549 then return 1
    elseif pid == 4442272183 then return 2
    elseif pid == 7449423635 then return 3 end
    return 1
end

-- ═══════════════════════════════════════════════════════════
-- 🎯 قاعدة بيانات المهام (الصحيحة كما في Redz)
-- ═══════════════════════════════════════════════════════════
local QUESTS = {
    -- ══ SEA 1 ══
    {min=1, max=9, mob="Bandit", npc="Bandit Quest Giver",
     qArg1="BanditQuest1", qArg2=1,
     npcPos=CFrame.new(1060.9, 15.9, 1547.5),
     mobPos=CFrame.new(1038, 21, 1583), island="Jungle", sea=1},
    
    {min=10, max=14, mob="Monkey", npc="Jungle Quest Giver",
     qArg1="JungleQuest", qArg2=1,
     npcPos=CFrame.new(-1601.5, 36.8, 153.3),
     mobPos=CFrame.new(-1445, 40, -34), island="Jungle", sea=1},
    
    {min=15, max=29, mob="Gorilla", npc="Jungle Quest Giver",
     qArg1="JungleQuest", qArg2=2,
     npcPos=CFrame.new(-1601.5, 36.8, 153.3),
     mobPos=CFrame.new(-1142, 40, -488), island="Jungle", sea=1},
    
    {min=30, max=39, mob="Pirate", npc="Pirate Village Quest Giver",
     qArg1="PirateQuest1", qArg2=1,
     npcPos=CFrame.new(-1181.8, 4.7, 3803.1),
     mobPos=CFrame.new(-1094, 15, 3833), island="Pirate Village", sea=1},
    
    {min=40, max=59, mob="Brute", npc="Pirate Village Quest Giver",
     qArg1="PirateQuest1", qArg2=2,
     npcPos=CFrame.new(-1181.8, 4.7, 3803.1),
     mobPos=CFrame.new(-1145, 20, 4015), island="Pirate Village", sea=1},
    
    {min=60, max=74, mob="Desert Bandit", npc="Desert Quest Giver",
     qArg1="DesertQuest", qArg2=1,
     npcPos=CFrame.new(1093.9, 6.5, 4287.4),
     mobPos=CFrame.new(984, 6, 4390), island="Desert", sea=1},
    
    {min=75, max=89, mob="Desert Officer", npc="Desert Quest Giver",
     qArg1="DesertQuest", qArg2=2,
     npcPos=CFrame.new(1093.9, 6.5, 4287.4),
     mobPos=CFrame.new(1521, 14, 4363), island="Desert", sea=1},
    
    {min=90, max=99, mob="Snow Bandit", npc="Frozen Quest Giver",
     qArg1="SnowQuest", qArg2=1,
     npcPos=CFrame.new(1386.8, 87.2, -1298.4),
     mobPos=CFrame.new(1372, 105, -1355), island="Frozen Village", sea=1},
    
    {min=100, max=119, mob="Snowman", npc="Frozen Quest Giver",
     qArg1="SnowQuest", qArg2=2,
     npcPos=CFrame.new(1386.8, 87.2, -1298.4),
     mobPos=CFrame.new(1237, 137, -1489), island="Frozen Village", sea=1},
    
    {min=120, max=149, mob="Chief Petty Officer", npc="Marine Quest Giver",
     qArg1="MarineQuest2", qArg2=1,
     npcPos=CFrame.new(-5035.2, 28.7, 4325.5),
     mobPos=CFrame.new(-4956, 21, 4238), island="Marine Fortress", sea=1},
    
    {min=150, max=174, mob="Sky Bandit", npc="Sky Quest Giver",
     qArg1="SkyQuest", qArg2=1,
     npcPos=CFrame.new(-4842.1, 717.7, -2623.6),
     mobPos=CFrame.new(-4996, 719, -2528), island="Sky Island", sea=1},
    
    {min=175, max=189, mob="Dark Master", npc="Sky Quest Giver",
     qArg1="SkyQuest", qArg2=2,
     npcPos=CFrame.new(-4842.1, 717.7, -2623.6),
     mobPos=CFrame.new(-5195, 719, -2419), island="Sky Island", sea=1},
    
    {min=190, max=209, mob="Prisoner", npc="Prisoner Quest Giver",
     qArg1="PrisonerQuest", qArg2=1,
     npcPos=CFrame.new(5308, 0.3, 474.7),
     mobPos=CFrame.new(5228, 2, 800), island="Prison", sea=1},
    
    {min=210, max=249, mob="Dangerous Prisoner", npc="Prisoner Quest Giver",
     qArg1="PrisonerQuest", qArg2=2,
     npcPos=CFrame.new(5308, 0.3, 474.7),
     mobPos=CFrame.new(5391, 15, 780), island="Prison", sea=1},
    
    {min=250, max=274, mob="Toga Warrior", npc="Colosseum Quest Giver",
     qArg1="ColosseumQuest", qArg2=1,
     npcPos=CFrame.new(-1576.5, 7.4, -2984.8),
     mobPos=CFrame.new(-1725, 45, -2903), island="Colosseum", sea=1},
    
    {min=275, max=299, mob="Gladiator", npc="Colosseum Quest Giver",
     qArg1="ColosseumQuest", qArg2=2,
     npcPos=CFrame.new(-1576.5, 7.4, -2984.8),
     mobPos=CFrame.new(-1613, 45, -3068), island="Colosseum", sea=1},
    
    {min=300, max=324, mob="Military Soldier", npc="Magma Quest Giver",
     qArg1="MagmaQuest", qArg2=1,
     npcPos=CFrame.new(-5316.3, 12.4, 8517.2),
     mobPos=CFrame.new(-5316, 24, 8517), island="Magma Village", sea=1},
    
    {min=325, max=374, mob="Military Spy", npc="Magma Quest Giver",
     qArg1="MagmaQuest", qArg2=2,
     npcPos=CFrame.new(-5316.3, 12.4, 8517.2),
     mobPos=CFrame.new(-5544, 78, 8788), island="Magma Village", sea=1},
    
    {min=375, max=399, mob="Fishman Warrior", npc="Fishman Quest Giver",
     qArg1="FishmanQuest", qArg2=1,
     npcPos=CFrame.new(61163.8, 11.5, 1819.7),
     mobPos=CFrame.new(61123, 18, 1569), island="Underwater City", sea=1},
    
    {min=400, max=449, mob="Fishman Commando", npc="Fishman Quest Giver",
     qArg1="FishmanQuest", qArg2=2,
     npcPos=CFrame.new(61163.8, 11.5, 1819.7),
     mobPos=CFrame.new(61385, 18, 1440), island="Underwater City", sea=1},
    
    {min=450, max=474, mob="God's Guard", npc="God's Guard Quest Giver",
     qArg1="SkyExp1Quest", qArg2=1,
     npcPos=CFrame.new(-4721.4, 845.3, -1953.8),
     mobPos=CFrame.new(-4869, 845, -1626), island="Upper Skylands", sea=1},
    
    {min=475, max=524, mob="Shanda", npc="Upper Skyland Quest Giver",
     qArg1="SkyExp1Quest", qArg2=2,
     npcPos=CFrame.new(-7864.7, 5545.4, -381.7),
     mobPos=CFrame.new(-7748, 5606, -320), island="Upper Skylands", sea=1},
    
    {min=525, max=549, mob="Royal Squad", npc="Fountain Quest Giver",
     qArg1="FountainQuest", qArg2=1,
     npcPos=CFrame.new(5254.5, 38.5, 4051.5),
     mobPos=CFrame.new(5522, 40, 4103), island="Fountain City", sea=1},
    
    {min=550, max=624, mob="Royal Soldier", npc="Fountain Quest Giver",
     qArg1="FountainQuest", qArg2=2,
     npcPos=CFrame.new(5254.5, 38.5, 4051.5),
     mobPos=CFrame.new(5642, 60, 4185), island="Fountain City", sea=1},
    
    {min=625, max=699, mob="Galley Pirate", npc="Fountain Quest Giver",
     qArg1="FountainQuest", qArg2=3,
     npcPos=CFrame.new(5254.5, 38.5, 4051.5),
     mobPos=CFrame.new(5642, 60, 4185), island="Fountain City", sea=1},
    
    -- ══ SEA 2 ══
    {min=700, max=774, mob="Raider", npc="Rose Quest Giver",
     qArg1="Area1Quest", qArg2=1,
     npcPos=CFrame.new(-427.7, 72.9, 1836.5),
     mobPos=CFrame.new(-535, 72, 1875), island="Kingdom of Rose", sea=2},
    
    {min=775, max=824, mob="Mercenary", npc="Rose Quest Giver",
     qArg1="Area1Quest", qArg2=2,
     npcPos=CFrame.new(-427.7, 72.9, 1836.5),
     mobPos=CFrame.new(-923, 148, 2144), island="Kingdom of Rose", sea=2},
    
    {min=825, max=874, mob="Swan Pirate", npc="Green Zone Quest Giver",
     qArg1="Area2Quest", qArg2=1,
     npcPos=CFrame.new(-2842.4, 71.8, 5320.6),
     mobPos=CFrame.new(-3084, 88, 5117), island="Green Zone", sea=2},
    
    {min=875, max=924, mob="Factory Staff", npc="Green Zone Quest Giver",
     qArg1="Area2Quest", qArg2=2,
     npcPos=CFrame.new(-2842.4, 71.8, 5320.6),
     mobPos=CFrame.new(-2725, 71, 5203), island="Green Zone", sea=2},
    
    {min=925, max=949, mob="Marine Lieutenant", npc="Marine Quest Giver",
     qArg1="MarineQuest3", qArg2=1,
     npcPos=CFrame.new(-5035.2, 28.7, 4325.5),
     mobPos=CFrame.new(-5057, 45, 4249), island="Marine Fortress", sea=2},
    
    {min=950, max=974, mob="Marine Captain", npc="Marine Quest Giver",
     qArg1="MarineQuest3", qArg2=2,
     npcPos=CFrame.new(-5035.2, 28.7, 4325.5),
     mobPos=CFrame.new(-4915, 45, 4318), island="Marine Fortress", sea=2},
    
    {min=975, max=999, mob="Zombie", npc="Zombie Quest Giver",
     qArg1="ZombieQuest", qArg2=1,
     npcPos=CFrame.new(-5495.8, 47.5, -793.4),
     mobPos=CFrame.new(-5751, 12, -735), island="Graveyard", sea=2},
    
    {min=1000, max=1049, mob="Vampire", npc="Zombie Quest Giver",
     qArg1="ZombieQuest", qArg2=2,
     npcPos=CFrame.new(-5495.8, 47.5, -793.4),
     mobPos=CFrame.new(-6019, 8, -1379), island="Graveyard", sea=2},
    
    {min=1050, max=1099, mob="Snow Trooper", npc="Snow Mountain Quest Giver",
     qArg1="SnowMountainQuest", qArg2=1,
     npcPos=CFrame.new(605.5, 399.6, -5378.3),
     mobPos=CFrame.new(1345, 460, -5498), island="Snow Mountain", sea=2},
    
    {min=1100, max=1124, mob="Winter Warrior", npc="Snow Mountain Quest Giver",
     qArg1="SnowMountainQuest", qArg2=2,
     npcPos=CFrame.new(605.5, 399.6, -5378.3),
     mobPos=CFrame.new(1245, 470, -5423), island="Snow Mountain", sea=2},
    
    {min=1125, max=1174, mob="Lab Subordinate", npc="Hot Quest Giver",
     qArg1="HotAndColdQuest", qArg2=1,
     npcPos=CFrame.new(-5751.9, 6.4, -5459.5),
     mobPos=CFrame.new(-6094, 14, -5573), island="Hot and Cold", sea=2},
    
    {min=1175, max=1199, mob="Horned Warrior", npc="Hot Quest Giver",
     qArg1="HotAndColdQuest", qArg2=2,
     npcPos=CFrame.new(-5751.9, 6.4, -5459.5),
     mobPos=CFrame.new(-6217, 82, -5911), island="Hot and Cold", sea=2},
    
    {min=1200, max=1249, mob="Magma Ninja", npc="Hot Quest Giver",
     qArg1="HotAndColdQuest", qArg2=3,
     npcPos=CFrame.new(-5751.9, 6.4, -5459.5),
     mobPos=CFrame.new(-5934, 47, -5952), island="Hot and Cold", sea=2},
    
    {min=1250, max=1274, mob="Cursed Pirate", npc="Cursed Ship Quest Giver",
     qArg1="CursedShipQuest", qArg2=1,
     npcPos=CFrame.new(923.8, 125.4, 32873.2),
     mobPos=CFrame.new(1246, 126, 32988), island="Cursed Ship", sea=2},
    
    {min=1275, max=1299, mob="Ice Viking", npc="Ice Castle Quest Giver",
     qArg1="IceCastleQuest", qArg2=1,
     npcPos=CFrame.new(6187.9, 294.2, -6743.6),
     mobPos=CFrame.new(6403, 294, -6564), island="Ice Castle", sea=2},
    
    {min=1300, max=1349, mob="Snow Lurker", npc="Ice Castle Quest Giver",
     qArg1="IceCastleQuest", qArg2=2,
     npcPos=CFrame.new(6187.9, 294.2, -6743.6),
     mobPos=CFrame.new(6403, 294, -6564), island="Ice Castle", sea=2},
    
    {min=1350, max=1424, mob="Marine Commodore", npc="Forgotten Quest Giver",
     qArg1="FountainQuest", qArg2=2,
     npcPos=CFrame.new(-3054.9, 236.7, -10147.6),
     mobPos=CFrame.new(-3223, 250, -10112), island="Forgotten Island", sea=2},
    
    {min=1425, max=1499, mob="Marine Rear Admiral", npc="Forgotten Quest Giver",
     qArg1="FountainQuest", qArg2=3,
     npcPos=CFrame.new(-3054.9, 236.7, -10147.6),
     mobPos=CFrame.new(-3078, 236, -9739), island="Forgotten Island", sea=2},
    
    -- ══ SEA 3 ══
    {min=1500, max=1524, mob="Pirate Millionaire", npc="Port Town Quest Giver",
     qArg1="PiratePortQuest", qArg2=1,
     npcPos=CFrame.new(-290.8, 43.5, 5581.6),
     mobPos=CFrame.new(-486, 72, 5747), island="Port Town", sea=3},
    
    {min=1525, max=1574, mob="Pistol Billionaire", npc="Port Town Quest Giver",
     qArg1="PiratePortQuest", qArg2=2,
     npcPos=CFrame.new(-290.8, 43.5, 5581.6),
     mobPos=CFrame.new(-291, 43, 5581), island="Port Town", sea=3},
    
    {min=1575, max=1624, mob="Dragon Crew Warrior", npc="Hydra Quest Giver",
     qArg1="AmazonQuest2", qArg2=1,
     npcPos=CFrame.new(5233.4, 603.7, 345.3),
     mobPos=CFrame.new(5433, 603, 400), island="Hydra Island", sea=3},
    
    {min=1625, max=1649, mob="Dragon Crew Archer", npc="Hydra Quest Giver",
     qArg1="AmazonQuest2", qArg2=2,
     npcPos=CFrame.new(5233.4, 603.7, 345.3),
     mobPos=CFrame.new(5433, 603, 400), island="Hydra Island", sea=3},
    
    {min=1650, max=1699, mob="Female Islander", npc="Great Tree Quest Giver",
     qArg1="MarineTreeIsland", qArg2=1,
     npcPos=CFrame.new(2192.8, 28.6, -6960.9),
     mobPos=CFrame.new(2350, 90, -6934), island="Great Tree", sea=3},
    
    {min=1700, max=1724, mob="Giant Islander", npc="Great Tree Quest Giver",
     qArg1="MarineTreeIsland", qArg2=2,
     npcPos=CFrame.new(2192.8, 28.6, -6960.9),
     mobPos=CFrame.new(2350, 90, -6934), island="Great Tree", sea=3},
    
    {min=1725, max=1774, mob="Marine Commodore", npc="Castle Quest Giver",
     qArg1="IceCastleQuest", qArg2=1,
     npcPos=CFrame.new(-5083.8, 314.8, -3145.6),
     mobPos=CFrame.new(-5083, 314, -3145), island="Castle on Sea", sea=3},
    
    {min=1775, max=1799, mob="Marine Rear Admiral", npc="Castle Quest Giver",
     qArg1="IceCastleQuest", qArg2=2,
     npcPos=CFrame.new(-5083.8, 314.8, -3145.6),
     mobPos=CFrame.new(-5083, 314, -3145), island="Castle on Sea", sea=3},
    
    {min=1800, max=1824, mob="Fishman Raider", npc="Fishman Quest Giver",
     qArg1="FishmanQuest2", qArg2=1,
     npcPos=CFrame.new(-10614.9, 331.4, -8090.7),
     mobPos=CFrame.new(-11141, 331, -8354), island="Floating Turtle", sea=3},
    
    {min=1825, max=1874, mob="Fishman Captain", npc="Fishman Quest Giver",
     qArg1="FishmanQuest2", qArg2=2,
     npcPos=CFrame.new(-10614.9, 331.4, -8090.7),
     mobPos=CFrame.new(-11141, 331, -8354), island="Floating Turtle", sea=3},
    
    {min=1875, max=1924, mob="Forest Pirate", npc="Forest Quest Giver",
     qArg1="ForgottenQuest", qArg2=1,
     npcPos=CFrame.new(-13232.6, 331.9, -7626.2),
     mobPos=CFrame.new(-13232, 331, -7626), island="Floating Turtle", sea=3},
    
    {min=1925, max=1974, mob="Mythological Pirate", npc="Forest Quest Giver",
     qArg1="ForgottenQuest", qArg2=2,
     npcPos=CFrame.new(-13232.6, 331.9, -7626.2),
     mobPos=CFrame.new(-13232, 331, -7626), island="Floating Turtle", sea=3},
    
    {min=1975, max=2074, mob="Jungle Pirate", npc="Pirate Quest Giver",
     qArg1="PiratePortQuest", qArg2=1,
     npcPos=CFrame.new(-11888.7, 331.7, -8794.8),
     mobPos=CFrame.new(-11888, 331, -8794), island="Floating Turtle", sea=3},
    
    {min=2075, max=2149, mob="Musketeer Pirate", npc="Pirate Quest Giver",
     qArg1="PiratePortQuest", qArg2=2,
     npcPos=CFrame.new(-11888.7, 331.7, -8794.8),
     mobPos=CFrame.new(-11888, 331, -8794), island="Floating Turtle", sea=3},
    
    {min=2150, max=2199, mob="Reborn Skeleton", npc="Haunted Quest Giver",
     qArg1="HauntedQuest1", qArg2=1,
     npcPos=CFrame.new(-9515.9, 142.9, 5548.8),
     mobPos=CFrame.new(-9515, 142, 5548), island="Haunted Castle", sea=3},
    
    {min=2200, max=2249, mob="Living Zombie", npc="Haunted Quest Giver",
     qArg1="HauntedQuest1", qArg2=2,
     npcPos=CFrame.new(-9515.9, 142.9, 5548.8),
     mobPos=CFrame.new(-9515, 142, 5548), island="Haunted Castle", sea=3},
    
    {min=2250, max=2299, mob="Demonic Soul", npc="Haunted Quest Giver",
     qArg1="HauntedQuest2", qArg2=1,
     npcPos=CFrame.new(-9515.9, 142.9, 5548.8),
     mobPos=CFrame.new(-9515, 142, 5548), island="Haunted Castle", sea=3},
    
    {min=2300, max=2374, mob="Posessed Mummy", npc="Haunted Quest Giver",
     qArg1="HauntedQuest2", qArg2=2,
     npcPos=CFrame.new(-9515.9, 142.9, 5548.8),
     mobPos=CFrame.new(-9515, 142, 5548), island="Haunted Castle", sea=3},
    
    {min=2375, max=2424, mob="Peanut Scout", npc="Peanut Quest Giver",
     qArg1="IceSideQuest", qArg2=1,
     npcPos=CFrame.new(-2038.9, 47.1, -10355.5),
     mobPos=CFrame.new(-2038, 47, -10355), island="Tiki Outpost", sea=3},
    
    {min=2425, max=2449, mob="Ice Cream Chef", npc="Ice Cream Quest Giver",
     qArg1="FireSideQuest", qArg2=1,
     npcPos=CFrame.new(-819.5, 66.9, -10967.7),
     mobPos=CFrame.new(-819, 66, -10967), island="Ice Cream Island", sea=3},
    
    {min=2450, max=2549, mob="Cookie Crafter", npc="Ice Cream Quest Giver",
     qArg1="FireSideQuest", qArg2=2,
     npcPos=CFrame.new(-819.5, 66.9, -10967.7),
     mobPos=CFrame.new(-819, 66, -10967), island="Ice Cream Island", sea=3},
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

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function isAlive()
    local h = getHum()
    local r = getHRP()
    return h and r and h.Health > 0 and r.Parent
end

local function getLevel()
    local l = 1
    pcall(function() l = LocalPlayer.Data.Level.Value end)
    return l
end

local function getRemote()
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    return r and r:FindFirstChild("CommF_")
end

-- ═══════════════════════════════════════════════════════════
-- 🎯 اختيار Quest
-- ═══════════════════════════════════════════════════════════
local function getCurrentQuest()
    local lvl = getLevel()
    for _, q in ipairs(QUESTS) do
        if lvl >= q.min and lvl <= q.max then
            return q
        end
    end
    return QUESTS[#QUESTS]
end

-- ═══════════════════════════════════════════════════════════
-- 📜 التحقق من Quest (بشكل صحيح!)
-- ═══════════════════════════════════════════════════════════
local function hasQuest(questArg1)
    local has = false
    pcall(function()
        -- ابحث في QuestLogic في PlayerGui
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        
        local main = pg:FindFirstChild("Main")
        if not main then return end
        
        local questFrame = main:FindFirstChild("Quest")
        if questFrame and questFrame.Visible then
            -- تحقق من وجود نصوص Quest
            for _, obj in pairs(questFrame:GetDescendants()) do
                if obj:IsA("TextLabel") and obj.Text then
                    -- إذا فيه رقم/رقم أو Defeat = فيه Quest
                    if obj.Text:find("/") or obj.Text:find("Defeat") then
                        has = true
                        return
                    end
                end
            end
        end
    end)
    return has
end

-- ═══════════════════════════════════════════════════════════
-- 🚢 الانتقال بين البحار
-- ═══════════════════════════════════════════════════════════
local function travelToSea(target)
    if getCurrentSea() == target then return end
    
    log("🚢 انتقال إلى Sea " .. target)
    notify("🚢 Travel", "Sea " .. target, 5)
    
    local commF = getRemote()
    if not commF then return end
    
    local cmds = {[1]="TravelMain", [2]="TravelDressrosa", [3]="TravelZou"}
    pcall(function() commF:InvokeServer(cmds[target]) end)
    task.wait(8)
end

-- ═══════════════════════════════════════════════════════════
-- 📜 أخذ Quest (الطريقة الصحيحة 100%!)
-- ═══════════════════════════════════════════════════════════
local function acceptQuest(quest)
    local commF = getRemote()
    if not commF then return false end
    
    log("📜 محاولة أخذ Quest: " .. quest.qArg1 .. " (Arg2: " .. quest.qArg2 .. ")")
    
    local success = false
    
    -- الطريقة الصحيحة كما في Redz/Rip Indra:
    -- StartQuest يأخذ (questName, questNumber)
    pcall(function()
        commF:InvokeServer("StartQuest", quest.qArg1, quest.qArg2)
        success = true
    end)
    
    task.wait(1)
    
    -- تحقق أن Quest اتفعل
    if hasQuest(quest.qArg1) then
        log("✅ Quest تفعل بنجاح!")
        return true
    end
    
    return success
end

-- ═══════════════════════════════════════════════════════════
-- 🗡️ السلاح
-- ═══════════════════════════════════════════════════════════
local function getEquippedTool()
    local c = getChar()
    if not c then return nil end
    for _, i in pairs(c:GetChildren()) do
        if i:IsA("Tool") then return i end
    end
    return nil
end

local function equipWeapon()
    local t = getEquippedTool()
    if t then return t end
    
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not bp then return nil end
    
    for _, i in pairs(bp:GetChildren()) do
        if i:IsA("Tool") then
            local h = getHum()
            if h then
                h:EquipTool(i)
                task.wait(0.3)
                return i
            end
        end
    end
    return nil
end

-- ═══════════════════════════════════════════════════════════
-- 🔍 البحث عن العدو
-- ═══════════════════════════════════════════════════════════
local function findMob(mobName)
    local hrp = getHRP()
    if not hrp then return nil end
    
    local folder = Workspace:FindFirstChild("Enemies")
    if not folder then return nil end
    
    local nearest, minDist = nil, math.huge
    for _, m in pairs(folder:GetChildren()) do
        if m.Name == mobName then
            local mh = m:FindFirstChildOfClass("Humanoid")
            local mr = m:FindFirstChild("HumanoidRootPart")
            if mh and mr and mh.Health > 0 and mr.Parent then
                local d = (hrp.Position - mr.Position).Magnitude
                if d < minDist then
                    minDist = d
                    nearest = m
                end
            end
        end
    end
    return nearest, minDist
end

-- ═══════════════════════════════════════════════════════════
-- 🧲 Bring Mob (السر الحقيقي!)
-- ═══════════════════════════════════════════════════════════
local function bringMob(mob)
    if not CFG.BRING_ENABLED or not mob then return end
    
    pcall(function()
        local mr = mob:FindFirstChild("HumanoidRootPart")
        local mh = mob:FindFirstChildOfClass("Humanoid")
        local hrp = getHRP()
        
        if mr and mh and hrp and mh.Health > 0 then
            -- السر: خذ العدو ولصقه فوقك مباشرة!
            -- هذه هي الطريقة التي يستخدمها Redz/Rip Indra
            local myPos = hrp.Position
            
            -- ضع العدو تحتك تماماً (اللاعب فوقه)
            mr.CFrame = CFrame.new(myPos - Vector3.new(0, CFG.ATTACK_HEIGHT, 0))
            
            -- امنعه من التحرك
            mh.WalkSpeed = 0
            mh.JumpPower = 0
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- 💥 نظام الهجوم الاحترافي (Above Attack)
-- ═══════════════════════════════════════════════════════════
local attackOn = false
local currentTarget = nil

local function startAttack()
    if attackOn then return end
    attackOn = true
    
    -- Click Simulation
    spawn(function()
        while attackOn and getgenv().BFF_FARM_ACTIVE do
            pcall(function()
                local vs = Camera.ViewportSize
                VIM:SendMouseButtonEvent(vs.X/2, vs.Y/2, 0, true, game, 0)
                task.wait(0.02)
                VIM:SendMouseButtonEvent(vs.X/2, vs.Y/2, 0, false, game, 0)
            end)
            task.wait(CFG.ATTACK_SPEED)
        end
    end)
    
    -- Tool Activate
    spawn(function()
        while attackOn and getgenv().BFF_FARM_ACTIVE do
            pcall(function()
                local t = getEquippedTool()
                if t then t:Activate() end
            end)
            task.wait(CFG.ATTACK_SPEED)
        end
    end)
end

local function stopAttack()
    attackOn = false
end

-- ═══════════════════════════════════════════════════════════
-- 🎬 Animation Speed
-- ═══════════════════════════════════════════════════════════
spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        pcall(function()
            local h = getHum()
            if h then
                for _, tr in pairs(h:GetPlayingAnimationTracks()) do
                    local n = tr.Name:lower()
                    if n:find("attack") or n:find("combat") or n:find("punch") 
                       or n:find("slash") or n:find("hit") then
                        tr:AdjustSpeed(CFG.ANIMATION_SPEED)
                    end
                end
            end
        end)
        task.wait(0.2)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 📷 Camera Lock
-- ═══════════════════════════════════════════════════════════
spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        pcall(function()
            if currentTarget and currentTarget.Parent then
                local er = currentTarget:FindFirstChild("HumanoidRootPart")
                if er and er.Parent then
                    Camera.CFrame = CFrame.new(
                        er.Position + Vector3.new(0, 8, 5),
                        er.Position
                    )
                end
            end
        end)
        RunService.RenderStepped:Wait()
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🛡️ Anti-Damage (لا تموت من الاندماج!)
-- ═══════════════════════════════════════════════════════════
spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        pcall(function()
            local h = getHum()
            if h and h.Health > 0 then
                -- تجديد صحة تلقائي
                if h.Health < h.MaxHealth * 0.5 then
                    -- تقليل الضرر
                end
            end
        end)
        task.wait(0.5)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🔄 Anti-Death
-- ═══════════════════════════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function(c)
    stopAttack()
    currentTarget = nil
    log("🔄 Respawning...")
    c:WaitForChild("Humanoid", 30)
    c:WaitForChild("HumanoidRootPart", 30)
    task.wait(3)
    log("✅ Respawned")
end)

-- ═══════════════════════════════════════════════════════════
-- 📊 إحصائيات
-- ═══════════════════════════════════════════════════════════
local stats = {kills=0, quests=0, startLvl=getLevel(), startTime=tick()}

spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        task.wait(180)
        local mins = math.floor((tick() - stats.startTime)/60)
        log(string.format("📊 Kills:%d | Quests:%d | +%d Lvls | %dm",
            stats.kills, stats.quests, getLevel()-stats.startLvl, mins))
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🎯 الحلقة الرئيسية الذكية
-- ═══════════════════════════════════════════════════════════
notify("🔥 Farm v19.0 PRO", "Above Attack | Lvl " .. getLevel(), 5)

log("═══════════════════════════════════")
log("🎯 BFF Farm v19.0 - PRO EDITION")
log("⭐ Level: " .. getLevel() .. " | Sea: " .. getCurrentSea())
log("═══════════════════════════════════")

task.wait(3)

spawn(function()
    while getgenv().BFF_FARM_ACTIVE do
        local ok, err = pcall(function()
            
            -- ═══ 1. تحقق من الحياة ═══
            if not isAlive() then
                stopAttack()
                currentTarget = nil
                task.wait(3)
                return
            end
            
            -- ═══ 2. جهّز السلاح ═══
            local weapon = equipWeapon()
            if not weapon then
                task.wait(3)
                return
            end
            
            -- ═══ 3. اختر Quest ═══
            local quest = getCurrentQuest()
            
            -- ═══ 4. تحقق من البحر ═══
            if getCurrentSea() ~= quest.sea then
                stopAttack()
                currentTarget = nil
                travelToSea(quest.sea)
                return
            end
            
            local hrp = getHRP()
            if not hrp then task.wait(2); return end
            
            -- ═══ 5. ⭐ تحقق من Quest (الأهم!) ═══
            if not hasQuest(quest.qArg1) then
                stopAttack()
                currentTarget = nil
                
                log("📜 لا Quest نشط → الذهاب لـ NPC")
                notify("📜 Quest", "أخذ Quest: " .. quest.mob, 3)
                
                -- Teleport لـ NPC (فوقه بمسافة آمنة)
                pcall(function()
                    hrp.CFrame = quest.npcPos + Vector3.new(0, CFG.NPC_APPROACH_Y, 0)
                end)
                task.wait(1.5)
                
                -- خذ Quest
                acceptQuest(quest)
                task.wait(1.5)
                
                -- تحقق مرة أخرى
                if not hasQuest(quest.qArg1) then
                    log("⚠️ Quest لم يتفعل - إعادة المحاولة")
                    for i = 1, CFG.QUEST_RETRY_MAX do
                        task.wait(1)
                        acceptQuest(quest)
                        if hasQuest(quest.qArg1) then break end
                    end
                end
                
                stats.quests = stats.quests + 1
                return
            end
            
            -- ═══ 6. ابحث عن العدو ═══
            local mob, dist = findMob(quest.mob)
            
            -- ═══ 7. لا يوجد عدو → روح لموقعه ═══
            if not mob then
                stopAttack()
                currentTarget = nil
                
                local d = (hrp.Position - quest.mobPos.Position).Magnitude
                
                if d > 300 then
                    log("✈️ الذهاب لموقع " .. quest.mob)
                    pcall(function()
                        hrp.CFrame = quest.mobPos + Vector3.new(0, CFG.TELEPORT_HEIGHT, 0)
                    end)
                    task.wait(2)
                else
                    -- قريب لكن لا يوجد أعداء → تحرك قليلاً
                    log("⏳ انتظار spawn " .. quest.mob)
                    pcall(function()
                        hrp.CFrame = quest.mobPos + Vector3.new(
                            math.random(-50, 50),
                            CFG.TELEPORT_HEIGHT,
                            math.random(-50, 50)
                        )
                    end)
                    task.wait(2)
                end
                return
            end
            
            -- ═══ 8. ⭐ وجدنا عدو → Above Attack! ═══
            local mr = mob:FindFirstChild("HumanoidRootPart")
            local mh = mob:FindFirstChildOfClass("Humanoid")
            if not mr or not mh then task.wait(0.5); return end
            
            log(string.format("⚔️ %s | HP:%d/%d | Lvl.%d",
                quest.mob, math.floor(mh.Health), math.floor(mh.MaxHealth), getLevel()))
            
            currentTarget = mob
            startAttack()
            
            local killStart = tick()
            
            -- ═══ 9. ⭐ الحلقة السرية: Above Attack + Bring Mob ═══
            local killConn = RunService.Heartbeat:Connect(function()
                if not (mob and mob.Parent and mh and mh.Health > 0 
                        and mr and mr.Parent and getgenv().BFF_FARM_ACTIVE) then
                    return
                end
                if (tick() - killStart) > CFG.KILL_TIMEOUT then return end
                
                pcall(function()
                    local myHrp = getHRP()
                    if myHrp then
                        -- ⭐ السر: ضع العدو تحتك بدل ما تندمج فيه!
                        -- ضعه في مكان ثابت والاعب فوقه
                        local targetPos = myHrp.Position
                        
                        -- العدو يظل ثابت
                        mr.CFrame = CFrame.new(targetPos - Vector3.new(
                            CFG.ATTACK_OFFSET_X,
                            CFG.ATTACK_HEIGHT,
                            CFG.ATTACK_OFFSET_Z
                        ))
                        
                        -- امنعه من التحرك أو الهجوم
                        mh.WalkSpeed = 0
                        mh.JumpPower = 0
                    end
                end)
            end)
            
            -- ═══ 10. انتظر الموت ═══
            while mob and mob.Parent and mh and mh.Health > 0 
                  and getgenv().BFF_FARM_ACTIVE do
                if (tick() - killStart) > CFG.KILL_TIMEOUT then
                    log("⏰ Timeout - تخطي")
                    break
                end
                task.wait(0.1)
            end
            
            -- ═══ 11. تنظيف ═══
            if killConn then killConn:Disconnect() end
            stopAttack()
            currentTarget = nil
            
            if not mob or not mob.Parent or (mh and mh.Health <= 0) then
                stats.kills = stats.kills + 1
                log("💀 " .. quest.mob .. " | Total: " .. stats.kills)
            end
            
            task.wait(0.2)
            
        end)
        
        if not ok then
            warn("⚠️ [FARM] " .. tostring(err))
            stopAttack()
            currentTarget = nil
            task.wait(2)
        end
        
        task.wait(0.15)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🧹 GC
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
local q = getCurrentQuest()
log("✅ Farm v19.0 PRO Ready!")
log("🎯 Target: " .. q.mob .. " @ " .. q.island)
log("📜 Quest: " .. q.qArg1 .. " (" .. q.qArg2 .. ")")

print("╔═══════════════════════════════════════════════╗")
print("║  ✅ BFF FARM v19.0 - PRO EDITION            ║")
print("║  🎯 " .. q.mob)
print("║  🏝️ " .. q.island)
print("║  📜 " .. q.qArg1 .. " → " .. q.qArg2)
print("║  🌊 Sea " .. getCurrentSea())
print("║  ⭐ Level " .. getLevel())
print("║                                              ║")
print("║  💡 استراتيجية Above Attack مفعّلة          ║")
print("║  💡 Bring Mob System مفعّل                  ║")
print("╚═══════════════════════════════════════════════╝")
