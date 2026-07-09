--[[
    ══════════════════════════════════════════════
    🔥 BFF Startup - اختيار Marines تلقائياً 🔥
    ══════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════
-- دالة اختيار Marines
-- ═══════════════════════════════════════
local function ChooseMarines()
    local success, err = pcall(function()
        -- الطريقة الرسمية للعبة Blox Fruits
        ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marine")
    end)
    
    if success then
        StarterGui:SetCore("SendNotification", {
            Title = "⚓ Marines";
            Text = "تم اختيار فريق Marines بنجاح!";
            Duration = 3;
        })
        print("✅ [BFF] Marines Team Selected!")
        return true
    else
        warn("❌ [BFF] فشل اختيار Marines: " .. tostring(err))
        return false
    end
end

-- ═══════════════════════════════════════
-- التحقق: هل اللاعب لسا ما اختار فريق؟
-- ═══════════════════════════════════════
local function NeedsTeamSelection()
    -- إذا شاشة "Pick a Side" ظاهرة، معناها ما اختار فريق
    local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    if playerGui then
        local mainGui = playerGui:FindFirstChild("Main")
        if mainGui then
            local chooseFrame = mainGui:FindFirstChild("ChooseTeam")
            if chooseFrame and chooseFrame.Visible then
                return true
            end
        end
    end
    return false
end

-- ═══════════════════════════════════════
-- تشغيل الكود
-- ═══════════════════════════════════════
wait(3) -- انتظر تحميل اللعبة

if NeedsTeamSelection() then
    print("🎯 [BFF] شاشة اختيار الفريق ظاهرة، جاري اختيار Marines...")
    wait(1)
    ChooseMarines()
else
    print("✅ [BFF] اللاعب قد اختار فريقه مسبقاً")
end

-- ═══════════════════════════════════════
-- تأكيد الاختيار (محاولة إضافية)
-- ═══════════════════════════════════════
wait(2)
pcall(function()
    ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marine")
end)

print("✅ [BFF] Startup complete!")
