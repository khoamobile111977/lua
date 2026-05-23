repeat wait() until game:IsLoaded() and game.Players.LocalPlayer
task.wait(4)

if not game.Players.LocalPlayer.Team then
    game.ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", getgenv().Team or "Pirates")
end
repeat wait() until game.Players.LocalPlayer.Team
task.wait(5)

-- Anti-AFK
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

local lp          = game.Players.LocalPlayer
local rs          = game.ReplicatedStorage
local HttpService = game:GetService("HttpService")
local StarterGui  = game:GetService("StarterGui")
local playerName  = lp.Name
local stateFile   = playerName .. "_yamaTushitaCDK.json"

-- ============================================================
--  STATE
-- ============================================================
local function readState()
    if isfile(stateFile) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(stateFile))
        end)
        if ok and type(data) == "table" and data.state then return data end
    end
    return { state = "FARM_YAMA", data = {} }
end

local function writeState(state, extraData)
    writefile(stateFile, HttpService:JSONEncode({
        state     = state,
        data      = extraData or {},
        timestamp = os.time()
    }))
end

-- ============================================================
--  STATUS UI
-- ============================================================
pcall(function()
    if game.CoreGui:FindFirstChild("YamaTushitaCDKStatus") then
        game.CoreGui.YamaTushitaCDKStatus:Destroy()
    end
end)

local StatusGui   = Instance.new("ScreenGui")
local StatusFrame = Instance.new("Frame")
local StatusLabel = Instance.new("TextLabel")
local UICorner_   = Instance.new("UICorner")
local UIStroke_   = Instance.new("UIStroke")

StatusGui.Name           = "YamaTushitaCDKStatus"
StatusGui.Parent         = game.CoreGui
StatusGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
StatusGui.ResetOnSpawn   = false

StatusFrame.Parent                 = StatusGui
StatusFrame.BackgroundColor3       = Color3.fromRGB(20, 20, 25)
StatusFrame.BackgroundTransparency = 0.3
StatusFrame.BorderSizePixel        = 0
StatusFrame.Position               = UDim2.new(0.5, -150, 0, 10)
StatusFrame.Size                   = UDim2.new(0, 300, 0, 60)
UICorner_.CornerRadius             = UDim.new(0, 10)
UICorner_.Parent                   = StatusFrame
UIStroke_.Parent                   = StatusFrame
UIStroke_.Color                    = Color3.fromRGB(138, 43, 226)
UIStroke_.Thickness                = 2
UIStroke_.Transparency             = 0.5

StatusLabel.Parent                 = StatusFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Size                   = UDim2.new(1, -10, 1, -10)
StatusLabel.Position               = UDim2.new(0, 5, 0, 5)
StatusLabel.Font                   = Enum.Font.GothamBold
StatusLabel.TextColor3             = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize               = 13
StatusLabel.TextWrapped            = true
StatusLabel.TextYAlignment         = Enum.TextYAlignment.Top

local statusTexts = {
    FARM_YAMA    = "⚔️ Farm Yama Mastery",
    FARM_TUSHITA = "⚔️ Farm Tushita Mastery",
    GET_CDK      = "🔥 Đang Get CDK",
    FARM_CDK     = "⚔️ Farm CDK Mastery",
    COMPLETED    = "✅ HOÀN THÀNH!"
}

local function updateStatusUI(state, extraText)
    pcall(function()
        StatusLabel.Text = (statusTexts[state] or tostring(state))
            .. (extraText and ("\n" .. extraText) or "")
        if state == "COMPLETED" then
            UIStroke_.Color = Color3.fromRGB(0, 255, 127)
        elseif state == "GET_CDK" then
            UIStroke_.Color = Color3.fromRGB(255, 69, 0)
        elseif tostring(state):find("FARM") then
            UIStroke_.Color = Color3.fromRGB(255, 165, 0)
        else
            UIStroke_.Color = Color3.fromRGB(138, 43, 226)
        end
    end)
    print("[CDK] " .. tostring(state)
        .. (extraText and (" | " .. tostring(extraText):gsub("\n", " ")) or ""))
end

-- ============================================================
--  INVENTORY CACHE – TTL-based như fullybelt7
--  (dùng _ensureCache() để tự động refresh khi hết TTL,
--   thay vì luôn gọi server như cũ – tránh spam request)
-- ============================================================
local CACHE_TTL  = 8     -- giây, giống fullybelt7
local invCache   = {}
local invCacheTs = 0

local function safeInvoke(...)
    local args = { ... }
    local result
    pcall(function() result = rs.Remotes.CommF_:InvokeServer(table.unpack(args)) end)
    return result
end

-- Chỉ gọi server, không đặt điều kiện TTL
local function _refreshCache()
    local inv
    pcall(function() inv = safeInvoke("getInventory") end)
    if type(inv) ~= "table" then return end
    invCache = {}
    for _, item in pairs(inv) do
        if type(item) == "table" and item.Name then
            invCache[item.Name] = {
                count   = item.Count   or 1,
                mastery = item.Mastery or 0,
                itype   = item.Type    or "",
            }
        end
    end
    invCacheTs = tick()
end

-- Refresh nếu cache đã quá TTL (giống fullybelt7)
local function _ensureCache()
    if tick() - invCacheTs > CACHE_TTL then
        _refreshCache()
    end
end

-- Gọi khi khởi động để có data ngay
local function warmupInventoryCache()
    _refreshCache()
end

-- ============================================================
--  CHECK INVENTORY – như hasDojoBelt trong fullybelt7
--  Dùng _ensureCache() (TTL-based) thay vì luôn gọi server
--  → check CDK có chưa giống như check đai đỏ/đen trong belt7
-- ============================================================
local function checkInventory(name)
    _ensureCache()
    return invCache[name] ~= nil
end

local function getItemCount(itemName)
    _ensureCache()
    local e = invCache[itemName]
    return e and e.count or 0
end

-- ============================================================
--  CHECK MASTERY – giống logic DH/DS trong fullybelt7
--  1. Tìm IntValue "Level" trong tool đang cầm / Backpack / wsChars
--     → trả về lv.Value (realtime, không cần server)
--  2. Fallback: mastery từ cache (đã _ensureCache)
-- ============================================================
local function findWeaponLevel(weaponName)
    local locations = {
        workspace.Characters and workspace.Characters:FindFirstChild(playerName),
        lp.Character,
        lp.Backpack,
    }
    for _, container in ipairs(locations) do
        if container then
            local tool = container:FindFirstChild(weaponName)
            if tool then
                local lv = tool:FindFirstChild("Level")
                if lv then return lv, tool end
            end
        end
    end
    return nil, nil
end

local function checkMastery(weaponName)
    -- Ưu tiên Level.Value từ tool (như fullybelt7 dùng cho Dragonheart/Dragonstorm)
    local lv, _ = findWeaponLevel(weaponName)
    if lv then return lv.Value end
    -- Fallback: cache inventory
    _ensureCache()
    local e = invCache[weaponName]
    return (e and e.mastery) or 0
end

-- ============================================================
--  MASTERY WATCHER – giống startWeaponMasteryWatcher fullybelt7
--  Hook Level.Changed + fallback poll 10s (force _refreshCache)
-- ============================================================
local masteryWatcherActive = {}

local function startWeaponMasteryWatcher(weaponName, targetMastery, onReached, uiState)
    if masteryWatcherActive[weaponName] then return end
    masteryWatcherActive[weaponName] = true

    local triggered = false

    local function handleMastery(mas)
        if triggered then return end
        -- Hiển thị trạng thái hiện tại (giống cách DH/DS trong fullybelt7)
        local yama    = checkMastery("Yama")
        local tushita = checkMastery("Tushita")
        local cdk     = checkMastery("Cursed Dual Katana")
        local info    = "Yama: " .. yama .. "/350  Tushita: " .. tushita .. "/350"
        if checkInventory("Cursed Dual Katana") then
            info = info .. "\nCDK: " .. cdk .. "/375"
        end
        updateStatusUI(uiState, info)

        if mas >= targetMastery then
            triggered = true
            masteryWatcherActive[weaponName] = false
            onReached(mas)
        end
    end

    task.spawn(function()
        task.wait(5)

        local currentConn = nil

        local function reconnect()
            if currentConn then
                pcall(function() currentConn:Disconnect() end)
                currentConn = nil
            end
            if triggered then return end
            local lv, _ = findWeaponLevel(weaponName)
            if not lv then return end
            handleMastery(lv.Value)
            currentConn = lv.Changed:Connect(function(newVal)
                handleMastery(newVal)
            end)
        end

        reconnect()

        local bpConn = lp.Backpack.ChildAdded:Connect(function(child)
            if child.Name == weaponName then task.wait(0.1); reconnect() end
        end)

        local function watchChar(char)
            if not char then return end
            char.ChildAdded:Connect(function(child)
                if child.Name == weaponName then task.wait(0.1); reconnect() end
            end)
        end

        local wsChars = workspace:FindFirstChild("Characters")
        if wsChars then
            local myChar = wsChars:FindFirstChild(playerName)
            if myChar then watchChar(myChar) end
            wsChars.ChildAdded:Connect(function(child)
                if child.Name == playerName then
                    task.wait(1); watchChar(child); reconnect()
                end
            end)
        end

        lp.CharacterAdded:Connect(function(char)
            task.wait(1); watchChar(char); reconnect()
        end)

        -- Fallback poll 10s – force _refreshCache để không bỏ lỡ
        while masteryWatcherActive[weaponName] do
            task.wait(10)
            if triggered then break end
            pcall(function()
                _refreshCache()  -- force refresh (không dùng TTL ở đây)
                local lv, _ = findWeaponLevel(weaponName)
                if lv then
                    handleMastery(lv.Value)
                    if not currentConn then reconnect() end
                else
                    local e = invCache[weaponName]
                    local mas = (e and e.mastery) or 0
                    if mas > 0 then handleMastery(mas) end
                end
            end)
        end

        pcall(function() if currentConn then currentConn:Disconnect() end end)
        pcall(function() bpConn:Disconnect() end)
    end)
end

-- ============================================================
--  REJOIN
-- ============================================================
local function rejoin(reason)
    local st = readState()
    updateStatusUI(st.state, reason or "Đang rejoin...")
    task.wait(3)
    rs:WaitForChild("__ServerBrowser"):InvokeServer("teleport", game.JobId)
end

-- ============================================================
--  LOAD WEAPON & EXECUTE CONFIG
-- ============================================================
local function ensureInBackpack(weaponName)
    local inBP   = lp.Backpack:FindFirstChild(weaponName)
    local char   = lp.Character
    local inChar = char and char:FindFirstChild(weaponName)
    if not inBP and not inChar then
        pcall(function()
            rs.Remotes.CommF_:InvokeServer("LoadItem", weaponName)
            task.wait(1.5)
        end)
    end
end

local function executeConfig(configType)
    getgenv().Key = getgenv().Keybanana

    if configType == "FARM_YAMA" then
        updateStatusUI("FARM_YAMA", "Load Yama vào backpack...")
        ensureInBackpack("Yama")
        task.wait(2)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/khoamobile111977/config/refs/heads/main/dh_mas"))()

    elseif configType == "FARM_TUSHITA" then
        updateStatusUI("FARM_TUSHITA", "Load Tushita vào backpack...")
        ensureInBackpack("Tushita")
        task.wait(2)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/khoamobile111977/config/refs/heads/main/dh_mas"))()

    elseif configType == "GET_CDK" then
        updateStatusUI("GET_CDK", "Đang thực hiện Get CDK...")
        task.wait(2)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/khoamobile111977/config/refs/heads/main/cdk"))()

    elseif configType == "FARM_CDK" then
        updateStatusUI("FARM_CDK", "Load Cursed Dual Katana vào backpack...")
        ensureInBackpack("Cursed Dual Katana")
        task.wait(2)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/khoamobile111977/config/refs/heads/main/dh_mas"))()
    end
end

-- ============================================================
--  MONITORING – giống fullybelt7
--
--  FIX CHÍNH:
--  - Mastery states (FARM_YAMA/TUSHITA/CDK): dùng startWeaponMasteryWatcher
--    → hook Level.Changed realtime, không cần rejoin mới check được
--  - GET_CDK và các state khác: dùng checkStateTransition poll (5s)
--    → giống cách fullybelt7 check item trong farm (đai đỏ, bone, egg...)
--  - startMonitoring LUÔN được gọi TRƯỚC executeConfig
--    → tránh bị block khi loadstring chạy BananaHub
-- ============================================================
local monitorActive = false

local function startMonitoring(initState)
    if monitorActive then return end
    monitorActive = true

    -- ── FARM_YAMA: watcher Yama ──────────────────────────────
    if initState == "FARM_YAMA" then
        startWeaponMasteryWatcher("Yama", 350, function(mas)
            local tushita = checkMastery("Tushita")
            if tushita >= 350 then
                writeState("GET_CDK")
                task.wait(2)
                rejoin("Yama " .. mas .. " + Tushita " .. tushita .. " >= 350 → GET_CDK")
            else
                writeState("FARM_TUSHITA")
                task.wait(2)
                rejoin("Yama đủ 350 → FARM_TUSHITA")
            end
        end, "FARM_YAMA")
        return
    end

    -- ── FARM_TUSHITA: watcher Tushita ────────────────────────
    if initState == "FARM_TUSHITA" then
        startWeaponMasteryWatcher("Tushita", 350, function(mas)
            local yama = checkMastery("Yama")
            if yama >= 350 then
                writeState("GET_CDK")
                task.wait(2)
                rejoin("Tushita " .. mas .. " + Yama " .. yama .. " >= 350 → GET_CDK")
            else
                writeState("FARM_YAMA")
                task.wait(2)
                rejoin("Tushita đủ 350 → FARM_YAMA")
            end
        end, "FARM_TUSHITA")
        return
    end

    -- ── FARM_CDK: watcher CDK ────────────────────────────────
    if initState == "FARM_CDK" then
        startWeaponMasteryWatcher("Cursed Dual Katana", 375, function(mas)
            local yama    = checkMastery("Yama")
            local tushita = checkMastery("Tushita")
            writeState("COMPLETED")
            updateStatusUI("COMPLETED",
                "Yama: " .. yama .. " | Tushita: " .. tushita .. " | CDK: " .. mas)
            StarterGui:SetCore("SendNotification", {
                Title    = "✅ HOÀN THÀNH!",
                Text     = "Yama: " .. yama .. " | Tushita: " .. tushita .. " | CDK: " .. mas,
                Duration = 5
            })
            if isfile(stateFile) then delfile(stateFile) end
        end, "FARM_CDK")
        return
    end

    -- ── GET_CDK và các state còn lại: checkStateTransition poll ──
    -- Giống cách fullybelt7 check item khi đang farm (belt, bone, egg...)
    -- Check mỗi 5s, _ensureCache() tự refresh nếu quá TTL
    local function checkStateTransition()
        local saved = readState()
        if not saved then return end
        local st = saved.state

        local yamaMas    = checkMastery("Yama")
        local tushitaMas = checkMastery("Tushita")
        local cdkMas     = checkMastery("Cursed Dual Katana")
        -- checkInventory dùng _ensureCache() – giống check đai trong fullybelt7
        local hasCDK     = checkInventory("Cursed Dual Katana")

        local info = "Yama: " .. yamaMas .. "/350  Tushita: " .. tushitaMas .. "/350"
        if hasCDK then info = info .. "\nCDK: " .. cdkMas .. "/375" end
        updateStatusUI(st, info)

        -- GET_CDK: chờ nhận được CDK rồi chuyển sang FARM_CDK
        if st == "GET_CDK" then
            if hasCDK then
                writeState("FARM_CDK")
                task.wait(2)
                rejoin("Nhận được CDK → FARM_CDK")
            end

        -- Phòng trường hợp state bị lệch trong quá trình farm
        elseif st == "FARM_YAMA" then
            if yamaMas >= 350 then
                if tushitaMas >= 350 then
                    writeState("GET_CDK")
                    task.wait(2)
                    rejoin("Yama + Tushita đủ 350 → GET_CDK")
                else
                    writeState("FARM_TUSHITA")
                    task.wait(2)
                    rejoin("Yama đủ 350 → FARM_TUSHITA")
                end
            end

        elseif st == "FARM_TUSHITA" then
            if tushitaMas >= 350 then
                if yamaMas >= 350 then
                    writeState("GET_CDK")
                    task.wait(2)
                    rejoin("Yama + Tushita đủ 350 → GET_CDK")
                else
                    writeState("FARM_YAMA")
                    task.wait(2)
                    rejoin("Tushita đủ 350 → FARM_YAMA")
                end
            end
        end
    end

    task.spawn(function()
        task.wait(15)  -- chờ script farm ổn định trước
        while monitorActive do
            pcall(checkStateTransition)
            task.wait(5)
        end
    end)
end

-- ============================================================
--  MAIN
--  FIX: startMonitoring gọi TRƯỚC executeConfig
--  → executeConfig gọi loadstring() sẽ block thread hiện tại,
--    nếu startMonitoring gọi sau thì không bao giờ chạy được
-- ============================================================
warmupInventoryCache()
task.wait(1)

local savedData  = readState()
local state      = savedData.state

local yamaMas    = checkMastery("Yama")
local tushitaMas = checkMastery("Tushita")
local cdkMas     = checkMastery("Cursed Dual Katana")
local hasCDK     = checkInventory("Cursed Dual Katana")

updateStatusUI(state,
    "Yama: " .. yamaMas .. "/350  Tushita: " .. tushitaMas .. "/350"
    .. (hasCDK and ("\nCDK: " .. cdkMas .. "/375") or ""))

-- ── Đã hoàn thành tất cả ────────────────────────────────────
if yamaMas >= 350 and tushitaMas >= 350 and cdkMas >= 375 then
    if isfile(stateFile) then delfile(stateFile) end
    updateStatusUI("COMPLETED",
        "Yama: " .. yamaMas .. " | Tushita: " .. tushitaMas .. " | CDK: " .. cdkMas)
    StarterGui:SetCore("SendNotification", {
        Title    = "✅ HOÀN THÀNH!",
        Text     = "Yama, Tushita & CDK đã đạt Mastery!",
        Duration = 5
    })

-- ── Có CDK, Yama+Tushita đủ → farm CDK mastery ──────────────
elseif hasCDK and cdkMas < 375 and yamaMas >= 350 and tushitaMas >= 350 then
    writeState("FARM_CDK")
    startMonitoring("FARM_CDK")   -- ← trước executeConfig
    executeConfig("FARM_CDK")

-- ── Yama+Tushita đủ, chưa có CDK → get CDK ──────────────────
elseif yamaMas >= 350 and tushitaMas >= 350 and not hasCDK then
    writeState("GET_CDK")
    startMonitoring("GET_CDK")    -- ← trước executeConfig
    executeConfig("GET_CDK")

-- ── Farm Yama ────────────────────────────────────────────────
elseif state == "FARM_YAMA" and yamaMas < 350 then
    writeState("FARM_YAMA")
    startMonitoring("FARM_YAMA")  -- ← trước executeConfig
    executeConfig("FARM_YAMA")

-- ── Farm Tushita ─────────────────────────────────────────────
elseif state == "FARM_TUSHITA" and tushitaMas < 350 then
    writeState("FARM_TUSHITA")
    startMonitoring("FARM_TUSHITA")  -- ← trước executeConfig
    executeConfig("FARM_TUSHITA")

-- ── Yama đủ nhưng state lệch ─────────────────────────────────
elseif yamaMas >= 350 and tushitaMas < 350 then
    writeState("FARM_TUSHITA")
    task.wait(2)
    rejoin("Yama đủ 350 → FARM_TUSHITA")

-- ── Tushita đủ nhưng state lệch ──────────────────────────────
elseif tushitaMas >= 350 and yamaMas < 350 then
    writeState("FARM_YAMA")
    task.wait(2)
    rejoin("Tushita đủ 350 → FARM_YAMA")

-- ── Mặc định: bắt đầu từ FARM_YAMA ──────────────────────────
else
    writeState("FARM_YAMA")
    startMonitoring("FARM_YAMA")  -- ← trước executeConfig
    executeConfig("FARM_YAMA")
end
