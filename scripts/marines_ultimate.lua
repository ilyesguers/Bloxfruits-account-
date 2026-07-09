getgenv().Team = "Marines"

--[[
    🔥 BFF MARINES ULTIMATE PICKER 🔥
    يختار MARINES بأي طريقة ممكنة
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

repeat wait() until game:IsLoaded()
wait(2)

StarterGui:SetCore("SendNotification", {Title="⚓ BFF", Text="بداية اختيار MARINES...", Duration=3})
print("🔥 [BFF] Ultimate Marines Picker Started")

local function tap(x,y)
    pcall(function()
        VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
        wait(0.08)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
    end)
end

local function tryRemote()
    local teams = {"Marines", "Marine", "MARINES", "marines"}
    local remotes = {"SetTeam", "setteam", "SelectTeam", "ChooseTeam", "PickTeam"}
    local comm = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
    if not comm then return false end
    
    for _, r in ipairs(remotes) do
        for _, t in ipairs(teams) do
            local ok = pcall(function()
                comm:InvokeServer(r, t)
            end)
            if ok then print("✅ جربت Remote: "..r.." "..t) end
            wait(0.1)
        end
    end
    return true
end

local function findAndFireMarineButton()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return false end
    
    for _, obj in pairs(pg:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Text and obj.Text:lower():find("marines") then
            print("🎯 لقيت نص MARINES في: "..obj:GetFullName())
            -- اطلع لفوق 5 مستويات ودور زر
            local p = obj.Parent
            for i=1,6 do
                if not p then break end
                if p:IsA("GuiButton") or p:IsA("ImageButton") or p:IsA("TextButton") then
                    print("💥 لقيت زر: "..p:GetFullName())
                    pcall(function() firesignal(p.Activated) end)
                    pcall(function() firesignal(p.MouseButton1Click) end)
                    pcall(function() for _,c in pairs(getconnections(p.MouseButton1Click)) do c:Fire() end end)
                    return true
                end
                -- شوف إذا فيه زر ابن
                for _, child in pairs(p:GetChildren()) do
                    if child:IsA("GuiButton") then
                        pcall(function() firesignal(child.Activated) end)
                        pcall(function() firesignal(child.MouseButton1Click) end)
                    end
                end
                p = p.Parent
            end
        end
    end
    return false
end

-- الحلقة النهائية
spawn(function()
    local tries = 0
    while tries < 40 do
        tries = tries + 1
        print("🔄 محاولة "..tries.."/40")
        
        -- 1. جرب الريموت
        tryRemote()
        wait(0.5)
        
        -- 2. جرب تدوير الزر
        findAndFireMarineButton()
        wait(0.5)
        
        -- 3. اضغط في منطقة MARINES (يمين الشاشة)
        local vs = workspace.CurrentCamera.ViewportSize
        -- منطقة MARINES تقريبا من X 55% ل 85% و Y 35% ل 75%
        for x = 0.58, 0.85, 0.06 do
            for y = 0.38, 0.72, 0.08 do
                tap(vs.X * x, vs.Y * y)
                wait(0.05)
            end
        end
        
        -- هل تم الاختيار؟
        if LocalPlayer.Team and LocalPlayer.Team.Name:lower():find("marine") then
            StarterGui:SetCore("SendNotification", {Title="✅ تم!", Text="MARINES تم اختياره بنجاح", Duration=5})
            print("✅✅✅ MARINES SELECTED: "..LocalPlayer.Team.Name)
            break
        end
        
        wait(1)
    end
end)
