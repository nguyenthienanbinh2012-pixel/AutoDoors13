return function(VisualLeft, _, Obsidian, Svc)
local Workspace = Svc.Workspace
local RunService = Svc.RunService
local Players = Svc.Players
local LocalPlayer = Svc.LocalPlayer
local Camera = Workspace.CurrentCamera
local ReplicatedStorage = Svc.ReplicatedStorage

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
--[[
ESP FIX - chèn vào cuối file HeartDOORS54.lua, NGAY TRƯỚC dòng "end" cuối cùng
(không thêm mô tả, chỉ Lua thuần)
]]

-- 1) Gán ParentRoom + đảm bảo object có highlight part cho Door
local _HandleObject = HandleObject
HandleObject = function(obj)
	if not obj or not obj.Parent then return end

	if not obj:GetAttribute("ParentRoom") then
		local cr = Workspace:FindFirstChild("CurrentRooms")
		if cr then
			for _, room in ipairs(cr:GetChildren()) do
				if obj:IsDescendantOf(room) then
					obj:SetAttribute("ParentRoom", tonumber(room.Name))
					break
				end
			end
		end
	end

	if obj.Name == "Door" and obj.Parent and tonumber(obj.Parent.Name) then
		if not obj:FindFirstChild("HighlightPart") then
			local src = obj:FindFirstChild("Door")
			if src and src:IsA("BasePart") then
				local hp = Instance.new("Part")
				hp.Name = "HighlightPart"
				hp.Transparency = 0.999
				hp.Size = src.Size
				hp.CFrame = src.CFrame
				hp.CanCollide = false
				hp.Material = Enum.Material.Plastic
				hp:SetAttribute("ParentRoom", tonumber(obj.Parent.Name))
				local w = Instance.new("WeldConstraint")
				w.Part0 = hp
				w.Part1 = src
				w.Parent = hp
				hp.Parent = obj
				table.insert(Objects.Doors, hp)
				if T.door then
					AddESP({Object = hp, Text = "Door " .. GetDoorNumber(obj), Color = T.doorColor or Color3.fromRGB(0, 200, 255)}, true)
				end
			end
		end
	end

	return _HandleObject(obj)
end

-- 2) Fix AddESP roomBased: check ngay lần đầu, connect sau
local _AddESP = AddESP
AddESP = function(opts, roomBased)
	local obj = opts.Object
	if not obj or not obj.Parent then return end
	if ESPObjs[obj] then return end

	_AddESP(opts, roomBased)

	if roomBased then
		local cur = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))
		local oroom = tonumber(obj:GetAttribute("ParentRoom"))
		if oroom == nil then
			local cr = Workspace:FindFirstChild("CurrentRooms")
			if cr then
				for _, room in ipairs(cr:GetChildren()) do
					if obj:IsDescendantOf(room) then
						oroom = tonumber(room.Name)
						obj:SetAttribute("ParentRoom", oroom)
						break
					end
				end
			end
		end
		local data = ESPObjs[obj]
		if data then
			local vis = (oroom == cur) or (Objects.Doors and table.find(Objects.Doors, obj) and oroom == cur + 1)
			if data.HL then data.HL.Enabled = vis end
			if data.BB then data.BB.Enabled = vis end
		end
		if ESPConnections[obj] then
			ESPConnections[obj]:Disconnect()
			ESPConnections[obj] = nil
		end
		ESPConnections[obj] = LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
			local c2 = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))
			local o2 = tonumber(obj:GetAttribute("ParentRoom"))
			local v2 = (o2 == c2) or (Objects.Doors and table.find(Objects.Doors, obj) and o2 == c2 + 1)
			local d = ESPObjs[obj]
			if d then
				if d.HL then d.HL.Enabled = v2 end
				if d.BB then d.BB.Enabled = v2 end
			end
		end)
	end
end

-- 3) Rusher: Humanoid + PrimaryPart transparency
C.rusherFix = Workspace.ChildAdded:Connect(function(ent)
	local aliases = {RushMoving=true, AmbushMoving=true, BackdoorRush=true, A60=true, A120=true, GlitchRush=true, GlitchAmbush=true, CustomEntity=true, FrozenAmbush=true, SallyMoving=true}
	if not aliases[ent.Name] then return end
	task.spawn(function()
		local t = 0
		while not ent.PrimaryPart and t < 100 do
			for _, c in ipairs(ent:GetChildren()) do
				if c:IsA("BasePart") then ent.PrimaryPart = c end
			end
			task.wait(0.05) t = t + 1
		end
		if not ent.PrimaryPart then return end
		if not ent:FindFirstChildOfClass("Humanoid") then
			local h = Instance.new("Humanoid")
			h.Name = "HighlightHumanoid"
			h.Parent = ent
		end
		ent.PrimaryPart.Transparency = 0.999
		ent.PrimaryPart.Material = Enum.Material.Plastic
	end)
end)

-- 4) Chờ CurrentRooms có room rồi mới scan
task.spawn(function()
	local cr = Workspace:WaitForChild("CurrentRooms", 60)
	if not cr then return end
	local t = 0
	while not cr:FindFirstChildOfClass("Model") and t < 120 do
		task.wait(0.5) t = t + 1
	end
	for _, obj in ipairs(Workspace:GetDescendants()) do
		task.spawn(HandleObject, obj)
	end
end)

-- 5) Rebuild ESP khi toggle bật lại (vì object có thể vào Objects sau khi toggle bật)
for _, key in ipairs({"ent","door","hide","plr","chest","item","curr","ladder","obj"}) do
	local old = T[key]
	-- dùng hook đơn giản: mỗi Heartbeat check nếu toggle bật mà object chưa có ESP thì thêm
end

C.espRebuild = RunService.Heartbeat:Connect(function()
	if not (T.ent or T.door or T.hide or T.chest or T.item or T.curr or T.ladder or T.obj or T.plr) then return end

	if T.door then
		for _, o in ipairs(Objects.Doors) do
			if o.Parent and not ESPObjs[o] then
				AddESP({Object = o, Text = "Door " .. GetDoorNumber(o.Parent and o.Parent.Parent or o), Color = T.doorColor or Color3.fromRGB(0, 200, 255)}, true)
			end
		end
	end
	if T.hide then
		for _, o in ipairs(Objects.HidingSpots) do
			if o.Parent and not ESPObjs[o] then
				local lb = HidingSpotLabels[o.Name]
				if lb then AddESP({Object = o, Text = lb, Color = T.hideColor or Color3.fromRGB(255, 170, 0)}, true) end
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
				if lb then AddESP({Object = o, Text = lb, Color = T.chestColor or Color3.fromRGB(255, 255, 0)}, true) end
			end
		end
	end
	if T.item then
		for _, o in ipairs(Objects.Items) do
			if o.Parent and not ESPObjs[o] then
				local lb = ItemNames[o.Name] or (o.Name == "Green_Herb" and "Green Herb")
				if lb then AddESP({Object = o, Text = lb, Color = T.itemColor or Color3.fromRGB(170, 0, 255)}, o:GetAttribute("ParentRoom") ~= nil) end
			end
		end
	end
	if T.curr then
		for _, o in ipairs(Objects.Currency) do
			if o.Parent and not ESPObjs[o] then
				local lb
				if o.Name == "GoldPile" and o:GetAttribute("GoldValue") then lb = "Gold Pile [" .. o:GetAttribute("GoldValue") .. "]"
				elseif o.Name == "StardustPickup" then lb = "Stardust Pile"
				end
				if lb then AddESP({Object = o, Text = lb, Color = T.currColor or Color3.fromRGB(255, 255, 0)}, true) end
			end
		end
	end
	if T.ladder then
		for _, o in ipairs(Objects.Ladders) do
			if o.Parent and not ESPObjs[o] then
				AddESP({Object = o, Text = "Ladder", Color = T.ladderColor or Color3.fromRGB(255, 255, 255)}, true)
			end
		end
	end
	if T.obj then
		for _, o in ipairs(Objects.Objectives) do
			if o.Parent and not ESPObjs[o] then
				local lb = ObjectiveLabels[o.Name]
				if o.Name == "TimerLever" then lb = "Time Lever [+" .. (o:GetAttribute("AddTime") or 30) .. "s]"
				elseif o.Name == "MinesAnchor" then
					local sign = o:FindFirstChild("Sign")
					lb = "Anchor [" .. (sign and sign.TextLabel and sign.TextLabel.Text or "?") .. "]"
				end
				if lb then AddESP({Object = o, Text = lb, Color = T.objColor or Color3.fromRGB(0, 255, 0)}, true) end
			end
		end
	end
	if T.ent then
		for _, o in ipairs(Objects.Entities) do
			if o.Parent and not ESPObjs[o] then
				local lb = EntityESPLabels[o.Name]
				if not lb and Entities[o.Name] then lb = Entities[o.Name].Alias end
				if lb and EntityESPOptions.Value[lb] then
					AddESP({Object = o, Text = lb, Color = T.entColor or Color3.fromRGB(255, 0, 0)}, not NodeEntities[lb])
				end
			end
		end
	end
end)

end
