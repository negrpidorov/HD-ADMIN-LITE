--[[
--------------------------------------------------------------------
-- Объединенный скрипт: HD Admin Lite + FE Trolling Commands
-- fly / noclip / fling / jumpboost / infinityjump / bang / suc / getsuc / getbang / jerk
-- 2025-07 | SlapBattlesFarmer228
--------------------------------------------------------------------
]]

--------------------------------------------------------------------
-- SERVICES
--------------------------------------------------------------------
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TeleportService  = game:GetService("TeleportService")
local TweenService     = game:GetService("TweenService")
local TextChatService  = pcall(function() return game:GetService("TextChatService") end) and game:GetService("TextChatService") or nil

--------------------------------------------------------------------
-- DETECT RIG TYPE (R6 / R15)
--------------------------------------------------------------------
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local isR6 = character:FindFirstChild("Torso") ~= nil

--------------------------------------------------------------------
-- SETTINGS / RUNTIME FLAGS
--------------------------------------------------------------------
local GUI_LANG  = "en"
local PREFIX    = ":"
local FLY_SPEED = 50
local Flying,   FlyConn      = false, nil
local Noclipping, NoclipConn = false, nil
local FlingConn              = nil
local InfinityJumpOn, IJConn = false, nil

--------------------------------------------------------------------
-- NOTIFICATION FUNCTION
--------------------------------------------------------------------
local function showNotification(message)
    local notificationGui = game.CoreGui:FindFirstChild("NotificationGui")
    if not notificationGui then
        notificationGui = Instance.new("ScreenGui")
        notificationGui.IgnoreGuiInset = true
        notificationGui.Name = "NotificationGui"
        notificationGui.Parent = game.CoreGui
    end

    local notificationFrame = Instance.new("Frame")
    notificationFrame.Size = UDim2.new(0, 300, 0, 50)
    notificationFrame.Position = UDim2.new(0.5, -150, 1, -60)
    notificationFrame.AnchorPoint = Vector2.new(0.5, 1)
    notificationFrame.BackgroundTransparency = 1
    notificationFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 255)
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Parent = notificationGui

    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, 10)
    uicorner.Parent = notificationFrame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 1, 0)
    textLabel.Position = UDim2.new(0, 10, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = message .. " | by SlapBattlesFarmer228"
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 18
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = notificationFrame

    TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
    TweenService:Create(textLabel,       TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0})    :Play()

    task.delay(5, function()
        TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        TweenService:Create(textLabel,       TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {TextTransparency = 1})    :Play()
        task.delay(0.5, function()
            if notificationFrame.Parent then notificationFrame:Destroy() end
        end)
    end)
end

-- Initial notification
if isR6 then
    showNotification("🌟 R6 detected!")
else
    showNotification("✨ R15 detected!")
end

--------------------------------------------------------------------
-- CLEAN OLD GUI (in case of re‑execution)
--------------------------------------------------------------------
for _,o in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
    if table.find({"HD_Admin_Lite","HDAdmin_Minimized","BangGui","NotificationGui"}, o.Name) then
        o:Destroy()
    end
end

--------------------------------------------------------------------
-- BUILD GUI
--------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name  = "HD_Admin_Lite"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer.PlayerGui

-- Main window
local frame = Instance.new("Frame", gui)
frame.Size  = UDim2.new(0,320,0,380)
frame.Position = UDim2.new(0.5,-160,0.5,-190)
frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
frame.Active, frame.Draggable = true, true

local title = Instance.new("TextLabel", frame)
title.Size  = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(25,25,25)
title.TextColor3       = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "🛠️ HD Admin Lite"
\local btnMin = Instance.new("TextButton", frame)
btnMin.Size  = UDim2.new(0,30,0,30)
btnMin.Position = UDim2.new(1,-30,0,0)
btnMin.Text = "–"
btnMin.TextSize = 20
btnMin.BackgroundColor3 = Color3.fromRGB(60,60,60)
btnMin.TextColor3 = Color3.new(1,1,1)

local btnLang = Instance.new("TextButton", frame)
btnLang.Size  = UDim2.new(0,70,0,30)
btnLang.Position = UDim2.new(1,-110,0,0)
btnLang.BackgroundColor3 = Color3.fromRGB(60,60,60)
btnLang.TextColor3 = Color3.new(1,1,1)
btnLang.Font = Enum.Font.GothamBold
btnLang.TextSize = 14

local btnPrefix = Instance.new("TextButton", frame)
btnPrefix.Size  = UDim2.new(0,70,0,30)
btnPrefix.Position = UDim2.new(1,-190,0,0)
btnPrefix.BackgroundColor3 = Color3.fromRGB(60,60,60)
btnPrefix.TextColor3 = Color3.new(1,1,1)
btnPrefix.Font = Enum.Font.GothamBold
btnPrefix.TextSize = 14

local cmdBox = Instance.new("TextBox", frame)
cmdBox.Size  = UDim2.new(1,-20,0,30)
cmdBox.Position = UDim2.new(0,10,0,40)
cmdBox.BackgroundColor3 = Color3.fromRGB(55,55,55)
cmdBox.TextColor3 = Color3.new(1,1,1)
cmdBox.Font = Enum.Font.Gotham
cmdBox.TextSize = 16
cmdBox.ClearTextOnFocus = false

local btnRun = Instance.new("TextButton", frame)
btnRun.Size  = UDim2.new(1,-20,0,35)
btnRun.Position = UDim2.new(0,10,0,80)
btnRun.BackgroundColor3 = Color3.fromRGB(80,80,80)
btnRun.TextColor3 = Color3.new(1,1,1)
btnRun.Font = Enum.Font.GothamBold
btnRun.TextSize = 16

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size  = UDim2.new(1,-20,0,210)
scroll.Position = UDim2.new(0,10,0,125)
scroll.BackgroundColor3 = Color3.fromRGB(45,45,45)
scroll.ScrollBarThickness = 6
scroll.CanvasSize = UDim2.new(0,0,2,0)

local helpLbl = Instance.new("TextLabel", scroll)
helpLbl.Size  = UDim2.new(1,-10,0,900)
helpLbl.Position = UDim2.new(0,5,0,0)
helpLbl.BackgroundTransparency = 1
helpLbl.TextColor3 = Color3.new(1,1,1)
helpLbl.Font = Enum.Font.Code
helpLbl.TextSize = 14
helpLbl.TextXAlignment = Enum.TextXAlignment.Left
helpLbl.TextYAlignment = Enum.TextYAlignment.Top
helpLbl.TextWrapped = true

local credit = Instance.new("TextLabel", frame)
credit.Size  = UDim2.new(1,-10,0,20)
credit.Position = UDim2.new(0,5,1,-25)
credit.BackgroundTransparency = 1
credit.TextColor3 = Color3.fromRGB(200,200,200)
credit.Font = Enum.Font.Gotham
credit.TextSize = 13
credit.TextXAlignment = Enum.TextXAlignment.Right

-- Minimized drag square
local miniBtn = Instance.new("TextButton", gui)
miniBtn.Name = "HDAdmin_Minimized"
miniBtn.Size = UDim2.new(0,100,0,30)
miniBtn.Position = UDim2.new(0,10,1,-40)
miniBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
miniBtn.TextColor3 = Color3.new(1,1,1)
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextSize = 16
miniBtn.Visible = false
miniBtn.Active, miniBtn.Draggable = true, true

--------------------------------------------------------------------
-- LANGUAGE / HELP REFRESH
--------------------------------------------------------------------
local function refreshTexts()
    if GUI_LANG == "ru" then
        helpLbl.Text = [[
Команды (только для вас):
:fly (me)            — включить полёт
:unfly (me)          — выключить полёт
:noclip (me)         — проход сквозь стены
:clip (me)           — выключить noclip
:fling (me)          — эффект fling
:unfling (me)        — остановить fling
:jumpboost <N>       — сила прыжка N
:infinityjump        — вкл/выкл бесконечные прыжки
:flyspeed <N>        — скорость полёта
:rejoin              — переподключиться
:prefix <символ>     — сменить префикс
:bang                — выполнить Bang V2
:getbang             — выполнить Get Banged
:suc                 — выполнить Suck
:getsuc              — выполнить Get Suc
:jerk                — выполнить Jerk
]]
        btnLang.Text      = "🌐 Рус"
        btnRun.Text       = "▶ Выполнить"
        credit.Text       = "🔧 Сделано SlapBattlesFarmer228"
        miniBtn.Text      = "HD АДМИН"
        cmdBox.PlaceholderText = PREFIX .. "fly (me)"
        btnPrefix.Text    = "Префикс: " .. PREFIX
    else
        helpLbl.Text = [[
Commands (self only):
:fly (me)            — enable flight
:unfly (me)          — disable flight
:noclip (me)         — walk through walls
:clip (me)           — disable noclip
:fling (me)          — fling effect
:unfling (me)        — stop fling
:jumpboost <N>       — jump power N
:infinityjump        — toggle infinite jumps
:flyspeed <N>        — set fly speed
:rejoin              -- rejoin game
:prefix <symbol>     — change prefix
:bang                — execute Bang V2
:getbang             — execute Get Banged
:suc                 — execute Suck
:getsuc              — execute Get Suc
:jerk                — execute Jerk
]]
        btnLang.Text      = "🌐 Eng"
        btnRun.Text       = "▶ Execute"
        credit.Text       = "🔧 Made by SlapBattlesFarmer228"
        miniBtn.Text      = "HD ADMIN"
        cmdBox.PlaceholderText = PREFIX .. "fly (me)"
        btnPrefix.Text    = "Prefix: " .. PREFIX
    end
end
refreshTexts()

btnLang.MouseButton1Click:Connect(function()
    GUI_LANG = (GUI_LANG == "ru") and "en" or "ru"
    refreshTexts()
end)

--------------------------------------------------------------------
-- WINDOW MINIMIZE / RESTORE
--------------------------------------------------------------------
btnMin.MouseButton1Click:Connect(function()
    frame.Visible = false
    miniBtn.Visible = true
end)
miniBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    miniBtn.Visible = false
end)

--------------------------------------------------------------------
-- PREFIX CHANGE VIA BUTTON
--------------------------------------------------------------------
btnPrefix.MouseButton1Click:Connect(function()
    local newPref = cmdBox.Text:match("^%s*([^%s])")
    if newPref and #newPref == 1 then
        PREFIX = newPref
        refreshTexts()
    end
end)

--------------------------------------------------------------------
-- FLY
--------------------------------------------------------------------
local function startFly()
    if Flying then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    Flying = true

    local keys = {W=false,A=false,S=false,D=false,Sp=false,Sh=false}
    local function setKey(on,obj)
        if obj.KeyCode == Enum.KeyCode.W then keys.W=on end
        if obj.KeyCode == Enum.KeyCode.A then keys.A=on end
        if obj.KeyCode == Enum.KeyCode.S then keys.S=on end
        if obj.KeyCode == Enum.KeyCode.D then keys.D=on end
        if obj.KeyCode == Enum.KeyCode.Space then keys.Sp=on end
        if obj.KeyCode == Enum.KeyCode.LeftShift then keys.Sh=on end
    end

    local ib = UserInputService.InputBegan:Connect(function(i,g) if not g then setKey(true,i) end end)
    local ie = UserInputService.InputEnded:Connect(function(i,g) if not g then setKey(false,i) end end)

    FlyConn = RunService.Heartbeat:Connect(function(dt)
        if not Flying or not hrp.Parent then
            if FlyConn then FlyConn:Disconnect() end
            if ib then ib:Disconnect() end
            if ie then ie:Disconnect() end
            return
        end
        local cam = workspace.CurrentCamera
        local dir = Vector3.new()
        if keys.W then dir += cam.CFrame.LookVector end
        if keys.S then dir -= cam.CFrame.LookVector end
        if keys.A then dir -= cam.CFrame.RightVector end
        if keys.D then dir += cam.CFrame.RightVector end
        if keys.Sp then dir += Vector3.new(0,1,0) end
        if keys.Sh then dir -= Vector3.new(0,1,0) end
        if dir.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + dir.Unit * FLY_SPEED * dt
        end
    end)
    showNotification("Полёт включен.")
end

local function stopFly()
    Flying = false
    if FlyConn then FlyConn:Disconnect(); FlyConn = nil end
    showNotification("Полёт выключен.")
end

--------------------------------------------------------------------
-- NOCLIP
--------------------------------------------------------------------
local function startNoclip()
    if Noclipping then return end
    Noclipping = true
    NoclipConn = RunService.Stepped:Connect(function()
        if not Noclipping then return end
        local char = LocalPlayer.Character
        if char then
            for _,p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
    showNotification("Noclip включен.")
end

local function stopNoclip()
    Noclipping = false
    if NoclipConn then NoclipConn:Disconnect(); NoclipConn = nil end
    local char = LocalPlayer.Character
    if char then
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
    showNotification("Noclip выключен.")
end

--------------------------------------------------------------------
-- FLING
--------------------------------------------------------------------
local function startFling()
    if FlingConn then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
    FlingConn = RunService.Heartbeat:Connect(function()
        bv.Velocity = Vector3.new(math.random(-100,100),100,math.random(-100,100))
    end)
    showNotification("Fling включен.")
end

local function stopFling()
    if FlingConn then FlingConn:Disconnect(); FlingConn = nil end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _,c in ipairs(hrp:GetChildren()) do if c:IsA("BodyVelocity") then c:Destroy() end end
        hrp.Velocity = Vector3.zero
    end
    showNotification("Fling выключен.")
end

--------------------------------------------------------------------
-- JUMPBOOST
--------------------------------------------------------------------
local function setJumpPower(val)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
    if hum and val > 0 then
        if hum.UseJumpPower ~= nil then
            hum.JumpPower = val
        else
            hum.JumpHeight = val/5
        end
        showNotification("Сила прыжка установлена на " .. val .. ".")
    end
end

--------------------------------------------------------------------
-- INFINITY JUMP
--------------------------------------------------------------------
local function toggleInfinityJump()
    InfinityJumpOn = not InfinityJumpOn
    if InfinityJumpOn then
        IJConn = UserInputService.JumpRequest:Connect(function()
            if InfinityJumpOn then
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
        showNotification("Бесконечный прыжок включен.")
    else
        if IJConn then IJConn:Disconnect(); IJConn = nil end
        showNotification("Бесконечный прыжок выключен.")
    end
end

--------------------------------------------------------------------
-- FE TROLLING SCRIPTS
--------------------------------------------------------------------
local fe_trolling_scripts = {
    bang    = {name="Bang V2",     r6="https://pastebin.com/raw/aPSHMV6K", r15="https://pastebin.com/raw/1ePMTt9n"},
    getbang = {name="Get Banged",  r6="https://pastebin.com/raw/zHbw7ND1", r15="https://pastebin.com/raw/7hvcjDnW"},
    suc     = {name="Suck",        r6="https://pastebin.com/raw/SymCfnAW", r15="https://pastebin.com/raw/p8yxRfr4"},
    getsuc  = {name="Get Suc",     r6="https://pastebin.com/raw/FPu4e2Qh", r15="https://pastebin.com/raw/DyPP2tAF"},
    jerk    = {name="Jerk",        r6="https://pastefy.app/wa3v2Vgm/raw",   r15="https://pastefy.app/YZoglOyJ/raw"}
}

local function executeScript(name,url)
    if not url then
        warn("URL скрипта " .. name .. " не найден.")
        showNotification("URL скрипта " .. name .. " не найден!")
        return
    end
    local success, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    if success then
        showNotification("Выполнено: " .. name .. "!")
    else
        warn("Ошибка при выполнении скрипта " .. name .. ": " .. tostring(err))
        showNotification("Ошибка при выполнении скрипта: " .. name .. "!")
    end
end

--------------------------------------------------------------------
-- COMMAND PARSER
--------------------------------------------------------------------
local function exec(str)
    if type(str) ~= "string" or #str == 0 then return end
    local originalStr = str

    -- ;jumpboost command (no prefix)
    if str:sub(1,1) == ";" then
        local cmd,val = str:match("^;(%w+)%s*(%d*)")
        if cmd == "jumpboost" and tonumber(val) then
            setJumpPower(tonumber(val))
        else
            showNotification("Неизвестная команда или неправильный формат: " .. originalStr)
        end
        return
    end

    -- Commands with prefix
    if not str:lower():find("^"..PREFIX) then
        showNotification("Команда должна начинаться с префикса: " .. PREFIX)
        return
    end

    local args = {}
    for w in str:gsub("^"..PREFIX,""):gmatch("%S+") do table.insert(args, w) end
    local cmd = args[1] and args[1]:lower() or ""

    if cmd == "fly" then startFly()
    elseif cmd == "unfly" then stopFly()
    elseif cmd == "noclip" then startNoclip()
    elseif cmd == "clip" then stopNoclip()
    elseif cmd == "fling" then startFling()
    elseif cmd == "unfling" then stopFling()
    elseif cmd == "flyspeed" and tonumber(args[2]) then
        FLY_SPEED = tonumber(args[2])
        showNotification("Скорость полёта установлена на " .. FLY_SPEED .. ".")
    elseif cmd == "infinityjump" then toggleInfinityJump()
    elseif cmd == "rejoin" then
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
        showNotification("Переподключение к игре...")
    elseif cmd == "prefix" and args[2] and #args[2] == 1 then
        PREFIX = args[2]
        refreshTexts()
        showNotification("Префикс изменён на '" .. PREFIX .. "'.")
    elseif fe_trolling_scripts[cmd] then
        local sData = fe_trolling_scripts[cmd]
        local url = isR6 and sData.r6 or sData.r15
        executeScript(sData.name, url)
    else
        showNotification("Неизвестная команда: " .. originalStr)
    end
end

--------------------------------------------------------------------
-- GUI EVENTS
--------------------------------------------------------------------
btnRun.MouseButton1Click:Connect(function() exec(cmdBox.Text) end)
cmdBox.FocusLost:Connect(function(enter) if enter then
