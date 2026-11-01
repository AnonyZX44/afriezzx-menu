local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

local Theme = {
	base = Color3.fromRGB(8, 8, 10),
	panel = Color3.fromRGB(14, 14, 17),
	surface = Color3.fromRGB(19, 19, 23),
	hover = Color3.fromRGB(26, 26, 31),
	stroke = Color3.fromRGB(36, 36, 42),
	text = Color3.fromRGB(238, 238, 242),
	muted = Color3.fromRGB(128, 128, 140),
	accent = Color3.fromRGB(214, 178, 112),
	good = Color3.fromRGB(118, 214, 160),
	bad = Color3.fromRGB(226, 100, 100),
}

local W, H = 432, 344

local function fetch(name)
	local ok, value = pcall(function()
		return _G[name]
	end)
	if ok and value ~= nil then
		return value
	end
	return nil
end

local function resolveParent()
	local gethuiFn = fetch("gethui")
	if type(gethuiFn) == "function" then
		local ok, result = pcall(gethuiFn)
		if ok and result then
			return result
		end
	end
	local ok, core = pcall(function()
		return game:GetService("CoreGui")
	end)
	if ok and core then
		return core
	end
	return Player:WaitForChild("PlayerGui")
end

local function build(class, props, parent)
	local object = Instance.new(class)
	for key, value in pairs(props) do
		object[key] = value
	end
	object.Parent = parent
	return object
end

local function round(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

local function outline(parent, color, thickness, transparency)
	local line = Instance.new("UIStroke")
	line.Color = color or Theme.stroke
	line.Thickness = thickness or 1
	line.Transparency = transparency or 0
	line.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	line.Parent = parent
	return line
end

local function label(parent, props)
	local object = Instance.new("TextLabel")
	object.BackgroundTransparency = 1
	object.BorderSizePixel = 0
	object.Font = Enum.Font.GothamMedium
	object.TextColor3 = Theme.text
	object.TextSize = 12
	object.TextXAlignment = Enum.TextXAlignment.Left
	object.TextYAlignment = Enum.TextYAlignment.Center
	for key, value in pairs(props) do
		object[key] = value
	end
	object.Parent = parent
	return object
end

local function animate(instance, time, goal, style, direction)
	local info = TweenInfo.new(time, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
	TweenService:Create(instance, info, goal):Play()
end

local guiParent = resolveParent()
local stale = guiParent:FindFirstChild("AfriezzxProbe")
if stale then
	pcall(function()
		stale:Destroy()
	end)
end

local gui = build("ScreenGui", {
	Name = "AfriezzxProbe",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 1000,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, guiParent)

local shell = build("Frame", {
	Name = "Shell",
	Size = UDim2.fromOffset(W, H),
	Position = UDim2.new(0.5, -W / 2, 0.5, -H / 2),
	BackgroundColor3 = Theme.base,
	BorderSizePixel = 0,
	Visible = false,
}, gui)
round(shell, 10)
outline(shell, Theme.stroke, 1, 0.2)

local shellScale = Instance.new("UIScale")
shellScale.Scale = 1
shellScale.Parent = shell

local header = build("Frame", {
	Size = UDim2.new(1, 0, 0, 44),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, shell)

label(header, {
	Name = "Title",
	Text = "Probe",
	Font = Enum.Font.GothamBold,
	TextSize = 15,
	Position = UDim2.fromOffset(16, 10),
	Size = UDim2.fromOffset(120, 18),
})

label(header, {
	Name = "Subtitle",
	Text = "remote check",
	TextSize = 11,
	TextColor3 = Theme.muted,
	Position = UDim2.fromOffset(16, 26),
	Size = UDim2.fromOffset(160, 12),
})

local runAll = build("TextButton", {
	Name = "RunAll",
	Text = "jalankan",
	Font = Enum.Font.GothamMedium,
	TextSize = 11,
	TextColor3 = Theme.base,
	BackgroundColor3 = Theme.accent,
	AutoButtonColor = false,
	Position = UDim2.new(1, -86, 0, 12),
	Size = UDim2.fromOffset(70, 24),
}, header)
round(runAll, 7)

local closeButton = build("TextButton", {
	Name = "Close",
	Text = "x",
	Font = Enum.Font.GothamMedium,
	TextSize = 12,
	TextColor3 = Theme.muted,
	BackgroundColor3 = Theme.surface,
	AutoButtonColor = false,
	Position = UDim2.new(1, -40, 0, 12),
	Size = UDim2.fromOffset(24, 24),
}, header)
round(closeButton, 7)

local tabs = build("Frame", {
	Name = "Tabs",
	Position = UDim2.fromOffset(14, 48),
	Size = UDim2.new(1, -28, 0, 26),
	BackgroundTransparency = 1,
}, shell)

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 6)
tabLayout.Parent = tabs

local pages = build("Frame", {
	Name = "Pages",
	Position = UDim2.fromOffset(14, 82),
	Size = UDim2.new(1, -28, 0, 168),
	BackgroundTransparency = 1,
}, shell)

local logPanel = build("Frame", {
	Name = "LogPanel",
	Position = UDim2.fromOffset(14, 256),
	Size = UDim2.new(1, -28, 0, 74),
	BackgroundColor3 = Theme.panel,
	BorderSizePixel = 0,
}, shell)
round(logPanel, 8)
outline(logPanel, Theme.stroke, 1, 0.35)

label(logPanel, {
	Name = "LogTitle",
	Text = "log",
	TextSize = 10,
	TextColor3 = Theme.muted,
	Position = UDim2.fromOffset(10, 5),
	Size = UDim2.fromOffset(60, 12),
})

local logScroll = build("ScrollingFrame", {
	Name = "LogScroll",
	Position = UDim2.fromOffset(8, 20),
	Size = UDim2.new(1, -16, 1, -26),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	ScrollBarThickness = 2,
	ScrollBarImageColor3 = Theme.stroke,
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, logPanel)

local logLayout = Instance.new("UIListLayout")
logLayout.Padding = UDim.new(0, 2)
logLayout.Parent = logScroll

local logCount = 0

local function log(text, color)
	logCount = logCount + 1
	if logCount > 90 then
		local first = logScroll:FindFirstChildOfClass("TextLabel")
		if first then
			first:Destroy()
		end
	end
	local line = label(logScroll, {
		Text = text,
		TextSize = 10,
		Font = Enum.Font.Code,
		TextColor3 = color or Theme.muted,
		Size = UDim2.new(1, -6, 0, 12),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	line.Name = "LogLine"
	task.defer(function()
		if logScroll then
			logScroll.CanvasPosition = Vector2.new(0, math.max(0, #logScroll:GetChildren() * 14 - 40))
		end
	end)
end

local function fmt(value)
	local kind = typeof(value)
	if kind == "string" then
		return string.format("%q", string.sub(value, 1, 48))
	elseif kind == "table" then
		local count = 0
		for _ in pairs(value) do
			count = count + 1
		end
		return "table(" .. count .. ")"
	elseif kind == "Instance" then
		return value.Name
	elseif value == nil then
		return "nil"
	end
	return tostring(value)
end

local function invoke(remote, tag, ...)
	if not remote then
		log(tag .. ": remote tidak ada", Theme.bad)
		return
	end
	local args = { ... }
	local ok, result = pcall(function()
		return remote:InvokeServer(table.unpack(args))
	end)
	if ok then
		log(tag .. ": " .. fmt(result), Theme.good)
	else
		log(tag .. ": gagal " .. tostring(result), Theme.bad)
	end
end

local function fire(remote, tag, ...)
	if not remote then
		log(tag .. ": remote tidak ada", Theme.bad)
		return
	end
	local args = { ... }
	local ok, result = pcall(function()
		remote:FireServer(table.unpack(args))
	end)
	if ok then
		log(tag .. ": terkirim", Theme.good)
	else
		log(tag .. ": gagal " .. tostring(result), Theme.bad)
	end
end

local function findRemote(path)
	local node = ReplicatedStorage
	for _, name in ipairs(path) do
		node = node:FindFirstChild(name)
		if not node then
			return nil
		end
	end
	if node:IsA("RemoteEvent") or node:IsA("RemoteFunction") then
		return node
	end
	return nil
end

local daily = findRemote({ "DailyRewardRequest" })
local radar = findRemote({ "GearRemotes", "UseRadar" })
local slot = findRemote({ "GearRemotes", "BuyGearSlot" })
local gearShop = findRemote({ "GearRemotes", "GetGearShop" }) or findRemote({ "GetGearShop" })
local relaunch = findRemote({ "AquariumSkinSystem", "Request" })
local requests = findRemote({ "EggGame", "Requests" })
local challenge = findRemote({ "EggChallengeRemotes", "PublicRequest" })

local function makePage(name)
	local page = build("ScrollingFrame", {
		Name = name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = name == "Remote",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.stroke,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, pages)
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.Parent = page
	return page
end

local remotePage = makePage("Remote")
local objectPage = makePage("Object")
local infoPage = makePage("Info")

local tabButtons = {}
local function selectTab(name)
	for tabName, button in pairs(tabButtons) do
		button.BackgroundColor3 = tabName == name and Theme.surface or Theme.base
		button.TextColor3 = tabName == name and Theme.accent or Theme.muted
	end
	for _, page in ipairs(pages:GetChildren()) do
		if page:IsA("ScrollingFrame") then
			page.Visible = page.Name == name
		end
	end
end

local function addTab(name)
	local button = build("TextButton", {
		Name = name,
		Text = name,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = Theme.muted,
		BackgroundColor3 = Theme.base,
		AutoButtonColor = false,
		Size = UDim2.fromOffset(70, 24),
	}, tabs)
	round(button, 6)
	tabButtons[name] = button
	button.MouseButton1Click:Connect(function()
		selectTab(name)
	end)
end

addTab("Remote")
addTab("Object")
addTab("Info")

local function row(parent, text, buttonText, callback)
	local frame = build("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundColor3 = Theme.panel,
		BorderSizePixel = 0,
	}, parent)
	round(frame, 6)
	label(frame, {
		Text = text,
		TextSize = 11,
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -90, 1, 0),
	})
	local button = build("TextButton", {
		Name = "Act_" .. string.gsub(text, " ", "_"),
		Text = buttonText,
		Font = Enum.Font.GothamMedium,
		TextSize = 10,
		TextColor3 = Theme.text,
		BackgroundColor3 = Theme.surface,
		AutoButtonColor = false,
		Position = UDim2.new(1, -74, 0, 4),
		Size = UDim2.fromOffset(64, 18),
	}, frame)
	round(button, 5)
	button.MouseButton1Click:Connect(function()
		button.BackgroundColor3 = Theme.hover
		task.delay(0.12, function()
			if button then
				button.BackgroundColor3 = Theme.surface
			end
		end)
		local ok, err = pcall(callback)
		if not ok then
			log("error: " .. tostring(err), Theme.bad)
		end
	end)
	return frame
end

row(remotePage, "Daily state", "cek", function()
	invoke(daily, "daily state", "State")
end)

row(remotePage, "Daily claim", "kirim", function()
	invoke(daily, "daily claim", "Claim")
end)

row(remotePage, "Radar", "kirim", function()
	fire(radar, "radar")
end)

row(remotePage, "Buy slot -1", "kirim", function()
	fire(slot, "slot -1", -1)
end)

row(remotePage, "Buy slot 1", "kirim", function()
	fire(slot, "slot 1", 1)
end)

row(remotePage, "Relaunch claim", "kirim", function()
	invoke(relaunch, "relaunch", "RelaunchClaim", "relaunch_stormforge")
end)

row(remotePage, "Gear shop", "baca", function()
	invoke(gearShop, "gear shop")
end)

row(remotePage, "Challenge 7", "kirim", function()
	fire(challenge, "challenge", 7)
end)

local uuidBox = build("TextBox", {
	Name = "Uuid",
	PlaceholderText = "uuid ikan / telur",
	Text = "",
	Font = Enum.Font.Code,
	TextSize = 10,
	TextColor3 = Theme.text,
	PlaceholderColor3 = Theme.muted,
	BackgroundColor3 = Theme.panel,
	BorderSizePixel = 0,
	ClearTextOnFocus = false,
	TextXAlignment = Enum.TextXAlignment.Left,
	Size = UDim2.new(1, 0, 0, 24),
}, objectPage)
round(uuidBox, 6)
local uuidPad = Instance.new("UIPadding")
uuidPad.PaddingLeft = UDim.new(0, 8)
uuidPad.Parent = uuidBox

row(objectPage, "Equip fish", "kirim", function()
	local id = uuidBox.Text
	if id == "" then
		log("uuid kosong", Theme.bad)
		return
	end
	fire(requests, "equip fish", "EquipFish", id)
end)

row(objectPage, "Drop egg", "kirim", function()
	local id = uuidBox.Text
	if id == "" then
		log("uuid kosong", Theme.bad)
		return
	end
	fire(requests, "drop egg", "DropCarriedEgg", id)
end)

local ownerRow = build("Frame", {
	Size = UDim2.new(1, 0, 0, 24),
	BackgroundTransparency = 1,
}, objectPage)
local ownerBox = build("TextBox", {
	Name = "Owner",
	PlaceholderText = "userid",
	Font = Enum.Font.Code,
	TextSize = 10,
	TextColor3 = Theme.text,
	PlaceholderColor3 = Theme.muted,
	BackgroundColor3 = Theme.panel,
	BorderSizePixel = 0,
	ClearTextOnFocus = false,
	Size = UDim2.new(0.58, -3, 1, 0),
}, ownerRow)
round(ownerBox, 6)
local slotBox = build("TextBox", {
	Name = "Slot",
	PlaceholderText = "slot",
	Font = Enum.Font.Code,
	TextSize = 10,
	TextColor3 = Theme.text,
	PlaceholderColor3 = Theme.muted,
	BackgroundColor3 = Theme.panel,
	BorderSizePixel = 0,
	ClearTextOnFocus = false,
	Size = UDim2.new(0.42, -3, 1, 0),
	Position = UDim2.new(0.58, 3, 0, 0),
}, ownerRow)
round(slotBox, 6)

row(objectPage, "Skip grow target", "kirim", function()
	local owner = tonumber(ownerBox.Text)
	local index = tonumber(slotBox.Text)
	if not owner or not index then
		log("owner atau slot bukan angka", Theme.bad)
		return
	end
	fire(requests, "skip grow", "SkipGrowTarget", { owner = owner, slot = index })
end)

row(infoPage, "Remote status", "cek", function()
	local list = {
		{ "daily", daily },
		{ "radar", radar },
		{ "slot", slot },
		{ "shop", gearShop },
		{ "relaunch", relaunch },
		{ "requests", requests },
		{ "challenge", challenge },
	}
	for _, entry in ipairs(list) do
		log(entry[1] .. ": " .. (entry[2] and "ada" or "hilang"), entry[2] and Theme.good or Theme.bad)
	end
end)

row(infoPage, "Clear log", "hapus", function()
	for _, child in ipairs(logScroll:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
	logCount = 0
end)

row(infoPage, "Players count", "cek", function()
	log("players: " .. #Players:GetPlayers(), Theme.good)
end)

row(infoPage, "Uptime", "cek", function()
	log("uptime: " .. math.floor(time()) .. "s", Theme.good)
end)

local function runAllProbes()
	selectTab("Remote")
	log("--- mulai ---", Theme.accent)
	invoke(daily, "daily state", "State")
	invoke(daily, "daily claim", "Claim")
	fire(radar, "radar")
	fire(slot, "slot -1", -1)
	invoke(relaunch, "relaunch", "RelaunchClaim", "relaunch_stormforge")
	invoke(gearShop, "gear shop")
	fire(challenge, "challenge", 7)
	log("--- selesai ---", Theme.accent)
end

runAll.MouseButton1Click:Connect(function()
	local ok, err = pcall(runAllProbes)
	if not ok then
		log("error: " .. tostring(err), Theme.bad)
	end
end)

local function listen(remote, name, handler)
	if not remote then
		return
	end
	remote.OnClientEvent:Connect(function(...)
		local ok, err = pcall(handler, ...)
		if not ok then
			log(name .. " error: " .. tostring(err), Theme.bad)
		end
	end)
end

listen(challenge, "challenge", function(id, data)
	local rows = 0
	if type(data) == "table" and type(data.Rows) == "table" then
		rows = #data.Rows
	end
	log("challenge " .. tostring(id) .. ": rows " .. rows, Theme.muted)
end)

listen(radar, "radar", function(data)
	if type(data) == "table" then
		local tier = tostring(data.targetTier)
		local position = data.targetPosition
		local where = position and string.format("%.0f %.0f %.0f", position.X, position.Y, position.Z) or "?"
		log("radar: " .. tier .. " di " .. where, Theme.muted)
	end
end)

listen(findRemote({ "GearRemotes", "GearShopSync" }), "shop", function(data)
	if type(data) == "table" and type(data.slots) == "table" then
		log("shop: " .. #data.slots .. " slot", Theme.muted)
	end
end)

listen(findRemote({ "EggGame", "Events" }), "events", function(tag, payload)
	log("event: " .. tostring(tag), Theme.muted)
end)

listen(findRemote({ "EggGame", "TrackSync" }), "track", function(list)
	if type(list) == "table" then
		log("track: " .. #list .. " tier", Theme.muted)
	end
end)

listen(findRemote({ "TokenSystem", "Feedback" }), "token", function(tag, data)
	if type(data) == "table" and data.Position then
		log("token: " .. string.format("%.0f %.0f %.0f", data.Position.X, data.Position.Y, data.Position.Z), Theme.muted)
	end
end)

local bubble = build("TextButton", {
	Name = "Bubble",
	Text = "A",
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	TextColor3 = Theme.base,
	BackgroundColor3 = Theme.accent,
	AutoButtonColor = false,
	Size = UDim2.fromOffset(44, 44),
	Position = UDim2.new(1, -64, 0.5, -22),
	Visible = false,
}, gui)
round(bubble, 999)

local dragObject = nil
local dragStart = nil
local startPosition = nil
local bubbleMoved = false

local function startDrag(object, input)
	dragObject = object
	dragStart = input.Position
	startPosition = object.Position
end

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		startDrag(shell, input)
	end
end)

shell.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		startDrag(shell, input)
	end
end)

bubble.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		bubbleMoved = false
		startDrag(bubble, input)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragObject or not dragStart or not startPosition then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local delta = input.Position - dragStart
	if dragObject == bubble and delta.Magnitude > 6 then
		bubbleMoved = true
	end
	dragObject.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragObject = nil
		dragStart = nil
		startPosition = nil
	end
end)

local function setMenu(open)
	if open then
		bubble.Visible = false
		shell.Visible = true
		shellScale.Scale = 0.97
		animate(shellScale, 0.18, { Scale = 1 })
	else
		shell.Visible = false
		bubble.Visible = true
	end
end

closeButton.MouseButton1Click:Connect(function()
	setMenu(false)
end)

bubble.MouseButton1Click:Connect(function()
	if not bubbleMoved then
		setMenu(true)
	end
end)

selectTab("Remote")

local intro = build("Frame", {
	Name = "Intro",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Theme.base,
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	ZIndex = 20,
}, gui)

local introText = label(intro, {
	Name = "IntroText",
	Text = "Made by Afriezzx",
	Font = Enum.Font.GothamBold,
	TextSize = 22,
	TextColor3 = Theme.text,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextTransparency = 1,
	Size = UDim2.new(1, 0, 0, 30),
	Position = UDim2.new(0, 0, 0.5, -15),
})

local introRule = build("Frame", {
	Size = UDim2.fromOffset(0, 1),
	Position = UDim2.new(0.5, -0, 0.5, 22),
	BackgroundColor3 = Theme.accent,
	BackgroundTransparency = 0.2,
	BorderSizePixel = 0,
}, intro)

animate(introText, 0.35, { TextTransparency = 0 })
animate(introRule, 0.5, { Size = UDim2.fromOffset(88, 1) })

task.delay(1.1, function()
	animate(intro, 0.4, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	animate(introText, 0.4, { TextTransparency = 1 }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	animate(introRule, 0.4, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	task.wait(0.45)
	intro:Destroy()
	setMenu(true)
	log("siap", Theme.accent)
end)

log("remote " .. (daily and "ada" or "hilang"), daily and Theme.good or Theme.bad)
