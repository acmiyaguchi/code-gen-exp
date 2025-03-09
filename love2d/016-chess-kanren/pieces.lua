local pieces = {}

-- Piece definitions
local piece_types = {}

pieces.Piece = {}
pieces.Piece.__index = pieces.Piece

-- Create a new piece
function pieces.new(piece_type, color, row, col)
    return setmetatable({
        type = piece_type,  -- "pawn", "rook", etc.
        color = color,      -- "white" or "black"
        row = row,
        col = col,
        has_moved = false   -- Track if piece has moved (for castling, pawn double moves)
    }, pieces.Piece)
end

-- Register a piece type and its move generation function
function pieces.register_piece_type(name, move_func)
    piece_types[name] = {
        move_func = move_func,
        name = name
    }
end

-- Get a registered piece type
function pieces.get_piece_type(name)
    return piece_types[name]
end

-- Get all registered piece types
function pieces.get_all_piece_types()
    local result = {}
    for name, type_info in pairs(piece_types) do
        table.insert(result, name)
    end
    return result
end

-- Standard piece values (for AI evaluation)
pieces.values = {
    pawn = 1,
    knight = 3,
    bishop = 3,
    rook = 5,
    queen = 9,
    king = 100
}

-- Define piece movement in terms of miniKanren constraints
-- These will be integrated with the miniKanren interface

-- Pawn movement
local function pawn_moves(piece, board_state, from_row, from_col, to_row, to_col, check_only)
    local direction = piece.color == "white" and -1 or 1  -- White pawns move up (-row), black pawns move down (+row)
    local start_row = piece.color == "white" and 7 or 2   -- Starting row for pawns
    
    -- Regular forward move
    if to_col == from_col and to_row == from_row + direction and not board.get_piece(board_state, to_row, to_col) then
        return true
    end
    
    -- Double move from starting position
    if from_row == start_row and to_col == from_col and to_row == from_row + 2 * direction and
       not board.get_piece(board_state, from_row + direction, from_col) and
       not board.get_piece(board_state, to_row, to_col) then
        return true
    end
    
    -- Diagonal capture
    if to_row == from_row + direction and math.abs(to_col - from_col) == 1 then
        local target_piece = board.get_piece(board_state, to_row, to_col)
        
        -- Regular capture
        if target_piece and target_piece.color ~= piece.color then
            return true
        end
        
        -- En passant capture
        local en_passant = board_state.en_passant
        if en_passant and to_row == en_passant.row and to_col == en_passant.col then
            return true
        end
    end
    
    return false
end

-- Knight movement
local function knight_moves(piece, board_state, from_row, from_col, to_row, to_col, check_only)
    -- Knight moves in L-shape: 2 squares in one direction, 1 square perpendicular
    local row_diff = math.abs(to_row - from_row)
    local col_diff = math.abs(to_col - from_col)
    
    if (row_diff == 2 and col_diff == 1) or (row_diff == 1 and col_diff == 2) then
        local target_piece = board.get_piece(board_state, to_row, to_col)
        return not target_piece or target_piece.color ~= piece.color
    end
    
    return false
end

-- Bishop movement
local function bishop_moves(piece, board_state, from_row, from_col, to_row, to_col, check_only)
    local row_diff = to_row - from_row
    local col_diff = to_col - from_col
    
    -- Bishops move diagonally
    if math.abs(row_diff) == math.abs(col_diff) and row_diff ~= 0 then
        local row_dir = row_diff > 0 and 1 or -1
        local col_dir = col_diff > 0 and 1 or -1
        
        -- Check path for obstacles
        local r, c = from_row + row_dir, from_col + col_dir
        while r ~= to_row do
            if board.get_piece(board_state, r, c) then
                return false  -- Path is blocked
            end
            r = r + row_dir
            c = c + col_dir
        end
        
        -- Check destination square
        local target_piece = board.get_piece(board_state, to_row, to_col)
        return not target_piece or target_piece.color ~= piece.color
    end
    
    return false
end

-- Rook movement
local function rook_moves(piece, board_state, from_row, from_col, to_row, to_col, check_only)
    local row_diff = to_row - from_row
    local col_diff = to_col - from_col
    
    -- Rooks move horizontally or vertically
    if (row_diff == 0 and col_diff ~= 0) or (row_diff ~= 0 and col_diff == 0) then
        local row_dir = row_diff == 0 and 0 or (row_diff > 0 and 1 or -1)
        local col_dir = col_diff == 0 and 0 or (col_diff > 0 and 1 or -1)
        
        -- Check path for obstacles
        local r, c = from_row + row_dir, from_col + col_dir
        while r ~= to_row or c ~= to_col do
            if board.get_piece(board_state, r, c) then
                return false  -- Path is blocked
            end
            r = r + row_dir
            c = c + col_dir
        end
        
        -- Check destination square
        local target_piece = board.get_piece(board_state, to_row, to_col)
        return not target_piece or target_piece.color ~= piece.color
    end
    
    return false
end

-- Queen movement (combines bishop and rook)
local function queen_moves(piece, board_state, from_row, from_col, to_row, to_col, check_only)
    return bishop_moves(piece, board_state, from_row, from_col, to_row, to_col, check_only) or
           rook_moves(piece, board_state, from_row, from_col, to_row, to_col, check_only)
end

-- King movement
local function king_moves(piece, board_state, from_row, from_col, to_row, to_col, check_only)
    local row_diff = math.abs(to_row - from_row)
    local col_diff = math.abs(to_col - from_col)
    
    -- Basic king move: 1 square in any direction
    if row_diff <= 1 and col_diff <= 1 and (row_diff > 0 or col_diff > 0) then
        local target_piece = board.get_piece(board_state, to_row, to_col)
        return not target_piece or target_piece.color ~= piece.color
    end
    
    -- Castling (only if not checking for attacks)
    if not check_only and row_diff == 0 and col_diff == 2 and not piece.has_moved then
        local castling = board_state.castling
        local row = from_row
        local is_kingside = to_col > from_col
        
        -- Check if castling is available
        if piece.color == "white" and 
           ((is_kingside and not castling.white_kingside) or 
            (not is_kingside and not castling.white_queenside)) then
            return false
        end
        
        if piece.color == "black" and 
           ((is_kingside and not castling.black_kingside) or 
            (not is_kingside and not castling.black_queenside)) then
            return false
        end
        
        -- Check if path is clear
        local rook_col = is_kingside and 8 or 1
        local step = is_kingside and 1 or -1
        local col = from_col + step
        
        -- The path between king and rook must be empty
        while col ~= rook_col do
            if board.get_piece(board_state, row, col) then
                return false
            end
            col = col + step
        end
        
        -- Check if rook exists and hasn't moved
        local rook = board.get_piece(board_state, row, rook_col)
        if not rook or rook.type ~= "rook" or rook.color ~= piece.color or rook.has_moved then
            return false
        end
        
        -- King cannot castle out of, through, or into check
        local opponent_color = piece.color == "white" and "black" or "white"
        
        -- Check if king is in check
        if board.is_square_attacked(board_state, from_row, from_col, opponent_color) then
            return false
        end
        
        -- Check if king passes through or ends up in check
        col = from_col
        while col ~= to_col do
            col = col + step
            if board.is_square_attacked(board_state, row, col, opponent_color) then
                return false
            end
        end
        
        return true
    end
    
    return false
end

-- Register the piece types with their move functions
pieces.register_piece_type("pawn", pawn_moves)
pieces.register_piece_type("knight", knight_moves)
pieces.register_piece_type("bishop", bishop_moves)
pieces.register_piece_type("rook", rook_moves)
pieces.register_piece_type("queen", queen_moves)
pieces.register_piece_type("king", king_moves)

return pieces
