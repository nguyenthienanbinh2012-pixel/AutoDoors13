return function(VisualLeft, _, Obsidian, Svc)
    local Workspace         = Svc.Workspace
    local RunService        = Svc.RunService
    local Players           = Svc.Players
    local LocalPlayer       = Svc.LocalPlayer
    local ReplicatedStorage = Svc.ReplicatedStorage
    local Camera            = Svc.Camera or Workspace.CurrentCamera

    ------------------------------------------------------------
    -- CONFIG
    ------------------------------------------------------------
 local Config = {
        FillTransparency    = 0.82,
        OutlineTransparency = 0.15,
        TextSize            = 12,
        MinTextSize         = 10,
        MaxTextSize         = 16,
        Font                = Enum.Font.FredokaOne, -- Cartoon Hologram
        StudsOffset         = 2.2,
        MaxDistance         = 350,
        ShowDistance        = true,
        BillboardW          = 120,
        BillboardH          = 20,
        DistUpdateHz        = 8,
    }

    local Colors = {
        Door      = Color3.fromRGB(0x35, 0xDD, 0xF5),
        Cabinet   = Color3.fromRGB(0x8B, 0xDC, 0xF5),
        Chest     = Color3.fromRGB(0xB6, 0x8C, 0xFF),
        Item      = Color3.fromRGB(0xA7, 0x8B, 0xFA),
        Entity    = Color3.fromRGB(0xFF, 0x52, 0x63),
        Gold      = Color3.fromRGB(0xFF, 0xD1, 0x66),
        Lever     = Color3.fromRGB(0xE0, 0xE0, 0xE0),
        Book      = Color3.fromRGB(0x55, 0xE6, 0xA5),
        Breaker   = Color3.fromRGB(0x35, 0xDD, 0xF5),
        Ladder    = Color3.fromRGB(0x8B, 0xDC, 0xF5),
        Fuse      = Color3.fromRGB(0xFF, 0xD1, 0x66),
        Hiding    = Color3.fromRGB(0x8B, 0xDC, 0xF5),
        Player    = Color3.fromRGB(0xEA, 0xF2, 0xFF),
        Objective = Color3.fromRGB(0x55, 0xE6, 0xA5),
    }
    ------------------------------------------------------------
    -- LOOKUP TABLES
    ------------------------------------------------------------
    local Items = {
        KeyObtain="Key", LiveHintBook="Book", Lighter="Lighter", Lockpick="Lockpicks",
        Vitamins="Vitamins", Crucifix="Crucifix", CrucifixWall="Crucifix",
        SkeletonKey="Skeleton Key", Flashlight="Flashlight", Candle="Candle",
        LiveBreakerPolePickup="Fuse", Shears="Shears", Battery="Battery",
        PickupItem="Paper", ElectricalKeyObtain="Electrical Key", Shakelight="Shakelight",
        Scanner="iPad", StarVial="Star Vial", StarBottle="Star Bottle", StarJug="Star Jug",
        Bandage="Bandage", BandagePack="Bandage Pack", BatteryPack="Battery Pack",
        HolyGrenade="Holy Grenade", ShieldMini="Mini Shield", ShieldBig="Big Shield",
        Glowsticks="Glowstick", AlarmClock="Alarm Clock", Compass="Compass",
        Lantern="Lantern", KeyIron="Iron Key", GoldGun="Golden Gun", Candy="Candy",
        WaterPump="Water Pump", VineGuillotine="Vine Lever", LotusPetalPickup="Lotus Petal",
        MouseHole="Louie Mouse", TimerLever="Timer Lever", LeverForGate="Gate Lever",
        Multitool="Multitool", RiftJar="Rift Jar", AloeVera="Aloe Vera",
        Donut="Donut", Lotus="Lotus", BoxingGloves="Boxing Gloves",
    }
    local Entities = {
        RushMoving="Rush", AmbushMoving="Ambush", FigureRagdoll="Figure", FigureRig="Figure",
        FigureLibrary="Figure", Figure="Figure", SeekMoving="Seek", Screech="Screech",
        Eyes="Eyes", Lookman="Eyes", Snare="Snare", A60="A-60", A120="A-120",
        GlitchRush="Glitch Rush", GlitchAmbush="Glitch Ambush", BackdoorRush="Blitz",
        BackdoorLookman="Lookman", JeffTheKiller="Jeff", Groundskeeper="Groundskeeper",
        MonumentEntity="Monument", GrumbleRig="Grumble", GiggleCeiling="Giggle",
        LiveEntityBramble="Bramble", Hole="Mandrake Hole", MandrakeLive="Mandrake",
        DoorFake="Dupe", FakeDoor="Dupe", SideroomSpace="Vacuum",
        GloombatSwarm="Gloombat Swarm", SallyMoving="Sally",
    }
    local Cabinets = {
        Wardrobe="Closet", Backdoor_Wardrobe="Closet", Toolshed="Closet",
        RetroWardrobe="Closet", ["Wardrobe-FOOLS26"]="Closet", Locker_Large="Locker",
        Rooms_Locker="Locker", Rooms_Locker_Fridge="Locker", Bed="Bed",
        Double_Bed="Double Bed", CircularVent="Vent", Dumpster="Dumpster",
    }
    local Chests = {
        ChestBox="Chest", ChestBoxLocked="Locked Chest", Toolbox="Toolbox",
        Toolbox_Locked="Locked Toolbox", Chest_Vine="Vine Chest", Toolshed_Small="Toolshed",
        Locker_Small_Locked="Locked Item Locker",
    }
    local Other = {
        Door="Door", GoldPile="Gold", Ladder="Ladder", FuseObtain="Fuse",
        MinesGenerator="Generator", MinesGateButton="Gate Button", MinesAnchor="Anchor",
    }
    local Objectives = {
        KeyObtain="Door Key", ElectricalKeyObtain="Electrical Key",
        MinesGenerator="Generator", FuseObtain="Generator Fuse",
        LiveHintBook="Hint Book", LiveBreakerPolePickup="Fuse Breaker",
        LibraryHintPaper="Hint Paper", PickupItem="Hint Paper",
        CringlePresent="Present", LeverForGate="Gate Lever",
        MinesGateButton="Gate Button", GardenGateButton="Gate Button",
        TimerLever="Timer Lever", MinesAnchor="Anchor", WaterPump="Water Pump",
        VineGuillotine="Vine Lever",
    }
    local NodeEntities = {
        Rush=true, Ambush=true, Eyes=true, Blitz=true, Lookman=true,
        ["A-60"]=true, ["A-120"]=true, Sally=true, ["Jeff The Killer"]=true,
        Monument=true, ["AR0xMBUSH"]=true, ["RNIUSHCG=="]=true,
    }

    ------------------------------------------------------------
    -- STATE
    ------------------------------------------------------------
    local State = {
        Door=false, Cabinet=false, Chest=false, Item=false, Entity=false,
        Gold=false, Lever=false, Book=false, Breaker=false, Ladder=false,
        Fuse=false, Hiding=false, Player=false, Objective=false,
    }
    local ColorsByCat = {}
    for cat, c in pairs(Colors) do ColorsByCat[cat] = c end

    ------------------------------------------------------------
    -- CORE ESP ENGINE (mới, không trùng lặp)
    ------------------------------------------------------------
    local ActiveESP = setmetatable({}, { __mode = "k" })
    local RoomConn  = setmetatable({}, { __mode = "k" })

    local function GetCurrentRoom()
        return tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 0
    end

    local function GetObjectRoom(obj)
        local r = tonumber(obj:GetAttribute("ParentRoom"))
        if r then return r end
        local rooms = Workspace:FindFirstChild("CurrentRooms")
        if not rooms then return nil end
        for _, room in ipairs(rooms:GetChildren()) do
            local n = tonumber(room.Name)
            if n and obj:IsDescendantOf(room) then
                obj:SetAttribute("ParentRoom", n)
                return n
            end
        end
        return nil
    end

    local function IsVisibleForRoom(obj, roomBased)
        if not roomBased then return true end
        local cur = GetCurrentRoom()
        local oroom = GetObjectRoom(obj)
        if oroom == nil then return true end  -- không xác định → luôn hiện
        return oroom == cur or oroom == cur + 1
    end

    local function CreateESP(obj, text, category, color)
        if not obj or not obj.Parent then return end
        if obj:IsA("ProximityPrompt") then return end
        if ActiveESP[obj] then
            -- update existing
            local d = ActiveESP[obj]
            d.text = text or d.text
            if color then d.color = color end
            if d.highlight then
                d.highlight.FillColor = d.color
                d.highlight.OutlineColor = d.color
            end
            if d.label then
                d.label.Text = d.text
                d.label:SetAttribute("BaseText", d.text)
                d.label.TextColor3 = d.color
                d.label.TextStrokeColor3 = Color3.new(d.color.R/2, d.color.G/2, d.color.B/2)
            end
            return
        end
        color = color or ColorsByCat[category] or Colors.Entity
        text  = text or "ESP"
        local target = obj
        if obj:IsA("Model") and not obj.PrimaryPart then
            local base = obj:FindFirstChildWhichIsA("BasePart")
            if not base then return end
            target = base
        end

        local hl = Instance.new("Highlight")
        hl.Name = "P3_ESP_HL"
        hl.FillColor = color
        hl.OutlineColor = color
        hl.FillTransparency = Config.FillTransparency
        hl.OutlineTransparency = Config.OutlineTransparency
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = target
        hl.Parent = target

        local bb = Instance.new("BillboardGui")
        bb.Name = "P3_ESP_BB"
        bb.Size = UDim2.new(0, 200, 0, 30)
        bb.AlwaysOnTop = true
        bb.StudsOffset = Vector3.new(0, Config.StudsOffset, 0)
        bb.Adornee = target
        bb.Parent = target

        local lbl = Instance.new("TextLabel")
        lbl.Name = "P3_ESP_LBL"
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextScaled = true
        lbl.Text = text
        lbl:SetAttribute("BaseText", text)
        lbl.TextColor3 = color
        lbl.TextStrokeTransparency = 0
        lbl.TextStrokeColor3 = Color3.new(color.R/2, color.G/2, color.B/2)
        lbl.TextSize = Config.TextSize
        lbl.Font = Config.Font
        lbl.Parent = bb

        ActiveESP[obj] = {
            highlight = hl,
            billboard = bb,
            label     = lbl,
            text      = text,
            color     = color,
            category  = category,
            target    = target,
        }

        obj.Destroying:Once(function()
            ActiveESP[obj] = nil
        end)
    end

    local function RemoveESP(obj)
        if not obj then return end
        local d = ActiveESP[obj]
        if d then
            if d.highlight then d.highlight:Destroy() end
            if d.billboard then d.billboard:Destroy() end
            ActiveESP[obj] = nil
        end
        if RoomConn[obj] then
            RoomConn[obj]:Disconnect()
            RoomConn[obj] = nil
        end
    end

    local function RemoveCategory(cat)
        for obj, d in pairs(ActiveESP) do
            if d.category == cat then RemoveESP(obj) end
        end
    end

    local function UpdateColor(cat, color)
        ColorsByCat[cat] = color
        for obj, d in pairs(ActiveESP) do
            if d.category == cat then
                d.color = color
                if d.highlight then
                    d.highlight.FillColor = color
                    d.highlight.OutlineColor = color
                end
                if d.label then
                    d.label.TextColor3 = color
                    d.label.TextStrokeColor3 = Color3.new(color.R/2, color.G/2, color.B/2)
                end
            end
        end
    end

    local function UpdateDistances()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        for obj, d in pairs(ActiveESP) do
            if d.label and d.target and d.target.Parent then
                local dist = math.floor((root.Position - d.target.Position).Magnitude)
                local base = d.label:GetAttribute("BaseText") or d.text
                d.label.Text = Config.ShowDistance and (base .. " [" .. dist .. "m]") or base
            end
        end
    end

    ------------------------------------------------------------
    -- SCANNERS
    ------------------------------------------------------------
    local function ScanRoom(room)
        if not room then return end
        local roomNum = tonumber(room.Name)
        if not roomNum then return end
        local cur = GetCurrentRoom()
        if roomNum < cur or roomNum > cur + 1 then return end

        for _, v in ipairs(room:GetDescendants()) do
            local n = v.Name
            local cat, label
            if State.Item and Items[n] and v:IsA("Model") then
                cat, label = "Item", Items[n]
            elseif State.Entity and Entities[n] then
                cat, label = "Entity", Entities[n]
            elseif State.Cabinet and Cabinets[n] then
                cat, label = "Cabinet", Cabinets[n]
            elseif State.Hiding and Cabinets[n] then
                cat, label = "Hiding", Cabinets[n]
            elseif State.Chest and Chests[n] then
                cat, label = "Chest", Chests[n]
            elseif State.Gold and n == "GoldPile" and v:GetAttribute("GoldValue") then
                cat, label = "Gold", tostring(v:GetAttribute("GoldValue")) .. " Gold"
            elseif State.Lever and n == "LeverForGate" then
                cat, label = "Lever", "Gate Lever"
            elseif State.Book and n == "LiveHintBook" then
                cat, label = "Book", "Library Book"
            elseif State.Breaker and n == "LiveBreakerPolePickup" then
                cat, label = "Breaker", "Breaker"
            elseif State.Ladder and n == "Ladder" then
                cat, label = "Ladder", "Ladder"
            elseif State.Fuse and (n == "FuseObtain" or n == "MinesGenerator" or n == "MinesGateButton") then
                cat, label = "Fuse", Other[n] or "Fuse"
            elseif State.Objective and Objectives[n] then
                cat, label = "Objective", Objectives[n]
            elseif State.Door and n == "Door" and v:IsA("Model") and v.Parent and tonumber(v.Parent.Name) then
                cat, label = "Door", "Door " .. (tonumber(v.Parent.Name) + 1)
            end

            if cat and label then
                CreateESP(v, label, cat, ColorsByCat[cat])
            end
        end
    end

    local function ScanWorkspace()
        if State.Entity then
            for _, v in ipairs(Workspace:GetChildren()) do
                if Entities[v.Name] then
                    CreateESP(v, Entities[v.Name], "Entity", ColorsByCat.Entity)
                end
            end
        end
        if State.Player then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        CreateESP(plr.Character,
                            plr.Name .. " [" .. math.floor(hum.Health / hum.MaxHealth * 100) .. "%]",
                            "Player", ColorsByCat.Player)
                    end
                end
            end
        end
    end

    ------------------------------------------------------------
    -- ROOM-BASED VISIBILITY (mới, không lỗi)
    ------------------------------------------------------------
    local function BindRoomVisibility(obj, roomBased)
        if not roomBased then return end
        local d = ActiveESP[obj]
        if not d then return end

        local function Refresh()
            local vis = IsVisibleForRoom(obj, true)
            if d.highlight then d.highlight.Enabled = vis end
            if d.billboard then d.billboard.Enabled = vis end
        end

        Refresh()

        if RoomConn[obj] then RoomConn[obj]:Disconnect() end
        RoomConn[obj] = LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(Refresh)
    end

    ------------------------------------------------------------
    -- CONNECTIONS
    ------------------------------------------------------------
    local Conns = {}

    Conns.render = RunService.RenderStepped:Connect(function()
        if not (State.Door or State.Cabinet or State.Chest or State.Item or State.Entity
            or State.Gold or State.Lever or State.Book or State.Breaker or State.Ladder
            or State.Fuse or State.Hiding or State.Player or State.Objective) then
            return
        end
        UpdateDistances()
    end)

    Conns.room = LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
        -- xóa ESP không phải entity/player
        for obj, d in pairs(ActiveESP) do
            if d.category ~= "Entity" and d.category ~= "Player" then
                RemoveESP(obj)
            end
        end
        local rooms = Workspace:FindFirstChild("CurrentRooms")
        if rooms then
            local cur = GetCurrentRoom()
            for _, room in ipairs(rooms:GetChildren()) do
                local n = tonumber(room.Name)
                if n and n >= cur and n <= cur + 1 then ScanRoom(room) end
            end
        end
        ScanWorkspace()
    end)

    Conns.desc = Workspace.DescendantAdded:Connect(function(v)
        if v:IsA("ProximityPrompt") then return end
        task.defer(function()
            local rooms = Workspace:FindFirstChild("CurrentRooms")
            if rooms and v:IsDescendantOf(rooms) then
                local room = v:FindFirstAncestorOfClass("Model")
                while room and room.Parent ~= rooms do room = room.Parent end
                if room then ScanRoom(room) end
            elseif Entities[v.Name] and State.Entity then
                CreateESP(v, Entities[v.Name], "Entity", ColorsByCat.Entity)
            end
        end)
    end)

    ------------------------------------------------------------
    -- PUBLIC API
    ------------------------------------------------------------
    local API = {}

    function API:Toggle(cat, value)
        State[cat] = value
        if not value then
            RemoveCategory(cat)
            return
        end
        local rooms = Workspace:FindFirstChild("CurrentRooms")
        if rooms then
            local cur = GetCurrentRoom()
            for _, room in ipairs(rooms:GetChildren()) do
                local n = tonumber(room.Name)
                if n and n >= cur and n <= cur + 1 then ScanRoom(room) end
            end
        end
        ScanWorkspace()
    end

    function API:SetColor(cat, color)      UpdateColor(cat, color) end
    function API:SetFillTransparency(v)
        Config.FillTransparency = v
        for _, d in pairs(ActiveESP) do
            if d.highlight then d.highlight.FillTransparency = v end
        end
    end
    function API:SetOutlineTransparency(v)
        Config.OutlineTransparency = v
        for _, d in pairs(ActiveESP) do
            if d.highlight then d.highlight.OutlineTransparency = v end
        end
    end
    function API:SetTextSize(v)
        Config.TextSize = v
        for _, d in pairs(ActiveESP) do
            if d.label then d.label.TextSize = v end
        end
    end
    function API:SetFont(v)
        Config.Font = v
        for _, d in pairs(ActiveESP) do
            if d.label then d.label.Font = v end
        end
    end
    function API:SetShowDistance(v)
        Config.ShowDistance = v
        UpdateDistances()
    end

    function API:Unload()
        for k, c in pairs(Conns) do
            pcall(function() c:Disconnect() end)
        end
        Conns = {}
        for obj in pairs(ActiveESP) do RemoveESP(obj) end
        for obj, c in pairs(RoomConn) do
            pcall(function() c:Disconnect() end)
            RoomConn[obj] = nil
        end
        ActiveESP = setmetatable({}, { __mode = "k" })
    end

    getgenv().PaintESP = API

    ------------------------------------------------------------
    -- UI (giữ nguyên AddToggle + AddColorPicker cạnh nhau)
    ------------------------------------------------------------
    local Box = VisualLeft
    Box:AddLabel("ESP Toggles", true)

    -- helper: tạo toggle + color picker + callback đồng bộ
    local function MakeESPToggle(id, text, cat, defaultColor, onEnable, onDisable)
        local tog = Box:AddToggle(id, { Text = text, Default = false })
        local col = tog:AddColorPicker(id .. "Color", {
            Text = text,
            Default = defaultColor,
            Transparency = 0,
        })
        col:OnChanged(function(c)
            ColorsByCat[cat] = c
            UpdateColor(cat, c)
        end)
tog:OnChanged(function(v)
            API:Toggle(cat, v)
            if v then
                if onEnable then onEnable() end
            else
                if onDisable then onDisable() end
            end
        end)
        return tog, col
    end
    -- Entity list dropdown
    local entityListVals = {"Rush","Ambush","Eyes","Dupe","Figure","Blitz","Lookman","Snare","Giggle","Gloombat Eggs","Grumble","A-60","A-120","Sally","Jeff the Killer","Groundskeeper","Mandrake Hole","Monument","Bramble","AR0xMBUSH","RNIUSHCG=="}
    local EntityESPOptions = Box:AddDropdown("EntityESPOptions", {
        Text = "Entity List",
        Values = entityListVals,
        Multi = true, AllowNull = true, Default = {},
    })

    -- Khi thay đổi danh sách entity, cập nhật lại ESP
    EntityESPOptions:OnChanged(function()
        if not State.Entity then return end
        -- Xóa ESP entity cũ không còn trong danh sách
        for obj, d in pairs(ActiveESP) do
            if d.category == "Entity" then
                local label = Entities[obj.Name]
                if not label or not EntityESPOptions.Value[label] then
                    RemoveESP(obj)
                end
            end
        end
        -- Quét lại để thêm ESP cho entity mới được chọn
        local rooms = Workspace:FindFirstChild("CurrentRooms")
        if rooms then
            local cur = GetCurrentRoom()
            for _, room in ipairs(rooms:GetChildren()) do
                local n = tonumber(room.Name)
                if n and n >= cur and n <= cur + 1 then ScanRoom(room) end
            end
        end
        ScanWorkspace()
    end)

    ------------------------------------------------------------
    -- ESP TOGGLES (toggle + color picker cạnh nhau)
    ------------------------------------------------------------

    -- Entities (có filter theo EntityESPOptions)
    local entToggle = Box:AddToggle("ESP_Entities", { Text = "Entities", Default = false })
    local entColor = entToggle:AddColorPicker("ESP_EntitiesColor", {
        Text = "Entities",
        Default = ColorsByCat.Entity,
        Transparency = 0,
    })
    entColor:OnChanged(function(c)
        ColorsByCat.Entity = c
        UpdateColor("Entity", c)
    end)
    entToggle:OnChanged(function(v)
        State.Entity = v
        if not v then
            RemoveCategory("Entity")
            return
        end
        -- Chỉ thêm entity có trong danh sách đã chọn
        for _, obj in ipairs(Workspace:GetChildren()) do
            if Entities[obj.Name] and EntityESPOptions.Value[Entities[obj.Name]] then
                CreateESP(obj, Entities[obj.Name], "Entity", ColorsByCat.Entity)
            end
        end
        ScanWorkspace()
    end)

    -- Doors
    local doorToggle = Box:AddToggle("ESP_Doors", { Text = "Doors", Default = false })
    local doorColor = doorToggle:AddColorPicker("ESP_DoorsColor", {
        Text = "Doors",
        Default = ColorsByCat.Door,
        Transparency = 0,
    })
    doorColor:OnChanged(function(c)
        ColorsByCat.Door = c
        UpdateColor("Door", c)
    end)
    doorToggle:OnChanged(function(v)
        API:Toggle("Door", v)
    end)

    -- Hiding Spots
    local hideToggle = Box:AddToggle("ESP_Hide", { Text = "Hiding Spots", Default = false })
    local hideColor = hideToggle:AddColorPicker("ESP_HideColor", {
        Text = "Hiding Spots",
        Default = ColorsByCat.Hiding,
        Transparency = 0,
    })
    hideColor:OnChanged(function(c)
        ColorsByCat.Hiding = c
        UpdateColor("Hiding", c)
    end)
    hideToggle:OnChanged(function(v)
        API:Toggle("Hiding", v)
    end)

    -- Chests
    local chestToggle = Box:AddToggle("ESP_Chest", { Text = "Chests", Default = false })
    local chestColor = chestToggle:AddColorPicker("ESP_ChestColor", {
        Text = "Chests",
        Default = ColorsByCat.Chest,
        Transparency = 0,
    })
    chestColor:OnChanged(function(c)
        ColorsByCat.Chest = c
        UpdateColor("Chest", c)
    end)
    chestToggle:OnChanged(function(v)
        API:Toggle("Chest", v)
    end)

    -- Items
    local itemToggle = Box:AddToggle("ESP_Item", { Text = "Items", Default = false })
    local itemColor = itemToggle:AddColorPicker("ESP_ItemColor", {
        Text = "Items",
        Default = ColorsByCat.Item,
        Transparency = 0,
    })
    itemColor:OnChanged(function(c)
        ColorsByCat.Item = c
        UpdateColor("Item", c)
    end)
    itemToggle:OnChanged(function(v)
        API:Toggle("Item", v)
    end)

    -- Currency (Gold / Stardust)
    local currToggle = Box:AddToggle("ESP_Currency", { Text = "Currency", Default = false })
    local currColor = currToggle:AddColorPicker("ESP_CurrencyColor", {
        Text = "Currency",
        Default = ColorsByCat.Gold,
        Transparency = 0,
    })
    currColor:OnChanged(function(c)
        ColorsByCat.Gold = c
        UpdateColor("Gold", c)
    end)
    currToggle:OnChanged(function(v)
        API:Toggle("Gold", v)
    end)

    -- Ladders
    local ladderToggle = Box:AddToggle("ESP_Ladder", { Text = "Ladders", Default = false })
    local ladderColor = ladderToggle:AddColorPicker("ESP_LadderColor", {
        Text = "Ladders",
        Default = ColorsByCat.Ladder,
        Transparency = 0,
    })
    ladderColor:OnChanged(function(c)
        ColorsByCat.Ladder = c
        UpdateColor("Ladder", c)
    end)
    ladderToggle:OnChanged(function(v)
        API:Toggle("Ladder", v)
    end)

    -- Objectives
    local objToggle = Box:AddToggle("ESP_Obj", { Text = "Objectives", Default = false })
    local objColor = objToggle:AddColorPicker("ESP_ObjColor", {
        Text = "Objectives",
        Default = ColorsByCat.Objective,
        Transparency = 0,
    })
    objColor:OnChanged(function(c)
        ColorsByCat.Objective = c
        UpdateColor("Objective", c)
    end)
    objToggle:OnChanged(function(v)
        API:Toggle("Objective", v)
    end)

    -- Players
    local plrToggle = Box:AddToggle("ESP_Player", { Text = "Players", Default = false })
    local plrColor = plrToggle:AddColorPicker("ESP_PlayerColor", {
        Text = "Players",
        Default = ColorsByCat.Player,
        Transparency = 0,
    })
    plrColor:OnChanged(function(c)
        ColorsByCat.Player = c
        UpdateColor("Player", c)
    end)
    plrToggle:OnChanged(function(v)
        State.Player = v
        if not v then
            RemoveCategory("Player")
            return
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    CreateESP(plr.Character,
                        plr.Name .. " [" .. math.floor(hum.Health / hum.MaxHealth * 100) .. "%]",
                        "Player", ColorsByCat.Player)
                end
            end
        end
    end)

    -- Bật/tắt ESP Player khi player chết hoặc respawn
    Conns.playerAdded = Players.PlayerAdded:Connect(function(plr)
        if plr == LocalPlayer then return end
        plr.CharacterAdded:Connect(function(char)
            if State.Player then
                task.wait(0.5)
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    CreateESP(char,
                        plr.Name .. " [" .. math.floor(hum.Health / hum.MaxHealth * 100) .. "%]",
                        "Player", ColorsByCat.Player)
                end
            end
        end)
    end)

    ------------------------------------------------------------
    -- ESP SETTINGS (sliders + toggles)
    ------------------------------------------------------------
    Box:AddDivider()

    Box:AddSlider("ESP_FillT", {
        Text = "Fill Transparency", Min = 0, Max = 1, Default = 0.75,
        Rounding = 2, Compact = true,
        Callback = function(v) API:SetFillTransparency(v) end,
    })
    Box:AddSlider("ESP_OutlineT", {
        Text = "Outline Transparency", Min = 0, Max = 1, Default = 0,
        Rounding = 2, Compact = true,
        Callback = function(v) API:SetOutlineTransparency(v) end,
    })
    Box:AddSlider("ESP_TextSize", {
        Text = "Text Size", Min = 12, Max = 24, Default = 16,
        Rounding = 0, Compact = true,
        Callback = function(v) API:SetTextSize(v) end,
    })
    Box:AddToggle("ESP_Dist", { Text = "Show Distance", Default = true })
        :OnChanged(function(v) API:SetShowDistance(v) end)

    ------------------------------------------------------------
    -- INITIAL SCAN
    ------------------------------------------------------------
    task.spawn(function()
        local rooms = Workspace:WaitForChild("CurrentRooms", 60)
        if not rooms then return end
        local cur = GetCurrentRoom()
        for _, room in ipairs(rooms:GetChildren()) do
            local n = tonumber(room.Name)
            if n and n >= cur and n <= cur + 1 then ScanRoom(room) end
        end
        ScanWorkspace()
    end)
end
