local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = workspace
local Camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")

local Player = Players.LocalPlayer

local Theme = {
	base = Color3.fromRGB(8, 8, 10),
	panel = Color3.fromRGB(14, 14, 17),
	raised = Color3.fromRGB(21, 21, 26),
	hover = Color3.fromRGB(24, 24, 29),
	stroke = Color3.fromRGB(39, 39, 46),
	text = Color3.fromRGB(235, 235, 240),
	muted = Color3.fromRGB(128, 128, 140),
	accent = Color3.fromRGB(216, 182, 117),
	accentDim = Color3.fromRGB(58, 50, 34),
	live = Color3.fromRGB(120, 214, 160),
	danger = Color3.fromRGB(226, 92, 92),
	ally = Color3.fromRGB(124, 176, 232),
	loot = Color3.fromRGB(232, 178, 96),
	key = Color3.fromRGB(150, 220, 170),
}

local WINDOW_W = 600
local WINDOW_H = 400

local function fetch(name)
	local ok, value = pcall(function()
		local env = getfenv(0)
		return env and env[name]
	end)
	if ok and value ~= nil then
		return value
	end
	ok, value = pcall(function()
		local env = getfenv()
		return env and env[name]
	end)
	if ok and value ~= nil then
		return value
	end
	ok, value = pcall(function()
		return _G[name]
	end)
	if ok then
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

local function text(parent, props)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamMedium
	label.TextColor3 = Theme.text
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	for key, value in pairs(props) do
		label[key] = value
	end
	label.Parent = parent
	return label
end

local guiParent = resolveParent()
local staleGui = guiParent:FindFirstChild("AfriezzxMenu")
if staleGui then
	pcall(function()
		staleGui:Destroy()
	end)
end

local gui = build("ScreenGui", {
	Name = "AfriezzxMenu",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 999,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, guiParent)

local flags = {
	esp = false,
	players = true,
	opah = true,
	names = true,
	distance = true,
	tracers = false,
	breakables = false,
	keys = false,
}

local refreshESP

local switchStyle = {
	on = Theme.accent,
	off = Theme.raised,
}

local function animate(instance, time, goal, style, direction)
	local info = TweenInfo.new(time, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
	local tween = TweenService:Create(instance, info, goal)
	tween:Play()
	return tween
end

local function buildSwitch(parent, default, changed)
	local track = build("Frame", {
		Name = "Track",
		Size = UDim2.fromOffset(38, 20),
		Position = UDim2.fromOffset(0, 0),
		BackgroundColor3 = Theme.raised,
		BorderSizePixel = 0,
	}, parent)
	round(track, 10)
	local edge = outline(track, Theme.stroke, 1, 0.25)
	local knob = build("Frame", {
		Name = "Knob",
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = Theme.muted,
		BorderSizePixel = 0,
	}, track)
	round(knob, 7)

	local state = default == true
	local function render(withTween)
		local goal = state and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)
		local fill = state and Theme.accent or Theme.muted
		local backing = state and Theme.accentDim or Theme.raised
		if withTween then
			animate(knob, 0.14, { Position = goal })
			animate(knob, 0.14, { BackgroundColor3 = fill })
			animate(track, 0.14, { BackgroundColor3 = backing })
			animate(edge, 0.14, { Color = state and Theme.accent or Theme.stroke, Transparency = state and 0.55 or 0.25 })
		else
			knob.Position = goal
			knob.BackgroundColor3 = fill
			track.BackgroundColor3 = backing
			edge.Color = state and Theme.accent or Theme.stroke
			edge.Transparency = state and 0.55 or 0.25
		end
	end
	render(false)

	local hit = build("TextButton", {
		Name = "Hit",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
	}, track)
	hit.MouseButton1Click:Connect(function()
		state = not state
		render(true)
		if changed then
			changed(state)
		end
	end)

	return {
		get = function()
			return state
		end,
		set = function(value, withTween)
			state = value == true
			render(withTween ~= false)
		end,
	}
end

local function buildRow(list, order, title, subtitle, default, changed)
	local row = build("Frame", {
		Name = title,
		Size = UDim2.new(1, 0, 0, 54),
		BackgroundColor3 = Theme.hover,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = order,
	}, list)

	text(row, {
		Size = UDim2.new(1, -58, 0, 20),
		Position = UDim2.fromOffset(0, 9),
		Text = title,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
	})

	local sub = text(row, {
		Size = UDim2.new(1, -58, 0, 16),
		Position = UDim2.fromOffset(0, 28),
		Text = subtitle or "",
		TextSize = 11,
		TextColor3 = Theme.muted,
		Font = Enum.Font.Gotham,
	})

	local divider = build("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = Theme.stroke,
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
	}, row)

	local control = buildSwitch(row, default, changed)
	control.frame = row
	control.track = row:FindFirstChild("Track")

	row.MouseEnter:Connect(function()
		animate(row, 0.12, { BackgroundTransparency = 0 })
	end)
	row.MouseLeave:Connect(function()
		animate(row, 0.12, { BackgroundTransparency = 1 })
	end)
	sub.Visible = subtitle ~= nil and subtitle ~= ""

	local switch = row:FindFirstChild("Track")
	if switch then
		switch.Position = UDim2.new(1, -38, 0.5, -10)
	end

	return control
end

local menu = build("Frame", {
	Name = "Window",
	Size = UDim2.fromOffset(WINDOW_W, WINDOW_H),
	BackgroundColor3 = Theme.base,
	BorderSizePixel = 0,
}, gui)
menu.Visible = false
round(menu, 18)
outline(menu, Theme.stroke, 1, 0.15)

local menuScale = Instance.new("UIScale")
menuScale.Scale = 1
menuScale.Parent = menu

local topLine = build("Frame", {
	Size = UDim2.new(1, -36, 0, 1),
	Position = UDim2.fromOffset(18, 0),
	BackgroundColor3 = Theme.accent,
	BackgroundTransparency = 0.35,
	BorderSizePixel = 0,
}, menu)
local topGradient = Instance.new("UIGradient")
topGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.5, 0.25),
	NumberSequenceKeypoint.new(1, 1),
})
topGradient.Parent = topLine

local header = build("Frame", {
	Name = "Header",
	Size = UDim2.new(1, 0, 0, 58),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, menu)

local mark = build("Frame", {
	Size = UDim2.fromOffset(26, 26),
	Position = UDim2.fromOffset(18, 16),
	BackgroundColor3 = Theme.accent,
	BorderSizePixel = 0,
}, header)
round(mark, 8)
text(mark, {
	Size = UDim2.fromScale(1, 1),
	Text = "A",
	Font = Enum.Font.GothamBlack,
	TextSize = 15,
	TextColor3 = Theme.base,
	TextXAlignment = Enum.TextXAlignment.Center,
})

text(header, {
	Size = UDim2.fromOffset(200, 18),
	Position = UDim2.fromOffset(54, 15),
	Text = "Afriezzx",
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	TextColor3 = Theme.text,
})

text(header, {
	Size = UDim2.fromOffset(200, 14),
	Position = UDim2.fromOffset(54, 31),
	Text = "roblox menu",
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextColor3 = Theme.muted,
})

local version = text(header, {
	Size = UDim2.fromOffset(46, 16),
	Position = UDim2.new(1, -104, 0, 21),
	Text = "v1.0",
	Font = Enum.Font.Code,
	TextSize = 10,
	TextColor3 = Theme.muted,
	TextXAlignment = Enum.TextXAlignment.Right,
})

local close = build("TextButton", {
	Size = UDim2.fromOffset(26, 26),
	Position = UDim2.new(1, -44, 0, 16),
	BackgroundColor3 = Theme.raised,
	Text = "×",
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	TextColor3 = Theme.muted,
	AutoButtonColor = false,
	BorderSizePixel = 0,
}, header)
round(close, 8)

close.MouseEnter:Connect(function()
	animate(close, 0.12, { BackgroundColor3 = Theme.hover, TextColor3 = Theme.text })
end)
close.MouseLeave:Connect(function()
	animate(close, 0.12, { BackgroundColor3 = Theme.raised, TextColor3 = Theme.muted })
end)

local headerRule = build("Frame", {
	Size = UDim2.new(1, -36, 0, 1),
	Position = UDim2.fromOffset(18, 57),
	BackgroundColor3 = Theme.stroke,
	BackgroundTransparency = 0.3,
	BorderSizePixel = 0,
}, menu)

local rail = build("Frame", {
	Name = "Rail",
	Size = UDim2.new(0, 148, 1, -88),
	Position = UDim2.fromOffset(0, 58),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, menu)

local railLine = build("Frame", {
	Size = UDim2.new(0, 1, 1, -36),
	Position = UDim2.new(0, 147, 0, 18),
	BackgroundColor3 = Theme.stroke,
	BackgroundTransparency = 0.4,
	BorderSizePixel = 0,
}, rail)

local railList = build("Frame", {
	Size = UDim2.new(1, 0, 0, 120),
	Position = UDim2.fromOffset(0, 12),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, rail)
local railLayout = Instance.new("UIListLayout")
railLayout.Padding = UDim.new(0, 2)
railLayout.SortOrder = Enum.SortOrder.LayoutOrder
railLayout.Parent = railList

local content = build("Frame", {
	Name = "Content",
	Size = UDim2.new(1, -166, 1, -88),
	Position = UDim2.fromOffset(166, 58),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, menu)

local contentTitle = text(content, {
	Size = UDim2.new(1, 0, 0, 22),
	Position = UDim2.fromOffset(0, 14),
	Text = "ESP",
	Font = Enum.Font.GothamBold,
	TextSize = 17,
})

local contentSub = text(content, {
	Size = UDim2.new(1, 0, 0, 15),
	Position = UDim2.fromOffset(0, 36),
	Text = "render highlights and tracking",
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextColor3 = Theme.muted,
})

local pages = {}
local tabs = {}

local function createPage(name)
	local page = build("ScrollingFrame", {
		Name = name,
		Size = UDim2.new(1, 0, 1, -66),
		Position = UDim2.fromOffset(0, 60),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.muted,
		ScrollBarImageTransparency = 0.55,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ClipsDescendants = true,
		Visible = false,
	}, content)
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 0)
	layout.Parent = page
	local padding = Instance.new("UIPadding")
	padding.PaddingBottom = UDim.new(0, 6)
	padding.Parent = page
	pages[name] = page
	return page
end

local espPage = createPage("ESP")
local worldPage = createPage("World")
local aboutPage = createPage("About")

local pageMeta = {
	ESP = { "ESP", "render highlights and tracking" },
	World = { "World", "objects worth marking on the map" },
	About = { "About", "build and controls" },
}

local function selectTab(name)
	for pageName, page in pairs(pages) do
		page.Visible = pageName == name
	end
	for tabName, tab in pairs(tabs) do
		local active = tabName == name
		animate(tab.label, 0.14, { TextColor3 = active and Theme.text or Theme.muted })
		animate(tab.bar, 0.14, {
			BackgroundTransparency = active and 0 or 1,
			Size = active and UDim2.fromOffset(2, 16) or UDim2.fromOffset(2, 6),
		})
	end
	local meta = pageMeta[name]
	contentTitle.Text = meta[1]
	contentSub.Text = meta[2]
end

local function buildTab(order, name)
	local button = build("TextButton", {
		Name = name,
		Size = UDim2.new(1, -18, 0, 34),
		Position = UDim2.fromOffset(0, 0),
		BackgroundColor3 = Theme.raised,
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		LayoutOrder = order,
	}, railList)

	local bar = build("Frame", {
		Size = UDim2.fromOffset(2, 6),
		Position = UDim2.fromOffset(10, 9),
		BackgroundColor3 = Theme.accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, button)
	round(bar, 1)

	local label = text(button, {
		Size = UDim2.new(1, -26, 1, 0),
		Position = UDim2.fromOffset(22, 0),
		Text = name,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextColor3 = Theme.muted,
	})

	button.MouseEnter:Connect(function()
		if not pages[name].Visible then
			animate(label, 0.12, { TextColor3 = Theme.text })
		end
	end)
	button.MouseLeave:Connect(function()
		if not pages[name].Visible then
			animate(label, 0.12, { TextColor3 = Theme.muted })
		end
	end)
	button.MouseButton1Click:Connect(function()
		selectTab(name)
	end)

	tabs[name] = { label = label, bar = bar }
end

buildTab(1, "ESP")
buildTab(2, "World")
buildTab(3, "About")

local footer = build("Frame", {
	Name = "Footer",
	Size = UDim2.new(1, 0, 0, 30),
	Position = UDim2.new(0, 0, 1, -30),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, menu)

local footerRule = build("Frame", {
	Size = UDim2.new(1, -36, 0, 1),
	Position = UDim2.fromOffset(18, 0),
	BackgroundColor3 = Theme.stroke,
	BackgroundTransparency = 0.35,
	BorderSizePixel = 0,
}, footer)

text(footer, {
	Size = UDim2.fromOffset(180, 30),
	Position = UDim2.fromOffset(18, 0),
	Text = "afriezzx",
	Font = Enum.Font.GothamMedium,
	TextSize = 10,
	TextColor3 = Theme.accent,
})

local statusDot = build("Frame", {
	Size = UDim2.fromOffset(6, 6),
	Position = UDim2.new(1, -104, 0.5, -3),
	BackgroundColor3 = Theme.muted,
	BorderSizePixel = 0,
}, footer)
round(statusDot, 3)

local statusText = text(footer, {
	Size = UDim2.fromOffset(72, 30),
	Position = UDim2.new(1, -94, 0, 0),
	Text = "right shift",
	Font = Enum.Font.Code,
	TextSize = 10,
	TextColor3 = Theme.muted,
	TextXAlignment = Enum.TextXAlignment.Right,
})

local tracked = {}
local tracers = {}
local drawingReady = nil

local function checkDrawing()
	if drawingReady ~= nil then
		return drawingReady
	end
	local ok = pcall(function()
		local line = Drawing.new("Line")
		line:Remove()
	end)
	drawingReady = ok
	return ok
end

local function entryPart(inst)
	if inst:IsA("BasePart") then
		return inst
	end
	if inst:IsA("Model") then
		return inst.PrimaryPart or inst:FindFirstChild("HumanoidRootPart") or inst:FindFirstChildWhichIsA("BasePart")
	end
	return nil
end

local function makeEntry(inst, kind, color, labelText)
	if not inst or tracked[inst] then
		return tracked[inst]
	end
	local part = entryPart(inst)
	if not part then
		return nil
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "AFZ_MARK"
	highlight.FillColor = color
	highlight.FillTransparency = 0.64
	highlight.OutlineColor = color
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee = inst
	highlight.Enabled = false
	highlight.Parent = inst

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "AFZ_TAG"
	billboard.Size = UDim2.fromOffset(160, 20)
	billboard.StudsOffset = Vector3.new(0, 2.6, 0)
	billboard.AlwaysOnTop = true
	billboard.Enabled = false
	billboard.Adornee = part
	billboard.Parent = part

	local caption = text(billboard, {
		Size = UDim2.fromScale(1, 1),
		Text = labelText,
		TextSize = 11,
		Font = Enum.Font.GothamMedium,
		TextColor3 = color,
		TextStrokeTransparency = 0.35,
		TextXAlignment = Enum.TextXAlignment.Center,
	})

	local entry = {
		kind = kind,
		part = part,
		highlight = highlight,
		billboard = billboard,
		caption = caption,
		label = labelText,
	}
	tracked[inst] = entry
	return entry
end

local function kindVisible(kind)
	if not flags.esp then
		return false
	end
	if kind == "player" then
		return flags.players
	elseif kind == "opah" then
		return flags.opah
	elseif kind == "breakable" then
		return flags.breakables
	elseif kind == "key" then
		return flags.keys
	end
	return false
end

local function dropEntry(inst, entry)
	if entry.highlight then
		pcall(function()
			entry.highlight:Destroy()
		end)
	end
	if entry.billboard then
		pcall(function()
			entry.billboard:Destroy()
		end)
	end
	local line = tracers[inst]
	if line then
		pcall(function()
			line:Remove()
		end)
		tracers[inst] = nil
	end
	tracked[inst] = nil
end

refreshESP = function()
	for inst, entry in pairs(tracked) do
		if not inst.Parent then
			dropEntry(inst, entry)
		else
			local visible = kindVisible(entry.kind)
			entry.highlight.Enabled = visible
			entry.billboard.Enabled = visible and (flags.names or flags.distance)
		end
	end
	statusDot.BackgroundColor3 = flags.esp and Theme.live or Theme.muted
	statusText.Text = flags.esp and "active" or "right shift"
end

local function scanPlayers()
	local function attach(character, displayName)
		if not character then
			return
		end
		task.wait(0.15)
		makeEntry(character, "player", Theme.ally, displayName)
		refreshESP()
	end

	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= Player then
			task.spawn(attach, other.Character, other.DisplayName)
			other.CharacterAdded:Connect(function(character)
				attach(character, other.DisplayName)
			end)
		end
	end
	Players.PlayerAdded:Connect(function(other)
		other.CharacterAdded:Connect(function(character)
			attach(character, other.DisplayName)
		end)
		attach(other.Character, other.DisplayName)
	end)
	Players.PlayerRemoving:Connect(function(other)
		if other.Character then
			local entry = tracked[other.Character]
			if entry then
				dropEntry(other.Character, entry)
			end
		end
	end)
end

local function scanFolder(folderName, kind, color, prefix)
	task.spawn(function()
		local folder = Workspace:WaitForChild(folderName, 25)
		if not folder then
			return
		end
		local function attach(child)
			if child:IsA("Model") or child:IsA("BasePart") then
				makeEntry(child, kind, color, prefix .. child.Name)
			end
		end
		for _, child in ipairs(folder:GetChildren()) do
			attach(child)
		end
		folder.ChildAdded:Connect(function(child)
			task.wait(0.15)
			attach(child)
		end)
		refreshESP()
	end)
end

local function scanOpah()
	task.spawn(function()
		while true do
			local opah = Workspace:FindFirstChild("Opah")
			if opah then
				if opah:IsA("Model") and opah:FindFirstChild("HumanoidRootPart") then
					makeEntry(opah, "opah", Theme.danger, "Opah")
				end
				for _, child in ipairs(opah:GetDescendants()) do
					if child:IsA("Model") and child:FindFirstChildOfClass("Humanoid") and child ~= opah then
						makeEntry(child, "opah", Theme.danger, "Opah")
					end
				end
			end
			refreshESP()
			task.wait(2)
		end
	end)
end

scanPlayers()
scanFolder("OpahBreakables", "breakable", Theme.loot, "")
scanFolder("PuzzleItems", "key", Theme.key, "")
scanOpah()

local espSwitches = {}

espSwitches.esp = buildRow(espPage, 1, "ESP", "master switch", false, function(value)
	flags.esp = value
	refreshESP()
end)

espSwitches.players = buildRow(espPage, 2, "Players", "highlight other players", true, function(value)
	flags.players = value
	refreshESP()
end)

espSwitches.opah = buildRow(espPage, 3, "Opah", "mark the entity through walls", true, function(value)
	flags.opah = value
	refreshESP()
end)

espSwitches.names = buildRow(espPage, 4, "Names", "label above each target", true, function(value)
	flags.names = value
	refreshESP()
end)

espSwitches.distance = buildRow(espPage, 5, "Distance", "meters to target", true, function(value)
	flags.distance = value
	refreshESP()
end)

espSwitches.tracers = buildRow(espPage, 6, "Tracers", "line from screen bottom", false, function(value)
	flags.tracers = value
	if value and not checkDrawing() then
		flags.tracers = false
		espSwitches.tracers.set(false)
	end
	refreshESP()
end)

espSwitches.breakables = buildRow(worldPage, 1, "Breakables", "chairs and props in OpahBreakables", false, function(value)
	flags.breakables = value
	refreshESP()
end)

espSwitches.keys = buildRow(worldPage, 2, "Puzzle keys", "keys and padlock items", false, function(value)
	flags.keys = value
	refreshESP()
end)

local aboutLines = {
	{ "author", "Afriezzx" },
	{ "version", "1.0" },
	{ "toggle", "RightShift or the A bubble" },
	{ "targets", "Players, Opah, Breakables, PuzzleItems" },
}

for index, pair in ipairs(aboutLines) do
	local row = build("Frame", {
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = Theme.hover,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = index,
	}, aboutPage)
	text(row, {
		Size = UDim2.fromOffset(110, 42),
		Position = UDim2.fromOffset(0, 0),
		Text = pair[1],
		TextSize = 11,
		Font = Enum.Font.Gotham,
		TextColor3 = Theme.muted,
	})
	text(row, {
		Size = UDim2.new(1, -120, 0, 42),
		Position = UDim2.fromOffset(120, 0),
		Text = pair[2],
		TextSize = 12,
		Font = Enum.Font.GothamMedium,
	})
	local rule = build("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = Theme.stroke,
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
	}, row)
	rule.Name = "Rule"
end

local bubble = build("TextButton", {
	Name = "Bubble",
	Size = UDim2.fromOffset(46, 46),
	BackgroundColor3 = Theme.base,
	Text = "A",
	Font = Enum.Font.GothamBlack,
	TextSize = 18,
	TextColor3 = Theme.accent,
	AutoButtonColor = false,
	BorderSizePixel = 0,
	Visible = false,
}, gui)
round(bubble, 23)
local bubbleStroke = outline(bubble, Theme.stroke, 1, 0.05)

local openState = false
local animToken = 0

local function setMenu(open)
	openState = open
	animToken = animToken + 1
	local token = animToken
	if open then
		menu.Visible = true
		menuScale.Scale = 0.94
		animate(menuScale, 0.16, { Scale = 1 })
		animate(bubble, 0.12, { TextColor3 = Theme.accent })
	else
		animate(menuScale, 0.14, { Scale = 0.94 })
		task.delay(0.14, function()
			if token == animToken then
				menu.Visible = false
			end
		end)
	end
end

local function toggleMenu()
	setMenu(not openState)
end

close.MouseButton1Click:Connect(function()
	setMenu(false)
end)

bubble.MouseEnter:Connect(function()
	animate(bubbleStroke, 0.12, { Color = Theme.accent, Transparency = 0.45 })
end)
bubble.MouseLeave:Connect(function()
	animate(bubbleStroke, 0.12, { Color = Theme.stroke, Transparency = 0.05 })
end)

selectTab("ESP")

local function fitWindow()
	local viewport = Camera.ViewportSize
	if viewport.X < 32 or viewport.Y < 32 then
		return
	end
	local scale = math.min(1, (viewport.X - 24) / WINDOW_W, (viewport.Y - 24) / WINDOW_H)
	scale = math.max(scale, 0.55)
	menuScale.Scale = scale
	local width = WINDOW_W * scale
	local height = WINDOW_H * scale
	menu.Position = UDim2.fromOffset((viewport.X - width) / 2, (viewport.Y - height) / 2)
end

fitWindow()

local bubblePosition = UDim2.new(1, -70, 0.5, -23)
local bubbleTouchOffset
local bubbleOrigin
local bubbleTravel = 0

bubble.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		bubbleTouchOffset = Vector2.new(input.Position.X, input.Position.Y) - Vector2.new(bubble.AbsolutePosition.X, bubble.AbsolutePosition.Y)
		bubbleOrigin = Vector2.new(input.Position.X, input.Position.Y)
		bubbleTravel = 0
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not bubbleTouchOffset then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local pointer = Vector2.new(input.Position.X, input.Position.Y)
	bubbleTravel = math.max(bubbleTravel, (pointer - bubbleOrigin).Magnitude)
	local viewport = Camera.ViewportSize
	local x = math.clamp(input.Position.X - bubbleTouchOffset.X, 0, math.max(0, viewport.X - 46))
	local y = math.clamp(input.Position.Y - bubbleTouchOffset.Y, 0, math.max(0, viewport.Y - 46))
	bubble.Position = UDim2.fromOffset(x, y)
end)

UserInputService.InputEnded:Connect(function(input)
	if not bubbleTouchOffset then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	bubbleTouchOffset = nil
	if bubbleTravel < 6 then
		toggleMenu()
	end
end)

local dragging
local dragOffset

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragOffset = Vector2.new(input.Position.X, input.Position.Y) - Vector2.new(menu.AbsolutePosition.X, menu.AbsolutePosition.Y)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local viewport = Camera.ViewportSize
	local scale = menuScale.Scale
	local x = math.clamp(input.Position.X - dragOffset.X, 0, math.max(0, viewport.X - WINDOW_W * scale))
	local y = math.clamp(input.Position.Y - dragOffset.Y, 0, math.max(0, viewport.Y - WINDOW_H * scale))
	menu.Position = UDim2.fromOffset(x, y)
end)

UserInputService.InputEnded:Connect(function(input)
	if not dragging then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	if Workspace.CurrentCamera then
		Camera = Workspace.CurrentCamera
	end
end)

local viewportConnection = Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	if not dragging then
		fitWindow()
	end
	if bubble.Visible then
		local viewport = Camera.ViewportSize
		local absolute = bubble.AbsolutePosition
		bubble.Position = UDim2.fromOffset(
			math.clamp(absolute.X, 0, math.max(0, viewport.X - 46)),
			math.clamp(absolute.Y, 0, math.max(0, viewport.Y - 46))
		)
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.RightShift then
		toggleMenu()
	end
end)

local labelClock = 0

RunService.RenderStepped:Connect(function(delta)
	labelClock = labelClock + delta

	if labelClock >= 0.1 then
		labelClock = 0
		local origin = Camera.CFrame.Position
		for inst, entry in pairs(tracked) do
			if not inst.Parent then
				dropEntry(inst, entry)
			elseif entry.highlight.Enabled then
				local distance = math.floor((origin - entry.part.Position).Magnitude)
				local caption = entry.label
				if flags.distance then
					caption = caption .. "  " .. distance .. "m"
				end
				entry.caption.Text = caption
			end
		end
	end

	local drawOn = flags.esp and flags.tracers and drawingReady
	local viewport = Camera.ViewportSize
	for inst, entry in pairs(tracked) do
		local line = tracers[inst]
		local visible = drawOn and entry.highlight.Enabled
		if visible then
			if not line then
				local ok, created = pcall(function()
					return Drawing.new("Line")
				end)
				if ok and created then
					line = created
					tracers[inst] = line
				end
			end
			if line then
				local point, onScreen = Camera:WorldToViewportPoint(entry.part.Position)
				if onScreen and point.Z > 0 then
					line.From = Vector2.new(viewport.X / 2, viewport.Y)
					line.To = Vector2.new(point.X, point.Y)
					line.Color = entry.highlight.OutlineColor
					line.Thickness = 1
					line.Transparency = 0.35
					line.Visible = true
				else
					line.Visible = false
				end
			end
		elseif line then
			line.Visible = false
		end
	end
end)

gui.Destroying:Connect(function()
	if viewportConnection then
		viewportConnection:Disconnect()
	end
	for inst, entry in pairs(tracked) do
		dropEntry(inst, entry)
	end
	for inst, line in pairs(tracers) do
		pcall(function()
			line:Remove()
		end)
		tracers[inst] = nil
	end
end)

local intro = build("Frame", {
	Name = "Intro",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
}, gui)

local introStack = build("Frame", {
	Size = UDim2.fromOffset(320, 90),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, intro)

local introKicker = text(introStack, {
	Size = UDim2.new(1, 0, 0, 18),
	Position = UDim2.fromOffset(0, 4),
	Text = "Made by",
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextColor3 = Theme.muted,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextTransparency = 1,
})

local introName = text(introStack, {
	Size = UDim2.new(1, 0, 0, 44),
	Position = UDim2.fromOffset(0, 22),
	Text = "Afriezzx",
	Font = Enum.Font.GothamBlack,
	TextSize = 34,
	TextColor3 = Theme.text,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextTransparency = 1,
})

local introRule = build("Frame", {
	Size = UDim2.fromOffset(28, 1),
	Position = UDim2.fromOffset(146, 74),
	BackgroundColor3 = Theme.accent,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, introStack)

task.spawn(function()
	animate(introKicker, 0.28, { TextTransparency = 0 })
	task.wait(0.08)
	animate(introName, 0.34, { TextTransparency = 0 })
	animate(introRule, 0.34, { BackgroundTransparency = 0.2, Size = UDim2.fromOffset(64, 1), Position = UDim2.fromOffset(128, 74) })
	task.wait(1.05)
	animate(introKicker, 0.4, { TextTransparency = 1 })
	animate(introName, 0.4, { TextTransparency = 1 })
	animate(introRule, 0.4, { BackgroundTransparency = 1 })
	animate(intro, 0.4, { BackgroundTransparency = 1 })
	task.wait(0.42)
	intro:Destroy()
	bubble.Visible = true
	bubble.Position = bubblePosition
	setMenu(true)
end)

if not checkDrawing() then
	espSwitches.tracers.set(false)
	local track = espSwitches.tracers.frame and espSwitches.tracers.frame:FindFirstChild("Track")
	local hit = track and track:FindFirstChild("Hit")
	if hit then
		hit.Visible = false
	end
end
