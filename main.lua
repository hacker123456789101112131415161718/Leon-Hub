local OrionLib
for _ = 1, 3 do
    local ok, result = pcall(function()
        return loadstring(game:HttpGet('https://raw.githubusercontent.com/hacker123456789101112131415161718/Leons-New-modded-ui/refs/heads/main/moddedui.lua'))()
    end)
    if ok and result then OrionLib = result break end
    task.wait(2)
end
if not OrionLib then error("Leon Hub: failed to load UI library") end

local Window = OrionLib:MakeWindow({
    Name = "Leon Hub V1.1 | Cali Shootout",
    HidePremium = true,
    SaveConfig = true,
    ConfigFolder = "LeonWare",
    IntroEnabled = true,
    IntroText = "Leon Hub V1.1",
    IntroIcon = "rbxassetid://4483345998"
})

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local pid = tostring(game.PlaceId)

if pid ~= "12077443856" then
    LP:Kick("Leon Hub V1.1 | Unsupported game. PlaceId: " .. pid)
    return
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService          = game:GetService("RunService")
local TweenService        = game:GetService("TweenService")

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://10734977012",
    PremiumOnly = false
})

local UIS = game:GetService("UserInputService")
local RS  = RunService

local function getChar() return LP.Character end
local function getHum()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getHrp()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

LP.CharacterAdded:Connect(function(c)
    _char = c
    _hum  = c:FindFirstChildOfClass("Humanoid")
    _hrp  = c:FindFirstChild("HumanoidRootPart")
    task.wait(0.5)
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h then return end
    if cfg.speedOn    then h.WalkSpeed  = cfg.walkSpeed  end
    if cfg.jumpPowerOn then h.JumpPower = cfg.jumpPower  end
end)

local cfg = {
    walkSpeed   = 16,
    flySpeed    = 50,
    jumpPower   = 50,
    spinPower   = 5,
    speedOn     = false,
    flyOn       = false,
    infJumpOn   = false,
    noclipOn    = false,
    clickTpOn   = false,
    spinOn      = false,
    jumpPowerOn = false,
}

local flyConn   = nil
local spinConn  = nil
local ncConn    = nil
local clickConn = nil
local jumpConn  = nil
local velBP     = nil
local speedConn = nil

local MainSection = MainTab:AddSection({ Name = "Player" })

MainSection:AddToggle({
    Name = "Speed",
    Default = false,
    Callback = function(val)
        cfg.speedOn = val
        if speedConn then speedConn:Disconnect() speedConn = nil end
        if val then
            speedConn = RS.Heartbeat:Connect(function()
                if not cfg.speedOn then
                    speedConn:Disconnect() speedConn = nil
                    local h = getHum()
                    if h then h.WalkSpeed = 16 end
                    return
                end
                local h = getHum()
                if h then h.WalkSpeed = cfg.walkSpeed end
            end)
        else
            local h = getHum()
            if h then h.WalkSpeed = 16 end
        end
    end
})

MainSection:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(val)
        cfg.flyOn = val
        if flyConn then flyConn:Disconnect() flyConn = nil end
        if velBP and velBP.Parent then velBP:Destroy() velBP = nil end
        local h = getHum()
        if val then
            local hrp = getHrp()
            if not hrp then cfg.flyOn = false return end
            velBP = Instance.new("BodyVelocity")
            velBP.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            velBP.Velocity  = Vector3.zero
            velBP.Parent    = hrp
            if h then h.PlatformStand = true end
            flyConn = RS.Heartbeat:Connect(function()
                if not cfg.flyOn then
                    flyConn:Disconnect() flyConn = nil
                    if velBP and velBP.Parent then velBP:Destroy() velBP = nil end
                    local hh = getHum()
                    if hh then hh.PlatformStand = false end
                    return
                end
                local hrp2 = getHrp()
                if not hrp2 then return end
                local cam = workspace.CurrentCamera
                local dir = Vector3.zero
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space)     then dir += Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
                if velBP and velBP.Parent ~= hrp2 then velBP.Parent = hrp2 end
                if velBP then
                    velBP.Velocity = dir.Magnitude > 0 and dir.Unit * cfg.flySpeed or Vector3.zero
                end
            end)
        else
            if h then h.PlatformStand = false end
        end
    end
})

MainSection:AddToggle({
    Name = "Inf Jump",
    Default = false,
    Callback = function(val)
        cfg.infJumpOn = val
        if jumpConn then jumpConn:Disconnect() jumpConn = nil end
        if val then
            jumpConn = UIS.JumpRequest:Connect(function()
                if not cfg.infJumpOn then
                    jumpConn:Disconnect() jumpConn = nil
                    return
                end
                local h = getHum()
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    end
})

MainSection:AddToggle({
    Name = "No-Clip",
    Default = false,
    Callback = function(val)
        cfg.noclipOn = val
        if ncConn then ncConn:Disconnect() ncConn = nil end
        if val then
            ncConn = RS.Stepped:Connect(function()
                if not cfg.noclipOn then
                    ncConn:Disconnect() ncConn = nil
                    local c = getChar()
                    if c then for _, p in ipairs(c:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = true end
                    end end
                    return
                end
                local c = getChar()
                if c then for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end end
            end)
        else
            local c = getChar()
            if c then for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end end
        end
    end
})

MainSection:AddToggle({
    Name = "Click To TP",
    Default = false,
    Callback = function(val)
        cfg.clickTpOn = val
        if clickConn then clickConn:Disconnect() clickConn = nil end
        if val then
            clickConn = UIS.InputBegan:Connect(function(input, gpe)
                if gpe or not cfg.clickTpOn then return end
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mouse = LP:GetMouse()
                    local hrp   = getHrp()
                    if mouse.Target and hrp then
                        hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
                    end
                end
            end)
        end
    end
})

MainSection:AddToggle({
    Name = "Spin-Bot",
    Default = false,
    Callback = function(val)
        cfg.spinOn = val
        if spinConn then spinConn:Disconnect() spinConn = nil end
        if val then
            spinConn = RS.Heartbeat:Connect(function()
                if not cfg.spinOn then
                    spinConn:Disconnect() spinConn = nil
                    return
                end
                local hrp = getHrp()
                if hrp then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(cfg.spinPower), 0)
                end
            end)
        end
    end
})

local MainSettingsSection = MainTab:AddSection({ Name = "Settings" })

MainSettingsSection:AddSlider({
    Name = "Walk Speed",
    Min = 0,
    Max = 100,
    Default = 16,
    Increment = 1,
    ValueName = "speed",
    Callback = function(val)
        cfg.walkSpeed = val
        if cfg.speedOn then
            local h = getHum()
            if h then h.WalkSpeed = val end
        end
    end
})

MainSettingsSection:AddSlider({
    Name = "Fly Speed",
    Min = 0,
    Max = 200,
    Default = 50,
    Increment = 1,
    ValueName = "speed",
    Callback = function(val) cfg.flySpeed = val end
})

MainSettingsSection:AddSlider({
    Name = "Jump Power",
    Min = 0,
    Max = 300,
    Default = 50,
    Increment = 5,
    ValueName = "power",
    Callback = function(val)
        cfg.jumpPower = val
        local h = getHum()
        if h then h.JumpPower = val end
    end
})

MainSettingsSection:AddSlider({
    Name = "Spin Power",
    Min = 1,
    Max = 100,
    Default = 5,
    Increment = 1,
    ValueName = "power",
    Callback = function(val) cfg.spinPower = val end
})

local GunTab = Window:MakeTab({
    Name = "Gun Mods",
    Icon = "rbxassetid://10709818534",
    PremiumOnly = false
})

local GunSection = GunTab:AddSection({ Name = "Gun Mods" })
local _gunTbl = nil
local _origVals = nil
local _infAmmoConn = nil
local _gunHeartbeat = nil

local gunCfg = {
    noRecoil   = false,
    noSpread   = false,
    rapidFire  = false,
    neverJam   = false,
    infAmmo    = false,
    noCooldown = false,
    burstFire  = false,
}

local function isGunTable(v)
    return type(v) == "table"
        and rawget(v, "FireRate") ~= nil
        and rawget(v, "Recoil") ~= nil
        and rawget(v, "AmmoPerMag") ~= nil
        and rawget(v, "Spread") ~= nil
        and rawget(v, "BulletSpeed") ~= nil
        and rawget(v, "Auto") ~= nil
        and rawget(v, "Range") ~= nil
        and rawget(v, "HitmarkerEnabled") ~= nil
end

local _gunTbls = {}
local _origValsMap = {}

local function cacheOrig(t)
    if _origValsMap[t] then return end
    _origValsMap[t] = {
        Recoil                = t.Recoil,
        CameraRecoilingEnabled= t.CameraRecoilingEnabled,
        AngleX_Min            = t.AngleX_Min,
        AngleX_Max            = t.AngleX_Max,
        AngleY_Min            = t.AngleY_Min,
        AngleY_Max            = t.AngleY_Max,
        AngleZ_Min            = t.AngleZ_Min,
        AngleZ_Max            = t.AngleZ_Max,
        Spread                = t.Spread,
        BulletBloom           = t.BulletBloom,
        FireRate              = t.FireRate,
        BurstRate             = t.BurstRate,
        Auto                  = t.Auto,
        MinigunEnabled        = t.MinigunEnabled,
        DelayBeforeFiring     = t.DelayBeforeFiring,
        DelayAfterFiring      = t.DelayAfterFiring,
        BurstFireEnabled      = t.BurstFireEnabled,
        FireRates             = t.FireRates and table.clone(t.FireRates) or nil,
        BurstRates            = t.BurstRates and table.clone(t.BurstRates) or nil,
        Mag                   = t.Mag,
        AmmoPerMag            = t.AmmoPerMag,
        Ammo                  = t.Ammo,
        MaxAmmo               = t.MaxAmmo,
        LimitedAmmoEnabled    = t.LimitedAmmoEnabled,
        CooldownTime          = t.CooldownTime,
        ReloadTime            = t.ReloadTime,
        Jammed                = t.Jammed,
        BulletPerBurst        = t.BulletPerBurst,
        BaseDamage            = t.BaseDamage,
        DamageMultipliers     = t.DamageMultipliers and table.clone(t.DamageMultipliers) or nil,
    }
end

local function findAllGunTables()
    local found = {}
    local seen = {}

    local ok1, gc1 = pcall(getgc, true)
    if ok1 and gc1 then
        for _, v in ipairs(gc1) do
            if isGunTable(v) and not seen[v] then
                seen[v] = true
                table.insert(found, v)
                cacheOrig(v)
            end
        end
    end

    if #found == 0 then
        local ok2, gc2 = pcall(getgc, false)
        if ok2 and gc2 then
            for _, fn in ipairs(gc2) do
                if type(fn) == "function" then
                    for i = 1, 50 do
                        local ok3, uv = pcall(debug.getupvalue, fn, i)
                        if not ok3 or uv == nil then break end
                        if isGunTable(uv) and not seen[uv] then
                            seen[uv] = true
                            table.insert(found, uv)
                            cacheOrig(uv)
                        end
                    end
                end
            end
        end
    end

    _gunTbls = found
    return found
end

local function findGunTable()
    if #_gunTbls > 0 and isGunTable(_gunTbls[1]) then return _gunTbls[1] end
    findAllGunTables()
    return _gunTbls[1] or nil
end

local function restoreVal(t, key)
    local orig = _origValsMap[t]
    if orig and orig[key] ~= nil then
        t[key] = orig[key]
    end
end

local function applyMods(t)
    if gunCfg.noRecoil then
        t.Recoil = 0
        t.CameraRecoilingEnabled = false
        t.AngleX_Min = 0 t.AngleX_Max = 0
        t.AngleY_Min = 0 t.AngleY_Max = 0
        t.AngleZ_Min = 0 t.AngleZ_Max = 0
    else
        restoreVal(t,"Recoil") restoreVal(t,"CameraRecoilingEnabled")
        restoreVal(t,"AngleX_Min") restoreVal(t,"AngleX_Max")
        restoreVal(t,"AngleY_Min") restoreVal(t,"AngleY_Max")
        restoreVal(t,"AngleZ_Min") restoreVal(t,"AngleZ_Max")
    end

    if gunCfg.noSpread then
        t.Spread = 0
        if t.BulletBloom ~= nil then t.BulletBloom = 0 end
    else
        restoreVal(t,"Spread") restoreVal(t,"BulletBloom")
    end

    if gunCfg.rapidFire then
        t.FireRate = 0 t.BurstRate = 0
        t.Auto = true t.MinigunEnabled = false
        t.DelayBeforeFiring = 0 t.DelayAfterFiring = 0
        t.BurstFireEnabled = false
        if type(t.FireRates) == "table" then
            for i = 1,#t.FireRates do t.FireRates[i] = 0 end
        end
        if type(t.BurstRates) == "table" then
            for i = 1,#t.BurstRates do t.BurstRates[i] = 0 end
        end
    else
        restoreVal(t,"FireRate") restoreVal(t,"BurstRate")
        restoreVal(t,"Auto") restoreVal(t,"MinigunEnabled")
        restoreVal(t,"DelayBeforeFiring") restoreVal(t,"DelayAfterFiring")
        restoreVal(t,"BurstFireEnabled")
        local orig = _origValsMap[t]
        if orig and type(orig.FireRates) == "table" and type(t.FireRates) == "table" then
            for i = 1,#t.FireRates do t.FireRates[i] = orig.FireRates[i] or t.FireRates[i] end
        end
        if orig and type(orig.BurstRates) == "table" and type(t.BurstRates) == "table" then
            for i = 1,#t.BurstRates do t.BurstRates[i] = orig.BurstRates[i] or t.BurstRates[i] end
        end
    end

    if gunCfg.infAmmo then
        t.Mag = 1e+21
        t.AmmoPerMag = 1e+21
        if t.Ammo ~= nil then t.Ammo = 0 end
        if t.MaxAmmo ~= nil then t.MaxAmmo = 0 end
        t.LimitedAmmoEnabled = false
    else
        restoreVal(t,"Mag") restoreVal(t,"AmmoPerMag")
        restoreVal(t,"Ammo") restoreVal(t,"MaxAmmo")
        restoreVal(t,"LimitedAmmoEnabled")
    end

    if gunCfg.noCooldown then
        if t.CooldownTime ~= nil then t.CooldownTime = 0.001 end
        if t.ReloadTime ~= nil then t.ReloadTime = 0.01 end
    else
        restoreVal(t,"CooldownTime") restoreVal(t,"ReloadTime")
    end

    if gunCfg.neverJam then
        if t.Jammed ~= nil then t.Jammed = false end
    else
        restoreVal(t,"Jammed")
    end

    if gunCfg.burstFire then
        t.BurstFireEnabled = true
        t.BulletPerBurst = 10
        t.BurstRate = 0.001
    else
        restoreVal(t,"BurstFireEnabled") restoreVal(t,"BulletPerBurst")
        if not gunCfg.rapidFire then restoreVal(t,"BurstRate") end
    end

    if gunCfg.superBullet then
        if t.BaseDamage ~= nil then t.BaseDamage = 99999 end
        if type(t.DamageMultipliers) == "table" then t.DamageMultipliers.Head = 99999 end
    else
        restoreVal(t,"BaseDamage")
        local origDM = _origValsMap[t]
        if origDM and type(origDM.DamageMultipliers) == "table" and type(t.DamageMultipliers) == "table" then
            for k, v in pairs(origDM.DamageMultipliers) do t.DamageMultipliers[k] = v end
        end
    end
end

LP.CharacterAdded:Connect(function() _gunTbls = {} _origValsMap = {} end)

_gunHeartbeat = game:GetService("RunService").Heartbeat:Connect(function()
    local anyOn = false
    for _, v in pairs(gunCfg) do if v then anyOn = true break end end
    if not anyOn then return end
    if #_gunTbls == 0 then findAllGunTables() end
    for _, t in ipairs(_gunTbls) do
        if isGunTable(t) then pcall(applyMods, t) end
    end
end)

local function toggleMod(key, val)
    gunCfg[key] = val
    if not val then
        for _, t in ipairs(_gunTbls) do
            if isGunTable(t) then pcall(applyMods, t) end
        end
        local anyStillOn = false
        for _, v in pairs(gunCfg) do if v then anyStillOn = true break end end
        if not anyStillOn then
            _gunTbls = {}
            _origValsMap = {}
        end
    else
        _gunTbls = {}
        _origValsMap = {}
        findAllGunTables()
        for _, t in ipairs(_gunTbls) do
            if isGunTable(t) then pcall(applyMods, t) end
        end
    end
end

GunSection:AddToggle({
    Name = "No Recoil",
    Default = false,
    Callback = function(val) toggleMod("noRecoil", val) end
})

GunSection:AddToggle({
    Name = "No Spread",
    Default = false,
    Callback = function(val) toggleMod("noSpread", val) end
})

GunSection:AddToggle({
    Name = "Rapid Fire",
    Default = false,
    Callback = function(val) toggleMod("rapidFire", val) end
})

GunSection:AddToggle({
    Name = "Never Jam",
    Default = false,
    Callback = function(val) toggleMod("neverJam", val) end
})

GunSection:AddToggle({
    Name = "Infinite Ammo",
    Default = false,
    Callback = function(val)
        toggleMod("infAmmo", val)
        if not val then
            if _infAmmoConn then _infAmmoConn:Disconnect() _infAmmoConn = nil end
        end
    end
})

GunSection:AddToggle({
    Name = "No Cooldown",
    Default = false,
    Callback = function(val) toggleMod("noCooldown", val) end
})

GunSection:AddToggle({
    Name = "Burst Fire",
    Default = false,
    Callback = function(val) toggleMod("burstFire", val) end
})

local AutoFarmTab = Window:MakeTab({
    Name = "AutoFarm",
    Icon = "rbxassetid://10709752630",
    PremiumOnly = false
})

local function Char()
    local c = LP.Character
    if not c then return nil, nil end
    return c, c:FindFirstChild("HumanoidRootPart")
end

local PromptOriginals = {}
local PromptExpanderThread = nil

local function startPromptExpander()
    if PromptExpanderThread then return end
    PromptExpanderThread = task.spawn(function()
        while true do
            task.wait(0.5)
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    pcall(function()
                        if not PromptOriginals[obj] then
                            PromptOriginals[obj] = {
                                MaxActivationDistance = obj.MaxActivationDistance,
                                RequiresLineOfSight = obj.RequiresLineOfSight,
                                HoldDuration = obj.HoldDuration,
                            }
                        end
                        obj.MaxActivationDistance = 999
                        obj.RequiresLineOfSight = false
                        obj.HoldDuration = 0
                    end)
                end
            end
        end
    end)
end

local function stopPromptExpander()
    if PromptExpanderThread then
        task.cancel(PromptExpanderThread)
        PromptExpanderThread = nil
    end
    for obj, original in pairs(PromptOriginals) do
        pcall(function()
            if obj and obj.Parent then
                obj.MaxActivationDistance = original.MaxActivationDistance
                obj.RequiresLineOfSight = original.RequiresLineOfSight
                obj.HoldDuration = original.HoldDuration
            end
        end)
    end
    PromptOriginals = {}
end

local _hubReady = false
local S = { JanitorJob = false, ShowNotifications = true }
local S2 = { BoxFarm = false, ShowBoxNotifications = true }
local S3 = { GrassFarm = false, ShowGrassNotifications = true, SellDelay = 3 }
local S4 = { CheckFarm = false, ShowCheckNotifications = true }

local function anyFarmActive()
    return S.JanitorJob or S2.BoxFarm or S3.GrassFarm or S4.CheckFarm
end

local function makeNotif(title, content, duration)
    OrionLib:MakeNotification({
        Name = title,
        Content = content,
        Image = "rbxassetid://4483345998",
        Time = duration or 4
    })
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LeonHubOverlay"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    if syn then syn.protect_gui(screenGui) end
    screenGui.Parent = game.CoreGui
end)
if not screenGui.Parent then
    screenGui.Parent = LP.PlayerGui
end

local overlayFrame = Instance.new("Frame")
overlayFrame.Size = UDim2.new(0, 200, 0, 28)
overlayFrame.Position = UDim2.new(0.5, -100, 0, 8)
overlayFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
overlayFrame.BackgroundTransparency = 0.3
overlayFrame.BorderSizePixel = 0
overlayFrame.Parent = screenGui

local overlayCorner = Instance.new("UICorner")
overlayCorner.CornerRadius = UDim.new(0, 6)
overlayCorner.Parent = overlayFrame

local overlayStroke = Instance.new("UIStroke")
overlayStroke.Color = Color3.fromRGB(255, 0, 0)
overlayStroke.Thickness = 1
overlayStroke.Parent = overlayFrame

local overlayLabel = Instance.new("TextLabel")
overlayLabel.Size = UDim2.new(1, -10, 1, 0)
overlayLabel.Position = UDim2.new(0, 5, 0, 0)
overlayLabel.BackgroundTransparency = 1
overlayLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
overlayLabel.TextSize = 13
overlayLabel.Font = Enum.Font.GothamBold
overlayLabel.Text = "FPS: -- | Ping: --"
overlayLabel.Parent = overlayFrame

local fpsCount = 0
local lastFpsTime = tick()
local currentFps = 0

RunService.RenderStepped:Connect(function()
    fpsCount = fpsCount + 1
    local now = tick()
    if now - lastFpsTime >= 1 then
        currentFps = fpsCount
        fpsCount = 0
        lastFpsTime = now
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        local ping = 0
        pcall(function()
            ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        overlayLabel.Text = "FPS: " .. currentFps .. " | Ping: " .. ping .. " ms"
    end
end)

local function teleport(position)
    local _, hrp = Char()
    if hrp then hrp.CFrame = CFrame.new(position) end
end

local function fireproximitypromptSafe(prompt)
    if not prompt then return end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 999
        prompt.RequiresLineOfSight = false
    end)
    pcall(function() fireproximityprompt(prompt) end)
end

local Stats = { DirtCleaned = 0, CyclesCompleted = 0 }
local FarmThread = nil
local SessionStart = nil
local StatusLabel = nil
local StatLabel = nil

local function setStatus(msg)
    if StatusLabel then StatusLabel:Set("Status: " .. msg) end
end

local function updateStats()
    if not StatLabel then return end
    local elapsed = SessionStart and math.floor(tick() - SessionStart) or 0
    local mins = math.floor(elapsed / 60)
    local secs = elapsed % 60
    pcall(function()
        StatLabel:Set("Cleaned: " .. Stats.DirtCleaned .. " | Cycles: " .. Stats.CyclesCompleted .. " | Time: " .. string.format("%02d:%02d", mins, secs))
    end)
end

local function isWorking()
    local char = LP.Character
    if not char then return false end
    local v = char:FindFirstChild("ValHolder")
    if not v then return false end
    local iw = v:FindFirstChild("isWorking")
    return iw and iw.Value == true
end

local function acceptJob()
    local giveMop = ReplicatedStorage:FindFirstChild("giveMop")
    if giveMop then
        pcall(function() giveMop:FireServer() end)
        task.wait(1)
    end
    return true
end

local function equipMop()
    local char = LP.Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find("mop") then return true end
        end
    end
    for _ = 1, 20 do
        for _, t in ipairs(LP.Backpack:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find("mop") then
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then hum:EquipTool(t) task.wait(0.3) return true end
            end
        end
        task.wait(0.15)
    end
    return false
end

local function cleanDirt()
    local dirtSpawn = workspace:FindFirstChild("Cleaning_System") and workspace.Cleaning_System:FindFirstChild("Dirt_Spawn")
    if not dirtSpawn then setStatus("dirt spawn missing") return 0 end
    local spots = {}
    for _, child in ipairs(dirtSpawn:GetChildren()) do
        local part, prompt = nil, nil
        if child:IsA("BasePart") then
            part = child
            prompt = child:FindFirstChildOfClass("ProximityPrompt") or child:FindFirstChild("ProximityPrompt", true)
        elseif child:IsA("Model") then
            local mp = child:FindFirstChild("Main") or child:FindFirstChild("Main Part") or child.PrimaryPart
            if not mp then for _, d in ipairs(child:GetDescendants()) do if d:IsA("BasePart") then mp = d break end end end
            part = mp
            prompt = child:FindFirstChild("ProximityPrompt", true)
        end
        if part and prompt then spots[#spots+1] = { part=part, prompt=prompt, pos=part.Position } end
    end
    if #spots == 0 then setStatus("no dirt found") return 0 end
    local _, hrp = Char()
    if hrp then
        local o = hrp.Position
        table.sort(spots, function(a,b) return (a.pos-o).Magnitude < (b.pos-o).Magnitude end)
    end
    setStatus("found " .. #spots .. " spots, cleaning...")
    local cleaned = 0
    for _, d in ipairs(spots) do
        if not S.JanitorJob then break end
        local _, hrp2 = Char()
        if not hrp2 then break end
        if d.part.Transparency ~= 1 then
            teleport(d.pos + Vector3.new(0, 3, 0))
            task.wait(0.25)
            fireproximitypromptSafe(d.prompt)
            task.wait(0.2)
            cleaned = cleaned + 1
            Stats.DirtCleaned = Stats.DirtCleaned + 1
            updateStats()
        end
    end
    return cleaned
end

local function runJanitorCycle()
    if not S.JanitorJob then return end
    local _, hrp = Char()
    if not hrp then setStatus("no character found") return end
    setStatus("checking job...")
    if not isWorking() then
        setStatus("getting job...")
        if not acceptJob() then setStatus("job failed, retrying...") task.wait(2) return end
        task.wait(0.5)
    end
    setStatus("grabbing mop...")
    if not equipMop() then setStatus("mop not found, waiting...") task.wait(2) return end
    task.wait(0.3)
    local cleaned = cleanDirt()
    Stats.CyclesCompleted = Stats.CyclesCompleted + 1
    setStatus("cycle " .. Stats.CyclesCompleted .. " - cleaned " .. cleaned)
    updateStats()
    if S.ShowNotifications and Stats.CyclesCompleted % 5 == 0 then
        makeNotif("Janitor Farm", "Cycles: " .. Stats.CyclesCompleted .. " | Cleaned: " .. Stats.DirtCleaned, 4)
    end
    task.wait(4)
end

local BoxStats = { BoxesDelivered = 0, CyclesCompleted = 0 }
local BoxFarmThread = nil
local BoxSessionStart = nil
local BoxStatusLabel = nil
local BoxStatLabel = nil

local function setBoxStatus(msg)
    if BoxStatusLabel then BoxStatusLabel:Set("Status: " .. msg) end
end

local function updateBoxStats()
    if not BoxStatLabel then return end
    local elapsed = BoxSessionStart and math.floor(tick() - BoxSessionStart) or 0
    local mins = math.floor(elapsed / 60)
    local secs = elapsed % 60
    pcall(function()
        BoxStatLabel:Set("Boxes: " .. BoxStats.BoxesDelivered .. " | Cycles: " .. BoxStats.CyclesCompleted .. " | Time: " .. string.format("%02d:%02d", mins, secs))
    end)
end

local function runBoxCycle()
    if not S2.BoxFarm then return end
    local _, hrp = Char()
    if not hrp then setBoxStatus("no character found") return end
    local jobSystem = workspace:FindFirstChild("Job System")
    local boxJob = jobSystem and jobSystem:FindFirstChild("BoxPickingJob")
    if not boxJob then setBoxStatus("box job not found") task.wait(2) return end
    local boxes = {}
    for _, child in ipairs(boxJob:GetChildren()) do
        if child.Name ~= "Job" then
            local part = child:IsA("BasePart") and child or (child.PrimaryPart or child:FindFirstChildOfClass("BasePart"))
            if not part then for _, d in ipairs(child:GetDescendants()) do if d:IsA("BasePart") then part=d break end end end
            local prompt = child:FindFirstChild("ProximityPrompt", true)
            if part and prompt then boxes[#boxes+1] = { name=child.Name, part=part, prompt=prompt, pos=part.Position } end
        end
    end
    if #boxes == 0 then setBoxStatus("no boxes found") task.wait(2) return end
    local job = boxJob:FindFirstChild("Job")
    if not job then setBoxStatus("dropoff not found") task.wait(2) return end
    local dropPart = job:IsA("BasePart") and job or (job.PrimaryPart or job:FindFirstChildOfClass("BasePart"))
    if not dropPart then for _, d in ipairs(job:GetDescendants()) do if d:IsA("BasePart") then dropPart=d break end end end
    if not dropPart then setBoxStatus("dropoff part missing") task.wait(2) return end
    for _, box in ipairs(boxes) do
        if not S2.BoxFarm then break end
        local _, hrp2 = Char()
        if not hrp2 then break end
        setBoxStatus("picking up " .. box.name)
        hrp2.CFrame = CFrame.new(box.pos + Vector3.new(0, 3, 0))
        task.wait(0.25)
        fireproximitypromptSafe(box.prompt)
        task.wait(0.5)
        local char = LP.Character
        local boxTool = LP.Backpack:FindFirstChild("BOX")
        if boxTool and char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:EquipTool(boxTool) task.wait(0.4) end
        end
        setBoxStatus("dropping off " .. box.name)
        local _, hrp3 = Char()
        if not hrp3 then break end
        hrp3.CFrame = CFrame.new(dropPart.Position + Vector3.new(0, 4, 0))
        task.wait(0.3)
        local char2 = LP.Character
        local handle = nil
        if char2 then
            for _, t in ipairs(char2:GetChildren()) do
                if t:IsA("Tool") and t.Name == "BOX" then handle = t:FindFirstChild("Handle") break end
            end
        end
        local target = handle or hrp3
        if not char2 then break end
        pcall(function() firetouchinterest(target, dropPart, 0) end)
        task.wait(0.1)
        pcall(function() firetouchinterest(target, dropPart, 1) end)
        task.wait(0.3)
        BoxStats.BoxesDelivered = BoxStats.BoxesDelivered + 1
        updateBoxStats()
    end
    BoxStats.CyclesCompleted = BoxStats.CyclesCompleted + 1
    setBoxStatus("looping...")
    updateBoxStats()
    if S2.ShowBoxNotifications and BoxStats.CyclesCompleted % 5 == 0 then
        makeNotif("Box Farm", "Cycles: " .. BoxStats.CyclesCompleted .. " | Boxes: " .. BoxStats.BoxesDelivered, 4)
    end
    task.wait(3)
end

local GrassStats = { GrassCollected = 0, CyclesCompleted = 0, Skipped = 0 }
local GrassFarmThread = nil
local GrassSessionStart = nil
local GrassStatusLabel = nil
local GrassStatLabel = nil

local GRASS_SELL_POS = Vector3.new(-2004.4849853515625, 5.267117500305176, 197.87506103515625)

local GRASS_CFRAMES = {
    CFrame.new(-1989.46448, 6.79505634, 182.808807, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    CFrame.new(-1985.76453, 6.79505634, 182.808807, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    CFrame.new(-1981.86438, 5.19505787, 182.808807, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    CFrame.new(-1975.26453, 3.39505863, 182.808807, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    CFrame.new(-1971.56458, 5.19505787, 182.808807, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    CFrame.new(-1967.66443, 6.79505634, 182.808807, 0, 0, 1, 0, 1, 0, -1, 0, 0),
}

local function setGrassStatus(msg)
    if GrassStatusLabel then GrassStatusLabel:Set("Status: " .. msg) end
end

local function updateGrassStats()
    if not GrassStatLabel then return end
    local elapsed = GrassSessionStart and math.floor(tick() - GrassSessionStart) or 0
    local mins = math.floor(elapsed / 60)
    local secs = elapsed % 60
    local perHour = elapsed > 0 and math.floor(((GrassStats.GrassCollected or 0) / elapsed) * 3600) or 0
    pcall(function()
        GrassStatLabel:Set(
            "Collected: " .. (GrassStats.GrassCollected or 0) ..
            " | Skipped: " .. (GrassStats.Skipped or 0) ..
            " | Time: " .. string.format("%02d:%02d", mins, secs) ..
            " | /hr: " .. perHour
        )
    end)
end

local function getGrassPromptNearCFrame(cf)
    local pos = cf.Position
    local best, bestDist = nil, 8
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and (obj.ActionText == "Take Grass" or obj.ActionText:lower():find("grass")) then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") then
                local dist = (parent.Position - pos).Magnitude
                if dist < bestDist then bestDist = dist best = obj end
            end
        end
    end
    return best
end

local function getSellPoint()
    local best, bestDist = nil, 1e+10
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local dist = (obj.Position - GRASS_SELL_POS).Magnitude
            if dist < bestDist then bestDist = dist best = obj end
        end
    end
    return bestDist < 20 and best or nil
end

local function teleportToSellAndSell()
    local _, hrp = Char()
    if not hrp then return end
    hrp.CFrame = CFrame.new(GRASS_SELL_POS + Vector3.new(0, 4, 0))
    task.wait(0.5)
    local sellPrompt = nil
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") and (parent.Position - GRASS_SELL_POS).Magnitude < 20 then
                sellPrompt = obj break
            end
        end
    end
    if sellPrompt then fireproximitypromptSafe(sellPrompt) task.wait(0.3) end
end

local function equipGrassTool()
    local char = LP.Character
    if not char then return end
    local t = LP.Backpack:FindFirstChild("Grass")
    if t then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(t) task.wait(0.3) end
    end
end

local function runGrassCycle()
    if not S3.GrassFarm then return end
    local _, hrp = Char()
    if not hrp then setGrassStatus("no character found") return end
    local sellPart = getSellPoint()
    if not sellPart then setGrassStatus("sell point not found") task.wait(2) return end
    local anyReady = false
    for _, cf in ipairs(GRASS_CFRAMES) do
        if getGrassPromptNearCFrame(cf) then anyReady = true break end
    end
    if not anyReady then
        setGrassStatus("nothing ready yet...")
        task.wait(5) return
    end
    for i, cf in ipairs(GRASS_CFRAMES) do
        if not S3.GrassFarm then break end
        local _, hrp2 = Char()
        if not hrp2 then break end
        local prompt = getGrassPromptNearCFrame(cf)
        if not prompt then
            setGrassStatus("pot " .. i .. " not ready")
            GrassStats.Skipped = (GrassStats.Skipped or 0) + 1
        else
            setGrassStatus("pot " .. i)
            hrp2.CFrame = cf + Vector3.new(0, 3, 0)
            task.wait(0.3)
            fireproximitypromptSafe(prompt)
            task.wait(0.2)
            for _ = 1, 5 do
                local fp = getGrassPromptNearCFrame(cf)
                if fp then fireproximitypromptSafe(fp) break end
                task.wait(0.1)
            end
            task.wait(0.5)
            local got = false
            for _ = 1, 20 do
                if LP.Backpack:FindFirstChild("Grass") then got = true break end
                local c2 = LP.Character
                if c2 then
                    for _, t in ipairs(c2:GetChildren()) do
                        if t:IsA("Tool") and t.Name == "Grass" then got = true break end
                    end
                end
                if got then break end
                task.wait(0.1)
            end
            if got then
                equipGrassTool()
                task.wait(0.3)
                GrassStats.GrassCollected = (GrassStats.GrassCollected or 0) + 1
                GrassStats.CyclesCompleted = (GrassStats.CyclesCompleted or 0) + 1
                updateGrassStats()
                setGrassStatus("selling...")
                teleportToSellAndSell()
                task.wait(S3.SellDelay)
                if S3.ShowGrassNotifications and GrassStats.CyclesCompleted % 5 == 0 then
                    makeNotif("Grass Farm", "Cycles: " .. GrassStats.CyclesCompleted .. " | Grass: " .. GrassStats.GrassCollected, 4)
                end
            else
                setGrassStatus("missed pot " .. i)
            end
        end
    end
    setGrassStatus("waiting for regrowth...")
    task.wait(5)
end

local CheckStats = { ChecksCompleted = 0, CyclesCompleted = 0 }
local CheckFarmThread = nil
local CheckSessionStart = nil
local CheckStatusLabel = nil
local CheckStatLabel = nil

local CHECK_CLONE_CF    = CFrame.new(-2455.2981, 109.931854, -215.117569, 1, 0, 0, 0, 1, 0, 0, 0, 1)
local CHECK_ACTIVATE_CF = CFrame.new(-2450.46631, 111.450897, -214.559769, -0.0175019503, 0, 0.999846935, 0, 1, 0, -0.999846935, 0, -0.0175019503)
local CHECK_VENDER_CF   = CFrame.new(-2356.46143, 4.81541586, 131.441406, 0, 0, -1, 0, 1, 0, 1, 0, 0)

local function setCheckStatus(msg)
    if CheckStatusLabel then CheckStatusLabel:Set("Status: " .. msg) end
end

local function updateCheckStats()
    if not CheckStatLabel then return end
    local elapsed = CheckSessionStart and math.floor(tick() - CheckSessionStart) or 0
    local mins = math.floor(elapsed / 60)
    local secs = elapsed % 60
    local perHour = elapsed > 0 and math.floor(((CheckStats.ChecksCompleted or 0) / elapsed) * 3600) or 0
    pcall(function()
        CheckStatLabel:Set(
            "Checks: " .. (CheckStats.ChecksCompleted or 0) ..
            " | Cycles: " .. (CheckStats.CyclesCompleted or 0) ..
            " | Time: " .. string.format("%02d:%02d", mins, secs) ..
            " | /hr: " .. perHour
        )
    end)
end

local function firePromptNearCFrame(cf, radius)
    radius = radius or 10
    local pos = cf.Position
    local best, bestDist = nil, radius
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") then
                local dist = (parent.Position - pos).Magnitude
                if dist < bestDist then bestDist = dist best = obj end
            end
        end
    end
    if best then fireproximitypromptSafe(best) return true end
    return false
end

local function runCheckCycle()
    if not S4.CheckFarm then return end
    local _, hrp = Char()
    if not hrp then setCheckStatus("no character found") return end
    setCheckStatus("getting check...")
    hrp.CFrame = CHECK_CLONE_CF + Vector3.new(0, 3, 0)
    task.wait(0.4)
    firePromptNearCFrame(CHECK_CLONE_CF)
    task.wait(0.5)

    setCheckStatus("activating...")
    hrp.CFrame = CHECK_ACTIVATE_CF + Vector3.new(0, 3, 0)
    task.wait(0.4)
    firePromptNearCFrame(CHECK_ACTIVATE_CF)
    task.wait(0.5)

    setCheckStatus("cashing out...")
    hrp.CFrame = CHECK_VENDER_CF + Vector3.new(0, 3, 0)
    task.wait(0.4)
    firePromptNearCFrame(CHECK_VENDER_CF)
    task.wait(0.5)

    CheckStats.ChecksCompleted = (CheckStats.ChecksCompleted or 0) + 1
    CheckStats.CyclesCompleted = (CheckStats.CyclesCompleted or 0) + 1
    updateCheckStats()

    if S4.ShowCheckNotifications and CheckStats.CyclesCompleted % 10 == 0 then
        makeNotif("Check Farm", "Cycles: " .. CheckStats.CyclesCompleted .. " | Checks: " .. CheckStats.ChecksCompleted, 4)
    end

    setCheckStatus("back at spawn...")
    hrp.CFrame = CHECK_CLONE_CF + Vector3.new(0, 3, 0)
    for i = 8, 1, -1 do
        if not S4.CheckFarm then break end
        setCheckStatus("cooldown " .. i .. "s")
        task.wait(1)
    end

    setCheckStatus("looping...")
end

local JanitorSection = AutoFarmTab:AddSection({ Name = "Janitor Job" })

JanitorSection:AddToggle({
    Name = "Enable Janitor Farm",
    Default = false,
    Callback = function(val)
        S.JanitorJob = val
        if val then
            SessionStart = tick()
            Stats = { DirtCleaned = 0, CyclesCompleted = 0 }
            setStatus("starting up...")
            startPromptExpander()
            if FarmThread then task.cancel(FarmThread) end
            FarmThread = task.spawn(function()
                while S.JanitorJob do pcall(runJanitorCycle) task.wait(0.5) end
                setStatus("idle")
            end)
        else
            if FarmThread then task.cancel(FarmThread) FarmThread = nil end
            setStatus("idle")
            if not anyFarmActive() then stopPromptExpander() end
            if _hubReady and S.ShowNotifications then makeNotif("Janitor Farm", "Stopped: " .. Stats.CyclesCompleted .. " cycles", 4) end
        end
    end
})

JanitorSection:AddToggle({
    Name = "Show Notifications",
    Default = true,
    Callback = function(val) S.ShowNotifications = val end
})

local JanitorStatsSection = AutoFarmTab:AddSection({ Name = "Janitor Stats" })
StatusLabel = JanitorStatsSection:AddLabel("Status: Idle")
StatLabel = JanitorStatsSection:AddLabel("Cleaned: 0 | Cycles: 0 | Time: 00:00")
JanitorStatsSection:AddButton({
    Name = "Reset Stats",
    Callback = function()
        Stats = { DirtCleaned = 0, CyclesCompleted = 0 }
        SessionStart = tick()
        updateStats()
        setStatus("stats cleared")
    end
})

local BoxSection = AutoFarmTab:AddSection({ Name = "Box Picking Job" })

BoxSection:AddToggle({
    Name = "Enable Box Farm",
    Default = false,
    Callback = function(val)
        S2.BoxFarm = val
        if val then
            BoxSessionStart = tick()
            BoxStats = { BoxesDelivered = 0, CyclesCompleted = 0 }
            setBoxStatus("starting up...")
            startPromptExpander()
            if BoxFarmThread then task.cancel(BoxFarmThread) end
            BoxFarmThread = task.spawn(function()
                while S2.BoxFarm do pcall(runBoxCycle) task.wait(0.5) end
                setBoxStatus("idle")
            end)
        else
            if BoxFarmThread then task.cancel(BoxFarmThread) BoxFarmThread = nil end
            setBoxStatus("idle")
            if not anyFarmActive() then stopPromptExpander() end
            if _hubReady and S2.ShowBoxNotifications then makeNotif("Box Farm", "Stopped: " .. BoxStats.CyclesCompleted .. " cycles", 4) end
        end
    end
})

BoxSection:AddToggle({
    Name = "Show Notifications",
    Default = true,
    Callback = function(val) S2.ShowBoxNotifications = val end
})

local BoxStatsSection = AutoFarmTab:AddSection({ Name = "Box Stats" })
BoxStatusLabel = BoxStatsSection:AddLabel("Status: Idle")
BoxStatLabel = BoxStatsSection:AddLabel("Boxes: 0 | Cycles: 0 | Time: 00:00")
BoxStatsSection:AddButton({
    Name = "Reset Stats",
    Callback = function()
        BoxStats = { BoxesDelivered = 0, CyclesCompleted = 0 }
        BoxSessionStart = tick()
        updateBoxStats()
        setBoxStatus("stats cleared")
    end
})

local GrassSection = AutoFarmTab:AddSection({ Name = "Grass Picking Job" })

GrassSection:AddToggle({
    Name = "Enable Grass Farm",
    Default = false,
    Callback = function(val)
        S3.GrassFarm = val
        if val then
            GrassSessionStart = tick()
            GrassStats = { GrassCollected = 0, CyclesCompleted = 0, Skipped = 0 }
            setGrassStatus("starting up...")
            startPromptExpander()
            if GrassFarmThread then task.cancel(GrassFarmThread) end
            GrassFarmThread = task.spawn(function()
                while S3.GrassFarm do pcall(runGrassCycle) task.wait(0.5) end
                setGrassStatus("idle")
            end)
        else
            if GrassFarmThread then task.cancel(GrassFarmThread) GrassFarmThread = nil end
            setGrassStatus("idle")
            if not anyFarmActive() then stopPromptExpander() end
            if _hubReady and S3.ShowGrassNotifications then makeNotif("Grass Farm", "Stopped: collected " .. (GrassStats.GrassCollected or 0), 4) end
        end
    end
})

GrassSection:AddToggle({
    Name = "Show Notifications",
    Default = true,
    Callback = function(val) S3.ShowGrassNotifications = val end
})

local GrassStatsSection = AutoFarmTab:AddSection({ Name = "Grass Stats" })
GrassStatusLabel = GrassStatsSection:AddLabel("Status: Idle")
GrassStatLabel = GrassStatsSection:AddLabel("Collected: 0 | Skipped: 0 | Time: 00:00 | /hr: 0")
GrassStatsSection:AddButton({
    Name = "Reset Stats",
    Callback = function()
        GrassStats = { GrassCollected = 0, CyclesCompleted = 0, Skipped = 0 }
        GrassSessionStart = tick()
        updateGrassStats()
        setGrassStatus("stats cleared")
    end
})

local CheckSection = AutoFarmTab:AddSection({ Name = "Fake Check" })

CheckSection:AddToggle({
    Name = "Enable Check Farm",
    Default = false,
    Callback = function(val)
        S4.CheckFarm = val
        if val then
            CheckSessionStart = tick()
            CheckStats = { ChecksCompleted = 0, CyclesCompleted = 0 }
            setCheckStatus("starting up...")
            startPromptExpander()
            if CheckFarmThread then task.cancel(CheckFarmThread) end
            CheckFarmThread = task.spawn(function()
                while S4.CheckFarm do pcall(runCheckCycle) task.wait(0.3) end
                setCheckStatus("idle")
            end)
        else
            if CheckFarmThread then task.cancel(CheckFarmThread) CheckFarmThread = nil end
            setCheckStatus("idle")
            if not anyFarmActive() then stopPromptExpander() end
            if _hubReady and S4.ShowCheckNotifications then makeNotif("Check Farm", "Stopped: " .. (CheckStats.CyclesCompleted or 0) .. " cycles", 4) end
        end
    end
})

CheckSection:AddToggle({
    Name = "Show Notifications",
    Default = true,
    Callback = function(val) S4.ShowCheckNotifications = val end
})

local CheckStatsSection = AutoFarmTab:AddSection({ Name = "Check Stats" })
CheckStatusLabel = CheckStatsSection:AddLabel("Status: Idle")
CheckStatLabel = CheckStatsSection:AddLabel("Checks: 0 | Cycles: 0 | Time: 00:00 | /hr: 0")
CheckStatsSection:AddButton({
    Name = "Reset Stats",
    Callback = function()
        CheckStats = { ChecksCompleted = 0, CyclesCompleted = 0 }
        CheckSessionStart = tick()
        updateCheckStats()
        setCheckStatus("stats cleared")
    end
})

task.spawn(function()
    while true do
        task.wait(1)
        updateStats()
        updateBoxStats()
        updateGrassStats()
        updateCheckStats()
    end
end)

task.wait(1.5)
_hubReady = true
makeNotif("Leon Hub V1.1", "Welcome to Leon Hub V1.1! Enjoy your time.", 5)

OrionLib:Init()
