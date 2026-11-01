local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = workspace
local Camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")

local Player = Players.LocalPlayer

local sessionToken = {}
_G.AFZ_MENU_TOKEN = sessionToken
local function sessionAlive()
	return _G.AFZ_MENU_TOKEN == sessionToken
end

local Theme = {
	base = Color3.fromRGB(7, 7, 9),
	panel = Color3.fromRGB(13, 13, 16),
	surface = Color3.fromRGB(17, 17, 21),
	hover = Color3.fromRGB(23, 23, 28),
	stroke = Color3.fromRGB(34, 34, 40),
	text = Color3.fromRGB(240, 240, 244),
	muted = Color3.fromRGB(136, 136, 148),
	accent = Color3.fromRGB(214, 178, 112),
	live = Color3.fromRGB(118, 214, 160),
	danger = Color3.fromRGB(226, 92, 92),
	ally = Color3.fromRGB(126, 178, 234),
	loot = Color3.fromRGB(230, 176, 96),
	key = Color3.fromRGB(150, 220, 170),
}

local WINDOW_W = 640
local WINDOW_H = 436
local BODY_Y = 76
local LEFT_W = 372
local RIGHT_X = 386
local RIGHT_W = 214

local flags = {
	esp = false,
	players = true,
	opah = true,
	names = true,
	distance = true,
	tracers = false,
	breakables = false,
	keys = false,
	noclip = false,
}

local refresh
local checkDrawing
local restoreNoclip

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

local function animate(instance, time, goal, style, direction)
	local info = TweenInfo.new(time, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
	TweenService:Create(instance, info, goal):Play()
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

local shell = build("CanvasGroup", {
	Name = "Shell",
	Size = UDim2.fromOffset(WINDOW_W, WINDOW_H),
	BackgroundColor3 = Theme.base,
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	GroupTransparency = 1,
	Visible = false,
}, gui)
round(shell, 20)
outline(shell, Theme.stroke, 1, 0.15)

local shellScale = Instance.new("UIScale")
shellScale.Scale = 1
shellScale.Parent = shell

local topLine = build("Frame", {
	Size = UDim2.new(1, -40, 0, 1),
	Position = UDim2.fromOffset(20, 0),
	BackgroundColor3 = Theme.accent,
	BackgroundTransparency = 0.25,
	BorderSizePixel = 0,
}, shell)
local topFade = Instance.new("UIGradient")
topFade.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.5, 0.2),
	NumberSequenceKeypoint.new(1, 1),
})
topFade.Parent = topLine

local header = build("Frame", {
	Name = "Header",
	Size = UDim2.new(1, 0, 0, 64),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, shell)

local mark = build("Frame", {
	Size = UDim2.fromOffset(28, 28),
	Position = UDim2.fromOffset(20, 18),
	BackgroundColor3 = Theme.accent,
	BorderSizePixel = 0,
}, header)
round(mark, 9)
text(mark, {
	Size = UDim2.fromScale(1, 1),
	Text = "A",
	Font = Enum.Font.GothamBlack,
	TextSize = 16,
	TextColor3 = Theme.base,
	TextXAlignment = Enum.TextXAlignment.Center,
})

text(header, {
	Size = UDim2.fromOffset(220, 20),
	Position = UDim2.fromOffset(58, 16),
	Text = "Afriezzx",
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	TextColor3 = Theme.text,
})

text(header, {
	Size = UDim2.fromOffset(220, 14),
	Position = UDim2.fromOffset(58, 35),
	Text = "roblox menu",
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextColor3 = Theme.muted,
})

local statusPill = build("Frame", {
	Size = UDim2.fromOffset(70, 22),
	Position = UDim2.new(1, -142, 0, 21),
	BackgroundColor3 = Theme.surface,
	BorderSizePixel = 0,
}, header)
round(statusPill, 11)
outline(statusPill, Theme.stroke, 1, 0.35)

local statusDot = build("Frame", {
	Size = UDim2.fromOffset(6, 6),
	Position = UDim2.fromOffset(11, 8),
	BackgroundColor3 = Theme.muted,
	BorderSizePixel = 0,
}, statusPill)
round(statusDot, 3)

local statusText = text(statusPill, {
	Size = UDim2.fromOffset(44, 22),
	Position = UDim2.fromOffset(22, 0),
	Text = "off",
	Font = Enum.Font.GothamMedium,
	TextSize = 10,
	TextColor3 = Theme.muted,
})

local close = build("TextButton", {
	Size = UDim2.fromOffset(28, 28),
	Position = UDim2.new(1, -48, 0, 18),
	BackgroundColor3 = Theme.surface,
	Text = "×",
	Font = Enum.Font.GothamBold,
	TextSize = 17,
	TextColor3 = Theme.muted,
	AutoButtonColor = false,
	BorderSizePixel = 0,
}, header)
round(close, 9)

close.MouseEnter:Connect(function()
	animate(close, 0.14, { BackgroundColor3 = Theme.hover, TextColor3 = Theme.text })
end)
close.MouseLeave:Connect(function()
	animate(close, 0.14, { BackgroundColor3 = Theme.surface, TextColor3 = Theme.muted })
end)

local headerRule = build("Frame", {
	Size = UDim2.new(1, -40, 0, 1),
	Position = UDim2.fromOffset(20, 63),
	BackgroundColor3 = Theme.stroke,
	BackgroundTransparency = 0.35,
	BorderSizePixel = 0,
}, shell)

local body = build("Frame", {
	Name = "Body",
	Size = UDim2.new(1, -40, 1, -114),
	Position = UDim2.fromOffset(20, BODY_Y),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, shell)

local leftFeed = build("Frame", {
	Size = UDim2.new(0, LEFT_W, 1, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, body)

local rightFeed = build("Frame", {
	Size = UDim2.new(0, RIGHT_W, 1, 0),
	Position = UDim2.fromOffset(RIGHT_X, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, body)

local visualTitle = text(leftFeed, {
	Size = UDim2.fromOffset(120, 20),
	Position = UDim2.fromOffset(0, 0),
	Text = "Visual",
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextColor3 = Theme.text,
})

local markedLabel = text(leftFeed, {
	Size = UDim2.fromOffset(140, 20),
	Position = UDim2.new(1, -140, 0, 0),
	Text = "0 marked",
	Font = Enum.Font.Code,
	TextSize = 10,
	TextColor3 = Theme.muted,
	TextXAlignment = Enum.TextXAlignment.Right,
})

local visualRule = build("Frame", {
	Size = UDim2.new(1, 0, 0, 1),
	Position = UDim2.fromOffset(0, 22),
	BackgroundColor3 = Theme.stroke,
	BackgroundTransparency = 0.4,
	BorderSizePixel = 0,
}, leftFeed)

local switchOn = Theme.accent
local switchOff = Theme.surface

local function buildSwitch(parent, default, changed)
	local track = build("Frame", {
		Name = "Track",
		Size = UDim2.fromOffset(40, 22),
		BackgroundColor3 = switchOff,
		BorderSizePixel = 0,
	}, parent)
	round(track, 11)
	local edge = outline(track, Theme.stroke, 1, 0.3)
	local knob = build("Frame", {
		Name = "Knob",
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = Theme.muted,
		BorderSizePixel = 0,
	}, track)
	round(knob, 8)

	local state = default == true
	local function render(withTween)
		local goal = state and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)
		local knobColor = state and Theme.base or Theme.muted
		local trackColor = state and Theme.accent or switchOff
		local edgeColor = state and Theme.accent or Theme.stroke
		if withTween then
			animate(knob, 0.18, { Position = goal, BackgroundColor3 = knobColor })
			animate(track, 0.18, { BackgroundColor3 = trackColor })
			animate(edge, 0.18, { Color = edgeColor, Transparency = state and 0.6 or 0.3 })
		else
			knob.Position = goal
			knob.BackgroundColor3 = knobColor
			track.BackgroundColor3 = trackColor
			edge.Color = edgeColor
			edge.Transparency = state and 0.6 or 0.3
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
		track = track,
		knob = knob,
	}
end

local function buildRow(parent, y, height, title, subtitle, default, changed, big)
	local row = build("Frame", {
		Name = title,
		Size = UDim2.new(1, 0, 0, height),
		Position = UDim2.fromOffset(0, y),
		BackgroundColor3 = Theme.hover,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, parent)

	text(row, {
		Size = UDim2.new(1, -58, 0, big and 22 or 18),
		Position = UDim2.fromOffset(0, big and 10 or 7),
		Text = title,
		Font = big and Enum.Font.GothamBold or Enum.Font.GothamMedium,
		TextSize = big and 15 or 13,
		TextColor3 = Theme.text,
	})

	if subtitle then
		text(row, {
			Size = UDim2.new(1, -58, 0, 15),
			Position = UDim2.fromOffset(0, big and 32 or 24),
			Text = subtitle,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = Theme.muted,
		})
	end

	local divider = build("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = Theme.stroke,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
	}, row)

	local control = buildSwitch(row, default, changed)
	control.track.Position = UDim2.new(1, -40, 0.5, -11)

	row.MouseEnter:Connect(function()
		animate(row, 0.14, { BackgroundTransparency = 0.35 })
	end)
	row.MouseLeave:Connect(function()
		animate(row, 0.14, { BackgroundTransparency = 1 })
	end)

	return control
end

local function buildModule(y, height, title)
	local module = build("Frame", {
		Size = UDim2.new(1, 0, 0, height),
		Position = UDim2.fromOffset(0, y),
		BackgroundColor3 = Theme.panel,
		BorderSizePixel = 0,
	}, rightFeed)
	round(module, 13)
	outline(module, Theme.stroke, 1, 0.25)

	text(module, {
		Size = UDim2.new(1, -28, 0, 18),
		Position = UDim2.fromOffset(14, 11),
		Text = title,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		TextColor3 = Theme.muted,
	})

	local rule = build("Frame", {
		Size = UDim2.new(1, -28, 0, 1),
		Position = UDim2.fromOffset(14, 30),
		BackgroundColor3 = Theme.stroke,
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
	}, module)

	return module
end

local function moduleRow(module, y, height, title, subtitle, default, changed)
	local row = build("Frame", {
		Name = title,
		Size = UDim2.new(1, -28, 0, height),
		Position = UDim2.fromOffset(14, y),
		BackgroundColor3 = Theme.hover,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, module)

	text(row, {
		Size = UDim2.new(1, -50, 0, 16),
		Position = UDim2.fromOffset(0, subtitle and 4 or (height - 16) / 2),
		Text = title,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextColor3 = Theme.text,
	})

	if subtitle then
		text(row, {
			Size = UDim2.new(1, -50, 0, 13),
			Position = UDim2.fromOffset(0, 21),
			Text = subtitle,
			Font = Enum.Font.Gotham,
			TextSize = 10,
			TextColor3 = Theme.muted,
		})
	end

	local control = buildSwitch(row, default, changed)
	control.track.Position = UDim2.new(1, -40, 0.5, -11)

	row.MouseEnter:Connect(function()
		animate(row, 0.14, { BackgroundTransparency = 0.4 })
	end)
	row.MouseLeave:Connect(function()
		animate(row, 0.14, { BackgroundTransparency = 1 })
	end)

	return control
end

local espSwitches = {}

espSwitches.esp = buildRow(leftFeed, 28, 58, "ESP", "draw through walls", false, function(value)
	flags.esp = value
	if refresh then
		refresh()
	end
end, true)

espSwitches.players = buildRow(leftFeed, 86, 44, "Players", "highlight other players", true, function(value)
	flags.players = value
	if refresh then
		refresh()
	end
end)

espSwitches.opah = buildRow(leftFeed, 130, 44, "Opah", "mark the entity through walls", true, function(value)
	flags.opah = value
	if refresh then
		refresh()
	end
end)

espSwitches.names = buildRow(leftFeed, 174, 44, "Names", "label above each target", true, function(value)
	flags.names = value
	if refresh then
		refresh()
	end
end)

espSwitches.distance = buildRow(leftFeed, 218, 44, "Distance", "meters to target", true, function(value)
	flags.distance = value
	if refresh then
		refresh()
	end
end)

espSwitches.tracers = buildRow(leftFeed, 262, 44, "Tracers", "line from screen bottom", false, function(value)
	flags.tracers = value
	if value and not checkDrawing() then
		flags.tracers = false
		espSwitches.tracers.set(false)
	end
	if refresh then
		refresh()
	end
end)

local movementModule = buildModule(0, 100, "Movement")

espSwitches.noclip = moduleRow(movementModule, 34, 58, "Noclip", "collisions stay off", false, function(value)
	flags.noclip = value
	if not value then
		restoreNoclip()
	end
end)

local worldModule = buildModule(112, 112, "World")

espSwitches.breakables = moduleRow(worldModule, 34, 38, "Breakables", nil, false, function(value)
	flags.breakables = value
	if refresh then
		refresh()
	end
end)

espSwitches.keys = moduleRow(worldModule, 72, 38, "Puzzle keys", nil, false, function(value)
	flags.keys = value
	if refresh then
		refresh()
	end
end)

local sessionModule = buildModule(236, 86, "Session")

local fpsValue = text(sessionModule, {
	Size = UDim2.fromOffset(60, 18),
	Position = UDim2.fromOffset(14, 38),
	Text = "60",
	Font = Enum.Font.Code,
	TextSize = 11,
	TextColor3 = Theme.text,
})
text(sessionModule, {
	Size = UDim2.fromOffset(50, 18),
	Position = UDim2.fromOffset(14, 56),
	Text = "fps",
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextColor3 = Theme.muted,
})

local uptimeValue = text(sessionModule, {
	Size = UDim2.fromOffset(100, 18),
	Position = UDim2.new(1, -114, 0, 38),
	Text = "00:00",
	Font = Enum.Font.Code,
	TextSize = 11,
	TextColor3 = Theme.text,
	TextXAlignment = Enum.TextXAlignment.Right,
})
text(sessionModule, {
	Size = UDim2.fromOffset(100, 18),
	Position = UDim2.new(1, -114, 0, 56),
	Text = "session",
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextColor3 = Theme.muted,
	TextXAlignment = Enum.TextXAlignment.Right,
})

local footer = build("Frame", {
	Size = UDim2.new(1, 0, 0, 38),
	Position = UDim2.new(0, 0, 1, -38),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, shell)

local footerRule = build("Frame", {
	Size = UDim2.new(1, -40, 0, 1),
	Position = UDim2.fromOffset(20, 0),
	BackgroundColor3 = Theme.stroke,
	BackgroundTransparency = 0.4,
	BorderSizePixel = 0,
}, footer)

text(footer, {
	Size = UDim2.fromOffset(180, 38),
	Position = UDim2.fromOffset(20, 0),
	Text = "afriezzx",
	Font = Enum.Font.GothamMedium,
	TextSize = 10,
	TextColor3 = Theme.accent,
})

text(footer, {
	Size = UDim2.fromOffset(220, 38),
	Position = UDim2.new(1, -220, 0, 0),
	Text = "right shift · drag header",
	Font = Enum.Font.Code,
	TextSize = 9,
	TextColor3 = Theme.muted,
	TextXAlignment = Enum.TextXAlignment.Right,
})

local tracked = {}
local tracers = {}
local drawingReady = nil

function checkDrawing()
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

	tracked[inst] = {
		kind = kind,
		part = part,
		highlight = highlight,
		billboard = billboard,
		caption = caption,
		label = labelText,
	}
	return tracked[inst]
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

refresh = function()
	local marked = 0
	for inst, entry in pairs(tracked) do
		if not inst.Parent then
			dropEntry(inst, entry)
		else
			local visible = kindVisible(entry.kind)
			entry.highlight.Enabled = visible
			entry.billboard.Enabled = visible and (flags.names or flags.distance)
			if visible then
				marked = marked + 1
			end
		end
	end
	markedLabel.Text = marked .. " marked"
	statusDot.BackgroundColor3 = flags.esp and Theme.live or Theme.muted
	statusText.Text = flags.esp and "live" or "off"
	statusText.TextColor3 = flags.esp and Theme.live or Theme.muted
end

local function scanPlayers()
	local function attach(character, displayName)
		if not character then
			return
		end
		task.wait(0.15)
		makeEntry(character, "player", Theme.ally, displayName)
		refresh()
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
		refresh()
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
			refresh()
			task.wait(2)
		end
	end)
end

scanPlayers()
scanFolder("OpahBreakables", "breakable", Theme.loot, "")
scanFolder("PuzzleItems", "key", Theme.key, "")
scanOpah()

local noclipSaved = {}

function restoreNoclip()
	for part, value in pairs(noclipSaved) do
		if part.Parent then
			part.CanCollide = value
		end
	end
	table.clear(noclipSaved)
end

RunService.Stepped:Connect(function()
	if not sessionAlive() or not flags.noclip then
		return
	end
	local character = Player.Character
	if not character then
		return
	end
	for _, item in ipairs(character:GetDescendants()) do
		if item:IsA("BasePart") then
			if noclipSaved[item] == nil then
				noclipSaved[item] = item.CanCollide
			end
			if item.CanCollide then
				item.CanCollide = false
			end
		end
	end
end)

Player.CharacterAdded:Connect(function()
	restoreNoclip()
end)

local bubble = build("TextButton", {
	Name = "Bubble",
	Size = UDim2.fromOffset(48, 48),
	BackgroundColor3 = Theme.base,
	Text = "A",
	Font = Enum.Font.GothamBlack,
	TextSize = 18,
	TextColor3 = Theme.accent,
	AutoButtonColor = false,
	BorderSizePixel = 0,
	Visible = false,
}, gui)
round(bubble, 24)
local bubbleStroke = outline(bubble, Theme.stroke, 1, 0.05)

local menuOpen = false
local animationToken = 0

local function setMenu(open)
	menuOpen = open
	animationToken = animationToken + 1
	local token = animationToken
	if open then
		shell.Visible = true
		shell.GroupTransparency = 1
		shellScale.Scale = 0.95
		body.Position = UDim2.fromOffset(20, BODY_Y + 8)
		animate(shell, 0.22, { GroupTransparency = 0 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		animate(shellScale, 0.3, { Scale = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		animate(body, 0.3, { Position = UDim2.fromOffset(20, BODY_Y) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	else
		animate(shell, 0.17, { GroupTransparency = 1 }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		animate(shellScale, 0.17, { Scale = 0.97 }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		task.delay(0.18, function()
			if token == animationToken then
				shell.Visible = false
			end
		end)
	end
end

local function toggleMenu()
	setMenu(not menuOpen)
end

close.MouseButton1Click:Connect(function()
	setMenu(false)
end)

bubble.MouseEnter:Connect(function()
	animate(bubbleStroke, 0.16, { Color = Theme.accent, Transparency = 0.5 })
	animate(bubble, 0.16, { TextColor3 = Theme.text })
end)
bubble.MouseLeave:Connect(function()
	animate(bubbleStroke, 0.16, { Color = Theme.stroke, Transparency = 0.05 })
	animate(bubble, 0.16, { TextColor3 = Theme.accent })
end)

local function fitWindow()
	local viewport = Camera.ViewportSize
	if viewport.X < 32 or viewport.Y < 32 then
		return
	end
	local scale = math.min(1, (viewport.X - 24) / WINDOW_W, (viewport.Y - 24) / WINDOW_H)
	scale = math.max(scale, 0.55)
	shellScale.Scale = scale
	shell.Position = UDim2.fromOffset((viewport.X - WINDOW_W * scale) / 2, (viewport.Y - WINDOW_H * scale) / 2)
end

fitWindow()

local bubbleOffset
local bubbleOrigin
local bubbleTravel = 0

bubble.InputBegan:Connect(function(input)
	if not sessionAlive() then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		bubbleOffset = Vector2.new(input.Position.X, input.Position.Y) - Vector2.new(bubble.AbsolutePosition.X, bubble.AbsolutePosition.Y)
		bubbleOrigin = Vector2.new(input.Position.X, input.Position.Y)
		bubbleTravel = 0
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not sessionAlive() or not bubbleOffset then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local pointer = Vector2.new(input.Position.X, input.Position.Y)
	bubbleTravel = math.max(bubbleTravel, (pointer - bubbleOrigin).Magnitude)
	local viewport = Camera.ViewportSize
	local x = math.clamp(input.Position.X - bubbleOffset.X, 0, math.max(0, viewport.X - 48))
	local y = math.clamp(input.Position.Y - bubbleOffset.Y, 0, math.max(0, viewport.Y - 48))
	bubble.Position = UDim2.fromOffset(x, y)
end)

UserInputService.InputEnded:Connect(function(input)
	if not sessionAlive() or not bubbleOffset then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	bubbleOffset = nil
	if bubbleTravel < 6 then
		toggleMenu()
	end
end)

local dragging
local dragOffset

header.InputBegan:Connect(function(input)
	if not sessionAlive() then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragOffset = Vector2.new(input.Position.X, input.Position.Y) - Vector2.new(shell.AbsolutePosition.X, shell.AbsolutePosition.Y)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not sessionAlive() or not dragging then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local viewport = Camera.ViewportSize
	local scale = shellScale.Scale
	local x = math.clamp(input.Position.X - dragOffset.X, 0, math.max(0, viewport.X - WINDOW_W * scale))
	local y = math.clamp(input.Position.Y - dragOffset.Y, 0, math.max(0, viewport.Y - WINDOW_H * scale))
	shell.Position = UDim2.fromOffset(x, y)
end)

UserInputService.InputEnded:Connect(function(input)
	if not sessionAlive() or not dragging then
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

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	if not dragging then
		fitWindow()
	end
	if bubble.Visible then
		local viewport = Camera.ViewportSize
		local absolute = bubble.AbsolutePosition
		bubble.Position = UDim2.fromOffset(
			math.clamp(absolute.X, 0, math.max(0, viewport.X - 48)),
			math.clamp(absolute.Y, 0, math.max(0, viewport.Y - 48))
		)
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if not sessionAlive() or processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.RightShift then
		toggleMenu()
	end
end)

local startedAt = os.clock()
local fpsFrames = 0
local fpsClock = 0
local labelClock = 0

RunService.RenderStepped:Connect(function(delta)
	if not sessionAlive() then
		return
	end
	labelClock = labelClock + delta
	fpsClock = fpsClock + delta
	fpsFrames = fpsFrames + 1

	if fpsClock >= 0.5 then
		fpsValue.Text = tostring(math.floor(fpsFrames / fpsClock + 0.5))
		fpsFrames = 0
		fpsClock = 0
		local elapsed = math.floor(os.clock() - startedAt)
		uptimeValue.Text = string.format("%02d:%02d", math.floor(elapsed / 60), elapsed % 60)
	end

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
	restoreNoclip()
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

local intro = build("CanvasGroup", {
	Name = "Intro",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	GroupTransparency = 0,
}, gui)

local introStack = build("Frame", {
	Size = UDim2.fromOffset(340, 96),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, intro)

local introKicker = text(introStack, {
	Size = UDim2.new(1, 0, 0, 18),
	Position = UDim2.fromOffset(0, 2),
	Text = "Made by",
	Font = Enum.Font.Gotham,
	TextSize = 12,
	TextColor3 = Theme.muted,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextTransparency = 1,
})

local introName = text(introStack, {
	Size = UDim2.new(1, 0, 0, 42),
	Position = UDim2.fromOffset(0, 22),
	Text = "Afriezzx",
	Font = Enum.Font.GothamBlack,
	TextSize = 32,
	TextColor3 = Theme.text,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextTransparency = 1,
})

local introRule = build("Frame", {
	Size = UDim2.fromOffset(24, 1),
	Position = UDim2.fromOffset(158, 72),
	BackgroundColor3 = Theme.accent,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, introStack)

if not checkDrawing() then
	espSwitches.tracers.set(false)
	espSwitches.tracers.track:FindFirstChild("Hit").Visible = false
end

refresh()

task.spawn(function()
	animate(introKicker, 0.3, { TextTransparency = 0 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	task.wait(0.06)
	animate(introName, 0.36, { TextTransparency = 0 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	animate(introRule, 0.42, { BackgroundTransparency = 0.15, Size = UDim2.fromOffset(72, 1), Position = UDim2.fromOffset(134, 72) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	task.wait(1)
	animate(intro, 0.45, { GroupTransparency = 1 }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	task.wait(0.46)
	intro:Destroy()
	bubble.Visible = true
	bubble.Position = UDim2.new(1, -72, 0.5, -24)
	setMenu(true)
end)
