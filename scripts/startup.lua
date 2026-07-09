--[[
    ══════════════════════════════════════════════
    🔥 BFF - اختيار Marines (Method: CommF_) 🔥
    ══════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

wait(2)

StarterGui:SetCore("SendNotification", {
    Title = "⚓ BFF Marines";
    Text = "جاري اختيار Marines...";
    Duration = 3;
})

-- ═══════════════════════════════════════
-- قائمة الأوامر اللي راح نجربها
-- ═══════════════════════════════════════
local commands = {
    {"SetTeam", "Marine"},
    {"SetTeam", "Marines"},
    {"setteam", "Marine"},
    {"SelectTeam", "Marine"},
    {"ChooseTeam", "Marine"},
    {"JoinTeam", "Marine"},
    {"PickSide", "Marines"},
    {"PickTeam", "Marines"},
}

local CommF = ReplicatedStorage:FindFirstChild("Remotes") 
    and ReplicatedStorage.Remotes:FindFirstChild("CommF_")

if not CommF then
    warn("❌ [BFF] لم يتم العثور على CommF_")
    return
end

print("✅ [BFF] وجد CommF_ في: " .. CommF:GetFullName())

-- ═══════════════════════════════════════
-- جرب كل الأوامر
-- ═══════════════════════════════════════
for i, cmd in ipairs(commands) do
    local success, result = pcall(function()
        return CommF:InvokeServer(cmd[1], cmd[2])
    end)
    
    if success then
        print("✅ [BFF] نجح الأمر: " .. cmd[1] .. " | " .. cmd[2])
        print("📥 النتيجة: " .. tostring(result))
    else
        print("❌ [BFF] فشل: " .. cmd[1] .. " -> " .. tostring(result))
    end
    
    wait(0.5)
end

-- ═══════════════════════════════════════
-- تأكد من الفريق الحالي
-- ═══════════════════════════════════════
wait(2)
if LocalPlayer.Team then
    print("🎯 [BFF] الفريق الحالي: " .. LocalPlayer.Team.Name)
    StarterGui:SetCore("SendNotification", {
        Title = "✅ الفريق الحالي";
        Text = LocalPlayer.Team.Name;
        Duration = 5;
    })
else
    print("⚠️ [BFF] اللاعب ما يزال بدون فريق")
    StarterGui:SetCore("SendNotification", {
        Title = "⚠️ تنبيه";
        Text = "لم يتم اختيار فريق!";
        Duration = 5;
    })
end
