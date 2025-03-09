local pieces = {}

-- Piece definitions
local piece_types = {}

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

-- Simple validation functions for each piece type
local function pawn_moves(piece, board_state, from_row, from_col, to_row, to_col)
    local direction = piece.color == "white" and -1 or 1
    local start_row = piece.color == "white" and 7 or 2
    
    -- Forward move
    if to_col == from_col and to_row == from_row + direction then
        if not board_state[to_row][to_col] then
            return true
        end
    end
    
    -- Double move from starting position
    if from_row == start_row and to_col == from_col and 
       to_row == from_row + 2 * direction and 
       not board_state[from_row + direction][from_col] and
       not board_state[to_row][to_col] then
        return true
    end
    
    -- Captures
    if to_row == from_row + direction and math.abs(to_col - from_col) == 1 then
        local target = board_state[to_row][to_col]
        if target and target:sub(1,5) ~= piece.color then
            return true
        end
    end
    
    return false
end

local function knight_moves(piece, board_state, from_row, from_col, to_row, to_col)
    local row_diff = math.abs(to_row - from_row)
    local col_diff = math.abs(to_col - from_col)
    
    return (row_diff == 2 and col_diff == 1) or (row_diff == 1 and col_diff == 2)
end

local function bishop_moves(piece, board_state, from_row, from_col, to_row, to_col)
    local row_diff = math.abs(to_row - from_row)
    local col_diff = math.abs(to_col - from_col)
    
    if row_diff ~= col_diff then return false end
    
    local row_step = (to_row > from_row) and 1 or -1
    local col_step = (to_col > from_col) and 1 or -1
    
    local row, col = from_row + row_step, from_col + col_step
    while row ~= to_row do
        if board_state[row][col] then return false end
        row = row + row_step
        col = col + col_step
    end
    
    return true
end

local function rook_moves(piece, board_state, from_row, from_col, to_row, to_col)
    if from_row ~= to_row and from_col ~= to_col then return false end
    
    local row_step = (to_row > from_row) and 1 or (to_row < from_row) and -1 or 0
    local col_step = (to_col > from_col) and 1 or (to_col < from_col) and -1 or 0
    
    local row, col = from_row + row_step, from_col + col_step
    while row ~= to_row or col ~= to_col do
        if board_state[row][col] then return false end
        row = row + row_step
        col = col + col_step
    end
    
    return true
end

local function queen_moves(piece, board_state, from_row, from_col, to_row, to_col)
    return bishop_moves(piece, board_state, from_row, from_col, to_row, to_col) or
           rook_moves(piece, board_state, from_row, from_col, to_row, to_col)
end

local function king_moves(piece, board_state, from_row, from_col, to_row, to_col)
    local row_diff = math.abs(to_row - from_row)
    local col_diff = math.abs(to_col - from_col)
    
    return row_diff <= 1 and col_diff <= 1 and (row_diff > 0 or col_diff > 0)
end

-- Register all piece types
pieces.register_piece_type("pawn", pawn_moves)
pieces.register_piece_type("knight", knight_moves)
pieces.register_piece_type("bishop", bishop_moves)
pieces.register_piece_type("rook", rook_moves)
pieces.register_piece_type("queen", queen_moves)
pieces.register_piece_type("king", king_moves)

return pieces
