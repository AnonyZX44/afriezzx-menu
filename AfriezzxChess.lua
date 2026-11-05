local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

local Palette = {
	ink = Color3.fromRGB(7, 10, 16),
	base = Color3.fromRGB(11, 15, 23),
	surface = Color3.fromRGB(17, 23, 34),
	raise = Color3.fromRGB(23, 31, 45),
	line = Color3.fromRGB(35, 47, 65),
	paper = Color3.fromRGB(231, 238, 248),
	dim = Color3.fromRGB(122, 138, 160),
	brass = Color3.fromRGB(92, 142, 214),
	brassSoft = Color3.fromRGB(58, 92, 140),
	good = Color3.fromRGB(104, 196, 152),
	bad = Color3.fromRGB(214, 104, 104),
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

local Chess = (function()
	local Engine = {}

	local VALUES = { P = 100, N = 320, B = 330, R = 500, Q = 900, K = 0 }
	local MATE = 1000000

	local PAWN_PST = {
		0, 0, 0, 0, 0, 0, 0, 0,
		50, 50, 50, 50, 50, 50, 50, 50,
		10, 10, 20, 30, 30, 20, 10, 10,
		5, 5, 10, 25, 25, 10, 5, 5,
		0, 0, 0, 20, 20, 0, 0, 0,
		5, -5, -10, 0, 0, -10, -5, 5,
		5, 10, 10, -20, -20, 10, 10, 5,
		0, 0, 0, 0, 0, 0, 0, 0,
	}

	local KNIGHT_PST = {
		-50, -40, -30, -30, -30, -30, -40, -50,
		-40, -20, 0, 0, 0, 0, -20, -40,
		-30, 0, 10, 15, 15, 10, 0, -30,
		-30, 5, 15, 20, 20, 15, 5, -30,
		-30, 0, 15, 20, 20, 15, 0, -30,
		-30, 5, 10, 15, 15, 10, 5, -30,
		-40, -20, 0, 5, 5, 0, -20, -40,
		-50, -40, -30, -30, -30, -30, -40, -50,
	}

	local BISHOP_PST = {
		-20, -10, -10, -10, -10, -10, -10, -20,
		-10, 0, 0, 0, 0, 0, 0, -10,
		-10, 0, 5, 10, 10, 5, 0, -10,
		-10, 5, 5, 10, 10, 5, 5, -10,
		-10, 0, 10, 10, 10, 10, 0, -10,
		-10, 10, 10, 10, 10, 10, 10, -10,
		-10, 5, 0, 0, 0, 0, 5, -10,
		-20, -10, -10, -10, -10, -10, -10, -20,
	}

	local ROOK_PST = {
		0, 0, 0, 0, 0, 0, 0, 0,
		5, 10, 10, 10, 10, 10, 10, 5,
		-5, 0, 0, 0, 0, 0, 0, -5,
		-5, 0, 0, 0, 0, 0, 0, -5,
		-5, 0, 0, 0, 0, 0, 0, -5,
		-5, 0, 0, 0, 0, 0, 0, -5,
		-5, 0, 0, 0, 0, 0, 0, -5,
		0, 0, 0, 5, 5, 0, 0, 0,
	}

	local QUEEN_PST = {
		-20, -10, -10, -5, -5, -10, -10, -20,
		-10, 0, 0, 0, 0, 0, 0, -10,
		-10, 0, 5, 5, 5, 5, 0, -10,
		-5, 0, 5, 5, 5, 5, 0, -5,
		0, 0, 5, 5, 5, 5, 0, -5,
		-10, 5, 5, 5, 5, 5, 0, -10,
		-10, 0, 5, 0, 0, 0, 0, -10,
		-20, -10, -10, -5, -5, -10, -10, -20,
	}

	local KING_PST = {
		-30, -40, -40, -50, -50, -40, -40, -30,
		-30, -40, -40, -50, -50, -40, -40, -30,
		-30, -40, -40, -50, -50, -40, -40, -30,
		-30, -40, -40, -50, -50, -40, -40, -30,
		-20, -30, -30, -40, -40, -30, -30, -20,
		-10, -20, -20, -20, -20, -20, -20, -10,
		20, 20, 0, 0, 0, 0, 20, 20,
		20, 30, 10, 0, 0, 10, 30, 20,
	}

	local PST = { P = PAWN_PST, N = KNIGHT_PST, B = BISHOP_PST, R = ROOK_PST, Q = QUEEN_PST, K = KING_PST }

	local KNIGHT_STEPS = { { 1, 2 }, { 2, 1 }, { 2, -1 }, { 1, -2 }, { -1, -2 }, { -2, -1 }, { -2, 1 }, { -1, 2 } }
	local BISHOP_STEPS = { { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } }
	local ROOK_STEPS = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
	local KING_STEPS = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 }, { 1, 1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } }

	local function isWhitePiece(piece)
		return piece ~= nil and piece:match("%u") ~= nil
	end

	local function isBlackPiece(piece)
		return piece ~= nil and piece:match("%l") ~= nil
	end

	local function sameSide(piece, white)
		if white then
			return isWhitePiece(piece)
		end
		return isBlackPiece(piece)
	end

	local function enemySide(piece, white)
		if white then
			return isBlackPiece(piece)
		end
		return isWhitePiece(piece)
	end

	local function squareOf(file, rank)
		return rank * 8 + file
	end

	local function fileOf(square)
		return square % 8
	end

	local function rankOf(square)
		return math.floor(square / 8)
	end

	local function onBoard(file, rank)
		return file >= 0 and file <= 7 and rank >= 0 and rank <= 7
	end

	local function parseSquare(value)
		if type(value) ~= "string" or #value ~= 2 then
			return nil
		end
		local file = string.byte(value, 1) - 97
		local rank = tonumber(string.sub(value, 2, 2))
		if not rank then
			return nil
		end
		rank = rank - 1
		if not onBoard(file, rank) then
			return nil
		end
		return squareOf(file, rank)
	end

	local function squareName(square)
		return string.char(97 + fileOf(square)) .. tostring(rankOf(square) + 1)
	end

	function Engine.parseFen(fen)
		if type(fen) ~= "string" then
			return nil
		end
		local parts = {}
		for token in string.gmatch(fen, "%S+") do
			table.insert(parts, token)
		end
		if #parts < 2 then
			return nil
		end
		local rows = {}
		for row in string.gmatch(parts[1], "[^/]+") do
			table.insert(rows, row)
		end
		if #rows ~= 8 then
			return nil
		end
		local board = {}
		local rank = 7
		for _, row in ipairs(rows) do
			local file = 0
			for index = 1, #row do
				local ch = string.sub(row, index, index)
				local empty = tonumber(ch)
				if empty then
					file = file + empty
				else
					if file > 7 then
						return nil
					end
					board[squareOf(file, rank)] = ch
					file = file + 1
				end
			end
			rank = rank - 1
		end
		local turn = parts[2]
		if turn ~= "w" and turn ~= "b" then
			return nil
		end
		local castling = { K = false, Q = false, k = false, q = false }
		local rights = parts[3] or "-"
		for index = 1, #rights do
			local ch = string.sub(rights, index, index)
			if castling[ch] ~= nil then
				castling[ch] = true
			end
		end
		local ep = nil
		if parts[4] and parts[4] ~= "-" then
			ep = parseSquare(parts[4])
		end
		return {
			board = board,
			turn = turn,
			castling = castling,
			ep = ep,
			halfmove = tonumber(parts[5] or "0") or 0,
			fullmove = tonumber(parts[6] or "1") or 1,
		}
	end

	function Engine.toFen(state)
		local rows = {}
		for rank = 7, 0, -1 do
			local row = ""
			local empty = 0
			for file = 0, 7 do
				local piece = state.board[squareOf(file, rank)]
				if piece then
					if empty > 0 then
						row = row .. tostring(empty)
						empty = 0
					end
					row = row .. piece
				else
					empty = empty + 1
				end
			end
			if empty > 0 then
				row = row .. tostring(empty)
			end
			table.insert(rows, row)
		end
		local rights = ""
		if state.castling.K then rights = rights .. "K" end
		if state.castling.Q then rights = rights .. "Q" end
		if state.castling.k then rights = rights .. "k" end
		if state.castling.q then rights = rights .. "q" end
		if rights == "" then rights = "-" end
		local ep = "-"
		if state.ep then
			ep = squareName(state.ep)
		end
		return table.concat(rows, "/") .. " " .. state.turn .. " " .. rights .. " " .. ep .. " " .. tostring(state.halfmove) .. " " .. tostring(state.fullmove)
	end

	local function attacked(board, square, byWhite)
		local file = fileOf(square)
		local rank = rankOf(square)

		if byWhite then
			if rank > 0 then
				for _, df in ipairs({ -1, 1 }) do
					local nf = file + df
					if onBoard(nf, rank - 1) and board[squareOf(nf, rank - 1)] == "P" then
						return true
					end
				end
			end
		else
			if rank < 7 then
				for _, df in ipairs({ -1, 1 }) do
					local nf = file + df
					if onBoard(nf, rank + 1) and board[squareOf(nf, rank + 1)] == "p" then
						return true
					end
				end
			end
		end

		local knight = byWhite and "N" or "n"
		for _, step in ipairs(KNIGHT_STEPS) do
			local nf = file + step[1]
			local nr = rank + step[2]
			if onBoard(nf, nr) and board[squareOf(nf, nr)] == knight then
				return true
			end
		end

		local king = byWhite and "K" or "k"
		for _, step in ipairs(KING_STEPS) do
			local nf = file + step[1]
			local nr = rank + step[2]
			if onBoard(nf, nr) and board[squareOf(nf, nr)] == king then
				return true
			end
		end

		local rook = byWhite and "R" or "r"
		local queen = byWhite and "Q" or "q"
		for _, step in ipairs(ROOK_STEPS) do
			local nf = file + step[1]
			local nr = rank + step[2]
			while onBoard(nf, nr) do
				local piece = board[squareOf(nf, nr)]
				if piece then
					if piece == rook or piece == queen then
						return true
					end
					break
				end
				nf = nf + step[1]
				nr = nr + step[2]
			end
		end

		local bishop = byWhite and "B" or "b"
		for _, step in ipairs(BISHOP_STEPS) do
			local nf = file + step[1]
			local nr = rank + step[2]
			while onBoard(nf, nr) do
				local piece = board[squareOf(nf, nr)]
				if piece then
					if piece == bishop or piece == queen then
						return true
					end
					break
				end
				nf = nf + step[1]
				nr = nr + step[2]
			end
		end

		return false
	end

	local function kingSquare(board, white)
		local target = white and "K" or "k"
		for square = 0, 63 do
			if board[square] == target then
				return square
			end
		end
		return nil
	end

	local function inCheck(state)
		local white = state.turn == "w"
		local king = kingSquare(state.board, white)
		if not king then
			return false
		end
		return attacked(state.board, king, not white)
	end

	local function addMove(moves, from, to, promo, flag)
		table.insert(moves, { from = from, to = to, promo = promo, flag = flag })
	end

	local function generateMoves(state)
		local moves = {}
		local board = state.board
		local white = state.turn == "w"

		for square = 0, 63 do
			local piece = board[square]
			if piece and sameSide(piece, white) then
				local upper = string.upper(piece)
				local file = fileOf(square)
				local rank = rankOf(square)

				if upper == "P" then
					local dir = white and 1 or -1
					local startRank = white and 1 or 6
					local promoRank = white and 7 or 0
					local oneRank = rank + dir
					if onBoard(file, oneRank) and not board[squareOf(file, oneRank)] then
						local one = squareOf(file, oneRank)
						if oneRank == promoRank then
							for _, promo in ipairs({ "q", "r", "b", "n" }) do
								addMove(moves, square, one, white and string.upper(promo) or promo, "promo")
							end
						else
							addMove(moves, square, one, nil, nil)
							local twoRank = rank + dir * 2
							if rank == startRank and not board[squareOf(file, twoRank)] then
								addMove(moves, square, squareOf(file, twoRank), nil, "double")
							end
						end
					end
					for _, df in ipairs({ -1, 1 }) do
						local nf = file + df
						if onBoard(nf, oneRank) then
							local target = squareOf(nf, oneRank)
							local victim = board[target]
							if victim and enemySide(victim, white) then
								if oneRank == promoRank then
									for _, promo in ipairs({ "q", "r", "b", "n" }) do
										addMove(moves, square, target, white and string.upper(promo) or promo, "promo")
									end
								else
									addMove(moves, square, target, nil, nil)
								end
							elseif state.ep == target then
								addMove(moves, square, target, nil, "ep")
							end
						end
					end
				elseif upper == "N" then
					for _, step in ipairs(KNIGHT_STEPS) do
						local nf = file + step[1]
						local nr = rank + step[2]
						if onBoard(nf, nr) then
							local target = squareOf(nf, nr)
							local victim = board[target]
							if not victim or enemySide(victim, white) then
								addMove(moves, square, target, nil, nil)
							end
						end
					end
				elseif upper == "B" or upper == "R" or upper == "Q" then
					local dirs = {}
					if upper == "B" then
						dirs = BISHOP_STEPS
					elseif upper == "R" then
						dirs = ROOK_STEPS
					else
						for _, step in ipairs(ROOK_STEPS) do
							table.insert(dirs, step)
						end
						for _, step in ipairs(BISHOP_STEPS) do
							table.insert(dirs, step)
						end
					end
					for _, step in ipairs(dirs) do
						local nf = file + step[1]
						local nr = rank + step[2]
						while onBoard(nf, nr) do
							local target = squareOf(nf, nr)
							local victim = board[target]
							if not victim then
								addMove(moves, square, target, nil, nil)
							else
								if enemySide(victim, white) then
									addMove(moves, square, target, nil, nil)
								end
								break
							end
							nf = nf + step[1]
							nr = nr + step[2]
						end
					end
				elseif upper == "K" then
					for _, step in ipairs(KING_STEPS) do
						local nf = file + step[1]
						local nr = rank + step[2]
						if onBoard(nf, nr) then
							local target = squareOf(nf, nr)
							local victim = board[target]
							if not victim or enemySide(victim, white) then
								addMove(moves, square, target, nil, nil)
							end
						end
					end
					if white and square == 4 then
						if state.castling.K and board[5] == nil and board[6] == nil and board[7] == "R" then
							if not attacked(board, 4, false) and not attacked(board, 5, false) and not attacked(board, 6, false) then
								addMove(moves, 4, 6, nil, "castleK")
							end
						end
						if state.castling.Q and board[3] == nil and board[2] == nil and board[1] == nil and board[0] == "R" then
							if not attacked(board, 4, false) and not attacked(board, 3, false) and not attacked(board, 2, false) then
								addMove(moves, 4, 2, nil, "castleQ")
							end
						end
					elseif not white and square == 60 then
						if state.castling.k and board[61] == nil and board[62] == nil and board[63] == "r" then
							if not attacked(board, 60, true) and not attacked(board, 61, true) and not attacked(board, 62, true) then
								addMove(moves, 60, 62, nil, "castleK")
							end
						end
						if state.castling.q and board[59] == nil and board[58] == nil and board[57] == nil and board[56] == "r" then
							if not attacked(board, 60, true) and not attacked(board, 59, true) and not attacked(board, 58, true) then
								addMove(moves, 60, 58, nil, "castleQ")
							end
						end
					end
				end
			end
		end

		return moves
	end

	local function makeMove(state, move)
		local board = {}
		for square = 0, 63 do
			board[square] = state.board[square]
		end
		local piece = board[move.from]
		local white = isWhitePiece(piece)
		local capture = board[move.to] ~= nil

		board[move.from] = nil
		board[move.to] = move.promo or piece

		if move.flag == "ep" then
			local victimSquare = white and move.to - 8 or move.to + 8
			board[victimSquare] = nil
			capture = true
		elseif move.flag == "castleK" then
			if white then
				board[5] = board[7]
				board[7] = nil
			else
				board[61] = board[63]
				board[63] = nil
			end
		elseif move.flag == "castleQ" then
			if white then
				board[3] = board[0]
				board[0] = nil
			else
				board[59] = board[56]
				board[56] = nil
			end
		end

		local castling = {
			K = state.castling.K,
			Q = state.castling.Q,
			k = state.castling.k,
			q = state.castling.q,
		}
		if piece == "K" then
			castling.K = false
			castling.Q = false
		elseif piece == "k" then
			castling.k = false
			castling.q = false
		elseif piece == "R" then
			if move.from == 0 then
				castling.Q = false
			elseif move.from == 7 then
				castling.K = false
			end
		elseif piece == "r" then
			if move.from == 56 then
				castling.q = false
			elseif move.from == 63 then
				castling.k = false
			end
		end
		if move.to == 0 then
			castling.Q = false
		elseif move.to == 7 then
			castling.K = false
		elseif move.to == 56 then
			castling.q = false
		elseif move.to == 63 then
			castling.k = false
		end

		local ep = nil
		if move.flag == "double" then
			ep = math.floor((move.from + move.to) / 2)
		end

		local pawnMove = string.upper(piece) == "P"
		local reset = pawnMove or capture
		local halfmove = reset and 0 or (state.halfmove + 1)

		return {
			board = board,
			turn = white and "b" or "w",
			castling = castling,
			ep = ep,
			halfmove = halfmove,
			fullmove = state.fullmove + (white and 0 or 1),
		}
	end

	local function legalMoves(state)
		local pseudo = generateMoves(state)
		local result = {}
		local white = state.turn == "w"
		for _, move in ipairs(pseudo) do
			local nextState = makeMove(state, move)
			local king = kingSquare(nextState.board, white)
			if not king or not attacked(nextState.board, king, not white) then
				table.insert(result, move)
			end
		end
		return result
	end

	local function evaluate(state)
		local score = 0
		for square = 0, 63 do
			local piece = state.board[square]
			if piece then
				local white = isWhitePiece(piece)
				local upper = string.upper(piece)
				local value = VALUES[upper] or 0
				local tableValue = PST[upper]
				local file = fileOf(square)
				local rank = rankOf(square)
				local visualRank = white and (7 - rank) or rank
				local bonus = tableValue and tableValue[visualRank * 8 + file + 1] or 0
				if white then
					score = score + value + bonus
				else
					score = score - value - bonus
				end
			end
		end
		return score
	end

	local function moveScore(move, board)
		local victim = board[move.to]
		local score = 0
		if victim then
			score = (VALUES[string.upper(victim)] or 0) * 10 - (VALUES[string.upper(board[move.from] or "")] or 0)
		end
		if move.promo then
			score = score + (VALUES[string.upper(move.promo)] or 0)
		end
		return score
	end

	local function orderedMoves(state, moves, capturesOnly)
		local board = state.board
		local scored = {}
		for _, move in ipairs(moves) do
			local victim = board[move.to]
			local take = victim ~= nil or move.flag == "ep" or move.promo ~= nil
			if not capturesOnly or take then
				table.insert(scored, { move = move, score = moveScore(move, board) })
			end
		end
		table.sort(scored, function(a, b)
			return a.score > b.score
		end)
		local result = {}
		for _, entry in ipairs(scored) do
			table.insert(result, entry.move)
		end
		return result
	end

	local nodesVisited = 0

	local function quiesce(state, alpha, beta, ply, limit)
		nodesVisited = nodesVisited + 1
		local white = state.turn == "w"
		local stand = white and evaluate(state) or -evaluate(state)
		if stand >= beta then
			return beta
		end
		if stand > alpha then
			alpha = stand
		end
		if ply >= limit then
			return alpha
		end
		local moves = orderedMoves(state, legalMoves(state), true)
		for _, move in ipairs(moves) do
			local nextState = makeMove(state, move)
			local score = -quiesce(nextState, -beta, -alpha, ply + 1, limit)
			if score >= beta then
				return beta
			end
			if score > alpha then
				alpha = score
			end
		end
		return alpha
	end

	local function negamax(state, depth, alpha, beta, ply)
		nodesVisited = nodesVisited + 1
		if depth <= 0 then
			return quiesce(state, alpha, beta, 0, 4)
		end
		local moves = legalMoves(state)
		if #moves == 0 then
			if inCheck(state) then
				return -MATE + ply
			end
			return 0
		end
		local ordered = orderedMoves(state, moves, false)
		local best = -MATE * 2
		for _, move in ipairs(ordered) do
			local nextState = makeMove(state, move)
			local score = -negamax(nextState, depth - 1, -beta, -alpha, ply + 1)
			if score > best then
				best = score
			end
			if score > alpha then
				alpha = score
			end
			if alpha >= beta then
				break
			end
		end
		return best
	end

	function Engine.moveToUci(move)
		local value = squareName(move.from) .. squareName(move.to)
		if move.promo then
			value = value .. string.lower(move.promo)
		end
		return value
	end

	function Engine.uciToMove(state, value)
		if type(value) ~= "string" or #value < 4 then
			return nil
		end
		local from = parseSquare(string.sub(value, 1, 2))
		local to = parseSquare(string.sub(value, 3, 4))
		if not from or not to then
			return nil
		end
		local promo = nil
		if #value >= 5 then
			promo = string.lower(string.sub(value, 5, 5))
		end
		for _, move in ipairs(legalMoves(state)) do
			if move.from == from and move.to == to then
				if move.promo then
					if promo == string.lower(move.promo) then
						return move
					end
				elseif not promo then
					return move
				end
			end
		end
		return nil
	end

	function Engine.legalMoves(fen)
		local state = Engine.parseFen(fen)
		if not state then
			return nil
		end
		local list = {}
		for _, move in ipairs(legalMoves(state)) do
			table.insert(list, Engine.moveToUci(move))
		end
		return list
	end

	function Engine.applyUci(fen, value)
		local state = Engine.parseFen(fen)
		if not state then
			return nil
		end
		local move = Engine.uciToMove(state, value)
		if not move then
			return nil
		end
		return Engine.toFen(makeMove(state, move))
	end

	local function searchState(state, depth)
		local moves = legalMoves(state)
		if #moves == 0 then
			return nil, nil, 0
		end
		local ordered = orderedMoves(state, moves, false)
		local bestMove = nil
		local bestScore = -MATE * 2
		nodesVisited = 0
		local alpha = -MATE * 2
		local beta = MATE * 2
		for _, move in ipairs(ordered) do
			local nextState = makeMove(state, move)
			local score = -negamax(nextState, depth - 1, -beta, -alpha, 1)
			if score > bestScore then
				bestScore = score
				bestMove = move
			end
			if score > alpha then
				alpha = score
			end
		end
		return bestMove, bestScore, nodesVisited
	end

	function Engine.bestMove(fen, depth)
		local state = Engine.parseFen(fen)
		if not state then
			return nil, nil, 0, nil
		end
		local best, score, nodes = searchState(state, math.max(1, math.min(4, depth or 2)))
		if not best then
			return nil, nil, nodes, nil
		end
		local reply = searchState(makeMove(state, best), math.max(1, (depth or 3) - 1))
		local replyText = nil
		if reply then
			replyText = Engine.moveToUci(reply)
		end
		return Engine.moveToUci(best), score, nodes, replyText
	end

	function Engine.worstMove(fen)
		local state = Engine.parseFen(fen)
		if not state then
			return nil
		end
		local moves = legalMoves(state)
		if #moves == 0 then
			return nil
		end
		local white = state.turn == "w"
		local worst = nil
		local worstScore = nil
		for _, move in ipairs(moves) do
			local nextState = makeMove(state, move)
			local score = white and evaluate(nextState) or -evaluate(nextState)
			if not worstScore or score < worstScore then
				worstScore = score
				worst = move
			end
		end
		return Engine.moveToUci(worst)
	end

	function Engine.turnOf(fen)
		local state = Engine.parseFen(fen)
		if not state then
			return nil
		end
		return state.turn
	end

	return Engine
end)()

local guiParent = resolveParent()
local stale = guiParent:FindFirstChild("AfriezzxChess")
if stale then
	pcall(function()
		stale:Destroy()
	end)
end

local gui = make("ScreenGui", {
	Name = "AfriezzxChess",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ClipToDeviceSafeArea = false,
	ScreenInsets = Enum.ScreenInsets.None,
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
local title = "Afriezzx"
math.randomseed(os.time())
for index = 1, #title do
	local glyph = string.sub(title, index, index)
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
	table.insert(letters, {
		cell = text(word, {
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
		}),
		restX = restX,
		restY = 8,
	})
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
	Text = "chess kit",
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
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	GroupTransparency = 1,
	Visible = false,
}, gui)
round(shell, 12)
outline(shell, Palette.line, 1, 0.25)

local shadeFrame = make("Frame", {
	Name = "Shade",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Palette.base,
	BorderSizePixel = 0,
	ZIndex = 0,
}, shell)
round(shadeFrame, 12)

local shade = Instance.new("UIGradient")
shade.Rotation = 90
shade.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 21, 32)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 11, 18)),
})
shade.Parent = shadeFrame

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
	Text = "chess kit",
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
	Position = UDim2.new(1, -86, 0, 14),
	Size = UDim2.fromOffset(40, 14),
})

local closeButton = make("TextButton", {
	Name = "Close",
	Text = "×",
	Font = Enum.Font.GothamMedium,
	TextSize = 16,
	TextColor3 = Palette.dim,
	BackgroundColor3 = Palette.surface,
	BorderSizePixel = 0,
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

local tabNames = { "Predict", "Move", "AI", "PvP", "Board" }
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

local function wipeLog()
	for _, child in ipairs(logScroll:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
	logCount = 0
end

clearLog.MouseButton1Click:Connect(wipeLog)

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
	make("TextLabel", {
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

local function waitNet()
	local packages = ReplicatedStorage:FindFirstChild("Packages") or ReplicatedStorage:WaitForChild("Packages", 6)
	if packages then
		local util = packages:FindFirstChild("RbxUtil") or packages:WaitForChild("RbxUtil", 4)
		if util then
			local found = util:FindFirstChild("Net") or util:WaitForChild("Net", 4)
			if found then
				return found
			end
		end
	end
	for _, child in ipairs(ReplicatedStorage:GetDescendants()) do
		if child.Name == "RF/AcceptChallenge" or string.sub(child.Name, 1, 13) == "RE/SubmitMove" then
			return child.Parent
		end
	end
	return nil
end

local Net = waitNet()
if not Net then
	statusLabel.Text = "offline"
	statusDot.BackgroundColor3 = Palette.bad
	introTag.Text = "net tidak ada"
	print("[AfriezzxChess] net tidak ada")
	log("Net tidak ada", "bad")
else
	log("net siap " .. tostring(#Net:GetChildren()) .. " remote", "ok")
	introTag.Text = "net " .. tostring(#Net:GetChildren()) .. " remote"
	print("[AfriezzxChess] net " .. tostring(#Net:GetChildren()) .. " remote")
end

local function netChild(name)
	if not Net then
		return nil
	end
	local ok, child = pcall(function()
		return Net:FindFirstChild(name)
	end)
	if ok then
		return child
	end
	return nil
end

local function prefixed(prefix)
	if not Net then
		return nil
	end
	local children = Net:GetChildren()
	for _, child in ipairs(children) do
		if string.sub(child.Name, 1, #prefix) == prefix then
			return child
		end
	end
	return nil
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

local function safeInvoke(remote, ...)
	if not remote then
		log("remote invoke hilang", "bad")
		return nil
	end
	local ok, result = pcall(function(...)
		return remote:InvokeServer(...)
	end, ...)
	if not ok then
		log("invoke gagal: " .. tostring(result), "bad")
		return nil
	end
	return result
end

local function fireSignal(remote, ...)
	if not remote then
		return false
	end
	local signal = grab("firesignal")
	if type(signal) ~= "function" then
		log("executor tanpa firesignal", "bad")
		return false
	end
	local ok, result = pcall(signal, remote.OnClientEvent, ...)
	if not ok then
		log("firesignal gagal: " .. tostring(result), "bad")
		return false
	end
	return true
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
		Text = tostring(initial),
		Font = Enum.Font.GothamMedium,
		TextSize = 10,
		TextColor3 = Palette.paper,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.fromOffset(24, 22),
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
		readout.Text = tostring(math.floor(value + 0.5))
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

local predictPage, predictScroll = page(1, "Predict")
local movePage, moveScroll = page(2, "Move")
local aiPage, aiScroll = page(3, "AI")
local pvpPage, pvpScroll = page(4, "PvP")
local boardPage, boardScroll = page(5, "Board")

pages[1] = predictPage
pages[2] = movePage
pages[3] = aiPage
pages[4] = pvpPage
pages[5] = boardPage

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
	tween(indicator, 0.26, { Position = UDim2.new((index - 1) / #tabNames, 9, 1, -1) })
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

local lastFen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
local myColor = nil
local detectedColor = nil
local colorMode = "auto"
local gameId = nil
local predictReply = true
local searchDepth = 3
local autoDraw = false
local autoRematch = false
local hijack = false
local thinking = false
local previewBusy = false
local lastPreviewFen = nil
local lastAutoFen = nil
local loopState = false
local lastRematch = nil
local challenges = {}
local localSpoof = false
local callbackConnected = false
local callbackOriginal = nil
local gameEndedRemote = nil
local moveMadeRemote = nil
local drawRemote = nil
local pastRemote = nil
local pendingMove = nil

local fenLabel
local turnLabel
local bestLabel
local replyLabel
local colorLabel
local srcLabel
local hookLabel
local rematchLabel

local function setStatus(value, good)
	statusLabel.Text = value
	statusDot.BackgroundColor3 = good and Palette.good or Palette.bad
end

local function shortFen(fen)
	if type(fen) ~= "string" then
		return "?"
	end
	if #fen <= 34 then
		return fen
	end
	return string.sub(fen, 1, 34) .. "..."
end

local function myTurn()
	return myColor ~= nil and Chess.turnOf(lastFen) == myColor
end

local Workspace = game:GetService("Workspace")
local espEnabled = true
local espFolder = nil
local espEntries = nil
local espRawCorners = nil
local espNormal = nil
local espScale = 1
local espFlip = false
local espKind = "?"
local espTriedAt = -1000000000
local espStatusLabel = nil
local espLastFen = nil
local espLastBest = nil
local espLastReply = nil

local espColorMine = Color3.fromRGB(90, 210, 255)
local espColorMineTo = Color3.fromRGB(90, 235, 160)
local espColorEnemy = Color3.fromRGB(255, 120, 130)
local espColorEnemyTo = Color3.fromRGB(255, 175, 90)

local toastLabel = text(gui, {
	Name = "Toast",
	Text = "",
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	TextColor3 = Palette.paper,
	TextStrokeTransparency = 0.4,
	BackgroundTransparency = 1,
	TextXAlignment = Enum.TextXAlignment.Center,
	Size = UDim2.fromOffset(320, 20),
	Position = UDim2.new(0.5, -160, 0, 58),
	Visible = false,
})

local toastToken = 0

local function toast(message, color)
	toastToken = toastToken + 1
	local token = toastToken
	toastLabel.Text = message
	toastLabel.TextColor3 = color or Palette.paper
	toastLabel.Visible = true
	task.delay(2.6, function()
		if token == toastToken then
			toastLabel.Visible = false
		end
	end)
end

local function fenPiece(fen, square)
	local board = tostring(fen or ""):match("^(%S+)")
	if not board or #square < 2 then
		return nil
	end
	local fileIndex = square:byte(1) - 96
	local rank = tonumber(square:sub(2, 2))
	if not rank or fileIndex < 1 or fileIndex > 8 then
		return nil
	end
	local row = 0
	for rankText in board:gmatch("[^/]+") do
		row = row + 1
		if row == 9 - rank then
			local index = 0
			for char in rankText:gmatch(".") do
				local empty = tonumber(char)
				if empty then
					index = index + empty
				else
					index = index + 1
					if index == fileIndex then
						return char
					end
				end
			end
		end
	end
	return nil
end

local function pieceLabel(letter)
	if not letter then
		return "?"
	end
	local names = {
		p = "pion",
		n = "kuda",
		b = "uskup",
		r = "benteng",
		q = "ratu",
		k = "raja",
	}
	local name = names[letter:lower()] or "?"
	local color = letter == string.upper(letter) and "putih" or "hitam"
	return name .. " " .. color
end

local function screenOf(position)
	local camera = Workspace and Workspace.CurrentCamera
	if not camera then
		return nil
	end
	local screen, visible = camera:WorldToViewportPoint(position)
	if not visible or screen.Z <= 0 then
		return nil
	end
	return Vector2.new(screen.X, screen.Y)
end

local function orderCorners(corners)
	local list = {}
	for _, position in ipairs(corners) do
		local screen = screenOf(position)
		if screen then
			table.insert(list, { world = position, screen = screen })
		end
	end
	if #list < 4 then
		return nil
	end
	table.sort(list, function(a, b)
		return a.screen.Y > b.screen.Y
	end)
	local low = { list[1], list[2] }
	local high = { list[3], list[4] }
	if low[1].screen.X > low[2].screen.X then
		low[1], low[2] = low[2], low[1]
	end
	if high[1].screen.X > high[2].screen.X then
		high[1], high[2] = high[2], high[1]
	end
	return {
		bl = low[1].world,
		br = low[2].world,
		tl = high[1].world,
		tr = high[2].world,
	}
end

local function topCorners(part)
	local cf = part.CFrame
	local center = cf.Position + cf.UpVector * (part.Size.Y * 0.5)
	local right = cf.RightVector * (part.Size.X * 0.5)
	local forward = cf.LookVector * (part.Size.Z * 0.5)
	return {
		center - right - forward,
		center + right - forward,
		center + right + forward,
		center - right + forward,
	}
end

local function cluster(values, tolerance)
	table.sort(values)
	local lines = {}
	for _, value in ipairs(values) do
		if #lines == 0 or math.abs(value - lines[#lines]) > tolerance then
			table.insert(lines, value)
		end
	end
	return lines
end

local function namedBoard()
	local tiles = {}
	for _, item in ipairs(Workspace:GetDescendants()) do
		if item:IsA("BasePart") then
			local lower = item.Name:lower()
			local file, rank = lower:match("^([a-h])([1-8])$")
			if not file then
				file, rank = lower:match("^[%a_%-]*([a-h])([1-8])$")
			end
			if file and rank then
				tiles[file .. rank] = item
			end
		end
	end
	local count = 0
	for _ in pairs(tiles) do
		count = count + 1
	end
	if count ~= 64 or not tiles["a1"] then
		return nil
	end
	local any = tiles["a1"]
	local cf = any.CFrame
	local right = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z)
	local forward = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
	if right.Magnitude < 0.01 or forward.Magnitude < 0.01 then
		return nil
	end
	right = right.Unit
	forward = forward.Unit
	local origin = any.Position
	local minX, maxX, minZ, maxZ, topY
	for _, tile in pairs(tiles) do
		local rel = tile.Position - origin
		local x = rel:Dot(right)
		local z = rel:Dot(forward)
		minX = minX and math.min(minX, x) or x
		maxX = maxX and math.max(maxX, x) or x
		minZ = minZ and math.min(minZ, z) or z
		maxZ = maxZ and math.max(maxZ, z) or z
		local top = tile.Position.Y + tile.Size.Y * 0.5
		topY = topY and math.max(topY, top) or top
	end
	local size = (any.Size.X + any.Size.Z) * 0.5
	local halfX = (maxX - minX) * 0.5 + size * 0.5
	local halfZ = (maxZ - minZ) * 0.5 + size * 0.5
	if math.abs(halfX - halfZ) > math.max(halfX, halfZ) * 0.3 then
		return nil
	end
	if size < 0.5 or halfX < 4 or halfX > 100 then
		return nil
	end
	local center = origin + right * ((minX + maxX) * 0.5) + forward * ((minZ + maxZ) * 0.5)
	center = Vector3.new(center.X, topY + 0.02, center.Z)
	espNormal = cf.UpVector
	espKind = "kotak"
	return orderCorners({
		center - right * halfX - forward * halfZ,
		center + right * halfX - forward * halfZ,
		center + right * halfX + forward * halfZ,
		center - right * halfX + forward * halfZ,
	})
end

local function gridBoard(parts, size)
	local cf = parts[1].CFrame
	local right = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z)
	local forward = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
	if right.Magnitude < 0.01 or forward.Magnitude < 0.01 then
		return nil
	end
	right = right.Unit
	forward = forward.Unit
	local origin = parts[1].Position
	local xs, zs = {}, {}
	local topY
	for _, part in ipairs(parts) do
		local rel = part.Position - origin
		table.insert(xs, rel:Dot(right))
		table.insert(zs, rel:Dot(forward))
		local top = part.Position.Y + part.Size.Y * 0.5
		topY = topY and math.max(topY, top) or top
	end
	local linesX = cluster(xs, size * 0.35)
	local linesZ = cluster(zs, size * 0.35)
	if #linesX ~= 8 or #linesZ ~= 8 then
		return nil
	end
	local center = origin + right * ((linesX[1] + linesX[8]) * 0.5) + forward * ((linesZ[1] + linesZ[8]) * 0.5)
	center = Vector3.new(center.X, topY + 0.02, center.Z)
	local halfX = (linesX[8] - linesX[1]) * 0.5 + size * 0.5
	local halfZ = (linesZ[8] - linesZ[1]) * 0.5 + size * 0.5
	espNormal = cf.UpVector
	espKind = "kotak"
	return orderCorners({
		center - right * halfX - forward * halfZ,
		center + right * halfX - forward * halfZ,
		center + right * halfX + forward * halfZ,
		center - right * halfX + forward * halfZ,
	})
end

local function espParams()
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ignored = {}
	if espFolder then
		table.insert(ignored, espFolder)
	end
	local character = Player and Player.Character
	if character then
		table.insert(ignored, character)
	end
	params.FilterDescendantsInstances = ignored
	return params
end

local function scanBoard()
	local camera = Workspace and Workspace.CurrentCamera
	if not camera then
		return nil
	end
	local viewport = camera.ViewportSize
	local center = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
	local origin = camera.CFrame.Position
	local groups = {}
	local candidates = {}
	for _, item in ipairs(Workspace:GetDescendants()) do
		if item:IsA("BasePart") then
			local size = item.Size
			local maxSide = math.max(size.X, size.Z)
			local squareish = math.abs(size.X - size.Z) <= maxSide * 0.08
			local thin = size.Y <= math.min(size.X, size.Z) * 0.5
			if squareish and thin and size.X >= 1 and size.X <= 160 then
				local distance = (item.Position - origin).Magnitude
				if distance < 350 then
					if size.X >= 16 then
						local screen = screenOf(item.Position)
						if screen and (screen - center).Magnitude < viewport.X * 0.3 then
							table.insert(candidates, item)
						end
					else
						local key = string.format("%.1f_%.1f", size.X, item.Position.Y)
						local group = groups[key]
						if not group then
							group = { size = size.X, parts = {}, seen = {} }
							groups[key] = group
						end
						if not group.seen[item] then
							group.seen[item] = true
							table.insert(group.parts, item)
						end
					end
				end
			end
		end
	end
	local best = nil
	for _, group in pairs(groups) do
		if #group.parts >= 24 and (not best or #group.parts > #best.parts) then
			best = group
		end
	end
	if best then
		local corners = gridBoard(best.parts, best.size)
		if corners then
			return corners
		end
	end
	table.sort(candidates, function(a, b)
		return a.Size.X < b.Size.X
	end)
	local single = candidates[1]
	if single then
		espNormal = single.CFrame.UpVector
		espKind = "papan"
		return orderCorners(topCorners(single))
	end
	return nil
end

local function rayBoard()
	local camera = Workspace and Workspace.CurrentCamera
	if not camera or not Workspace.Raycast then
		return nil
	end
	local viewport = camera.ViewportSize
	if not viewport or viewport.X <= 0 then
		return nil
	end
	local params = espParams()
	local groups = {}
	local big = nil
	local bigArea = 0
	for ix = 0, 10 do
		for iy = 0, 10 do
			local x = viewport.X * (0.15 + 0.7 * ix / 10)
			local y = viewport.Y * (0.15 + 0.7 * iy / 10)
			local ray = camera:ViewportPointToRay(x, y)
			local hit = Workspace:Raycast(ray.Origin, ray.Direction * 4000, params)
			local part = hit and hit.Instance
			if part and part:IsA("BasePart") then
				local flat = part.Size.Y <= math.min(part.Size.X, part.Size.Z) * 0.5
				if flat then
					local key = string.format("%.1f_%.1f_%.1f", part.Size.X, part.Size.Z, part.Position.Y)
					local group = groups[key]
					if not group then
						group = { size = (part.Size.X + part.Size.Z) * 0.5, parts = {}, seen = {} }
						groups[key] = group
					end
					if not group.seen[part] then
						group.seen[part] = true
						table.insert(group.parts, part)
					end
					local square = math.abs(part.Size.X - part.Size.Z) <= part.Size.X * 0.15
					local area = part.Size.X * part.Size.Z
					if square and part.Size.X >= 20 and part.Size.X <= 140 and area > bigArea then
						big = part
						bigArea = area
					end
				end
			end
		end
	end
	local best = nil
	for _, group in pairs(groups) do
		if #group.parts >= 20 and (not best or #group.parts > #best.parts) then
			best = group
		end
	end
	if best then
		local corners = gridBoard(best.parts, best.size)
		if corners then
			return corners
		end
	end
	if big then
		espNormal = big.CFrame.UpVector
		espKind = "papan"
		return orderCorners(topCorners(big))
	end
	return nil
end

local function detectBoard()
	if not Workspace or not Workspace.CurrentCamera then
		return nil
	end
	local corners = namedBoard()
	if not corners then
		corners = scanBoard()
	end
	if not corners then
		corners = rayBoard()
	end
	if not corners then
		espKind = "gagal"
		return nil
	end
	espRawCorners = corners
	if espNormal and espNormal.Y < 0 then
		espNormal = -espNormal
	end
	return corners
end

local function board()
	if not espRawCorners then
		local now = os.clock()
		if now - espTriedAt < 8 then
			return nil
		end
		espTriedAt = now
		local ok, corners = pcall(detectBoard)
		if not ok or not corners then
			return nil
		end
	end
	if espScale == 1 then
		return espRawCorners
	end
	local raw = espRawCorners
	local center = (raw.bl + raw.br + raw.tl + raw.tr) * 0.25
	local function scalePoint(point)
		return center + (point - center) * espScale
	end
	return {
		bl = scalePoint(raw.bl),
		br = scalePoint(raw.br),
		tl = scalePoint(raw.tl),
		tr = scalePoint(raw.tr),
	}
end

local function cellCenter(corners, file, rank)
	local u, v
	if (myColor == "b") ~= espFlip then
		u = (8 - file + 0.5) / 8
		v = (rank - 1 + 0.5) / 8
	else
		u = (file - 1 + 0.5) / 8
		v = (8 - rank + 0.5) / 8
	end
	local top = corners.tl:Lerp(corners.tr, u)
	local bottom = corners.bl:Lerp(corners.br, u)
	return top:Lerp(bottom, v)
end

local function cellSize(corners)
	local width = (corners.br - corners.bl).Magnitude / 8
	local height = (corners.tl - corners.bl).Magnitude / 8
	return (width + height) * 0.5
end

local function ensureEsp()
	if espFolder and espFolder.Parent == Workspace then
		return true
	end
	espFolder = Instance.new("Folder")
	espFolder.Name = "AfriezzxEsp"
	espFolder.Parent = Workspace
	espEntries = {}
	for index = 1, 6 do
		local part = Instance.new("Part")
		part.Name = "Box" .. index
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Material = Enum.Material.Neon
		part.Transparency = 0.25
		part.Size = Vector3.new(1, 0.05, 1)
		part.Parent = espFolder
		local tag = Instance.new("BillboardGui")
		tag.Name = "Tag"
		tag.AlwaysOnTop = true
		tag.LightInfluence = 0
		tag.Size = UDim2.fromOffset(150, 20)
		tag.Parent = part
		local label = Instance.new("TextLabel")
		label.Name = "Text"
		label.BackgroundTransparency = 1
		label.Size = UDim2.fromScale(1, 1)
		label.Font = Enum.Font.GothamBold
		label.TextScaled = true
		label.TextStrokeTransparency = 0.35
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.Text = ""
		label.Parent = tag
		espEntries[index] = { part = part, label = label, tag = tag }
	end
	return true
end

local function clearEsp()
	if espFolder then
		espFolder:Destroy()
		espFolder = nil
		espEntries = nil
	end
	espRawCorners = nil
	espLastBest = nil
	espTriedAt = -1000000000
end

local function renderEsp(fen, best, reply)
	espLastFen = fen
	espLastBest = best
	espLastReply = reply
	if not espEnabled then
		clearEsp()
		return
	end
	if not best or #best < 4 then
		return
	end
	local corners = board()
	if not corners or not ensureEsp() then
		if espStatusLabel then
			espStatusLabel.Text = "esp: gagal"
		end
		return
	end
	if espStatusLabel then
		espStatusLabel.Text = "esp: " .. espKind
	end
	local size = cellSize(corners)
	local right = corners.br - corners.bl
	local forward = corners.tl - corners.bl
	if right.Magnitude < 0.01 or forward.Magnitude < 0.01 then
		return
	end
	right = right.Unit
	forward = forward.Unit
	local normal = espNormal or Vector3.new(0, 1, 0)
	local turn = Chess.turnOf(fen)
	local mine = myColor == nil or turn == myColor
	local primaryFrom = string.sub(best, 1, 2)
	local primaryTo = string.sub(best, 3, 4)
	local replyFrom = reply and string.sub(reply, 1, 2) or nil
	local replyTo = reply and string.sub(reply, 3, 4) or nil

	local function hide(index)
		local entry = espEntries[index]
		if entry then
			entry.part.Transparency = 1
			entry.label.Text = ""
		end
	end

	local function place(index, squareName, color, labelText, arrowFrom)
		local entry = espEntries[index]
		if not entry or not squareName then
			return
		end
		local file = squareName:byte(1) - 96
		local rank = tonumber(squareName:sub(2, 2))
		if not file or not rank then
			return
		end
		local position = cellCenter(corners, file, rank) + normal * 0.08
		if arrowFrom then
			local fromFile = arrowFrom:byte(1) - 96
			local fromRank = tonumber(arrowFrom:sub(2, 2))
			if not fromFile or not fromRank then
				return
			end
			local origin = cellCenter(corners, fromFile, fromRank) + normal * 0.1
			local delta = position - origin
			local length = delta.Magnitude
			if length < 0.05 then
				hide(index)
				return
			end
			entry.part.Size = Vector3.new(size * 0.16, 0.05, length)
			entry.part.CFrame = CFrame.lookAt((origin + position) * 0.5, position, normal)
			entry.part.Color = color
			entry.part.Transparency = 0.1
			entry.label.Text = ""
		else
			entry.part.Size = Vector3.new(size * 0.86, 0.05, size * 0.86)
			entry.part.CFrame = CFrame.fromMatrix(position, right, normal)
			entry.part.Color = color
			entry.part.Transparency = 0.28
			entry.label.Text = labelText
			entry.label.TextColor3 = color
			entry.tag.StudsOffsetWorldSpace = normal * 1.3
		end
	end

	if mine then
		place(1, primaryFrom, espColorMine, "kamu " .. pieceLabel(fenPiece(fen, primaryFrom)) .. " " .. primaryFrom)
		place(2, primaryTo, espColorMineTo, "ke " .. primaryTo)
		place(5, primaryTo, espColorMineTo, "", primaryFrom)
	else
		place(1, primaryFrom, espColorEnemy, "lawan " .. pieceLabel(fenPiece(fen, primaryFrom)) .. " " .. primaryFrom)
		place(2, primaryTo, espColorEnemyTo, "ke " .. primaryTo)
		place(5, primaryTo, espColorEnemyTo, "", primaryFrom)
	end
	if replyFrom and replyTo then
		if mine then
			place(3, replyFrom, espColorEnemy, "lawan " .. pieceLabel(fenPiece(fen, replyFrom)) .. " " .. replyFrom)
			place(4, replyTo, espColorEnemyTo, "ke " .. replyTo)
			place(6, replyTo, espColorEnemyTo, "", replyFrom)
		else
			place(3, replyFrom, espColorMine, "kamu " .. pieceLabel(fenPiece(fen, replyFrom)) .. " " .. replyFrom)
			place(4, replyTo, espColorMineTo, "ke " .. replyTo)
			place(6, replyTo, espColorMineTo, "", replyFrom)
		end
	else
		hide(3)
		hide(4)
		hide(6)
	end
end

local function sendMove(value)
	local remote = prefixed("RE/SubmitMove_")
	safeCall(remote, "FireServer", value)
	log("move " .. value, "act")
	pendingMove = value
	task.delay(1.5, function()
		if pendingMove == value then
			pendingMove = nil
			log("move " .. value .. " ditolak server", "bad")
		end
	end)
end

local function thinkAndPlay(sourceFen, force)
	if thinking then
		return
	end
	thinking = true
	task.spawn(function()
		local ok, best, score, nodes, reply = pcall(Chess.bestMove, sourceFen, searchDepth)
		thinking = false
		if not ok or not best then
			log("engine gagal", "bad")
			return
		end
		if lastFen ~= sourceFen then
			return
		end
		log("best " .. best .. " (" .. tostring(score) .. ")", "ok")
		if predictReply and reply then
			log("lawan: " .. reply, "act")
		end
		renderEsp(sourceFen, best, reply)
		if force or loopState then
			sendMove(best)
			lastAutoFen = sourceFen
		end
	end)
end

local pendingPreview = nil

local function preview(fen)
	if not fen then
		return
	end
	if previewBusy then
		pendingPreview = fen
		return
	end
	if lastPreviewFen == fen then
		return
	end
	previewBusy = true
	task.spawn(function()
		local ok, best, score, nodes, reply = pcall(Chess.bestMove, fen, searchDepth)
		previewBusy = false
		if ok and best then
			lastPreviewFen = fen
			if bestLabel then
				bestLabel.Text = best .. "  " .. tostring(score)
			end
			if replyLabel then
				replyLabel.Text = reply or "-"
			end
			renderEsp(fen, best, reply)
		end
		local queued = pendingPreview
		pendingPreview = nil
		if queued and queued ~= lastPreviewFen then
			preview(queued)
		end
	end)
end

local proxyService = nil
local proxyGame = nil
local proxyAttempts = 0

local function proxyCurrent()
	if proxyService then
		local ok, game = pcall(function()
			return proxyService.ChessGame
		end)
		if ok and game then
			proxyGame = game
		end
		return proxyGame
	end
	if proxyAttempts >= 20 or type(require) ~= "function" then
		return nil
	end
	proxyAttempts = proxyAttempts + 1
	local scripts = Player and Player:FindFirstChild("PlayerScripts")
	local services = scripts and scripts:FindFirstChild("Services")
	local module = services and services:FindFirstChild("ChessProxyService")
	if not module then
		return nil
	end
	local ok, service = pcall(require, module)
	if ok and type(service) == "table" then
		proxyService = service
		local ok2, game = pcall(function()
			return service.ChessGame
		end)
		if ok2 and game then
			proxyGame = game
		end
	end
	return proxyGame
end

local function proxyRead(game, keys)
	for _, key in ipairs(keys) do
		local ok, value = pcall(function()
			return game[key]
		end)
		if ok and value ~= nil then
			return value
		end
	end
	return nil
end

local function proxyFen(game)
	if not game then
		return nil
	end
	local value = proxyRead(game, { "FEN", "fen", "CurrentFEN", "currentFEN", "Fen", "PositionFEN" })
	if type(value) == "string" and value:find("/") and value:find(" ") then
		return value
	end
	for _, key in ipairs({ "State", "state", "GameState", "gameState", "Data", "data" }) do
		local ok, state = pcall(function()
			return game[key]
		end)
		if ok and type(state) == "table" then
			local nested = proxyRead(state, { "FEN", "fen", "CurrentFEN", "currentFEN" })
			if type(nested) == "string" and nested:find("/") then
				return nested
			end
		end
	end
	for _, key in ipairs({ "GetFEN", "getFEN", "GetCurrentFEN", "ToFEN", "GetPosition", "getPosition" }) do
		local ok, fn = pcall(function()
			return game[key]
		end)
		if ok and type(fn) == "function" then
			local ok2, result = pcall(fn, game)
			if ok2 and type(result) == "string" and result:find("/") then
				return result
			end
		end
	end
	local ok, values = pcall(function()
		return game
	end)
	if ok and type(values) == "table" then
		local found = nil
		pcall(function()
			for _, item in pairs(values) do
				if type(item) == "string" and item:match("^[%w/]+ [wb] ") then
					found = item
					break
				end
			end
		end)
		if found then
			return found
		end
	end
	return nil
end

local function proxyColor(game)
	if not game then
		return nil
	end
	for _, key in ipairs({ "AmIWhite", "amIWhite", "IsWhite", "isWhite", "White" }) do
		local ok, value = pcall(function()
			return game[key]
		end)
		if ok and type(value) == "boolean" then
			return value and "w" or "b"
		end
	end
	for _, key in ipairs({ "Color", "color", "Side", "side", "PlayerColor", "playerColor" }) do
		local ok, value = pcall(function()
			return game[key]
		end)
		if ok then
			if value == "w" or value == "white" or value == "White" then
				return "w"
			end
			if value == "b" or value == "black" or value == "Black" then
				return "b"
			end
		end
	end
	local ok, state = pcall(function()
		return game.State or game.state
	end)
	if ok and type(state) == "table" then
		for _, key in ipairs({ "AmIWhite", "amIWhite", "IsWhite", "isWhite" }) do
			local ok2, value = pcall(function()
				return state[key]
			end)
			if ok2 and type(value) == "boolean" then
				return value and "w" or "b"
			end
		end
	end
	return nil
end

local function proxyTick()
	local game = proxyCurrent()
	local fen = proxyFen(game)
	local color = proxyColor(game)
	if color and color ~= detectedColor then
		detectedColor = color
		if colorMode == "auto" then
			myColor = color
		end
	end
	if fen and fen ~= lastFen then
		lastFen = fen
		lastPreviewFen = nil
		if fenLabel then
			fenLabel.Text = shortFen(fen)
		end
		local turn = Chess.turnOf(fen)
		if turnLabel then
			turnLabel.Text = turn == "w" and "white" or (turn == "b" and "black" or "?")
		end
		preview(fen)
	end
	if srcLabel then
		srcLabel.Text = fen and "proxy" or "move"
	end
	task.delay(0.5, proxyTick)
end
task.delay(0.5, proxyTick)

local connMove, connDraw, connEnded

local function bindGame()
	local foundMove = prefixed("RE/MoveMade_")
	if foundMove ~= moveMadeRemote then
		if connMove then
			pcall(function()
				connMove:Disconnect()
			end)
		end
		connMove = nil
		moveMadeRemote = foundMove
		if moveMadeRemote then
			connMove = moveMadeRemote.OnClientEvent:Connect(function(fen, events)
				if type(fen) ~= "string" or not fen:find("/") then
					return
				end
				lastFen = fen
				lastPreviewFen = nil
				if fenLabel then
					fenLabel.Text = shortFen(fen)
				end
				local turn = Chess.turnOf(fen)
				if turnLabel then
					turnLabel.Text = turn == "w" and "white" or (turn == "b" and "black" or "?")
				end
				if type(events) == "table" and type(events[2]) == "table" and events[2][1] == "Move" then
					local made = tostring(events[2][2]) .. tostring(events[2][3])
					log("jalan " .. made, "act")
					if pendingMove == made then
						pendingMove = nil
						log("move " .. made .. " diterima", "ok")
					end
				end
				if loopState and myTurn() and lastAutoFen ~= fen and not localSpoof then
					thinkAndPlay(fen)
				else
					preview(fen)
				end
			end)
		end
	end
	local foundDraw = prefixed("RE/DrawOffer_")
	if foundDraw ~= drawRemote then
		if connDraw then
			pcall(function()
				connDraw:Disconnect()
			end)
		end
		connDraw = nil
		drawRemote = foundDraw
		if drawRemote then
			connDraw = drawRemote.OnClientEvent:Connect(function(offered)
				if offered == true then
					log("tawaran draw masuk", "act")
					if autoDraw then
						task.delay(0.15, function()
							safeCall(drawRemote, "FireServer")
							log("draw dibalas", "ok")
						end)
					end
				end
			end)
		end
	end
	local foundEnded = prefixed("RE/GameEnded_")
	if foundEnded ~= gameEndedRemote then
		if connEnded then
			pcall(function()
				connEnded:Disconnect()
			end)
		end
		connEnded = nil
		gameEndedRemote = foundEnded
		if gameEndedRemote then
			connEnded = gameEndedRemote.OnClientEvent:Connect(function(payload)
				local description = "selesai"
				if type(payload) == "table" then
					description = tostring(payload.Description or payload.Result or "selesai")
				end
				log("game: " .. description, "ok")
				clearEsp()
				setStatus("ended", true)
			end)
		end
	end
	pastRemote = prefixed("RE/PastMove1_")
end

local function setColorFromPayload(payload)
	myColor = nil
	local name = Player.Name
	local display = Player.DisplayName
	if payload then
		if payload.whiteName == name or payload.whiteDisplayName == display then
			myColor = "w"
		elseif payload.blackName == name or payload.blackDisplayName == display then
			myColor = "b"
		elseif payload.againstEngine then
			myColor = payload.whiteName == name and "w" or "b"
		end
		if payload.gameID then
			gameId = payload.gameID
		end
	end
	detectedColor = myColor
	if colorMode == "auto" then
		myColor = detectedColor
	end
end

local gameStarted = netChild("RE/GameStarted")
if gameStarted then
	gameStarted.OnClientEvent:Connect(function(payload)
		if type(payload) == "table" then
			lastFen = payload.fen or lastFen
			setColorFromPayload(payload)
			setStatus("live", true)
			log("game mulai, warna " .. tostring(myColor), "ok")
			if payload.rated then
				log("mode rated", "act")
			end
			if payload.againstEngine then
				log("lawan engine " .. tostring(payload.ai and payload.ai.Engine or "?"), "act")
			end
			bindGame()
			clearEsp()
			if fenLabel then
				fenLabel.Text = shortFen(lastFen)
			end
			if turnLabel then
				turnLabel.Text = Chess.turnOf(lastFen) == "w" and "white" or "black"
			end
			lastPreviewFen = nil
			preview(lastFen)
		end
	end)
end

local rematchRemote = netChild("RE/RematchAvailable")
if rematchRemote then
	rematchRemote.OnClientEvent:Connect(function(id)
		if type(id) == "string" then
			lastRematch = id
			if rematchLabel then
				rematchLabel.Text = id
			end
			log("rematch tersedia " .. id, "act")
			if autoRematch then
				safeInvoke(netChild("RF/AcceptChallenge"), id)
				log("rematch diterima", "ok")
			end
		end
	end)
end

local replica = nil
local replicated = ReplicatedStorage:FindFirstChild("RemoteEvents")
if replicated then
	replica = replicated:FindFirstChild("ReplicaSet")
end
if replica then
	replica.OnClientEvent:Connect(function(kind, ids, details)
		if type(ids) == "table" then
			for _, id in ipairs(ids) do
				if type(id) == "string" then
					challenges[id] = type(details) == "table" and details or {}
				end
			end
		end
	end)
end

row(predictScroll, 1, "papan")
fenLabel = text(predictScroll.Row1, {
	Name = "State",
	Text = shortFen(lastFen),
	TextSize = 9,
	TextColor3 = Palette.dim,
	TextXAlignment = Enum.TextXAlignment.Right,
	Position = UDim2.new(0, 14, 0, 9),
	Size = UDim2.new(1, -28, 0, 14),
})

row(predictScroll, 2, "giliran")
turnLabel = text(predictScroll.Row2, {
	Name = "State",
	Text = "white",
	TextSize = 10,
	TextColor3 = Palette.brass,
	TextXAlignment = Enum.TextXAlignment.Right,
	Position = UDim2.new(0, 14, 0, 9),
	Size = UDim2.new(1, -28, 0, 14),
})

row(predictScroll, 3, "langkah")
bestLabel = text(predictScroll.Row3, {
	Name = "State",
	Text = "-",
	TextSize = 11,
	TextColor3 = Palette.good,
	TextXAlignment = Enum.TextXAlignment.Right,
	Position = UDim2.new(0, 14, 0, 9),
	Size = UDim2.new(1, -28, 0, 14),
})

row(predictScroll, 4, "balasan")
replyLabel = text(predictScroll.Row4, {
	Name = "State",
	Text = "-",
	TextSize = 10,
	TextColor3 = Palette.dim,
	TextXAlignment = Enum.TextXAlignment.Right,
	Position = UDim2.new(0, 14, 0, 9),
	Size = UDim2.new(1, -28, 0, 14),
})

row(predictScroll, 5, "depth")
slider(predictScroll.Row5, 1, 4, 3, 170, function(value)
	searchDepth = math.floor(value + 0.5)
	lastPreviewFen = nil
	if lastFen then
		preview(lastFen)
	end
end)

row(predictScroll, 6, "hitung")
button(predictScroll.Row6, "hitung", 62, function()
	local fen = lastFen
	if not fen then
		log("fen kosong", "bad")
		return
	end
	lastPreviewFen = nil
	task.spawn(function()
		local ok, best, score, nodes, reply = pcall(Chess.bestMove, fen, searchDepth)
		if not ok or not best then
			log("engine gagal", "bad")
			return
		end
		lastPreviewFen = fen
		bestLabel.Text = best .. "  " .. tostring(score)
		replyLabel.Text = reply or "-"
		log("best " .. best .. " skor " .. tostring(score) .. " node " .. tostring(nodes), "ok")
		if predictReply and reply then
			log("prediksi " .. reply, "act")
		end
		renderEsp(fen, best, reply)
		local box = moveScroll.Row1:FindFirstChild("Field")
		if box then
			box.Text = best
		end
	end)
end)

row(predictScroll, 7, "auto main")
toggle(predictScroll.Row7, false, function(state)
	loopState = state
	log(state and "auto main nyala" or "auto main mati", state and "ok" or "act")
	if state then
		if not myColor then
			log("warna belum ketahuan, atur di tombol warna", "bad")
		elseif myTurn() and lastFen then
			thinkAndPlay(lastFen)
		end
	end
end)

row(predictScroll, 8, "prediksi")
toggle(predictScroll.Row8, true, function(state)
	predictReply = state
	log(state and "prediksi nyala" or "prediksi mati", state and "ok" or "act")
end)

row(predictScroll, 9, "warna")
colorLabel = text(predictScroll.Row9, {
	Name = "State",
	Text = "auto",
	TextSize = 10,
	TextColor3 = Palette.brass,
	TextXAlignment = Enum.TextXAlignment.Right,
	Position = UDim2.new(0, 14, 0, 9),
	Size = UDim2.new(1, -110, 0, 14),
})
button(predictScroll.Row9, "ganti", 62, function()
	if colorMode == "auto" then
		colorMode = "w"
	elseif colorMode == "w" then
		colorMode = "b"
	else
		colorMode = "auto"
	end
	if colorMode == "auto" then
		myColor = detectedColor
	else
		myColor = colorMode
	end
	colorLabel.Text = colorMode == "w" and "white" or (colorMode == "b" and "black" or "auto")
	log("warna " .. colorLabel.Text, "act")
end)

row(predictScroll, 10, "esp")
espStatusLabel = predictScroll.Row10.Label
espStatusLabel.Text = "esp: aktif"
toggle(predictScroll.Row10, true, function(state)
	espEnabled = state
	if state then
		espTriedAt = 0
		espRawCorners = nil
		if espLastBest then
			renderEsp(espLastFen, espLastBest, espLastReply)
		end
		toast("ESP nyala", espColorMineTo)
	else
		clearEsp()
		espStatusLabel.Text = "esp: mati"
		toast("ESP mati", Palette.dim)
	end
end)

row(predictScroll, 11, "sumber")
srcLabel = text(predictScroll.Row11, {
	Name = "State",
	Text = "move",
	TextSize = 10,
	TextColor3 = Palette.dim,
	TextXAlignment = Enum.TextXAlignment.Right,
	Position = UDim2.new(0, 14, 0, 9),
	Size = UDim2.new(1, -28, 0, 14),
})

row(moveScroll, 1, "move uci")
local moveBox = field(moveScroll.Row1, "e2e4", "", 96)
row(moveScroll, 2, "kirim")
button(moveScroll.Row2, "kirim", 62, function()
	local value = string.lower(moveBox.Text)
	if value == "" then
		log("move kosong", "bad")
		return
	end
	sendMove(value)
end)

row(moveScroll, 3, "gerak ganda")
button(moveScroll.Row3, "2x", 62, function()
	local value = string.lower(moveBox.Text)
	if value == "" then
		log("move kosong", "bad")
		return
	end
	sendMove(value)
	local nextFen = Chess.applyUci(lastFen, value)
	if not nextFen then
		log("lanjutan tidak legal", "bad")
		return
	end
	task.delay(0.2, function()
		local ok, best = pcall(Chess.bestMove, nextFen, searchDepth)
		if ok and best then
			sendMove(best)
			log("ganda " .. value .. " + " .. best, "ok")
		end
	end)
end)

row(moveScroll, 4, "langkah terbaik")
button(moveScroll.Row4, "mainkan", 72, function()
	if not lastFen then
		return
	end
	thinkAndPlay(lastFen, true)
end)

row(moveScroll, 5, "salin fen")
button(moveScroll.Row5, "salin", 62, function()
	moveBox.Text = lastFen
	log("fen disalin ke kolom", "ok")
end)

row(moveScroll, 6, "bidak lawan")
button(moveScroll.Row6, "uji", 62, function()
	local value = string.lower(moveBox.Text)
	if value == "" then
		log("move kosong", "bad")
		return
	end
	sendMove(value)
	log("uji bidak lawan " .. value, "act")
end)

row(aiScroll, 1, "hijack ai")
toggle(aiScroll.Row1, false, function(state)
	hijack = state
	log(state and "hijack nyala" or "hijack mati", state and "ok" or "act")
end)

row(aiScroll, 2, "hook")
hookLabel = text(aiScroll.Row2, {
	Name = "State",
	Text = "belum",
	TextSize = 10,
	TextColor3 = Palette.dim,
	TextXAlignment = Enum.TextXAlignment.Right,
	Position = UDim2.new(0, 14, 0, 9),
	Size = UDim2.new(1, -28, 0, 14),
})

row(aiScroll, 3, "pasang")
button(aiScroll.Row3, "pasang", 62, function()
	local callback = netChild("RF/EngineCallback")
	if not callback then
		log("EngineCallback tidak ada", "bad")
		return
	end
	local getter = grab("getcallbackvalue")
	local setter = grab("setcallbackvalue")
	if type(getter) ~= "function" or type(setter) ~= "function" then
		log("executor tanpa callback hook", "bad")
		return
	end
	local ok, original = pcall(getter, callback, "OnClientInvoke")
	if not ok then
		log("baca callback gagal", "bad")
		return
	end
	callbackOriginal = original
	local function handler(...)
		local args = { ... }
		if hijack then
			local fen = nil
			for _, value in ipairs(args) do
				if type(value) == "string" and value:find("/") then
					fen = value
					break
				end
			end
			if fen then
				local worst = Chess.worstMove(fen)
				if worst then
					log("ai dipaksa " .. worst, "ok")
					return worst
				end
			end
		end
		if type(original) == "function" then
			return original(...)
		end
		return nil
	end
	local installed = pcall(setter, callback, "OnClientInvoke", handler)
	if installed then
		callbackConnected = true
		hookLabel.Text = "aktif"
		hookLabel.TextColor3 = Palette.good
		log("hook terpasang", "ok")
	else
		log("hook gagal", "bad")
	end
end)

row(aiScroll, 4, "lepas")
button(aiScroll.Row4, "lepas", 62, function()
	local callback = netChild("RF/EngineCallback")
	local setter = grab("setcallbackvalue")
	if callback and type(setter) == "function" and type(callbackOriginal) == "function" then
		local ok = pcall(setter, callback, "OnClientInvoke", callbackOriginal)
		if ok then
			callbackConnected = false
			hookLabel.Text = "lepas"
			hookLabel.TextColor3 = Palette.dim
			log("hook dilepas", "ok")
		end
	end
end)

row(aiScroll, 5, "engine")
local engineBox = field(aiScroll.Row5, "Sunfish", "Sunfish", 96)
button(aiScroll.Row5, "alokasi", 66, function()
	local name = engineBox.Text
	if name == "" then
		name = "Sunfish"
	end
	safeCall(netChild("RE/EngineResourceAllocation"), "FireServer", name)
	log("alokasi " .. name, "act")
end)

row(aiScroll, 6, "status")
text(aiScroll.Row6, {
	Name = "State",
	Text = "siap",
	TextSize = 10,
	TextColor3 = Palette.dim,
	TextXAlignment = Enum.TextXAlignment.Right,
	Position = UDim2.new(0, 14, 0, 9),
	Size = UDim2.new(1, -28, 0, 14),
})

row(pvpScroll, 1, "challenge id")
local challengeBox = field(pvpScroll.Row1, "R-...", "", 110)
row(pvpScroll, 2, "terima")
button(pvpScroll.Row2, "terima", 62, function()
	local id = challengeBox.Text
	if id == "" then
		log("id kosong", "bad")
		return
	end
	local result = safeInvoke(netChild("RF/AcceptChallenge"), id)
	log("terima " .. id .. " -> " .. tostring(result), result and "ok" or "bad")
end)

row(pvpScroll, 3, "rematch")
rematchLabel = text(pvpScroll.Row3, {
	Name = "State",
	Text = "-",
	TextSize = 9,
	TextColor3 = Palette.dim,
	TextXAlignment = Enum.TextXAlignment.Right,
	Position = UDim2.new(0, 14, 0, 9),
	Size = UDim2.new(1, -150, 0, 14),
})
button(pvpScroll.Row3, "main", 62, function()
	if not lastRematch then
		log("belum ada rematch", "bad")
		return
	end
	local result = safeInvoke(netChild("RF/AcceptChallenge"), lastRematch)
	log("rematch " .. tostring(result), result and "ok" or "bad")
end)

row(pvpScroll, 4, "draw")
button(pvpScroll.Row4, "tawar", 62, function()
	safeCall(prefixed("RE/DrawOffer_"), "FireServer")
	log("tawaran draw dikirim", "act")
end)

row(pvpScroll, 5, "auto draw")
toggle(pvpScroll.Row5, false, function(state)
	autoDraw = state
	log(state and "auto draw nyala" or "auto draw mati", state and "ok" or "act")
end)

row(pvpScroll, 6, "auto rematch")
toggle(pvpScroll.Row6, false, function(state)
	autoRematch = state
	log(state and "auto rematch nyala" or "auto rematch mati", state and "ok" or "act")
end)

row(pvpScroll, 7, "challenge")
button(pvpScroll.Row7, "pindai", 62, function()
	local count = 0
	for id, details in pairs(challenges) do
		count = count + 1
		local kind = tostring(details.Type or "?")
		local from = details.From and tostring(details.From) or "?"
		log(id .. " " .. kind .. " " .. from, "act")
	end
	log("total challenge " .. tostring(count), "ok")
end)

row(pvpScroll, 8, "surrender")
button(pvpScroll.Row8, "nyerah", 62, function()
	local target = prefixed("RE/Resign_") or prefixed("RE/Surrender_") or netChild("RE/Resign") or netChild("RE/Surrender")
	if not target then
		log("remote surrender tidak ada", "bad")
		return
	end
	safeCall(target, "FireServer")
	log("surrender dikirim", "act")
end)

row(boardScroll, 1, "fen palsu")
local fenBox = field(boardScroll.Row1, "fen", "", 110)
row(boardScroll, 2, "kirim")
button(boardScroll.Row2, "kirim", 62, function()
	local value = fenBox.Text
	if value == "" or not value:find("/") then
		log("fen tidak valid", "bad")
		return
	end
	localSpoof = true
	local ok = fireSignal(moveMadeRemote or prefixed("RE/MoveMade_"), value, {})
	task.delay(0.2, function()
		localSpoof = false
	end)
	log(ok and "fen palsu dikirim" or "gagal kirim fen", ok and "ok" or "bad")
end)

row(boardScroll, 3, "salin fen")
button(boardScroll.Row3, "salin", 62, function()
	fenBox.Text = lastFen
	log("fen asli disalin", "ok")
end)

row(boardScroll, 4, "selesai palsu")
button(boardScroll.Row4, "tampil", 62, function()
	local ok = fireSignal(gameEndedRemote or prefixed("RE/GameEnded_"), {
		Result = 1,
		Description = "Afriezzx win.",
	})
	log(ok and "layar selesai palsu" or "gagal", ok and "ok" or "bad")
end)

row(boardScroll, 5, "chat palsu")
local chatBox = field(boardScroll.Row5, "[SERVER] ...", "", 110)
row(boardScroll, 6, "kirim")
button(boardScroll.Row6, "kirim", 62, function()
	local value = chatBox.Text
	if value == "" then
		log("chat kosong", "bad")
		return
	end
	local ok = fireSignal(netChild("RE/ChatTimedMsg"), value)
	log(ok and "chat palsu dikirim" or "gagal", ok and "ok" or "bad")
end)

row(boardScroll, 7, "bersih log")
button(boardScroll.Row7, "bersih", 62, function()
	wipeLog()
end)

row(boardScroll, 8, "remote")
button(boardScroll.Row8, "pindai", 62, function()
	if not Net then
		log("net tidak ada", "bad")
		return
	end
	local children = Net:GetChildren()
	log("net " .. tostring(#children) .. " remote", "ok")
	for index, child in ipairs(children) do
		if index <= 12 then
			log(child.Name, "act")
		end
	end
end)

row(boardScroll, 9, "skala papan")
slider(boardScroll.Row9, 80, 100, 100, 170, function(value)
	espScale = value / 100
	if espLastBest then
		renderEsp(espLastFen, espLastBest, espLastReply)
	end
end)

row(boardScroll, 10, "pindai papan")
button(boardScroll.Row10, "cari", 62, function()
	espRawCorners = nil
	espTriedAt = 0
	local success, corners = pcall(detectBoard)
	local ok = success and corners ~= nil
	toast(ok and ("ESP: " .. espKind) or "ESP: papan tidak ketemu", ok and espColorMineTo or espColorEnemy)
	if ok and espLastBest then
		renderEsp(espLastFen, espLastBest, espLastReply)
	end
end)

row(boardScroll, 11, "balik papan")
toggle(boardScroll.Row11, false, function(state)
	espFlip = state
	if espLastBest then
		renderEsp(espLastFen, espLastBest, espLastReply)
	end
end)

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

local bubble = make("TextButton", {
	Name = "Bubble",
	Text = "",
	AutoButtonColor = false,
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
local bubbleMoved = 0

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
	if dragState.object == bubble then
		bubbleMoved = dragState.moved
	end
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
	dragState = nil
end)

header.InputBegan:Connect(function(input)
	beginDrag(input, shell, "window")
end)

bubble.InputBegan:Connect(function(input)
	bubbleMoved = 0
	beginDrag(input, bubble, "bubble")
end)

bubble.MouseButton1Click:Connect(function()
	if bubbleMoved >= 6 then
		return
	end
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
	task.delay(0.15 + (index - 1) * 0.06, function()
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
	tween(introTag, 0.35, { TextTransparency = 1 })
end)

task.delay(2.9, function()
	tween(veil, 0.5, { GroupTransparency = 1 })
	openMenu()
	task.delay(0.5, function()
		veil.Visible = false
	end)
end)

bindGame()
local function retryBind(attempt)
	if moveMadeRemote or attempt > 15 then
		return
	end
	task.delay(1, function()
		bindGame()
		retryBind(attempt + 1)
	end)
end
retryBind(0)
task.delay(3.2, function()
	if not espLastBest then
		preview(lastFen)
	end
end)
local function autoTick()
	if loopState and not thinking and myTurn() and lastFen and lastAutoFen ~= lastFen and not localSpoof then
		thinkAndPlay(lastFen)
	end
	task.delay(2, autoTick)
end
task.delay(2, autoTick)
log("kit siap", "ok")
