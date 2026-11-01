return function(VisualLeft, _, Obsidian, Svc)
local Workspace = Svc.Workspace
local RunService = Svc.RunService
local Players = Svc.Players
local LocalPlayer = Svc.LocalPlayer
local Camera = Workspace.CurrentCamera
local ReplicatedStorage = Svc.ReplicatedStorage

local ESP_Config = {
    DoorColor        = Color3.fromRGB(255, 150, 200),
    CabinetColor     = Color3.fromRGB(19, 211, 13),
    ChestColor       = Color3.fromRGB(131, 96, 168),
    ItemColor        = Color3.fromRGB(0, 170, 255),
    EntityColor      = Color3.fromRGB(255, 0, 0),
    GoldColor        = Color3.fromRGB(255, 215, 0),
    LeverColor       = Color3.fromRGB(200, 200, 200),
    BookColor        = Color3.fromRGB(0, 100, 255),
    BreakerColor     = Color3.fromRGB(0, 200, 255),
    LadderColor      = Color3.fromRGB(0, 191, 255),
    FuseColor        = Color3.fromRGB(255, 170, 0),
    HidingColor      = Color3.fromRGB(255, 255, 255),
    PlayerColor      = Color3.fromRGB(180, 180, 180),
    ObjectiveColor   = Color3.fromRGB(0, 255, 0),
    FillTransparency = 0.5,
    OutlineTransparency = 0,
    TextSize         = 16,
    Font             = Enum.Font.Oswald,
    StudsOffset      = 3,
}

local ESP_Items = {
    KeyObtain = "Key", LiveHintBook = "Book", Lighter = "Lighter", Lockpick = "Lockpicks",
    Vitamins = "Vitamins", Crucifix = "Crucifix", CrucifixWall = "Crucifix",
    SkeletonKey = "Skeleton Key", Flashlight = "Flashlight", Candle = "Candle",
    LiveBreakerPolePickup = "Fuse", Shears = "Shears", Battery = "Battery",
    PickupItem = "Paper", ElectricalKeyObtain = "Electrical Key", Shakelight = "Shakelight",
    Scanner = "iPad", StarVial = "Star Vial", StarBottle = "Star Bottle", StarJug = "Star Jug",
    Bandage = "Bandage", BandagePack = "Bandage Pack", BatteryPack = "Battery Pack",
    HolyGrenade = "Holy Grenade", ShieldMini = "Mini Shield", ShieldBig = "Big Shield",
    Glowsticks = "Glowstick", AlarmClock = "Alarm Clock", Compass = "Compass",
    Lantern = "Lantern", KeyIron = "Iron Key", GoldGun = "Golden Gun", Candy = "Candy",
    WaterPump = "Water Pump", VineGuillotine = "Vine Lever", LotusPetalPickup = "Lotus Petal",
    MouseHole = "Louie Mouse", TimerLever = "Timer Lever", LeverForGate = "Gate Lever",
}
local ESP_Entities = {
    RushMoving = "Rush", AmbushMoving = "Ambush", FigureRagdoll = "Figure", FigureRig = "Figure",
    FigureLibrary = "Figure", Figure = "Figure", SeekMoving = "Seek", Screech = "Screech",
    Eyes = "Eyes", Lookman = "Eyes", Snare = "Snare", A60 = "A-60", A120 = "A-120",
    GlitchRush = "Glitch Rush", GlitchAmbush = "Glitch Ambush", BackdoorRush = "Blitz",
    BackdoorLookman = "Lookman", JeffTheKiller = "Jeff", Groundskeeper = "Groundskeeper",
    MonumentEntity = "Monument", GrumbleRig = "Grumble", GiggleCeiling = "Giggle",
    LiveEntityBramble = "Bramble", Hole = "Mandrake Hole", MandrakeLive = "Mandrake",
    DoorFake = "Dupe", FakeDoor = "Dupe", SideroomSpace = "Vacuum",
    GloombatSwarm = "Gloombat Swarm", SallyMoving = "Sally",
}
local ESP_Cabinets = {
    Wardrobe = "Closet", ["Backdoor_Wardrobe"] = "Closet", Toolshed = "Closet",
    RetroWardrobe = "Closet", ["Wardrobe-FOOLS26"] = "Closet", Locker_Large = "Locker",
    Rooms_Locker = "Locker", Rooms_Locker_Fridge = "Locker", Bed = "Bed",
    Double_Bed = "Double Bed", CircularVent = "Vent", Dumpster = "Dumpster",
}
local ESP_Chests = {
    ChestBox = "Chest", ChestBoxLocked = "Locked Chest", Toolbox = "Toolbox",
    Toolbox_Locked = "Locked Toolbox", Chest_Vine = "Vine Chest", Toolshed_Small = "Toolshed",
    Locker_Small_Locked = "Locked Item Locker",
}
local ESP_Other = {
    Door = "Door", GoldPile = "Gold", Ladder = "Ladder", FuseObtain = "Fuse",
    MinesGenerator = "Generator", MinesGateButton = "Gate Button", MinesAnchor = "Anchor",
}

local ESP_State = {
    Door=false, Cabinet=false, Chest=false, Item=false, Entity=false, Gold=false,
    Lever=false, Book=false, Breaker=false, Ladder=false, Fuse=false, Hiding=false,
    Player=false, Objective=false,
}

local ESP_Objects = setmetatable({}, { __mode = "k" })
local ESP_ColorCache = {}

local function ESP_GetCurrentRoom()
    return tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 0
end
local function ESP_GetLatestRoom()
    local gd = ReplicatedStorage:FindFirstChild("GameData")
    if gd and gd:FindFirstChild("LatestRoom") then return gd.LatestRoom.Value end
    return ESP_GetCurrentRoom()
end

local function ESP_Add(obj, text, category, color)
    if not obj or not obj.Parent then return end
    if obj:IsA("ProximityPrompt") then return end
    local existing = ESP_Objects[obj]
    if existing then
        existing.text = text or existing.text
        if color then existing.color = color end
        if existing.label then
            existing.label.Text = existing.text
            existing.label:SetAttribute("BaseText", existing.text)
            existing.label.TextColor3 = existing.color
        end
        if existing.highlight then
            existing.highlight.FillColor = existing.color
            existing.highlight.OutlineColor = existing.color
        end
        return
    end
    color = color or ESP_Config.EntityColor
    text = text or "ESP"
    local target = obj
    if obj:IsA("Model") and not obj.PrimaryPart then
        local base = obj:FindFirstChildWhichIsA("BasePart")
        if base then target = base else return end
    end
    local hl = Instance.new("Highlight")
    hl.Name = "SkyESP_Highlight"
    hl.FillColor = color
    hl.OutlineColor = color
    hl.FillTransparency = ESP_Config.FillTransparency
    hl.OutlineTransparency = ESP_Config.OutlineTransparency
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = target
    hl.Parent = target
    local bb = Instance.new("BillboardGui")
    bb.Name = "SkyESP_Billboard"
    bb.Size = UDim2.new(0, 200, 0, 30)
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, ESP_Config.StudsOffset, 0)
    bb.Adornee = target
    bb.Parent = target
    local lbl = Instance.new("TextLabel")
    lbl.Name = "SkyESP_Label"
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextScaled = true
    lbl.Text = text
    lbl:SetAttribute("BaseText", text)
    lbl.TextColor3 = color
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.new(color.R/2, color.G/2, color.B/2)
    lbl.TextSize = ESP_Config.TextSize
    lbl.Font = ESP_Config.Font
    lbl.Parent = bb
    ESP_Objects[obj] = { highlight=hl, billboard=bb, label=lbl, text=text, color=color, category=category, target=target }
    obj.Destroying:Once(function() ESP_Objects[obj] = nil end)
end

local function ESP_Remove(obj)
    if not obj then return end
    local data = ESP_Objects[obj]
    if data then
        if data.highlight then data.highlight:Destroy() end
        if data.billboard then data.billboard:Destroy() end
        ESP_Objects[obj] = nil
    end
end

local function ESP_RemoveCategory(cat)
    for obj, data in pairs(ESP_Objects) do
        if data.category == cat then ESP_Remove(obj) end
    end
end

local function ESP_UpdateColor(cat, color)
    ESP_ColorCache[cat] = color
    for obj, data in pairs(ESP_Objects) do
        if data.category == cat then
            data.color = color
            if data.highlight then data.highlight.FillColor = color; data.highlight.OutlineColor = color end
            if data.label then data.label.TextColor3 = color; data.label.TextStrokeColor3 = Color3.new(color.R/2, color.G/2, color.B/2) end
        end
    end
end

local function ESP_ScanRoom(room)
    if not room then return end
    local roomNum = tonumber(room.Name) or 0
    local current = ESP_GetCurrentRoom()
    if roomNum < current or roomNum > current + 1 then return end
    for _, v in ipairs(room:GetDescendants()) do
        local n = v.Name
        if ESP_State.Item and ESP_Items[n] and v:IsA("Model") then ESP_Add(v, ESP_Items[n], "Item", ESP_Config.ItemColor) end
        if ESP_State.Entity and ESP_Entities[n] then ESP_Add(v, ESP_Entities[n], "Entity", ESP_Config.EntityColor) end
        if ESP_State.Cabinet and ESP_Cabinets[n] then ESP_Add(v, ESP_Cabinets[n], "Cabinet", ESP_Config.CabinetColor) end
        if ESP_State.Chest and ESP_Chests[n] then ESP_Add(v, ESP_Chests[n], "Chest", ESP_Config.ChestColor) end
        if ESP_State.Gold and n == "GoldPile" and v:GetAttribute("GoldValue") then ESP_Add(v, tostring(v:GetAttribute("GoldValue")).." Gold", "Gold", ESP_Config.GoldColor) end
        if ESP_State.Lever and n == "LeverForGate" then ESP_Add(v, "Gate Lever", "Lever", ESP_Config.LeverColor) end
        if ESP_State.Book and n == "LiveHintBook" then ESP_Add(v, "Library Book", "Book", ESP_Config.BookColor) end
        if ESP_State.Breaker and n == "LiveBreakerPolePickup" then ESP_Add(v, "Breaker", "Breaker", ESP_Config.BreakerColor) end
        if ESP_State.Ladder and n == "Ladder" then ESP_Add(v, "Ladder", "Ladder", ESP_Config.LadderColor) end
        if ESP_State.Fuse and (n=="FuseObtain" or n=="MinesGenerator" or n=="MinesGateButton") then ESP_Add(v, ESP_Other[n] or "Fuse", "Fuse", ESP_Config.FuseColor) end
        if ESP_State.Hiding and ESP_Cabinets[n] then ESP_Add(v, ESP_Cabinets[n], "Hiding", ESP_Config.HidingColor) end
        if ESP_State.Objective and (n=="KeyObtain" or n=="ElectricalKeyObtain" or n=="MinesAnchor" or n=="WaterPump") then ESP_Add(v, ESP_Items[n] or ESP_Other[n] or "Objective", "Objective", ESP_Config.ObjectiveColor) end
        if ESP_State.Door and n == "Door" and v:IsA("Model") and v.Parent and tonumber(v.Parent.Name) then ESP_Add(v, "Door "..(tonumber(v.Parent.Name)+1), "Door", ESP_Config.DoorColor) end
    end
end

local function ESP_ScanWorkspace()
    if ESP_State.Entity then
        for _, v in ipairs(Workspace:GetChildren()) do
            if ESP_Entities[v.Name] then ESP_Add(v, ESP_Entities[v.Name], "Entity", ESP_Config.EntityColor) end
        end
    end
    if ESP_State.Player then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    ESP_Add(plr.Character, plr.Name.." ["..math.floor(hum.Health/hum.MaxHealth*100).."%]", "Player", ESP_Config.PlayerColor)
                end
            end
        end
    end
end

local function ESP_UpdateDistances()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for obj, data in pairs(ESP_Objects) do
        if data.label and data.target then
            local dist = math.floor((root.Position - data.target.Position).Magnitude)
            local base = data.label:GetAttribute("BaseText") or data.text
            data.label.Text = base.." ["..dist.."m]"
        end
    end
end

local ESP_RenderConn = RunService.RenderStepped:Connect(function()
    if not (ESP_State.Door or ESP_State.Cabinet or ESP_State.Chest or ESP_State.Item or ESP_State.Entity or ESP_State.Gold or ESP_State.Lever or ESP_State.Book or ESP_State.Breaker or ESP_State.Ladder or ESP_State.Fuse or ESP_State.Hiding or ESP_State.Player or ESP_State.Objective) then return end
    ESP_UpdateDistances()
end)

local ESP_RoomWatcher = LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
    for obj, data in pairs(ESP_Objects) do
        if data.category ~= "Entity" and data.category ~= "Player" then ESP_Remove(obj) end
    end
    local rooms = Workspace:FindFirstChild("CurrentRooms")
    if rooms then
        local current = ESP_GetCurrentRoom()
        for _, room in ipairs(rooms:GetChildren()) do
            local n = tonumber(room.Name)
            if n and n >= current and n <= current+1 then ESP_ScanRoom(room) end
        end
    end
    ESP_ScanWorkspace()
end)

local ESP_DescConn = Workspace.DescendantAdded:Connect(function(v)
    if v:IsA("ProximityPrompt") then return end
    task.defer(function()
        local rooms = Workspace:FindFirstChild("CurrentRooms")
        if rooms and v:IsDescendantOf(rooms) then
            local room = v:FindFirstAncestorOfClass("Model")
            while room and room.Parent ~= rooms do room = room.Parent end
            if room then ESP_ScanRoom(room) end
        elseif ESP_Entities[v.Name] and ESP_State.Entity then
            ESP_Add(v, ESP_Entities[v.Name], "Entity", ESP_Config.EntityColor)
        end
    end)
end)

local SkyESP = {}
function SkyESP:Toggle(cat, value)
    ESP_State[cat] = value
    if not value then ESP_RemoveCategory(cat) return end
    local rooms = Workspace:FindFirstChild("CurrentRooms")
    if rooms then
        local current = ESP_GetCurrentRoom()
        for _, room in ipairs(rooms:GetChildren()) do
            local n = tonumber(room.Name)
            if n and n >= current and n <= current+1 then ESP_ScanRoom(room) end
        end
    end
    ESP_ScanWorkspace()
end
function SkyESP:SetColor(cat, c) ESP_UpdateColor(cat, c) end
function SkyESP:SetFillTransparency(v) ESP_Config.FillTransparency=v; for _,d in pairs(ESP_Objects) do if d.highlight then d.highlight.FillTransparency=v end end end
function SkyESP:SetOutlineTransparency(v) ESP_Config.OutlineTransparency=v; for _,d in pairs(ESP_Objects) do if d.highlight then d.highlight.OutlineTransparency=v end end end
function SkyESP:SetTextSize(v) ESP_Config.TextSize=v; for _,d in pairs(ESP_Objects) do if d.label then d.label.TextSize=v end end end
function SkyESP:SetFont(v) ESP_Config.Font=v; for _,d in pairs(ESP_Objects) do if d.label then d.label.Font=v end end end
function SkyESP:Unload()
    if ESP_RenderConn then ESP_RenderConn:Disconnect() end
    if ESP_RoomWatcher then ESP_RoomWatcher:Disconnect() end
    if ESP_DescConn then ESP_DescConn:Disconnect() end
    for obj in pairs(ESP_Objects) do ESP_Remove(obj) end
    ESP_Objects = setmetatable({}, { __mode = "k" })
end
getgenv().SkyESP = SkyESP


local T, C, TOGS, ESPObjs, ESPConnections = {}, {}, {}, {}, {}
local Objects = {
	Doors = {},
	HidingSpots = {},
	Entities = {},
	Chests = {},
	Items = {},
	Currency = {},
	Ladders = {},
	Objectives = {},
	Players = {}
}

local Entities = {
	["RushMoving"] = {Alias = "Rush", NotifyMessage = {Title = "Entity 'Rush' has spawned.", Body = "Find a hiding spot."}},
	["AmbushMoving"] = {Alias = "Ambush", NotifyMessage = {Title = "Entity 'Ambush' has spawned.", Body = "Find a hiding spot."}},
	["Eyes"] = {Alias = "Eyes", NotifyMessage = {Title = "Entity 'Eyes' has spawned.", Body = "Avoid looking at it."}},
	["Lookman"] = {Alias = "Eyes", NotifyMessage = {Title = "Entity 'Eyes' has spawned.", Body = "Avoid looking at it."}},
	["BackdoorRush"] = {Alias = "Blitz", NotifyMessage = {Title = "Entity 'Blitz' has spawned.", Body = "Find a hiding spot."}},
	["BackdoorLookman"] = {Alias = "Lookman", NotifyMessage = {Title = "Entity 'Lookman' has spawned.", Body = "Avoid looking at its eyes."}},
	["Groundskeeper"] = {Alias = "Groundskeeper", NotifyMessage = {Title = "Entity 'Groundskeeper' has spawned.", Body = "Avoid stepping on the grass."}},
	["A60"] = {Alias = "A-60", NotifyMessage = {Title = "Entity 'A-60' has spawned.", Body = "Find a hiding spot."}},
	["A120"] = {Alias = "A-120", NotifyMessage = {Title = "Entity 'A-120' has spawned.", Body = "Find a hiding spot."}},
	["GloombatSwarm"] = {Alias = "Gloombat Swarm", NotifyMessage = {Title = "Entity 'Gloombat Swarm' has spawned.", Body = "Keep all light sources turned off."}},
	["GlitchRush"] = {Alias = "RNIUSHCG==", NotifyMessage = {Title = "Entity 'RNIUSHCG==' has spawned.", Body = "Find a hiding spot."}},
	["GlitchAmbush"] = {Alias = "AR0xMBUSH", NotifyMessage = {Title = "Entity 'AR0xMBUSH' has spawned.", Body = "Find a hiding spot."}},
	["MonumentEntity"] = {Alias = "Monument", NotifyMessage = {Title = "Entity 'Monument' has spawned.", Body = "It can't move while you are looking at it."}},
	["JeffTheKiller"] = {Alias = "Jeff the Killer", NotifyMessage = {Title = "Entity 'Jeff the Killer' has spawned.", Body = "Avoid touching him."}},
	["CustomEntity"] = {Alias = "Custom Entity", NotifyMessage = {Title = "Entity 'Custom Entity' has spawned.", Body = "Find a hiding spot."}},
	["FrozenAmbush"] = {Alias = "Frozen Ambush", NotifyMessage = {Title = "Entity 'Frozen Ambush' has spawned.", Body = "Find a hiding spot."}},
	["SallyMoving"] = {Alias = "Sally", NotifyMessage = {Title = "Entity 'Sally' has spawned.", Body = "Drop an item for her."}}
}

local EntityIcons = {
	["RushMoving"] = "rbxassetid://10716032262",
	["AmbushMoving"] = "rbxassetid://10110576663",
	["A60"] = "rbxassetid://12571092295",
	["A120"] = "rbxassetid://12711591665",
	["BackdoorRush"] = "rbxassetid://16602023490",
	["Eyes"] = "rbxassetid://10183704772",
	["Lookman"] = "rbxassetid://10183704772",
	["BackdoorLookman"] = "rbxassetid://16764872677",
	["GloombatSwarm"] = "rbxassetid://79221203116470",
	["Halt"] = "rbxassetid://11331795398",
	["JeffTheKiller"] = "rbxassetid://94479432156278",
	["GlitchRush"] = "rbxassetid://73859273102919",
	["GlitchAmbush"] = "rbxassetid://88369678433359",
	["SallyMoving"] = "rbxassetid://10840888070",
	["MonumentEntity"] = "rbxassetid://88933556873017",
	["Groundskeeper"] = "rbxassetid://114991380115557"
}

local EntityESPLabels = {
	JeffTheKiller = "Jeff the Killer",
	GiggleCeiling = "Giggle",
	Snare = "Snare",
	GrumbleRig = "Grumble",
	Drakobloxxer = "Drakobloxxer",
	Hole = "Mandrake Hole",
	Groundskeeper = "Groundskeeper",
	LiveEntityBramble = "Bramble",
	Figure = "Figure",
	FigureRig = "Figure",
	FigureRagdoll = "Figure",
	FakeDoor = "Dupe",
	DoorFake = "Dupe"
}

local HidingSpotLabels = {
	Wardrobe = "Closet",
	["Backdoor_Wardrobe"] = "Closet",
	Toolshed = "Closet",
	RetroWardrobe = "Closet",
	["Wardrobe-FOOLS26"] = "Closet",
	Locker_Large = "Locker",
	Rooms_Locker = "Locker",
	Rooms_Locker_Fridge = "Locker",
	Bed = "Bed",
	Double_Bed = "Double Bed",
	CircularVent = "Vent",
	Dumpster = "Dumpster"
}

local ObjectiveLabels = {
	KeyObtain = "Door Key",
	ElectricalKeyObtain = "Electrical Key",
	MinesGenerator = "Generator",
	FuseObtain = "Generator Fuse",
	LiveHintBook = "Hint Book",
	LiveBreakerPolePickup = "Fuse Breaker",
	LibraryHintPaper = "Hint Paper",
	PickupItem = "Hint Paper",
	CringlePresent = "Present",
	LeverForGate = "Gate Lever",
	MinesGateButton = "Gate Button",
	GardenGateButton = "Gate Button"
}

local ItemNames = {
	Lighter = "Lighter",
	Flashlight = "Flashlight",
	Lockpick = "Lockpicks",
	Vitamins = "Vitamins",
	Bandage = "Bandage",
	StarVial = "Starlight Vial",
	StarBottle = "Starlight Bottle",
	StarJug = "Starlight Barrel",
	Shakelight = "Gummy Flashlight",
	Straplight = "Straplight",
	Bulklight = "Spotlight",
	Battery = "Battery",
	Candle = "Candle",
	Crucifix = "Crucifix",
	CrucifixWall = "Crucifix",
	Glowsticks = "Glowstick",
	SkeletonKey = "Skeleton Key",
	Candy = "Candy",
	ShieldMini = "Mini Shield Potion",
	ShieldBig = "Big Shield Potion",
	BandagePack = "Bandage Pack",
	BatteryPack = "Battery Pack",
	RiftCandle = "Moonlight Candle",
	LaserPointer = "Laser Pointer",
	HolyGrenade = "Holy Hand Grenade",
	Shears = "Shears",
	Smoothie = "Smoothie",
	Cheese = "Cheese",
	Bread = "Bread",
	AlarmClock = "Alarm Clock",
	RiftSmoothie = "Moonlight Smoothie",
	GweenSoda = "Gween Soda",
	GlitchCube = "Glitch Fragment",
	Scanner = "Tablet",
	Bomb = "Bomb",
	Knockbomb = "Knockbomb",
	Nanner = "Nanner",
	BigBomb = "Big Bomb",
	SnakeBox = "Hiding Box",
	GoldGun = "Golden Gun",
	StopSign = "Stop Sign",
	TipJar = "Tip Jar",
	Lantern = "Lantern",
	IronKey = "Iron Key",
	LotusPetal = "Lotus Petal",
	Compass = "Compass",
	LotusPetalPickup = "Lotus Petal",
	LanternLitItem = "Lantern",
	KeyIron = "Iron Key",
	IronKeyForCrypt = "Iron Key",
	LotusHolder = "Lotus Petal",
	Multitool = "Multitool",
	RiftJar = "Rift Jar",
	AloeVera = "Aloe Vera",
	Donut = "Donut",
	Lotus = "Lotus",
	BoxingGloves = "Boxing Gloves"
}

local NodeEntities = {
	Rush = true, Ambush = true, Eyes = true, Blitz = true, Lookman = true,
	["A-60"] = true, ["A-120"] = true, Sally = true, ["Jeff The Killer"] = true,
	Monument = true, ["AR0xMBUSH"] = true, ["RNIUSHCG=="] = true
}

local function notify(title, body, time)
	pcall(function()
		Obsidian:Notify({Title = title or "ESP", Description = body or "", Time = time or 4})
	end)
end

local function GetDoorNumber(obj)
	local n = tonumber(obj.Parent and obj.Parent.Name) or tonumber(obj.Parent and obj.Parent.Parent and obj.Parent.Parent.Name)
	if n then n = n + 1 end
	local gd = ReplicatedStorage:FindFirstChild("GameData")
	local floor = gd and gd:FindFirstChild("Floor") and gd.Floor.Value
	if floor == "Mines" then n = n + 100 end
	if floor == "Backdoor" then n = n - 50 end
	return tostring(n or "?")
end

local function AddESP(opts, roomBased)
	local obj = opts.Object
	if not obj or not obj.Parent then return end
	if ESPObjs[obj] then return end
	local hl = Instance.new("Highlight")
	hl.Name = "ESP_HL"
	hl.Adornee = obj
	hl.FillColor = opts.Color or Color3.fromRGB(255, 0, 0)
	hl.OutlineColor = opts.Color or Color3.fromRGB(255, 0, 0)
	hl.FillTransparency = T.fillT or 0.75
	hl.OutlineTransparency = T.outlineT or 0
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = obj
	local bb = Instance.new("BillboardGui")
	bb.Name = "ESP_BB"
	bb.Adornee = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
	bb.Size = UDim2.new(0, 200, 0, 50)
	bb.StudsOffset = Vector3.new(0, 2.5, 0)
	bb.AlwaysOnTop = true
	bb.Parent = obj
	local tl = Instance.new("TextLabel")
	tl.BackgroundTransparency = 1
	tl.Size = UDim2.new(1, 0, 1, 0)
	tl.Text = opts.Text or obj.Name
	tl.TextColor3 = opts.Color or Color3.fromRGB(255, 255, 255)
	tl.TextStrokeTransparency = T.textOutlineT or 0
	tl.TextSize = T.textSize or 16
	tl.Font = Enum.Font.GothamBold
	tl.Parent = bb
	ESPObjs[obj] = {HL = hl, BB = bb, Label = tl, Color = opts.Color}
	if roomBased then
		local conn = LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
			local cur = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))
			local oroom = tonumber(obj:GetAttribute("ParentRoom"))
			if oroom == cur or (Objects.Doors and table.find(Objects.Doors, obj) and oroom == cur + 1) then
				if hl then hl.Enabled = true end
				if bb then bb.Enabled = true end
			else
				if hl then hl.Enabled = false end
				if bb then bb.Enabled = false end
			end
		end)
		ESPConnections[obj] = conn
	end
end

local function RemoveESP(obj)
	if not obj then return end
	local data = ESPObjs[obj]
	if data then
		if data.HL then data.HL:Destroy() end
		if data.BB then data.BB:Destroy() end
		ESPObjs[obj] = nil
	end
	if ESPConnections[obj] then
		ESPConnections[obj]:Disconnect()
		ESPConnections[obj] = nil
	end
end

local function UpdateColor(obj, color)
	local data = ESPObjs[obj]
	if data then
		if data.HL then
			data.HL.FillColor = color
			data.HL.OutlineColor = color
		end
		if data.Label then data.Label.TextColor3 = color end
		data.Color = color
	end
end

local function addTog(side, id, text, key, onEnable, onDisable)
	local tog = side:AddToggle(id, {Text = text, Default = false})
	TOGS[key] = tog
	tog:OnChanged(function(v)
		T[key] = v
		if v then onEnable() else onDisable() end
	end)
	return tog
end

local function addColor(tog, id, text, def)
	return tog:AddColorPicker(id, {Text = text, Default = def or Color3.fromRGB(255, 255, 255)})
end

-- UI
local ESPBox = VisualLeft
ESPBox:AddLabel("ESP Toggles", true)

local entityListVals = {"Rush","Ambush","Eyes","Dupe","Figure","Blitz","Lookman","Snare","Giggle","Gloombat Eggs","Grumble","A-60","A-120","Sally","Jeff the Killer","Groundskeeper","Mandrake Hole","Monument","Bramble","AR0xMBUSH","RNIUSHCG=="}
local entityNotifyVals = {"Rush","Ambush","Eyes","Halt","Blitz","Lookman","Gloombat Swarm","A-60","A-120","Sally","Jeff the Killer","Groundskeeper","Monument","AR0xMBUSH","RNIUSHCG=="}

local EntityESPOptions = ESPBox:AddDropdown("EntityESPOptions", {
	Text = "Entity List",
	Values = entityListVals,
	Multi = true,
	AllowNull = true,
	Default = {}
})

local EntityNotifyList = ESPBox:AddDropdown("EntityNotifyList", {
	Text = "Notify Entity List",
	Values = entityNotifyVals,
	Multi = true,
	AllowNull = true,
	Default = {}
})

addTog(ESPBox, "ESP_Entities", "Entities", "ent", function()
	for _, obj in ipairs(Objects.Entities) do
		local label = EntityESPLabels[obj.Name]
		if not label and Entities[obj.Name] then label = Entities[obj.Name].Alias end
		if label and EntityESPOptions.Value[label] then
			AddESP({Object = obj, Text = label, Color = T.entColor or Color3.fromRGB(255, 0, 0)}, not NodeEntities[label])
		end
	end
end, function()
	for _, obj in ipairs(Objects.Entities) do RemoveESP(obj) end
end)
local entColor = addColor(TOGS.ent, "ESP_EntColor", "Entities", Color3.fromRGB(255, 0, 0))
entColor:OnChanged(function(c)
	T.entColor = c
	for _, obj in ipairs(Objects.Entities) do UpdateColor(obj, c) end
end)

addTog(ESPBox, "ESP_Doors", "Doors", "door", function()
	for _, obj in ipairs(Objects.Doors) do
		AddESP({Object = obj, Text = "Door " .. GetDoorNumber(obj), Color = T.doorColor or Color3.fromRGB(0, 200, 255)}, true)
	end
end, function()
	for _, obj in ipairs(Objects.Doors) do RemoveESP(obj) end
end)
local doorColor = addColor(TOGS.door, "ESP_DoorColor", "Doors", Color3.fromRGB(0, 200, 255))
doorColor:OnChanged(function(c)
	T.doorColor = c
	for _, obj in ipairs(Objects.Doors) do UpdateColor(obj, c) end
end)

addTog(ESPBox, "ESP_Hide", "Hiding Spots", "hide", function()
	for _, obj in ipairs(Objects.HidingSpots) do
		local label = HidingSpotLabels[obj.Name]
		if label then
			AddESP({Object = obj, Text = label, Color = T.hideColor or Color3.fromRGB(255, 170, 0)}, true)
		end
	end
end, function()
	for _, obj in ipairs(Objects.HidingSpots) do RemoveESP(obj) end
end)
local hideColor = addColor(TOGS.hide, "ESP_HideColor", "Hiding Spots", Color3.fromRGB(255, 170, 0))
hideColor:OnChanged(function(c)
	T.hideColor = c
	for _, obj in ipairs(Objects.HidingSpots) do UpdateColor(obj, c) end
end)

addTog(ESPBox, "ESP_Player", "Players", "plr", function()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr:GetAttribute("Alive") == true then
			AddESP({Object = plr.Character, Text = plr.Name, Color = T.plrColor or Color3.fromRGB(255, 255, 255)})
		end
	end
end, function()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then RemoveESP(plr.Character) end
	end
end)
local plrColor = addColor(TOGS.plr, "ESP_PlrColor", "Players", Color3.fromRGB(255, 255, 255))
plrColor:OnChanged(function(c)
	T.plrColor = c
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then UpdateColor(plr.Character, c) end
	end
end)

addTog(ESPBox, "ESP_Chest", "Chests", "chest", function()
	for _, obj in ipairs(Objects.Chests) do
		local label
		if obj.Name == "ChestBox" or obj.Name == "ChestBoxLocked" then
			label = obj:GetAttribute("Locked") and "Locked Chest" or "Chest"
		elseif obj.Name == "Toolbox" or obj.Name == "Toolbox_Locked" then
			label = obj:GetAttribute("Locked") and "Locked Toolbox" or "Toolbox"
		elseif obj.Name == "Chest_Vine" then label = "Vine Chest"
		elseif obj.Name == "Toolshed_Small" then label = "Toolshed"
		elseif obj.Name == "Locker_Small_Locked" then label = "Locked Item Locker"
		elseif obj.Name == "MouseHole" then label = "Mouse"
		end
		if label then
			AddESP({Object = obj, Text = label, Color = T.chestColor or Color3.fromRGB(255, 255, 0)}, true)
		end
	end
end, function()
	for _, obj in ipairs(Objects.Chests) do RemoveESP(obj) end
end)
local chestColor = addColor(TOGS.chest, "ESP_ChestColor", "Chests", Color3.fromRGB(255, 255, 0))
chestColor:OnChanged(function(c)
	T.chestColor = c
	for _, obj in ipairs(Objects.Chests) do UpdateColor(obj, c) end
end)

addTog(ESPBox, "ESP_Item", "Items", "item", function()
	for _, obj in ipairs(Objects.Items) do
		local label = ItemNames[obj.Name] or (obj.Name == "Green_Herb" and "Green Herb")
		if label then
			AddESP({Object = obj, Text = label, Color = T.itemColor or Color3.fromRGB(170, 0, 255)}, obj:GetAttribute("ParentRoom") ~= nil)
		end
	end
end, function()
	for _, obj in ipairs(Objects.Items) do RemoveESP(obj) end
end)
local itemColor = addColor(TOGS.item, "ESP_ItemColor", "Items", Color3.fromRGB(170, 0, 255))
itemColor:OnChanged(function(c)
	T.itemColor = c
	for _, obj in ipairs(Objects.Items) do UpdateColor(obj, c) end
end)

addTog(ESPBox, "ESP_Currency", "Currency", "curr", function()
	for _, obj in ipairs(Objects.Currency) do
		local label
		if obj.Name == "GoldPile" and obj:GetAttribute("GoldValue") then
			label = "Gold Pile [" .. obj:GetAttribute("GoldValue") .. "]"
		elseif obj.Name == "StardustPickup" then
			label = "Stardust Pile"
		end
		if label then
			AddESP({Object = obj, Text = label, Color = T.currColor or Color3.fromRGB(255, 255, 0)}, true)
		end
	end
end, function()
	for _, obj in ipairs(Objects.Currency) do RemoveESP(obj) end
end)
local currColor = addColor(TOGS.curr, "ESP_CurrColor", "Currency", Color3.fromRGB(255, 255, 0))
currColor:OnChanged(function(c)
	T.currColor = c
	for _, obj in ipairs(Objects.Currency) do UpdateColor(obj, c) end
end)

addTog(ESPBox, "ESP_Ladder", "Ladders", "ladder", function()
	for _, obj in ipairs(Objects.Ladders) do
		AddESP({Object = obj, Text = "Ladder", Color = T.ladderColor or Color3.fromRGB(255, 255, 255)}, true)
	end
end, function()
	for _, obj in ipairs(Objects.Ladders) do RemoveESP(obj) end
end)
local ladderColor = addColor(TOGS.ladder, "ESP_LadderColor", "Ladders", Color3.fromRGB(255, 255, 255))
ladderColor:OnChanged(function(c)
	T.ladderColor = c
	for _, obj in ipairs(Objects.Ladders) do UpdateColor(obj, c) end
end)

addTog(ESPBox, "ESP_Obj", "Objectives", "obj", function()
	for _, obj in ipairs(Objects.Objectives) do
		local label = ObjectiveLabels[obj.Name]
		if obj.Name == "TimerLever" then
			label = "Time Lever [+" .. (obj:GetAttribute("AddTime") or 30) .. "s]"
		elseif obj.Name == "MinesAnchor" then
			local sign = obj:FindFirstChild("Sign")
			label = "Anchor [" .. (sign and sign.TextLabel and sign.TextLabel.Text or "?") .. "]"
		end
		if label then
			AddESP({Object = obj, Text = label, Color = T.objColor or Color3.fromRGB(0, 255, 0)}, true)
		end
	end
end, function()
	for _, obj in ipairs(Objects.Objectives) do RemoveESP(obj) end
end)
local objColor = addColor(TOGS.obj, "ESP_ObjColor", "Objectives", Color3.fromRGB(0, 255, 0))
objColor:OnChanged(function(c)
	T.objColor = c
	for _, obj in ipairs(Objects.Objectives) do UpdateColor(obj, c) end
end)

ESPBox:AddDivider()
addTog(ESPBox, "ESP_Notify", "Notify Entities", "notify", function() end, function() end)
addTog(ESPBox, "ESP_Chat", "Notify Chat", "chat", function() end, function() end)
ESPBox:AddInput("EntityChatMessage", {Text = "Chat Message", Default = "spawned!", Numeric = false, Placeholder = "Message"})

ESPBox:AddDivider()
ESPBox:AddSlider("ESP_FillT", {Text = "Fill Transparency", Min = 0, Max = 1, Default = 0.75, Rounding = 2, Compact = true, Callback = function(v) T.fillT = v for _, d in pairs(ESPObjs) do if d.HL then d.HL.FillTransparency = v end end end})
ESPBox:AddSlider("ESP_OutlineT", {Text = "Outline Transparency", Min = 0, Max = 1, Default = 0, Rounding = 2, Compact = true, Callback = function(v) T.outlineT = v for _, d in pairs(ESPObjs) do if d.HL then d.HL.OutlineTransparency = v end end end})
ESPBox:AddSlider("ESP_TextSize", {Text = "Text Size", Min = 12, Max = 24, Default = 16, Rounding = 0, Compact = true, Callback = function(v) T.textSize = v for _, d in pairs(ESPObjs) do if d.Label then d.Label.TextSize = v end end end})
addTog(ESPBox, "ESP_Dist", "Show Distance", "dist", function() end, function() end)

-- Object handler
local function HandleObject(obj)
	if not obj or not obj.Parent then return end
	local name = obj.Name

	if name == "Door" and obj.Parent and tonumber(obj.Parent.Name) then
		local parts = {}
		for _, c in ipairs(obj:GetChildren()) do
			if c.Name == "Door" and c:IsA("BasePart") then table.insert(parts, c) end
		end
		if #parts >= 1 then
			local target = parts[1]
			table.insert(Objects.Doors, target)
			if T.door then
				AddESP({Object = target, Text = "Door " .. GetDoorNumber(obj), Color = T.doorColor or Color3.fromRGB(0, 200, 255)}, true)
			end
		end
	elseif HidingSpotLabels[name] then
		table.insert(Objects.HidingSpots, obj)
		if T.hide then
			AddESP({Object = obj, Text = HidingSpotLabels[name], Color = T.hideColor or Color3.fromRGB(255, 170, 0)}, true)
		end
	elseif name == "ChestBox" or name == "ChestBoxLocked" or name == "Toolbox" or name == "Toolbox_Locked" or name == "Chest_Vine" or name == "Toolshed_Small" or name == "Locker_Small_Locked" or name == "MouseHole" then
		table.insert(Objects.Chests, obj)
		if T.chest then
			local label
			if name == "ChestBox" or name == "ChestBoxLocked" then label = obj:GetAttribute("Locked") and "Locked Chest" or "Chest"
			elseif name == "Toolbox" or name == "Toolbox_Locked" then label = obj:GetAttribute("Locked") and "Locked Toolbox" or "Toolbox"
			elseif name == "Chest_Vine" then label = "Vine Chest"
			elseif name == "Toolshed_Small" then label = "Toolshed"
			elseif name == "Locker_Small_Locked" then label = "Locked Item Locker"
			elseif name == "MouseHole" then label = "Mouse"
			end
			if label then AddESP({Object = obj, Text = label, Color = T.chestColor or Color3.fromRGB(255, 255, 0)}, true) end
		end
	elseif ItemNames[name] and obj:FindFirstChild("ModulePrompt") then
		table.insert(Objects.Items, obj)
		if T.item then
			AddESP({Object = obj, Text = ItemNames[name], Color = T.itemColor or Color3.fromRGB(170, 0, 255)}, obj:GetAttribute("ParentRoom") ~= nil)
		end
	elseif name == "Green_Herb" then
		table.insert(Objects.Items, obj)
		if T.item then AddESP({Object = obj, Text = "Green Herb", Color = T.itemColor or Color3.fromRGB(170, 0, 255)}, true) end
	elseif name == "GoldPile" and obj:GetAttribute("GoldValue") then
		table.insert(Objects.Currency, obj)
		if T.curr then AddESP({Object = obj, Text = "Gold Pile [" .. obj:GetAttribute("GoldValue") .. "]", Color = T.currColor or Color3.fromRGB(255, 255, 0)}, true) end
	elseif name == "StardustPickup" then
		table.insert(Objects.Currency, obj)
		if T.curr then AddESP({Object = obj, Text = "Stardust Pile", Color = T.currColor or Color3.fromRGB(255, 255, 0)}, true) end
	elseif name == "Ladder" then
		table.insert(Objects.Ladders, obj)
		if T.ladder then AddESP({Object = obj, Text = "Ladder", Color = T.ladderColor or Color3.fromRGB(255, 255, 255)}, true) end
	elseif ObjectiveLabels[name] or name == "TimerLever" or name == "MinesAnchor" or name == "WaterPump" or name == "VineGuillotine" then
		table.insert(Objects.Objectives, obj)
		if T.obj then
			local label = ObjectiveLabels[name]
			if name == "TimerLever" then label = "Time Lever [+" .. (obj:GetAttribute("AddTime") or 30) .. "s]"
			elseif name == "MinesAnchor" then
				local sign = obj:FindFirstChild("Sign")
				label = "Anchor [" .. (sign and sign.TextLabel and sign.TextLabel.Text or "?") .. "]"
			end
			if label then AddESP({Object = obj, Text = label, Color = T.objColor or Color3.fromRGB(0, 255, 0)}, true) end
		end
	elseif EntityESPLabels[name] or Entities[name] then
		table.insert(Objects.Entities, obj)
		local label = EntityESPLabels[name]
		if not label and Entities[name] then label = Entities[name].Alias end
		if T.ent and label and EntityESPOptions.Value[label] then
			AddESP({Object = obj, Text = label, Color = T.entColor or Color3.fromRGB(255, 0, 0)}, not NodeEntities[label])
		end
	end
end

C.entitySpawn = Workspace.ChildAdded:Connect(function(ent)
	local data = Entities[ent.Name]
	if not data then return end
	task.spawn(function()
		local t = 0
		while not ent.PrimaryPart and t < 50 do task.wait(0.05) t = t + 1 end
		if not ent.PrimaryPart then return end
		if LocalPlayer:DistanceFromCharacter(ent.PrimaryPart.Position) >= 10000 then return end

		local alias = data.Alias
		if T.notify and EntityNotifyList.Value[alias] then
			local title = data.NotifyMessage.Title
			local body = data.NotifyMessage.Body
			local img = EntityIcons[ent.Name]
			if ent.Name == "RushMoving" and ent.PrimaryPart.Name ~= "RushNew" then
				title = title:gsub("Rush", ent.PrimaryPart.Name)
				alias = ent.PrimaryPart.Name
			end
			notify(title, body, 5)
			if T.chat then
				local msg = alias .. " " .. (Obsidian.Options and Obsidian.Options.EntityChatMessage and Obsidian.Options.EntityChatMessage.Value or "spawned!")
				pcall(function()
					local ch = game:GetService("TextChatService"):FindFirstChild("TextChannels")
					ch = ch and ch:FindFirstChild("RBXGeneral")
					if ch then ch:SendAsync(msg) end
				end)
			end
		end

		table.insert(Objects.Entities, ent)
		if T.ent and EntityESPOptions.Value[alias] then
			if ent.Name == "MonumentEntity" then
				AddESP({Object = ent.Top or ent, Text = alias, Color = T.entColor or Color3.fromRGB(255, 0, 0)})
			else
				AddESP({Object = ent, Text = alias, Color = T.entColor or Color3.fromRGB(255, 0, 0)})
			end
		end
	end)
end)

for _, obj in ipairs(Workspace:GetDescendants()) do
	task.spawn(HandleObject, obj)
end
C.descAdded = Workspace.DescendantAdded:Connect(function(obj)
	task.defer(HandleObject, obj)
end)

for _, plr in ipairs(Players:GetPlayers()) do
	if plr ~= LocalPlayer then
		if plr.Character and T.plr and plr:GetAttribute("Alive") == true then
			AddESP({Object = plr.Character, Text = plr.Name, Color = T.plrColor or Color3.fromRGB(255, 255, 255)})
		end
		C["plr_" .. plr.UserId] = plr.CharacterAdded:Connect(function(char)
			if T.plr then AddESP({Object = char, Text = plr.Name, Color = T.plrColor or Color3.fromRGB(255, 255, 255)}) end
		end)
	end
end
C.playerAdded = Players.PlayerAdded:Connect(function(plr)
	if plr == LocalPlayer then return end
	C["plr_" .. plr.UserId] = plr.CharacterAdded:Connect(function(char)
		if T.plr then AddESP({Object = char, Text = plr.Name, Color = T.plrColor or Color3.fromRGB(255, 255, 255)}) end
	end)
end)

C.distUpdate = RunService.Heartbeat:Connect(function()
	if not T.dist then return end
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	for obj, data in pairs(ESPObjs) do
		if data.Label and obj.Parent then
			local pos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetPivot().Position) or obj.Position
			if pos then
				local dist = math.floor((root.Position - pos).Magnitude)
				local base = data.Label.Text:match("^(.-)%s*%[") or data.Label.Text:match("^(.-)%s*$") or data.Label.Text
				data.Label.Text = base .. " [" .. dist .. "]"
			end
		end
	end
end)

C.cleaner = RunService.Heartbeat:Connect(function()
	for i = #Objects.Doors, 1, -1 do if not Objects.Doors[i] or not Objects.Doors[i].Parent then table.remove(Objects.Doors, i) end end
	for i = #Objects.HidingSpots, 1, -1 do if not Objects.HidingSpots[i] or not Objects.HidingSpots[i].Parent then table.remove(Objects.HidingSpots, i) end end
	for i = #Objects.Entities, 1, -1 do if not Objects.Entities[i] or not Objects.Entities[i].Parent then table.remove(Objects.Entities, i) end end
	for i = #Objects.Chests, 1, -1 do if not Objects.Chests[i] or not Objects.Chests[i].Parent then table.remove(Objects.Chests, i) end end
	for i = #Objects.Items, 1, -1 do if not Objects.Items[i] or not Objects.Items[i].Parent then table.remove(Objects.Items, i) end end
	for i = #Objects.Currency, 1, -1 do if not Objects.Currency[i] or not Objects.Currency[i].Parent then table.remove(Objects.Currency, i) end end
	for i = #Objects.Ladders, 1, -1 do if not Objects.Ladders[i] or not Objects.Ladders[i].Parent then table.remove(Objects.Ladders, i) end end
	for i = #Objects.Objectives, 1, -1 do if not Objects.Objectives[i] or not Objects.Objectives[i].Parent then table.remove(Objects.Objectives, i) end end
end)

EntityESPOptions:OnChanged(function()
	if not T.ent then return end
	for _, obj in ipairs(Objects.Entities) do
		local label = EntityESPLabels[obj.Name]
		if not label and Entities[obj.Name] then label = Entities[obj.Name].Alias end
		if label and EntityESPOptions.Value[label] then
			AddESP({Object = obj, Text = label, Color = T.entColor or Color3.fromRGB(255, 0, 0)}, not NodeEntities[label])
		else
			RemoveESP(obj)
		end
	end
end)

-- set ParentRoom cho mọi object đã có
local function _TagRoom(o)
	if not o or not o.Parent then return end
	if o:GetAttribute("ParentRoom") ~= nil then return end
	local cr = Workspace:FindFirstChild("CurrentRooms")
	if not cr then return end
	for _, r in ipairs(cr:GetChildren()) do
		if o:IsDescendantOf(r) then
			o:SetAttribute("ParentRoom", tonumber(r.Name))
			return
		end
	end
end

-- rebuild toàn bộ list với ParentRoom đúng
for _, arr in ipairs({Objects.Doors, Objects.HidingSpots, Objects.Entities, Objects.Chests, Objects.Items, Objects.Currency, Objects.Ladders, Objects.Objectives}) do
	for _, o in ipairs(arr) do _TagRoom(o) end
end

-- AddESP wrap: check room ngay lần đầu
local _AddESP = AddESP
AddESP = function(opts, roomBased)
	local obj = opts.Object
	if not obj or not obj.Parent then return end
	if ESPObjs[obj] then return end
	_TagRoom(obj)
	_AddESP(opts, roomBased)
	if roomBased then
		local cur = tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 0
		local oroom = tonumber(obj:GetAttribute("ParentRoom"))
		local d = ESPObjs[obj]
		local vis = (oroom ~= nil and (oroom == cur or oroom == cur + 1))
		if d then
			if d.HL then d.HL.Enabled = vis end
			if d.BB then d.BB.Enabled = vis end
		end
		if ESPConnections[obj] then ESPConnections[obj]:Disconnect() end
		ESPConnections[obj] = LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
			local c2 = tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 0
			local o2 = tonumber(obj:GetAttribute("ParentRoom"))
			local d2 = ESPObjs[obj]
			if d2 then
				local v2 = (o2 ~= nil and (o2 == c2 or o2 == c2 + 1))
				if d2.HL then d2.HL.Enabled = v2 end
				if d2.BB then d2.BB.Enabled = v2 end
			end
		end)
	end
end

-- rusher fix
C.rusherFix = Workspace.ChildAdded:Connect(function(ent)
	local a = {RushMoving=true,AmbushMoving=true,BackdoorRush=true,A60=true,A120=true,GlitchRush=true,GlitchAmbush=true,CustomEntity=true,FrozenAmbush=true,SallyMoving=true}
	if not a[ent.Name] then return end
	task.spawn(function()
		local t = 0
		while not ent.PrimaryPart and t < 100 do
			for _, c in ipairs(ent:GetChildren()) do if c:IsA("BasePart") then ent.PrimaryPart = c end end
			task.wait(0.05) t = t + 1
		end
		if ent.PrimaryPart then
			ent.PrimaryPart.Transparency = 0.999
			ent.PrimaryPart.Material = Enum.Material.Plastic
		end
	end)
end)

-- chờ CurrentRooms có room rồi scan lại + gán ParentRoom
task.spawn(function()
	local cr = Workspace:WaitForChild("CurrentRooms", 60)
	if not cr then return end
	local t = 0
	while not cr:FindFirstChildOfClass("Model") and t < 120 do task.wait(0.5) t = t + 1 end
	for _, o in ipairs(Workspace:GetDescendants()) do
		_TagRoom(o)
	end
	-- rebuild ESP nếu toggle đã bật trước đó
	if T.door then
		for _, o in ipairs(Objects.Doors) do
			if o.Parent and not ESPObjs[o] then
				AddESP({Object=o, Text="Door "..GetDoorNumber(o), Color=T.doorColor or Color3.fromRGB(0,200,255)}, true)
			end
		end
	end
	if T.hide then
		for _, o in ipairs(Objects.HidingSpots) do
			if o.Parent and not ESPObjs[o] then
				local lb = HidingSpotLabels[o.Name]
				if lb then AddESP({Object=o, Text=lb, Color=T.hideColor or Color3.fromRGB(255,170,0)}, true) end
			end
		end
	end
	if T.chest then
		for _, o in ipairs(Objects.Chests) do
			if o.Parent and not ESPObjs[o] then
				local lb
				if o.Name == "ChestBox" or o.Name == "ChestBoxLocked" then lb = o:GetAttribute("Locked") and "Locked Chest" or "Chest"
				elseif o.Name == "Toolbox" or o.Name == "Toolbox_Locked" then lb = o:GetAttribute("Locked") and "Locked Toolbox" or "Toolbox"
				elseif o.Name == "Chest_Vine" then lb = "Vine Chest"
				elseif o.Name == "Toolshed_Small" then lb = "Toolshed"
				elseif o.Name == "Locker_Small_Locked" then lb = "Locked Item Locker"
				elseif o.Name == "MouseHole" then lb = "Mouse"
				end
				if lb then AddESP({Object=o, Text=lb, Color=T.chestColor or Color3.fromRGB(255,255,0)}, true) end
			end
		end
	end
	if T.item then
		for _, o in ipairs(Objects.Items) do
			if o.Parent and not ESPObjs[o] then
				local lb = ItemNames[o.Name] or (o.Name == "Green_Herb" and "Green Herb")
				if lb then AddESP({Object=o, Text=lb, Color=T.itemColor or Color3.fromRGB(170,0,255)}, o:GetAttribute("ParentRoom") ~= nil) end
			end
		end
	end
	if T.curr then
		for _, o in ipairs(Objects.Currency) do
			if o.Parent and not ESPObjs[o] then
				local lb
				if o.Name == "GoldPile" and o:GetAttribute("GoldValue") then lb = "Gold Pile ["..o:GetAttribute("GoldValue").."]"
				elseif o.Name == "StardustPickup" then lb = "Stardust Pile"
				end
				if lb then AddESP({Object=o, Text=lb, Color=T.currColor or Color3.fromRGB(255,255,0)}, true) end
			end
		end
	end
	if T.ladder then
		for _, o in ipairs(Objects.Ladders) do
			if o.Parent and not ESPObjs[o] then
				AddESP({Object=o, Text="Ladder", Color=T.ladderColor or Color3.fromRGB(255,255,255)}, true)
			end
		end
	end
	if T.obj then
		for _, o in ipairs(Objects.Objectives) do
			if o.Parent and not ESPObjs[o] then
				local lb = ObjectiveLabels[o.Name]
				if o.Name == "TimerLever" then lb = "Time Lever [+"..(o:GetAttribute("AddTime") or 30).."s]"
				elseif o.Name == "MinesAnchor" then
					local s = o:FindFirstChild("Sign")
					lb = "Anchor ["..(s and s.TextLabel and s.TextLabel.Text or "?").."]"
				end
				if lb then AddESP({Object=o, Text=lb, Color=T.objColor or Color3.fromRGB(0,255,0)}, true) end
			end
		end
	end
	if T.ent then
		for _, o in ipairs(Objects.Entities) do
			if o.Parent and not ESPObjs[o] then
				local lb = EntityESPLabels[o.Name] or (Entities[o.Name] and Entities[o.Name].Alias)
				if lb and EntityESPOptions.Value[lb] then
					AddESP({Object=o, Text=lb, Color=T.entColor or Color3.fromRGB(255,0,0)}, not NodeEntities[lb])
				end
			end
		end
	end
end)
-- Fix: nếu oroom nil hoặc cur nil → KHÔNG tắt HL/BB, để mặc định enabled = true
local _AddESP3 = AddESP
AddESP = function(opts, roomBased)
	local obj = opts.Object
	if not obj or not obj.Parent then return end
	if ESPObjs[obj] then return end
	_TagRoom(obj)
	_AddESP3(opts, roomBased)
	if roomBased then
		local cur = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))
		local oroom = tonumber(obj:GetAttribute("ParentRoom"))
		local d = ESPObjs[obj]
		if d and cur ~= nil and oroom ~= nil then
			local vis = (oroom == cur or oroom == cur + 1)
			if d.HL then d.HL.Enabled = vis end
			if d.BB then d.BB.Enabled = vis end
		end
		if ESPConnections[obj] then ESPConnections[obj]:Disconnect() end
		ESPConnections[obj] = LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
			local c2 = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))
			local o2 = tonumber(obj:GetAttribute("ParentRoom"))
			if c2 == nil or o2 == nil then return end
			local v2 = (o2 == c2 or o2 == c2 + 1)
			local d2 = ESPObjs[obj]
			if d2 then
				if d2.HL then d2.HL.Enabled = v2 end
				if d2.BB then d2.BB.Enabled = v2 end
			end
		end)
	end
end

-- Heartbeat tag lại liên tục
C.fixTagHB = RunService.Heartbeat:Connect(function()
	local cr = Workspace:FindFirstChild("CurrentRooms")
	if not cr then return end
	for _, arr in ipairs({Objects.Doors,Objects.HidingSpots,Objects.Entities,Objects.Chests,Objects.Items,Objects.Currency,Objects.Ladders,Objects.Objectives}) do
		for _, o in ipairs(arr) do _TagRoom(o) end
	end
end)

end
