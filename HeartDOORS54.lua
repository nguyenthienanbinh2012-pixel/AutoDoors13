local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local function SafeNotify(title, content, duration)
    pcall(function()
        if WindUI and WindUI.Notify then
            WindUI:Notify({Title = title, Content = content, Duration = duration or 3})
        elseif Window and Window.Notify then
            Window:Notify({Title = title, Content = content, Duration = duration or 3})
        end
    end)
end

local Window = WindUI:CreateWindow({
    Title = "Twinkhook",
    Author = "Pain",
    Icon = "Heart",
    Folder = "Heart Auto",
    Size = UDim2.fromOffset(550, 400),
    Resizable = true,
    Theme = "Dark",
    OpenButton = {
        Title = "Show HeartHub",
        Enabled = true,
        Draggable = true,
        Scale = 1,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("FF3333")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("FF6666"))
        })
    }
})

Window:SetToggleKey(Enum.KeyCode.K)

local MainTab = Window:Tab({ Title = "Main", Icon = "layout-grid" })
local PathTab = Window:Tab({ Title = "Path", Icon = "route" })

local PATH_FOLDER_NAME = "Twinkhook_PathVisual"

local pathWaypoints = {}
local pathConnection = nil
local showPathConnection = nil
local showPathAttributeConn = nil
local showPathActive = false
local isDrawingPath = false
local isTeleporting = false

local autoTeleport = false
local autoMove = false
local removeStepAcceleration = false

local lastRenderedRoom = nil
local lastRenderedNextRoom = nil

local currentWaypointIndex = 1
local stuckPos = nil
local stuckTimer = 0

local autoTeleportGen = 0
local autoTeleportSpeed = 0.5

local function GetCurrentRoom()
    local cur = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))
    local rooms = Workspace:FindFirstChild("CurrentRooms")
    if cur and rooms then
        return rooms:FindFirstChild(tostring(cur)), cur
    end
    return nil, nil
end

local function GetNextRoom()
    local cur = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))
    local rooms = Workspace:FindFirstChild("CurrentRooms")
    if cur and rooms then
        local nextRoom = rooms:FindFirstChild(tostring(cur + 1))
        if nextRoom then
            return nextRoom, cur + 1
        end
    end
    return nil, nil
end

local function GetDoorPart(room)
    if not room then return nil end
    local door = room:FindFirstChild("Door")
    if not door then return nil end
    return door:FindFirstChild("Door") or door:FindFirstChildWhichIsA("BasePart")
end

-- [FIX 5] RemoteCrouchHandler
local crouchRemotes = {}

local function FindCrouchRemotes()
    table.clear(crouchRemotes)
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local n = obj.Name:lower()
            if n:find("crouch") or n:find("crouching") or n:find("sit") then
                table.insert(crouchRemotes, obj)
            end
        end
    end
end

local function SendCrouch(state)
    for _, remote in ipairs(crouchRemotes) do
        if remote:IsA("RemoteEvent") then
            pcall(function() remote:FireServer(state) end)
        elseif remote:IsA("RemoteFunction") then
            pcall(function() remote:InvokeServer(state) end)
        end
    end
end

FindCrouchRemotes()

local function ClearPath()
    local oldFolder = Workspace:FindFirstChild(PATH_FOLDER_NAME)
    if oldFolder then
        pcall(function() oldFolder:Destroy() end)
    end
    pathWaypoints = {}
    if pathConnection then
        pcall(function() pathConnection:Disconnect() end)
        pathConnection = nil
    end
    if showPathConnection then
        pcall(function() showPathConnection:Disconnect() end)
        showPathConnection = nil
    end
    if showPathAttributeConn then
        pcall(function() showPathAttributeConn:Disconnect() end)
        showPathAttributeConn = nil
    end
    showPathActive = false
    isDrawingPath = false
    lastRenderedRoom = nil
    lastRenderedNextRoom = nil
    currentWaypointIndex = 1
    stuckPos = nil
    stuckTimer = 0
end

local function AdjustWaypointToGround(wp, char, folder)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char, folder}
    params.IgnoreWater = true
    params.RespectCanCollide = true

    local rayOrigin = wp + Vector3.new(0, 2, 0)
    local rayResult = Workspace:Raycast(rayOrigin, Vector3.new(0, -10, 0), params)

    if rayResult and rayResult.Instance.CanCollide and rayResult.Instance.Transparency < 1 and rayResult.Instance.CanQuery then
        return Vector3.new(wp.X, rayResult.Position.Y + 0.15, wp.Z)
    end
    return wp
end

local function ProcessWaypoints(rawWps, char, folder)
    local result = {}
    for i = 1, #rawWps do
        local wp = AdjustWaypointToGround(rawWps[i], char, folder)
        table.insert(result, wp)

        if i < #rawWps then
            local nextRaw = rawWps[i + 1]
            local dir = nextRaw - wp
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {char, folder}
            params.IgnoreWater = true

            local hit = Workspace:Raycast(wp + Vector3.new(0, 1, 0), dir, params)
            if hit and hit.Instance.CanCollide then
                local midPoint = wp + dir.Unit * math.max(0, hit.Distance - 1) + Vector3.new(0, 2, 0)
                table.insert(result, midPoint)
            end
        end
    end
    return result
end

-- [FIX 7] Hologram Ghost
local function CreateGhostSegment(folder, p1, p2)
    local dist = (p2 - p1).Magnitude
    if dist < 0.1 then return end
    local mid = p1:Lerp(p2, 0.5)

    local core = Instance.new("Part")
    core.Name = "GhostCore"
    core.Shape = Enum.PartType.Cylinder
    core.Size = Vector3.new(dist, 0.1, 0.1)
    core.CFrame = CFrame.lookAt(mid, p2) * CFrame.Angles(0, math.rad(90), 0)
    core.Anchored = true
    core.CanCollide = false
    core.CanQuery = false
    core.CanTouch = false
    core.CastShadow = false
    core.Material = Enum.Material.ForceField
    core.Color = Color3.fromRGB(80, 200, 255)
    core.Transparency = 0.35
    core.Parent = folder

    local glow = core:Clone()
    glow.Name = "GhostGlow"
    glow.Size = Vector3.new(dist, 0.4, 0.4)
    glow.Color = Color3.fromRGB(120, 220, 255)
    glow.Transparency = 0.75
    glow.Parent = folder
end

local function CreateGhostMarker(folder, pos)
    local marker = Instance.new("Part")
    marker.Name = "GhostMarker"
    marker.Shape = Enum.PartType.Ball
    marker.Size = Vector3.new(0.9, 0.9, 0.9)
    marker.CFrame = CFrame.new(pos)
    marker.Anchored = true
    marker.CanCollide = false
    marker.CanQuery = false
    marker.CanTouch = false
    marker.CastShadow = false
    marker.Material = Enum.Material.ForceField
    marker.Color = Color3.fromRGB(80, 200, 255)
    marker.Transparency = 0.4
    marker.Parent = folder

    local halo = marker:Clone()
    halo.Name = "GhostHalo"
    halo.Size = Vector3.new(1.5, 1.5, 1.5)
    halo.Color = Color3.fromRGB(120, 220, 255)
    halo.Transparency = 0.85
    halo.Parent = folder
end

-- [FIX 6] DrawMultiRoomPath
local function DrawMultiRoomPath(numRoomsAhead)
    numRoomsAhead = numRoomsAhead or 3

    local oldFolder = Workspace:FindFirstChild(PATH_FOLDER_NAME)
    if oldFolder then pcall(function() oldFolder:Destroy() end) end
    pathWaypoints = {}

    local currentRoom, currentNum = GetCurrentRoom()
    if not currentRoom or not currentNum then return end

    local folder = Instance.new("Folder")
    folder.Name = PATH_FOLDER_NAME
    folder.Parent = Workspace

    local char = LocalPlayer.Character
    local rooms = Workspace:FindFirstChild("CurrentRooms")
    if not rooms then return end

    local prevDoor = GetDoorPart(currentRoom)
    if not prevDoor then return end

    local startDoorPos = prevDoor.Position
    local allWaypoints = {}

    for i = 1, numRoomsAhead do
        local roomNum = currentNum + i
        local nextRoom = rooms:FindFirstChild(tostring(roomNum))
        if not nextRoom then break end

        local nextDoor = GetDoorPart(nextRoom)
        if not nextDoor then break end

        local startPos = prevDoor.Position
        local endPos = nextDoor.Position

        local path = PathfindingService:CreatePath({
            AgentRadius = 2,
            AgentHeight = 5,
            AgentCanJump = true,
        })
        local ok = pcall(function() path:ComputeAsync(startPos, endPos) end)

        local rawWps = {}
        if ok and path.Status == Enum.PathStatus.Success then
            for _, wp in ipairs(path:GetWaypoints()) do
                table.insert(rawWps, wp.Position)
            end
        else
            table.insert(rawWps, startPos)
            table.insert(rawWps, endPos)
        end

        local processed = ProcessWaypoints(rawWps, char, folder)
        for _, wp in ipairs(processed) do
            table.insert(allWaypoints, wp)
        end

        prevDoor = nextDoor
    end

    for _, wp in ipairs(allWaypoints) do
        CreateGhostMarker(folder, wp)
        table.insert(pathWaypoints, wp)
    end

    local prevPos = startDoorPos
    for _, wp in ipairs(allWaypoints) do
        CreateGhostSegment(folder, prevPos, wp)
        prevPos = wp
    end
end

-- [FIX 3] FindFrontOfDoor
local function FindFrontOfDoor(doorPart, char)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char, doorPart.Parent}
    params.IgnoreWater = true

    local origin = doorPart.Position + Vector3.new(0, 2, 0)
    local directions = {
        doorPart.CFrame.LookVector,
        -doorPart.CFrame.LookVector,
        doorPart.CFrame.RightVector,
        -doorPart.CFrame.RightVector,
    }

    local bestDir = doorPart.CFrame.LookVector
    local bestDist = 0

    for _, dir in ipairs(directions) do
        local hit = Workspace:Raycast(origin, dir * 15, params)
        local dist = hit and hit.Distance or 15
        if dist > bestDist then
            bestDist = dist
            bestDir = dir
        end
    end

    if bestDist < 2 then
        local curRoom = GetCurrentRoom()
        if curRoom then
            local curPivot = curRoom:GetPivot().Position
            local toDoor = doorPart.Position - curPivot
            toDoor = Vector3.new(toDoor.X, 0, toDoor.Z)
            if toDoor.Magnitude > 0.1 then
                bestDir = toDoor.Unit
            end
        end
    end

    return bestDir
end

-- [FIX 4] GetGroundPosition check Normal.Y > 0.7
local function GetGroundPosition(fromPos, char)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {char}
    params.IgnoreWater = true
    params.RespectCanCollide = true

    local origin = fromPos + Vector3.new(0, 3, 0)
    local hit = Workspace:Raycast(origin, Vector3.new(0, -50, 0), params)

    if hit and hit.Instance.CanCollide and hit.Normal.Y > 0.7 then
        return hit.Position
    end
    return fromPos
end

-- [FIX 1] FastTeleportCharacter
local function FastTeleportCharacter(targetCFrame)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return false end

    local oldWS, oldJP = hum.WalkSpeed, hum.JumpPower
    local oldHRPCFrame = hrp.CFrame

    pcall(function() hum:Move(Vector3.zero, false) end)
    hum.WalkSpeed = 0
    hum.JumpPower = 0

    local offset = targetCFrame * oldHRPCFrame:Inverse()

    local parts = {}
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") then
            parts[#parts + 1] = {part = obj, cframe = obj.CFrame}
        end
    end

    for i = 1, #parts do
        parts[i].part.CFrame = offset * parts[i].cframe
    end

    for i = 1, #parts do
        local p = parts[i].part
        p.AssemblyLinearVelocity = Vector3.zero
        p.AssemblyAngularVelocity = Vector3.zero
    end

    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Landed) end)

    task.delay(0.1, function()
        if hum and hum.Parent then
            hum.WalkSpeed = oldWS
            hum.JumpPower = oldJP
        end
    end)

    return true
end

-- [FIX 2] SoftTeleport
local function SoftTeleport(targetCFrame)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local startPos = hrp.Position
    local targetPos = targetCFrame.Position
    local distance = (targetPos - startPos).Magnitude

    if distance < 3 then
        return FastTeleportCharacter(targetCFrame)
    end

    local frames = math.clamp(math.floor(distance / 20), 3, 10)
    for i = 1, frames do
        local alpha = i / frames
        local newPos = startPos:Lerp(targetPos, alpha)
        local newCF = CFrame.new(newPos) * (targetCFrame - targetCFrame.Position)
        pcall(function() hrp.CFrame = newCF end)
        task.wait(0.03)
    end

    return FastTeleportCharacter(targetCFrame)
end

local function TeleportToPosition(targetPos)
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local targetCFrame = CFrame.new(targetPos) * (hrp.CFrame - hrp.CFrame.Position)
    return SoftTeleport(targetCFrame)
end

-- [FIX 1 + FIX 2 + FIX 3 + FIX 4] TeleportToNextDoor
local function TeleportToNextDoor()
    if isTeleporting then return false end
    isTeleporting = true

    local ok, result = xpcall(function()
        local nextRoom = GetNextRoom()
        if not nextRoom then
            SafeNotify("Teleport", "Thất bại: không tìm thấy cửa", 2)
            return false
        end

        local doorPart = GetDoorPart(nextRoom)
        if not doorPart then
            SafeNotify("Teleport", "Thất bại: không tìm thấy cửa", 2)
            return false
        end

        local char = LocalPlayer.Character
        if not char then return false end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return false end

        local frontDir = FindFrontOfDoor(doorPart, char)
        local inFrontPos = doorPart.Position + frontDir * 2.5
        local groundPos = GetGroundPosition(inFrontPos, char)
        local finalPos = groundPos + Vector3.new(0, hum.HipHeight + 2, 0)
        local targetCFrame = CFrame.lookAt(finalPos, finalPos + frontDir)

        return SoftTeleport(targetCFrame)
    end, function(err)
        warn("[Twinkhook] Teleport error:", err, debug.traceback())
        return false
    end)

    isTeleporting = false
    return ok and result
end

local function StartAutoTeleport()
    autoTeleportGen = autoTeleportGen + 1
    local myGen = autoTeleportGen

    task.spawn(function()
        while autoTeleport and myGen == autoTeleportGen do
            local t0 = tick()
            TeleportToNextDoor()
            local elapsed = tick() - t0
            local waitTime = math.max(0.05, autoTeleportSpeed - elapsed)
            task.wait(waitTime)
        end
    end)
end

-- [FIX 5] StartAutoMove với crouch + remove step acceleration
local autoMoveConnection = nil

local function StartAutoMove()
    if autoMoveConnection then
        pcall(function() autoMoveConnection:Disconnect() end)
        autoMoveConnection = nil
    end
    currentWaypointIndex = 1
    stuckPos = nil
    stuckTimer = 0

    local attempts = 0
    while #pathWaypoints == 0 and attempts < 30 do
        attempts = attempts + 1
        pcall(DrawMultiRoomPath, 1)
        if #pathWaypoints > 0 then break end
        task.wait(0.1)
    end

    if #pathWaypoints == 0 then
        SafeNotify("Auto Move", "Không thể tạo path - chưa load room", 2)
        autoMove = false
        return
    end

    task.spawn(function()
        while autoMove do
            pcall(function() SendCrouch(false) end)
            task.wait(1)
        end
    end)

    autoMoveConnection = RunService.Heartbeat:Connect(function(dt)
        if not autoMove or isTeleporting then return end

        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end

        if currentWaypointIndex > #pathWaypoints then
            pcall(DrawMultiRoomPath, 1)
            currentWaypointIndex = 1
        end

        if #pathWaypoints == 0 then
            pcall(function() hum:Move(Vector3.zero, false) end)
            return
        end

        local targetPos = pathWaypoints[currentWaypointIndex]
        if not targetPos then return end

        local diff = targetPos - hrp.Position
        local flatDiff = Vector3.new(diff.X, 0, diff.Z)
        local dist = flatDiff.Magnitude

        if dist < 2 then
            currentWaypointIndex = currentWaypointIndex + 1
            stuckPos = nil
            stuckTimer = 0
            return
        end

        if removeStepAcceleration then
            hum.WalkSpeed = 30
            pcall(function() hum:Move(flatDiff.Unit, false) end)
        else
            if hum.WalkSpeed < 30 then hum.WalkSpeed = 30 end
            pcall(function() hum:MoveTo(targetPos) end)
        end

        if not stuckPos then
            stuckPos = hrp.Position
            stuckTimer = 0
        else
            stuckTimer = stuckTimer + dt
            if stuckTimer >= 2.5 then
                if (hrp.Position - stuckPos).Magnitude < 1.5 then
                    local tpCFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
                    SoftTeleport(tpCFrame)
                end
                stuckPos = nil
                stuckTimer = 0
            end
        end
    end)
end

-- [FIX 6] StartShowPath / StopShowPath
local function StartShowPath()
    if showPathConnection then
        pcall(function() showPathConnection:Disconnect() end)
        showPathConnection = nil
    end
    if showPathAttributeConn then
        pcall(function() showPathAttributeConn:Disconnect() end)
        showPathAttributeConn = nil
    end

    showPathActive = true
    lastRenderedRoom = nil
    lastRenderedNextRoom = nil

    local drawing = false
    local function TryDraw()
        if not showPathActive or drawing then return end
        local curRoom, curNum = GetCurrentRoom()
        local nextRoom, nextNum = GetNextRoom()
        if not curRoom or not nextRoom then return end

        if curNum == lastRenderedRoom and nextNum == lastRenderedNextRoom then
            return
        end

        drawing = true
        lastRenderedRoom = curNum
        lastRenderedNextRoom = nextNum
        pcall(DrawMultiRoomPath, 3)
        drawing = false
    end

    TryDraw()

    local accumulator = 0
    showPathConnection = RunService.Heartbeat:Connect(function(dt)
        if not showPathActive then return end
        accumulator = accumulator + dt
        if accumulator >= 0.3 then
            accumulator = 0
            pcall(TryDraw)
        end
    end)

    showPathAttributeConn = LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
        if not showPathActive then return end
        lastRenderedRoom = nil
    end)
end

local function StopShowPath()
    showPathActive = false
    if showPathConnection then
        pcall(function() showPathConnection:Disconnect() end)
        showPathConnection = nil
    end
    if showPathAttributeConn then
        pcall(function() showPathAttributeConn:Disconnect() end)
        showPathAttributeConn = nil
    end
    lastRenderedRoom = nil
    lastRenderedNextRoom = nil
    ClearPath()
end

-- [FIX 7] UI - Notify chỉ khi click button, không icon
local Section1 = MainTab:Section({ Title = "Teleport" })

Section1:Button({
    Title = "Teleport To the next door",
    Color = Color3.fromHex("FF3333"),
    Callback = function()
        pcall(function()
            if isTeleporting then return end
            SafeNotify("Teleport", "Đang teleport...", 1)
            local ok = TeleportToNextDoor()
            if not ok then
                SafeNotify("Teleport", "Thất bại: không tìm thấy cửa", 2)
            end
        end)
    end
})

Section1:Toggle({
    Title = "Auto Teleport Next Door",
    Value = false,
    Flag = "auto_teleport",
    Callback = function(state)
        pcall(function()
            autoTeleport = state
            if state then
                StartAutoTeleport()
            else
                autoTeleportGen = autoTeleportGen + 1
            end
        end)
    end
})

local Section2 = PathTab:Section({ Title = "Path Settings" })

Section2:Toggle({
    Title = "Show Path Next Door",
    Value = false,
    Flag = "show_path",
    Callback = function(state)
        pcall(function()
            if state then
                StartShowPath()
            else
                StopShowPath()
            end
        end)
    end
})

Section2:Toggle({
    Title = "Auto move Path",
    Value = false,
    Flag = "auto_move",
    Callback = function(state)
        pcall(function()
            autoMove = state
            if state then
                StartAutoMove()
            else
                if autoMoveConnection then
                    pcall(function() autoMoveConnection:Disconnect() end)
                    autoMoveConnection = nil
                end
                pcall(function() SendCrouch(false) end)
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    pcall(function() hum:Move(Vector3.zero, false) end)
                end
                currentWaypointIndex = 1
                stuckPos = nil
                stuckTimer = 0
            end
        end)
    end
})

-- [FIX 5] Toggle Remove step acceleration
Section2:Toggle({
    Title = "Remove step acceleration",
    Value = false,
    Flag = "remove_accel",
    Callback = function(state)
        pcall(function()
            removeStepAcceleration = state
            if state then
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = 30
                    if hum.UseJumpPower then
                        hum.JumpPower = 50
                    end
                end
            end
        end)
    end
})

Window:EditTheme({
    Accent = Color3.fromHex("FF3333"),
    Dialog = Color3.fromHex("1A1A1A"),
    Button = Color3.fromHex("FF6666")
})

SafeNotify("Heart Hub", "Ready!", 3)
