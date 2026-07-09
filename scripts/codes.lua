--[[
    ══════════════════════════════════════════════
    🎁 BFF AUTO CODES - كل الأكواد الشغالة 🎁
    ══════════════════════════════════════════════
    - Double XP Codes
    - Reset Stats Codes
    - Beli Codes
    ══════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════
-- 🎁 كل الأكواد (محدثة)
-- ═══════════════════════════════════════
local CODES = {
    -- ═══ Double XP Codes (20 دقيقة) ═══
    "kittgaming",           -- 20 min 2x XP
    "Sub2Fer999",           -- 20 min 2x XP
    "Enyu_is_Pro",          -- 20 min 2x XP
    "Magicbus",             -- 20 min 2x XP
    "JCWK",                 -- 20 min 2x XP
    "Starcodeheo",          -- 20 min 2x XP
    "Bluxxy",               -- 20 min 2x XP
    "fudd10_v2",            -- 25 Beli
    "SUB2GAMERROBOT_EXP1",  -- 20 min 2x XP
    "Sub2NoobMaster123",    -- 20 min 2x XP
    "Sub2OfficialNoobie",   -- 20 min 2x XP
    "Sub2Daigrock",         -- 15 min 2x XP
    "Axiore",               -- 20 min 2x XP
    "TantaiGaming",         -- 15 min 2x XP
    "StrawHatMaine",        -- 15 min 2x XP
    "Sub2UncleKizaru",      -- Stats Refund
    "NoobMaster123",        -- 20 min 2x XP
    "SUB2GAMERROBOT_RESET1", -- Stats Refund
    "TheGreatAce",          -- 20 min 2x XP
    "GAMERROBOT_YT",        -- 20 min 2x XP
    
    -- ═══ Money & Rewards ═══
    "fudd10",               -- 1 Beli
    "Bignews",              -- Title
    "SECRET_ADMIN",         -- 20 min 2x XP
    "KittGaming",           -- 20 min 2x XP
    "STRAWHATMAINE",        -- 15 min 2x XP
    
    -- ═══ Reset Stats ═══
    "3BVISUALS",            -- Reset Stats
    "Fanaticco",            -- Reset Stats
    "ADMIN_TROLL",          -- Reset Stats
    "RESET_5B",             -- Reset Stats
}

StarterGui:SetCore("SendNotification", {
    Title = "🎁 Auto Codes";
    Text = "جاري تفعيل " .. #CODES .. " كود...";
    Duration = 3;
})

print("╔═══════════════════════════════════╗")
print("║  🎁 BFF AUTO CODES              ║")
print("╚═══════════════════════════════════╝")

-- ═══════════════════════════════════════
-- تفعيل كود
-- ═══════════════════════════════════════
local function redeemCode(code)
    local success = false
    local message = ""
    
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if not remotes then return end
        
        local commF = remotes:FindFirstChild("CommF_")
        if not commF then return end
        
        -- طرق مختلفة للـ Redeem
        local result = commF:InvokeServer("Redeem", code)
        if result then
            success = true
            message = tostring(result)
        end
    end)
    
    return success, message
end

-- ═══════════════════════════════════════
-- 🎯 تفعيل كل الأكواد
-- ═══════════════════════════════════════
local function redeemAllCodes()
    local successCount = 0
    local failCount = 0
    
    for i, code in ipairs(CODES) do
        local ok, msg = redeemCode(code)
        
        if ok then
            successCount = successCount + 1
            print("✅ [CODE] " .. code .. " → " .. msg)
        else
            failCount = failCount + 1
            print("❌ [CODE] " .. code)
        end
        
        wait(0.5) -- تجنب الـ Rate Limit
    end
    
    print("═══════════════════════════════════")
    print("✅ نجح: " .. successCount)
    print("❌ فشل: " .. failCount)
    print("═══════════════════════════════════")
    
    StarterGui:SetCore("SendNotification", {
        Title = "🎁 Codes Done";
        Text = "نجح: " .. successCount .. " | فشل: " .. failCount;
        Duration = 5;
    })
end

-- ═══════════════════════════════════════
-- شغّل الأكواد
-- ═══════════════════════════════════════
wait(2)
redeemAllCodes()

-- ═══════════════════════════════════════
-- إعادة تفعيل الأكواد كل ساعة
-- (Double XP يخلص كل 20 دقيقة، فنفعّله كل ساعة)
-- ═══════════════════════════════════════
spawn(function()
    while true do
        wait(1200) -- كل 20 دقيقة
        print("🔄 [CODES] إعادة تفعيل Double XP...")
        redeemAllCodes()
    end
end)

print("✅ [CODES] Auto Redeem يعمل!")
