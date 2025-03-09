local pieces = require("pieces")
local minikanren = require("minikanren_interface")

local board = {}

-- Represents a square on the board
board.Square = {}
board.Square.__index = board.Square

function board.Square.new(piece, color)
    return setmetatable({
        piece = piece,   -- The piece occupying the square (or nil)
        color = color,   -- "white" or "black" (square color)
    }, board.Square)
end

-- Initialize a new chess board with pieces in starting positions
function board.new()
    local board_state = {
        squares = {},    -- 2D array of squares
        turn = "white",  -- Current player's turn
        en_passant = nil, -- Position of pawn that can be captured en passant (if any)
        castling = {     -- Castling availability
            white_kingside = true,
            white_queenside = true,
            black_kingside = true,
            black_queenside = true
        },
        half_move_clock = 0,  -- For 50-move rule
        full_move_number = 1, -- Increments after Black's move
        captured_pieces = {white = {}, black = {}}
    }
    
    -- Create empty board
    for row = 1, 8 do
        board_state.squares[row] = {}
        for col = 1, 8 do
            -- Alternate square colors (even sum = white, odd sum = black)
            local color = (row + col) % 2 == 0 and "white" or "black"
            board_state.squares[row][col] = board.Square.new(nil, color)
        end
    end
    
    -- Set up pawns
    for col = 1, 8 do
        local white_pawn = pieces.new("pawn", "white", 7, col)
        local black_pawn = pieces.new("pawn", "black", 2, col)
        board_state.squares[7][col].piece = white_pawn
        board_state.squares[2][col].piece = black_pawn
    end
    
    -- Set up back row pieces
    local back_row_order = {"rook", "knight", "bishop", "queen", "king", "bishop", "knight", "rook"}
    
    for col = 1, 8 do
        local piece_type = back_row_order[col]
        local white_piece = pieces.new(piece_type, "white", 8, col)
        local black_piece = pieces.new(piece_type, "black", 1, col)
        board_state.squares[8][col].piece = white_piece
        board_state.squares[1][col].piece = black_piece
    end
    
    return board_state
end

-- Gets the piece at specified row, col
function board.get_piece(board_state, row, col)
    if row < 1 or row > 8 or col < 1 or col > 8 then
        return nil
    end
    return board_state.squares[row][col].piece
end

-- Check if a move is valid
function board.is_valid_move(board_state, from_row, from_col, to_row, to_col)
    -- Delegate to miniKanren for move validation
    return minikanren.is_valid_move(board_state, from_row, from_col, to_row, to_col)
end

-- Update castling rights
local function update_castling_rights(board_state, piece_type, piece_color, from_row, from_col)
    if piece_type == "king" then
        if piece_color == "white" then
            board_state.castling.white_kingside = false
            board_state.castling.white_queenside = false
        else
            board_state.castling.black_kingside = false
            board_state.castling.black_queenside = false
        end
    elseif piece_type == "rook" then
        if piece_color == "white" then
            if from_row == 8 and from_col == 1 then
                board_state.castling.white_queenside = false
            elseif from_row == 8 and from_col == 8 then
                board_state.castling.white_kingside = false
            end
        else
            if from_row == 1 and from_col == 1 then
                board_state.castling.black_queenside = false
            elseif from_row == 1 and from_col == 8 then
                board_state.castling.black_kingside = false
            end
        end
    end
end

-- Handle special moves like castling and en passant
local function handle_special_moves(board_state, piece, from_row, from_col, to_row, to_col)
    -- Handle castling
    if piece.type == "king" and math.abs(from_col - to_col) == 2 then
        -- Kingside castling
        if to_col > from_col then
            local rook = board_state.squares[from_row][8].piece
            board_state.squares[from_row][8].piece = nil
            board_state.squares[from_row][to_col - 1].piece = rook
            if rook then
                rook.row = from_row
                rook.col = to_col - 1
            end
        -- Queenside castling
        else
            local rook = board_state.squares[from_row][1].piece
            board_state.squares[from_row][1].piece = nil
            board_state.squares[from_row][to_col + 1].piece = rook
            if rook then
                rook.row = from_row
                rook.col = to_col + 1
            end
        end
    end
    
    -- Handle en passant captures
    if piece.type == "pawn" and from_col ~= to_col and not board_state.squares[to_row][to_col].piece then
        -- This is a diagonal pawn move with no capture - must be en passant
        local captured_row = (piece.color == "white") and to_row + 1 or to_row - 1
        local captured_pawn = board_state.squares[captured_row][to_col].piece
        if captured_pawn then
            -- Add to captured pieces
            table.insert(board_state.captured_pieces[captured_pawn.color], captured_pawn)
            -- Remove the captured pawn
            board_state.squares[captured_row][to_col].piece = nil
        end
    end
    
    -- Set en passant square if pawn moves two squares
    board_state.en_passant = nil
    if piece.type == "pawn" and math.abs(from_row - to_row) == 2 then
        board_state.en_passant = {
            row = (from_row + to_row) / 2,
            col = from_col
        }
    end
end

-- Handle pawn promotion
local function handle_promotion(board_state, piece, to_row)
    if piece.type == "pawn" then
        if (piece.color == "white" and to_row == 1) or (piece.color == "black" and to_row == 8) then
            -- Auto-promote to queen for simplicity
            -- In a full game, you'd show UI to let the player choose
            piece.type = "queen"
        end
    end
end

-- Moves a piece on the board (assumes move is valid)
function board.move_piece(board_state, from_row, from_col, to_row, to_col)
    local piece = board_state.squares[from_row][from_col].piece
    
    if not piece then return false end
    
    -- Reset half move clock if pawn move or capture
    if piece.type == "pawn" or board_state.squares[to_row][to_col].piece then
        board_state.half_move_clock = 0
    else
        board_state.half_move_clock = board_state.half_move_clock + 1
    end
    
    -- Update castling rights
    update_castling_rights(board_state, piece.type, piece.color, from_row, from_col)
    
    -- If there's a piece at the destination, add it to captured pieces
    local captured_piece = board_state.squares[to_row][to_col].piece
    if captured_piece then
        table.insert(board_state.captured_pieces[captured_piece.color], captured_piece)
    end
    
    -- Handle special moves (castling, en passant)
    handle_special_moves(board_state, piece, from_row, from_col, to_row, to_col)
    
    -- Move the piece
    board_state.squares[from_row][from_col].piece = nil
    board_state.squares[to_row][to_col].piece = piece
    
    -- Update piece position
    piece.row = to_row
    piece.col = to_col
    
    -- Handle pawn promotion
    handle_promotion(board_state, piece, to_row)
    
    -- Update move counters and turn
    if piece.color == "black" then
        board_state.full_move_number = board_state.full_move_number + 1
    end
    
    board_state.turn = board_state.turn == "white" and "black" or "white"
    
    return true
end

-- Returns the current player's turn
function board.current_turn(board_state)
    return board_state.turn
end

-- Find the king of a specific color
local function find_king(board_state, color)
    for row = 1, 8 do
        for col = 1, 8 do
            local piece = board_state.squares[row][col].piece
            if piece and piece.type == "king" and piece.color == color then
                return row, col
            end
        end
    end
    return nil, nil
end

-- Check if a square is under attack by the opponent
local function is_square_attacked(board_state, row, col, attacker_color)
    for r = 1, 8 do
        for c = 1, 8 do
            local piece = board_state.squares[r][c].piece
            if piece and piece.color == attacker_color then
                if minikanren.is_valid_move(board_state, r, c, row, col, true) then
                    return true
                end
            end
        end
    end
    return false
end

-- Check if the current player is in check
function board.is_in_check(board_state)
    local king_color = board_state.turn
    local opponent_color = king_color == "white" and "black" or "white"
    
    local king_row, king_col = find_king(board_state, king_color)
    if not king_row then return false end
    
    return is_square_attacked(board_state, king_row, king_col, opponent_color)
end

-- Check if the current player has any legal moves
local function has_legal_moves(board_state)
    local current_color = board_state.turn
    
    for from_row = 1, 8 do
        for from_col = 1, 8 do
            local piece = board_state.squares[from_row][from_col].piece
            if piece and piece.color == current_color then
                local valid_moves = minikanren.get_valid_moves(board_state, piece)
                if #valid_moves > 0 then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Checks for checkmate or stalemate
function board.is_game_over(board_state)
    if board.is_in_check(board_state) then
        if not has_legal_moves(board_state) then
            return true, board_state.turn == "white" and "Checkmate - Black wins" or "Checkmate - White wins"
        end
        return false, board_state.turn == "white" and "White is in check" or "Black is in check"
    elseif not has_legal_moves(board_state) then
        return true, "Stalemate"
    elseif board_state.half_move_clock >= 50 then
        return true, "Draw (50-move rule)"
    end
    
    return false, ""
end

-- Creates a deep copy of the board state
function board.deep_copy(board_state)
    local new_state = {
        squares = {},
        turn = board_state.turn,
        en_passant = board_state.en_passant and {row = board_state.en_passant.row, col = board_state.en_passant.col} or nil,
        castling = {
            white_kingside = board_state.castling.white_kingside,
            white_queenside = board_state.castling.white_queenside,
            black_kingside = board_state.castling.black_kingside,
            black_queenside = board_state.castling.black_queenside,
        },
        half_move_clock = board_state.half_move_clock,
        full_move_number = board_state.full_move_number,
        captured_pieces = {white = {}, black = {}}
    }
    
    -- Copy squares and pieces
    for row = 1, 8 do
        new_state.squares[row] = {}
        for col = 1, 8 do
            local square = board_state.squares[row][col]
            local piece = square.piece
            local new_piece = nil
            
            if piece then
                new_piece = pieces.new(piece.type, piece.color, piece.row, piece.col)
            end
            
            new_state.squares[row][col] = board.Square.new(new_piece, square.color)
        end
    end
    
    -- Copy captured pieces
    for color, pieces_list in pairs(board_state.captured_pieces) do
        for i, piece in ipairs(pieces_list) do
            local new_piece = pieces.new(piece.type, piece.color, piece.row, piece.col)
            table.insert(new_state.captured_pieces[color], new_piece)
        end
    end
    
    return new_state
end

return board
