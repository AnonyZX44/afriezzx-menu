local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

local Palette = {
	ink = Color3.fromRGB(9, 9, 11),
	base = Color3.fromRGB(13, 13, 16),
	surface = Color3.fromRGB(19, 19, 23),
	raise = Color3.fromRGB(25, 25, 30),
	line = Color3.fromRGB(38, 38, 45),
	paper = Color3.fromRGB(236, 233, 226),
	dim = Color3.fromRGB(124, 124, 134),
	brass = Color3.fromRGB(201, 169, 107),
	brassSoft = Color3.fromRGB(148, 124, 78),
	good = Color3.fromRGB(111, 199, 151),
	bad = Color3.fromRGB(214, 104, 104),
	teamRed = Color3.fromRGB(214, 92, 92),
	teamBlue = Color3.fromRGB(92, 142, 214),
}

local Width, Height = 500, 394

local function grab(name)
	local ok, value = pcall(function()
		return _G[name]
	end)
	if ok and value ~= nil then
		return value
	end
	return nil
end

local function resolveParent()
	local getHui = grab("gethui")
	if type(getHui) == "function" then
		local ok, result = pcall(getHui)
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

local function make(class, props, parent)
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
	line.Color = color or Palette.line
	line.Thickness = thickness or 1
	line.Transparency = transparency or 0
	line.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	line.Parent = parent
	return line
end

local function text(parent, props)
	local object = Instance.new("TextLabel")
	object.BackgroundTransparency = 1
	object.BorderSizePixel = 0
	object.Font = Enum.Font.GothamMedium
	object.TextColor3 = Palette.paper
	object.TextSize = 12
	object.TextXAlignment = Enum.TextXAlignment.Left
	object.TextYAlignment = Enum.TextYAlignment.Center
	for key, value in pairs(props) do
		object[key] = value
	end
	object.Parent = parent
	return object
end

local function tween(instance, duration, goal, style, direction)
	local info = TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
	local animation = TweenService:Create(instance, info, goal)
	animation:Play()
	return animation
end

local guiParent = resolveParent()
local stale = guiParent:FindFirstChild("AfriezzxKit")
if stale then
	pcall(function()
		stale:Destroy()
	end)
end

local gui = make("ScreenGui", {
	Name = "AfriezzxKit",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 1000,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, guiParent)

local veil = make("CanvasGroup", {
	Name = "IntroVeil",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Palette.ink,
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	GroupTransparency = 1,
}, gui)

local word = make("CanvasGroup", {
	Name = "IntroWord",
	Size = UDim2.fromOffset(360, 70),
	Position = UDim2.new(0.5, -180, 0.5, -52),
	BackgroundTransparency = 1,
	GroupTransparency = 0,
}, gui)

local letters = {}
local name = "Afriezzx"
math.randomseed(os.time())
for index = 1, #name do
	local glyph = string.sub(name, index, index)
	local side = math.random(1, 4)
	local jitter = math.random(-14, 14)
	local restX = 28 + (index - 1) * 38
	local startX = restX
	local startY = 8
	if side == 1 then
		startY = -110
	elseif side == 2 then
		startY = 120
	elseif side == 3 then
		startX = restX - 170
	else
		startX = restX + 170
	end
	local cell = text(word, {
		Name = "Glyph" .. index,
		Text = glyph,
		Font = Enum.Font.GothamBold,
		TextSize = 34,
		TextColor3 = Palette.paper,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromOffset(38, 44),
		Position = UDim2.fromOffset(startX + jitter, startY),
		TextTransparency = 1,
		Rotation = math.random(-24, 24),
	})
	table.insert(letters, { cell = cell, restX = restX, restY = 8 })
end

local rule = make("Frame", {
	Name = "IntroRule",
	Size = UDim2.fromOffset(0, 1),
	Position = UDim2.new(0.5, 0, 1, -6),
	AnchorPoint = Vector2.new(0.5, 1),
	BackgroundColor3 = Palette.brass,
	BorderSizePixel = 0,
}, word)
round(rule, 1)

local introTag = text(gui, {
	Name = "IntroTag",
	Text = "sword kit",
	Font = Enum.Font.GothamMedium,
	TextSize = 10,
	TextColor3 = Palette.dim,
	TextXAlignment = Enum.TextXAlignment.Center,
	Size = UDim2.fromOffset(200, 16),
	Position = UDim2.new(0.5, -100, 0.5, 24),
	TextTransparency = 1,
})

local shell = make("CanvasGroup", {
	Name = "Shell",
	Size = UDim2.fromOffset(Width, Height),
	Position = UDim2.new(0.5, -Width / 2, 0.5, -Height / 2),
	BackgroundColor3 = Palette.base,
	BorderSizePixel = 0,
	GroupTransparency = 1,
	Visible = false,
}, gui)
round(shell, 12)
outline(shell, Palette.line, 1, 0.25)

local shade = Instance.new("UIGradient")
shade.Rotation = 90
shade.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(17, 17, 22)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 13)),
})
shade.Parent = shell

local shellScale = Instance.new("UIScale")
shellScale.Scale = 0.96
shellScale.Parent = shell

local header = make("Frame", {
	Name = "Header",
	Size = UDim2.new(1, 0, 0, 46),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Active = true,
}, shell)

local mark = make("Frame", {
	Name = "Mark",
	Size = UDim2.fromOffset(22, 22),
	Position = UDim2.fromOffset(14, 12),
	BackgroundColor3 = Palette.surface,
	BorderSizePixel = 0,
}, header)
round(mark, 7)
outline(mark, Palette.brassSoft, 1, 0.35)
text(mark, {
	Name = "Letter",
	Text = "A",
	Font = Enum.Font.GothamBold,
	TextSize = 12,
	TextColor3 = Palette.brass,
	TextXAlignment = Enum.TextXAlignment.Center,
	Size = UDim2.fromScale(1, 1),
})

text(header, {
	Name = "Title",
	Text = "Afriezzx",
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	Position = UDim2.fromOffset(44, 10),
	Size = UDim2.fromOffset(180, 16),
})

text(header, {
	Name = "Subtitle",
	Text = "sword kit",
	TextSize = 10,
	TextColor3 = Palette.dim,
	Position = UDim2.fromOffset(44, 27),
	Size = UDim2.fromOffset(180, 12),
})

local statusDot = make("Frame", {
	Name = "StatusDot",
	Size = UDim2.fromOffset(5, 5),
	Position = UDim2.new(1, -92, 0, 20),
	BackgroundColor3 = Palette.good,
	BorderSizePixel = 0,
}, header)
round(statusDot, 3)

local statusLabel = text(header, {
	Name = "Status",
	Text = "ready",
	Font = Enum.Font.GothamMedium,
	TextSize = 9,
	TextColor3 = Palette.dim,
	TextXAlignment = Enum.TextXAlignment.Right,
	Position = UDim2.new(1, -80, 0, 14),
	Size = UDim2.fromOffset(34, 14),
})

local closeButton = make("TextButton", {
	Name = "Close",
	Text = "×",
	Font = Enum.Font.GothamMedium,
	TextSize = 16,
	TextColor3 = Palette.dim,
	BackgroundColor3 = Palette.surface,
	AutoButtonColor = false,
	Size = UDim2.fromOffset(24, 24),
	Position = UDim2.new(1, -38, 0, 11),
}, header)
round(closeButton, 7)

local tabs = make("Frame", {
	Name = "Tabs",
	Size = UDim2.new(1, 0, 0, 34),
	Position = UDim2.fromOffset(0, 46),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, shell)

local headerRule = make("Frame", {
	Name = "HeaderRule",
	Size = UDim2.new(1, -28, 0, 1),
	Position = UDim2.fromOffset(14, 46),
	BackgroundColor3 = Palette.line,
	BackgroundTransparency = 0.7,
	BorderSizePixel = 0,
}, shell)
headerRule.ZIndex = 1

local tabNames = { "Dash", "Combat", "Ability", "Loot", "Visual", "Misc" }
local tabButtons = {}
local pages = {}
local indicator = make("Frame", {
	Name = "Indicator",
	Size = UDim2.new(1 / #tabNames, -18, 0, 2),
	Position = UDim2.new(0, 9, 1, -1),
	BackgroundColor3 = Palette.brass,
	BorderSizePixel = 0,
}, tabs)
round(indicator, 1)

local content = make("Frame", {
	Name = "Content",
	Size = UDim2.new(1, 0, 0, 208),
	Position = UDim2.fromOffset(0, 80),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ClipsDescendants = true,
}, shell)

local logPanel = make("Frame", {
	Name = "LogPanel",
	Size = UDim2.new(1, -16, 0, 92),
	Position = UDim2.new(0, 8, 1, -100),
	BackgroundColor3 = Palette.ink,
	BorderSizePixel = 0,
}, shell)
round(logPanel, 10)
outline(logPanel, Palette.line, 1, 0.55)

text(logPanel, {
	Name = "LogLabel",
	Text = "log",
	Font = Enum.Font.GothamMedium,
	TextSize = 9,
	TextColor3 = Palette.dim,
	Position = UDim2.fromOffset(12, 6),
	Size = UDim2.fromOffset(80, 10),
})

local logScroll = make("ScrollingFrame", {
	Name = "LogScroll",
	Size = UDim2.new(1, -24, 1, -26),
	Position = UDim2.fromOffset(12, 18),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	ScrollBarThickness = 2,
	ScrollBarImageColor3 = Palette.line,
	ScrollBarImageTransparency = 0.2,
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, logPanel)

local logLayout = Instance.new("UIListLayout")
logLayout.Padding = UDim.new(0, 3)
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Parent = logScroll

local logCount = 0

local clearLog = make("TextButton", {
	Name = "ClearLog",
	Text = "clear",
	Font = Enum.Font.GothamMedium,
	TextSize = 8,
	TextColor3 = Palette.dim,
	BackgroundTransparency = 1,
	AutoButtonColor = false,
	Size = UDim2.fromOffset(30, 14),
	Position = UDim2.new(1, -42, 0, 4),
	TextXAlignment = Enum.TextXAlignment.Right,
}, logPanel)

clearLog.MouseButton1Click:Connect(function()
	for _, child in ipairs(logScroll:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
	logCount = 0
end)

local function stamp()
	return os.date("%H:%M")
end

local function log(message, tone)
	logCount = logCount + 1
	if logCount > 90 then
		local first = logScroll:FindFirstChild("Line" .. (logCount - 90))
		if first then
			first:Destroy()
		end
	end
	local color = Palette.dim
	if tone == "ok" then
		color = Palette.good
	elseif tone == "bad" then
		color = Palette.bad
	elseif tone == "act" then
		color = Palette.paper
	end
	local line = make("TextLabel", {
		Name = "Line" .. logCount,
		LayoutOrder = logCount,
		Text = stamp() .. "  " .. message,
		Font = Enum.Font.Code,
		TextSize = 10,
		TextColor3 = color,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Size = UDim2.new(1, -4, 0, 12),
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, logScroll)
	task.defer(function()
		logScroll.CanvasPosition = Vector2.new(0, 1e6)
	end)
end

local Remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:WaitForChild("Remotes", 10)
if not Remotes then
	statusLabel.Text = "offline"
	statusDot.BackgroundColor3 = Palette.bad
	log("folder Remotes tidak ada", "bad")
end

local function findRemote(remoteName)
	local ok, found = pcall(function()
		return Remotes:FindFirstChild(remoteName)
	end)
	if ok then
		return found
	end
	return nil
end

local function findDashEvent()
	local character = Player.Character
	if character then
		local weapon = character:FindFirstChild("Frostbite")
		if weapon then
			local event = weapon:FindFirstChild("DashEvent")
			if event then
				return event
			end
		end
	end
	return findRemote("DashEvent")
end

local warned = {}

local function safeCall(remote, method, ...)
	if not remote then
		local key = tostring(method)
		if not warned[key] then
			warned[key] = true
			log("remote hilang: " .. method, "bad")
		end
		return false
	end
	local ok, result = pcall(function(...)
		return remote[method](remote, ...)
	end, ...)
	if not ok then
		log("gagal " .. method .. ": " .. tostring(result), "bad")
		return false
	end
	return true, result
end

local function summarize(value)
	if type(value) ~= "table" then
		return tostring(value)
	end
	if type(value[1]) == "table" and type(value[1][1]) == "table" and value[1][1].name == nil then
		value = value[1]
	end
	local count = 0
	local rarities = {}
	for _, entry in pairs(value) do
		count = count + 1
		if type(entry) == "table" and entry.rarity then
			rarities[entry.rarity] = (rarities[entry.rarity] or 0) + 1
		end
	end
	local parts = {}
	for rarity, amount in pairs(rarities) do
		table.insert(parts, rarity .. " " .. amount)
	end
	table.sort(parts)
	return count .. " entri " .. table.concat(parts, ", ")
end

local loops = {}

local function startLoop(key, interval, body)
	local token = {}
	loops[key] = token
	task.spawn(function()
		while loops[key] == token do
			body()
			task.wait(interval)
		end
	end)
end

local function stopLoop(key)
	loops[key] = nil
end

local dashSequence = 0

local function serverTime()
	local ok, value = pcall(function()
		return Workspace:GetServerTimeNow()
	end)
	if ok and value then
		return value
	end
	return os.clock()
end

local function cameraDirection()
	local camera = Workspace.CurrentCamera
	if camera then
		local ok, look = pcall(function()
			return camera.CFrame.LookVector
		end)
		if ok and look then
			return look
		end
	end
	return Vector3.new(0, 0, -1)
end

local function fireDash(direction, power, charged)
	dashSequence = dashSequence + 1
	local payload = { power or 1, charged and true or false, direction, serverTime(), dashSequence }
	safeCall(findRemote("DashFast"), "FireServer", table.unpack(payload))
	local reliable = findDashEvent()
	if reliable then
		pcall(function()
			reliable:FireServer(table.unpack(payload))
		end)
	end
end

local function row(parent, order, labelText, inset)
	local frame = make("Frame", {
		Name = "Row" .. order,
		LayoutOrder = order,
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = Palette.base,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, parent)
	text(frame, {
		Name = "Label",
		Text = labelText,
		TextSize = 11,
		TextColor3 = Palette.paper,
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -(inset or 150), 1, 0),
	})
	local hair = make("Frame", {
		Name = "Hair",
		Size = UDim2.new(1, -28, 0, 1),
		Position = UDim2.new(0, 14, 1, -1),
		BackgroundColor3 = Palette.line,
		BackgroundTransparency = 0.72,
		BorderSizePixel = 0,
	}, frame)
	hair.ZIndex = 1
	frame.MouseEnter:Connect(function()
		tween(frame, 0.15, { BackgroundColor3 = Palette.raise, BackgroundTransparency = 0.94 })
	end)
	frame.MouseLeave:Connect(function()
		tween(frame, 0.15, { BackgroundTransparency = 1 })
	end)
	return frame
end

local function button(parent, caption, width, callback)
	local control = make("TextButton", {
		Name = "Action",
		Text = caption,
		Font = Enum.Font.GothamMedium,
		TextSize = 10,
		TextColor3 = Palette.paper,
		BackgroundColor3 = Palette.surface,
		AutoButtonColor = false,
		Size = UDim2.fromOffset(width, 22),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
	}, parent)
	round(control, 6)
	outline(control, Palette.line, 1, 0.2)
	local scale = Instance.new("UIScale")
	scale.Scale = 1
	scale.Parent = control
	control.MouseEnter:Connect(function()
		tween(control, 0.15, { BackgroundColor3 = Palette.raise })
	end)
	control.MouseLeave:Connect(function()
		tween(control, 0.15, { BackgroundColor3 = Palette.surface })
	end)
	control.MouseButton1Down:Connect(function()
		tween(scale, 0.09, { Scale = 0.95 })
	end)
	control.MouseButton1Up:Connect(function()
		tween(scale, 0.14, { Scale = 1 }, Enum.EasingStyle.Back)
	end)
	control.MouseButton1Click:Connect(function()
		callback()
	end)
	return control
end

local function toggle(parent, initial, callback)
	local track = make("TextButton", {
		Name = "Toggle",
		Text = "",
		BackgroundColor3 = Palette.surface,
		AutoButtonColor = false,
		Size = UDim2.fromOffset(36, 20),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
	}, parent)
	round(track, 10)
	outline(track, Palette.line, 1, 0.15)
	local knob = make("Frame", {
		Name = "Knob",
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = Palette.dim,
		BorderSizePixel = 0,
	}, track)
	round(knob, 7)
	local state = initial and true or false
	local function paint(animated)
		local goalPosition = state and UDim2.fromOffset(19, 3) or UDim2.fromOffset(3, 3)
		local goalTrack = state and Palette.brassSoft or Palette.surface
		local goalKnob = state and Palette.brass or Palette.dim
		if animated then
			tween(knob, 0.18, { Position = goalPosition })
			tween(track, 0.18, { BackgroundColor3 = goalTrack })
			tween(knob, 0.18, { BackgroundColor3 = goalKnob })
		else
			knob.Position = goalPosition
			track.BackgroundColor3 = goalTrack
			knob.BackgroundColor3 = goalKnob
		end
	end
	paint(false)
	track.MouseButton1Click:Connect(function()
		state = not state
		paint(true)
		callback(state)
	end)
	return track
end

local function field(parent, placeholder, initial, width)
	local box = make("TextBox", {
		Name = "Field",
		Text = initial or "",
		PlaceholderText = placeholder,
		PlaceholderColor3 = Palette.dim,
		Font = Enum.Font.GothamMedium,
		TextSize = 10,
		TextColor3 = Palette.paper,
		BackgroundColor3 = Palette.ink,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.fromOffset(width, 22),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
	}, parent)
	round(box, 6)
	local boxStroke = outline(box, Palette.line, 1, 0.35)
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.Parent = box
	box.Focused:Connect(function()
		tween(boxStroke, 0.15, { Color = Palette.brassSoft, Transparency = 0.1 })
	end)
	box.FocusLost:Connect(function()
		tween(boxStroke, 0.15, { Color = Palette.line, Transparency = 0.35 })
	end)
	return box
end

local function slider(parent, minimum, maximum, initial, width, onChange)
	local hit = make("TextButton", {
		Name = "Slider",
		Text = "",
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Size = UDim2.fromOffset(width, 22),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
	}, parent)
	local rail = make("Frame", {
		Name = "Rail",
		Size = UDim2.new(1, 0, 0, 6),
		Position = UDim2.new(0, 0, 0.5, -3),
		BackgroundColor3 = Palette.surface,
		BorderSizePixel = 0,
	}, hit)
	round(rail, 3)
	outline(rail, Palette.line, 1, 0.4)
	local fill = make("Frame", {
		Name = "Fill",
		Size = UDim2.new(0, 0, 0, 6),
		BackgroundColor3 = Palette.brassSoft,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, rail)
	round(fill, 3)
	local knob = make("Frame", {
		Name = "Knob",
		Size = UDim2.fromOffset(12, 12),
		Position = UDim2.new(0, -6, 0.5, 0),
		BackgroundColor3 = Palette.brass,
		BorderSizePixel = 0,
		ZIndex = 3,
	}, hit)
	round(knob, 6)
	outline(knob, Palette.ink, 1, 0.35)
	local readout = text(parent, {
		Name = "Readout",
		Text = string.format("%.1f", initial),
		Font = Enum.Font.GothamMedium,
		TextSize = 10,
		TextColor3 = Palette.paper,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.fromOffset(30, 22),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -128, 0.5, 0),
	})
	local value = initial
	local dragging = false
	local function clamp(input)
		if input < minimum then
			return minimum
		end
		if input > maximum then
			return maximum
		end
		return input
	end
	local function paint(nextValue, silent)
		value = clamp(nextValue)
		local percent = (value - minimum) / (maximum - minimum)
		fill.Size = UDim2.new(percent, 0, 0, 6)
		knob.Position = UDim2.new(percent, -6, 0.5, 0)
		readout.Text = string.format("%.1f", value)
		onChange(value, silent)
	end
	local function fromPointer(pointerX)
		local widthPixels = hit.AbsoluteSize.X
		if widthPixels <= 0 then
			return
		end
		local relative = (pointerX - hit.AbsolutePosition.X) / widthPixels
		paint(minimum + relative * (maximum - minimum), true)
	end
	hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			fromPointer(input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			fromPointer(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			onChange(value, false)
		end
	end)
	paint(initial, true)
	return hit, readout
end

local function page(order, tabName)
	local canvas = make("CanvasGroup", {
		Name = tabName,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Visible = false,
	}, content)
	local scroll = make("ScrollingFrame", {
		Name = tabName .. "Scroll",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Palette.line,
		ScrollBarImageTransparency = 0.3,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, canvas)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingBottom = UDim.new(0, 10)
	padding.Parent = scroll
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll
	return canvas, scroll
end

local dashPage, dashScroll = page(1, "Dash")
local combatPage, combatScroll = page(2, "Combat")
local abilityPage, abilityScroll = page(3, "Ability")
local lootPage, lootScroll = page(4, "Loot")
local visualPage, visualScroll = page(5, "Visual")
local miscPage, miscScroll = page(6, "Misc")

pages[1] = dashPage
pages[2] = combatPage
pages[3] = abilityPage
pages[4] = lootPage
pages[5] = visualPage
pages[6] = miscPage

local activePage = 1

local function selectTab(index)
	if activePage == index then
		return
	end
	local previous = pages[activePage]
	local current = pages[index]
	activePage = index
	if previous then
		previous.Visible = false
	end
	current.Visible = true
	current.Position = UDim2.fromOffset(0, 6)
	current.GroupTransparency = 1
	tween(current, 0.22, { Position = UDim2.fromOffset(0, 0), GroupTransparency = 0 })
	tween(indicator, 0.26, {
		Position = UDim2.new((index - 1) / #tabNames, 9, 1, -1),
	})
	for position, tab in ipairs(tabButtons) do
		tween(tab, 0.2, { TextColor3 = position == index and Palette.paper or Palette.dim })
	end
end

for index, tabName in ipairs(tabNames) do
	local tab = make("TextButton", {
		Name = tabName,
		Text = tabName,
		Font = Enum.Font.GothamMedium,
		TextSize = 10,
		TextColor3 = Palette.dim,
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Size = UDim2.new(1 / #tabNames, 0, 1, 0),
		Position = UDim2.new((index - 1) / #tabNames, 0, 0, 0),
	}, tabs)
	tab.MouseButton1Click:Connect(function()
		selectTab(index)
	end)
	tab.MouseEnter:Connect(function()
		if activePage ~= index then
			tween(tab, 0.15, { TextColor3 = Palette.paper })
		end
	end)
	tab.MouseLeave:Connect(function()
		if activePage ~= index then
			tween(tab, 0.15, { TextColor3 = Palette.dim })
		end
	end)
	table.insert(tabButtons, tab)
end

tabButtons[1].TextColor3 = Palette.paper

local dashPower = 1
local dashInterval = 0.18

row(dashScroll, 1, "dash boost")
toggle(dashScroll.Row1, false, function(state)
	if state then
		log("dash boost aktif", "act")
		startLoop("boost", dashInterval, function()
			fireDash(cameraDirection(), dashPower, true)
		end)
	else
		stopLoop("boost")
		log("dash boost mati")
	end
end)

row(dashScroll, 2, "dash up")
toggle(dashScroll.Row2, false, function(state)
	if state then
		log("dash up aktif", "act")
		startLoop("up", dashInterval, function()
			fireDash(Vector3.new(0, 1, 0), dashPower, true)
		end)
	else
		stopLoop("up")
		log("dash up mati")
	end
end)

row(dashScroll, 3, "power", 190)
slider(dashScroll.Row3, 0.5, 3, 1, 110, function(value, silent)
	dashPower = value
	if not silent then
		log("power " .. string.format("%.1f", value))
	end
end)

row(dashScroll, 4, "interval")
local intervalBox = field(dashScroll.Row4, "0.18", "0.18", 70)
intervalBox.FocusLost:Connect(function()
	local value = tonumber(intervalBox.Text)
	if value and value >= 0.05 and value <= 5 then
		dashInterval = value
		log("interval " .. tostring(value))
	else
		intervalBox.Text = tostring(dashInterval)
		log("interval harus 0.05 sampai 5", "bad")
	end
end)

row(dashScroll, 5, "dash sekali")
button(dashScroll.Row5, "fire", 62, function()
	fireDash(cameraDirection(), dashPower, true)
	log("dash dikirim", "ok")
end)

row(dashScroll, 6, "arah ke atas")
button(dashScroll.Row6, "fire", 62, function()
	fireDash(Vector3.new(0, 1, 0), dashPower, true)
	log("dash vertikal dikirim", "ok")
end)

row(combatScroll, 1, "charge penuh")
button(combatScroll.Row1, "kirim", 62, function()
	safeCall(findRemote("ChargeStateEvent"), "FireServer", true, 99)
	log("charge 99 dikirim", "act")
	task.delay(0.3, function()
		safeCall(findRemote("ChargeStateEvent"), "FireServer", false)
	end)
end)

row(combatScroll, 2, "auto charge")
toggle(combatScroll.Row2, false, function(state)
	if state then
		log("auto charge aktif", "act")
		startLoop("charge", 0.25, function()
			safeCall(findRemote("ChargeStateEvent"), "FireServer", true, 99)
		end)
	else
		stopLoop("charge")
		log("auto charge mati")
	end
end)

row(combatScroll, 3, "blok")
button(combatScroll.Row3, "kirim", 62, function()
	safeCall(findRemote("BlockEvent"), "FireServer")
	log("blok dikirim", "act")
end)

row(combatScroll, 4, "lompat")
button(combatScroll.Row4, "kirim", 62, function()
	safeCall(findRemote("JumpEvent"), "FireServer")
	log("lompat dikirim", "act")
end)

row(combatScroll, 5, "charge 0.7")
button(combatScroll.Row5, "kirim", 62, function()
	safeCall(findRemote("ChargeStateEvent"), "FireServer", true, 0.72)
	log("charge 0.72 dikirim", "act")
end)

row(combatScroll, 6, "reset charge")
button(combatScroll.Row6, "kirim", 62, function()
	safeCall(findRemote("ChargeStateEvent"), "FireServer", false)
	log("charge dilepas", "act")
end)

row(abilityScroll, 1, "special")
button(abilityScroll.Row1, "pakai", 62, function()
	safeCall(findRemote("UseAbility"), "FireServer", "SpecialAbility")
	log("special dikirim", "act")
end)

row(abilityScroll, 2, "special spam")
toggle(abilityScroll.Row2, false, function(state)
	if state then
		log("special spam aktif", "act")
		startLoop("special", 0.3, function()
			safeCall(findRemote("UseAbility"), "FireServer", "SpecialAbility")
		end)
	else
		stopLoop("special")
		log("special spam mati")
	end
end)

row(abilityScroll, 3, "daftar ability")
button(abilityScroll.Row3, "minta", 62, function()
	safeCall(findRemote("MatchAbilitySwap"), "FireServer", "List")
	log("minta daftar ability", "act")
end)

row(abilityScroll, 4, "nama ability")
local abilityBox = field(abilityScroll.Row4, "Invisible", "Invisible", 96)

row(abilityScroll, 5, "tukar ability")
button(abilityScroll.Row5, "tukar", 62, function()
	local abilityName = abilityBox.Text
	if abilityName == "" then
		log("nama ability kosong", "bad")
		return
	end
	safeCall(findRemote("MatchAbilitySwap"), "FireServer", "Swap", abilityName)
	log("tukar ke " .. abilityName, "act")
end)

row(abilityScroll, 6, "pakai nama")
button(abilityScroll.Row6, "pakai", 62, function()
	local abilityName = abilityBox.Text
	if abilityName == "" then
		log("nama ability kosong", "bad")
		return
	end
	safeCall(findRemote("UseAbility"), "FireServer", abilityName)
	log("pakai " .. abilityName, "act")
end)

local swapRemote = findRemote("MatchAbilitySwap")
if swapRemote then
	swapRemote.OnClientEvent:Connect(function(kind, list, current)
		if kind == "List" and type(list) == "table" then
			local parts = {}
			for _, entry in ipairs(list) do
				table.insert(parts, tostring(entry))
			end
			if #parts > 0 then
				log("ability: " .. table.concat(parts, ", ") .. " | aktif " .. tostring(current), "ok")
			end
		end
	end)
end

local crateName = "GoldExplosion"
local crateCount = 1

row(lootScroll, 1, "nama crate")
local crateBox = field(lootScroll.Row1, "GoldExplosion", crateName, 110)
crateBox.FocusLost:Connect(function()
	if crateBox.Text ~= "" then
		crateName = crateBox.Text
		log("crate " .. crateName)
	end
end)

row(lootScroll, 2, "jumlah")
local countBox = field(lootScroll.Row2, "1", "1", 60)
countBox.FocusLost:Connect(function()
	local value = tonumber(countBox.Text)
	if value and value >= 1 and value <= 999 then
		crateCount = math.floor(value)
		log("jumlah " .. tostring(crateCount))
	else
		countBox.Text = tostring(crateCount)
		log("jumlah harus 1 sampai 999", "bad")
	end
end)

row(lootScroll, 3, "buka crate")
button(lootScroll.Row3, "buka", 62, function()
	safeCall(findRemote("CrateStashRequest"), "FireServer", "OpenRun", crateName, crateCount, 1)
	log("buka " .. crateName .. " x" .. tostring(crateCount), "act")
end)

row(lootScroll, 4, "pool standard")
button(lootScroll.Row4, "baca", 62, function()
	local ok, result = safeCall(findRemote("CrateContents"), "InvokeServer", "Standard")
	if ok then
		log("standard: " .. summarize(result), "ok")
	end
end)

row(lootScroll, 5, "pool gold")
button(lootScroll.Row5, "baca", 62, function()
	local ok, result = safeCall(findRemote("ExplosionCrateContents"), "InvokeServer", "Gold")
	if ok then
		log("gold: " .. summarize(result), "ok")
	end
end)

row(lootScroll, 6, "buka x5")
button(lootScroll.Row6, "buka", 62, function()
	safeCall(findRemote("CrateStashRequest"), "FireServer", "OpenRun", crateName, 5, 1)
	log("buka " .. crateName .. " x5", "act")
end)

local espHighlights = {}
local aimBeams = {}
local aimConnection = nil
local teamIds = { red = {}, blue = {} }
local espEnabled = false
local aimEnabled = false

local function clearEsp()
	for _, highlight in pairs(espHighlights) do
		pcall(function()
			highlight:Destroy()
		end)
	end
	espHighlights = {}
end

local function teamOf(userId)
	local tag = tostring(userId)
	for _, id in ipairs(teamIds.red) do
		if tostring(id) == tag then
			return "red"
		end
	end
	for _, id in ipairs(teamIds.blue) do
		if tostring(id) == tag then
			return "blue"
		end
	end
	return nil
end

local watched = {}
local watchCharacter
local paintEsp
local paintAim

watchCharacter = function(other)
	if watched[other] then
		return
	end
	watched[other] = true
	other.CharacterAdded:Connect(function()
		if espEnabled or aimEnabled then
			task.defer(function()
				if espEnabled then
					paintEsp()
				end
				if aimEnabled then
					paintAim()
				end
			end)
		end
	end)
end

paintEsp = function()
	if not espEnabled then
		return
	end
	clearEsp()
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= Player and other.Character then
			watchCharacter(other)
			local side = teamOf(other.UserId)
			local highlight = make("Highlight", {
				Name = "AfzEsp",
				FillColor = side == "red" and Palette.teamRed or side == "blue" and Palette.teamBlue or Palette.brass,
				OutlineColor = Palette.paper,
				FillTransparency = 0.72,
				OutlineTransparency = 0.25,
				DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
			}, other.Character)
			table.insert(espHighlights, highlight)
		end
	end
	log("esp " .. tostring(#espHighlights) .. " target", "ok")
end

local function clearAim()
	for _, entry in pairs(aimBeams) do
		pcall(function()
			if entry.base then
				entry.base:Destroy()
			end
			if entry.attachment then
				entry.attachment:Destroy()
			end
			entry.beam:Destroy()
		end)
	end
	aimBeams = {}
	if aimConnection then
		aimConnection:Disconnect()
		aimConnection = nil
	end
end

paintAim = function()
	clearAim()
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= Player and other.Character then
			local head = other.Character:FindFirstChild("Head")
			if head then
				local base = Instance.new("Attachment")
				base.Parent = head
				local tip = Instance.new("Attachment")
				tip.Parent = head
				local beam = Instance.new("Beam")
				beam.Attachment0 = base
				beam.Attachment1 = tip
				beam.FaceCamera = true
				beam.Width0 = 0.04
				beam.Width1 = 0.04
				beam.Color = ColorSequence.new(Palette.brass)
				beam.Transparency = NumberSequence.new(0.15)
				beam.Parent = head
				table.insert(aimBeams, { beam = beam, base = base, attachment = tip, head = head })
			end
		end
	end
	aimConnection = RunService.RenderStepped:Connect(function()
		for _, entry in pairs(aimBeams) do
			local ok, look = pcall(function()
				return entry.head.CFrame.LookVector
			end)
			if ok and look then
				entry.attachment.Position = look * 7
			end
		end
	end)
	log("aim line " .. tostring(#aimBeams) .. " target", "ok")
end

row(visualScroll, 1, "esp")
toggle(visualScroll.Row1, false, function(state)
	espEnabled = state
	if state then
		paintEsp()
	else
		clearEsp()
		log("esp mati")
	end
end)

row(visualScroll, 2, "aim line")
toggle(visualScroll.Row2, false, function(state)
	aimEnabled = state
	if state then
		paintAim()
	else
		clearAim()
		log("aim line mati")
	end
end)

row(visualScroll, 3, "refresh visual")
button(visualScroll.Row3, "refresh", 66, function()
	if espEnabled then
		paintEsp()
	end
	if aimEnabled then
		paintAim()
	end
end)

row(visualScroll, 4, "baca tim")
button(visualScroll.Row4, "baca", 62, function()
	local red = 0
	local blue = 0
	for _ in ipairs(teamIds.red) do
		red = red + 1
	end
	for _ in ipairs(teamIds.blue) do
		blue = blue + 1
	end
	log("tim merah " .. red .. " biru " .. blue, "ok")
end)

row(visualScroll, 5, "matikan semua")
button(visualScroll.Row5, "matikan", 66, function()
	espEnabled = false
	aimEnabled = false
	clearEsp()
	clearAim()
	log("visual dimatikan")
end)

row(miscScroll, 1, "map vote")
local mapBox = field(miscScroll.Row1, "CROSSING", "CROSSING", 110)

row(miscScroll, 2, "vote 10x")
button(miscScroll.Row2, "vote", 62, function()
	local mapName = mapBox.Text
	if mapName == "" then
		log("nama map kosong", "bad")
		return
	end
	task.spawn(function()
		for _ = 1, 10 do
			safeCall(findRemote("MapVote"), "FireServer", mapName)
			task.wait(0.08)
		end
		log("vote " .. mapName .. " x10", "ok")
	end)
end)

row(miscScroll, 3, "nama pemain")
local targetBox = field(miscScroll.Row3, "nama", "", 110)

row(miscScroll, 4, "tantang duel")
button(miscScroll.Row4, "tantang", 66, function()
	local target = Players:FindFirstChild(targetBox.Text)
	if target then
		safeCall(findRemote("DuelChallenge"), "FireServer", "Challenge", target)
		log("tantang " .. target.Name, "act")
	else
		log("pemain tidak ada: " .. targetBox.Text, "bad")
	end
end)

row(miscScroll, 5, "batal duel")
button(miscScroll.Row5, "batal", 62, function()
	safeCall(findRemote("DuelChallenge"), "FireServer", "CancelChallenge")
	log("batal duel", "act")
end)

row(miscScroll, 6, "head look 0")
button(miscScroll.Row6, "kirim", 62, function()
	safeCall(findRemote("HeadLookU"), "FireServer", 0, 0)
	log("head look nol", "act")
end)

local gameEvent = findRemote("GameEvent")
if gameEvent then
	gameEvent.OnClientEvent:Connect(function(kind, payload)
		if kind == "MatchStart" and type(payload) == "table" then
			teamIds.red = payload.redIds or {}
			teamIds.blue = payload.blueIds or {}
			log("match start, tim kebaca", "ok")
			if espEnabled then
				paintEsp()
			end
		elseif kind == "PlayerDied" then
			log("ada yang mati", "bad")
		elseif kind == "RoundFight" then
			log("ronde mulai", "act")
		end
	end)
end

local stashResult = findRemote("CrateStashResult")
if stashResult then
	stashResult.OnClientEvent:Connect(function(kind, crateIndex, ok, reason, detail)
		if kind == "Reply" then
			local state = ok and "ok" or "gagal"
			local extra = type(detail) == "table" and ("sisa " .. tostring(detail.left or 0)) or tostring(reason)
			log("crate " .. state .. " " .. extra, ok and "ok" or "bad")
		end
	end)
end

local spinEvent = findRemote("SpinEvent")
if spinEvent then
	spinEvent.OnClientEvent:Connect(function(kind, result, rarity)
		if kind then
			log("spin " .. tostring(result) .. " " .. tostring(rarity), "ok")
		end
	end)
end

local function openMenu()
	if shell.Visible then
		return
	end
	shell.Visible = true
	shellScale.Scale = 0.96
	shell.GroupTransparency = 1
	tween(shellScale, 0.3, { Scale = 1 })
	tween(shell, 0.3, { GroupTransparency = 0 })
end

local function closeMenu()
	if not shell.Visible then
		return
	end
	tween(shellScale, 0.22, { Scale = 0.96 })
	tween(shell, 0.22, { GroupTransparency = 1 })
	task.delay(0.24, function()
		shell.Visible = false
	end)
end

local bubble = make("CanvasGroup", {
	Name = "Bubble",
	Size = UDim2.fromOffset(46, 46),
	Position = UDim2.new(1, -66, 0.5, -23),
	BackgroundTransparency = 1,
	Visible = false,
	Active = true,
}, gui)

local bubbleRing = make("Frame", {
	Name = "Ring",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Palette.base,
	BorderSizePixel = 0,
}, bubble)
round(bubbleRing, 23)
outline(bubbleRing, Palette.brassSoft, 1, 0.2)

text(bubbleRing, {
	Name = "Glyph",
	Text = "A",
	Font = Enum.Font.GothamBold,
	TextSize = 17,
	TextColor3 = Palette.brass,
	TextXAlignment = Enum.TextXAlignment.Center,
	Size = UDim2.fromScale(1, 1),
})

local bubbleScale = Instance.new("UIScale")
bubbleScale.Scale = 1
bubbleScale.Parent = bubble

bubble.MouseEnter:Connect(function()
	tween(bubbleScale, 0.18, { Scale = 1.06 })
end)

bubble.MouseLeave:Connect(function()
	tween(bubbleScale, 0.18, { Scale = 1 })
end)

local dragState = nil

local function beginDrag(input, object, keep)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	dragState = {
		object = object,
		keep = keep,
		start = input.Position,
		origin = object.Position,
		moved = 0,
	}
end

UserInputService.InputChanged:Connect(function(input)
	if not dragState then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local deltaX = input.Position.X - dragState.start.X
	local deltaY = input.Position.Y - dragState.start.Y
	dragState.moved = math.abs(deltaX) + math.abs(deltaY)
	dragState.object.Position = UDim2.new(
		dragState.origin.X.Scale,
		dragState.origin.X.Offset + deltaX,
		dragState.origin.Y.Scale,
		dragState.origin.Y.Offset + deltaY
	)
end)

UserInputService.InputEnded:Connect(function(input)
	if not dragState then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local finished = dragState
	dragState = nil
	if finished.keep == "bubble" and finished.moved < 6 then
		tween(bubbleScale, 0.1, { Scale = 0.86 })
		task.delay(0.1, function()
			tween(bubbleScale, 0.26, { Scale = 1 }, Enum.EasingStyle.Back)
			if shell.Visible then
				closeMenu()
				task.delay(0.24, function()
					bubble.Visible = true
				end)
			else
				bubble.Visible = false
				openMenu()
			end
		end)
	end
end)

header.InputBegan:Connect(function(input)
	beginDrag(input, shell, "window")
end)

bubble.InputBegan:Connect(function(input)
	beginDrag(input, bubble, "bubble")
end)

closeButton.MouseButton1Click:Connect(function()
	closeMenu()
	task.delay(0.24, function()
		bubble.Visible = true
		tween(bubbleScale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
	end)
end)

closeButton.MouseEnter:Connect(function()
	tween(closeButton, 0.15, { BackgroundColor3 = Palette.raise, TextColor3 = Palette.paper })
end)

closeButton.MouseLeave:Connect(function()
	tween(closeButton, 0.15, { BackgroundColor3 = Palette.surface, TextColor3 = Palette.dim })
end)

pages[1].Visible = true
pages[1].GroupTransparency = 0

tween(veil, 0.25, { GroupTransparency = 0 })
for index, entry in ipairs(letters) do
	local delay = 0.15 + (index - 1) * 0.06
	task.delay(delay, function()
		tween(entry.cell, 0.75, {
			Position = UDim2.fromOffset(entry.restX, entry.restY),
			TextTransparency = 0,
			Rotation = 0,
		})
	end)
end

task.delay(0.9, function()
	tween(rule, 0.5, { Size = UDim2.fromOffset(220, 1) })
	tween(introTag, 0.45, { TextTransparency = 0 })
end)

task.delay(2.4, function()
	tween(word, 0.45, { GroupTransparency = 1, Position = UDim2.new(0.5, -180, 0.5, -64) })
	tween(veil, 0.45, { GroupTransparency = 1 })
	tween(introTag, 0.35, { TextTransparency = 1 })
end)

task.delay(2.9, function()
	veil.Visible = false
	word.Visible = false
	introTag.Visible = false
	openMenu()
	log("kit siap", "ok")
end)
