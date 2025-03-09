local ukanren = require("lib.vendor.ukanren")
local pieces = {}

-- Piece definitions
local piece_types = {}

function pieces.register_piece_type(name, move_constraints)
    piece_types[name] = {
        move_constraints = move_constraints,
        name = name
    }
end

function pieces.get_piece_type(name)
    return piece_types[name]
end

-- Helper function to check if path is clear for sliding pieces
local function path_is_clear(board_state, from_row, from_col, to_row, to_col)
    local row_step = 0
    local col_step = 0
    
    if from_row < to_row then row_step = 1
    elseif from_row > to_row then row_step = -1
    end
    
    if from_col < to_col then col_step = 1
    elseif from_col > to_col then col_step = -1
    end
    
    local row, col = from_row + row_step, from_col + col_step
    while row ~= to_row or col ~= to_col do
        if board_state[row][col] then
            return false -- Path is blocked
        end
        row = row + row_step
        col = col + col_step
    end
    
    return true
end

-- Define piece movement constraints using miniKanren
local function pawn_constraints(piece, board_state, from_row, from_col, to_row, to_col)
    return function(s_c)
        -- Define direction based on piece color
        local direction = piece.color == "white" and -1 or 1
        local start_row = piece.color == "white" and 7 or 2
        
        -- Forward move (one square)
        if to_col == from_col and to_row == from_row + direction and 
           not board_state[to_row][to_col] then
            return ukanren.unit(s_c)
        end
        
        -- Initial double move
        if from_row == start_row and to_col == from_col and 
           to_row == from_row + 2 * direction and
           not board_state[from_row + direction][from_col] and
           not board_state[to_row][to_col] then
            return ukanren.unit(s_c)
        end
        
        -- Diagonal capture
        if to_row == from_row + direction and math.abs(to_col - from_col) == 1 then
            -- Regular capture
            if board_state[to_row][to_col] and 
               board_state[to_row][to_col]:sub(1,5) ~= piece.color then
                return ukanren.unit(s_c)
            end
            
            -- En passant capture
            local en_passant = board_state.en_passant
            if en_passant and en_passant.row == to_row and en_passant.col == to_col then
                return ukanren.unit(s_c)
            end
        end
        
        return ukanren.mzero
    end
end

local function knight_constraints(piece, board_state, from_row, from_col, to_row, to_col)
    return function(s_c)
        local row_diff = math.abs(to_row - from_row)
        local col_diff = math.abs(to_col - from_col)
        
        -- Knight moves in L-shape: 2 squares in one direction, 1 square perpendicular
        if (row_diff == 2 and col_diff == 1) or (row_diff == 1 and col_diff == 2) then
            -- Can't land on our own pieces
            local target = board_state[to_row][to_col]
            if not target or target:sub(1,5) ~= piece.color then
                return ukanren.unit(s_c)
            end
        end
        
        return ukanren.mzero
    end
end

local function bishop_constraints(piece, board_state, from_row, from_col, to_row, to_col)
    return function(s_c)
        local row_diff = math.abs(to_row - from_row)
        local col_diff = math.abs(to_col - from_col)
        
        -- Bishop moves diagonally (equal row and column differences)
        if row_diff == col_diff and row_diff > 0 then
            -- Check if path is clear
            if path_is_clear(board_state, from_row, from_col, to_row, to_col) then
                -- Can't land on our own pieces
                local target = board_state[to_row][to_col]
                if not target or target:sub(1,5) ~= piece.color then
                    return ukanren.unit(s_c)
                end
            end
        end
        
        return ukanren.mzero
    end
end

local function rook_constraints(piece, board_state, from_row, from_col, to_row, to_col)
    return function(s_c)
        -- Rook moves horizontally or vertically
        if (from_row == to_row or from_col == to_col) and 
           (from_row ~= to_row or from_col ~= to_col) then
            -- Check if path is clear
            if path_is_clear(board_state, from_row, from_col, to_row, to_col) then
                -- Can't land on our own pieces
                local target = board_state[to_row][to_col]
                if not target or target:sub(1,5) ~= piece.color then
                    return ukanren.unit(s_c)
                end
            end
        end
        
        return ukanren.mzero
    end
end

local function queen_constraints(piece, board_state, from_row, from_col, to_row, to_col)
    return function(s_c)
        local row_diff = math.abs(to_row - from_row)
        local col_diff = math.abs(to_col - from_col)
        
        -- Queen moves like a bishop or a rook
        if (from_row == to_row or from_col == to_col) or -- Rook-like moves
           (row_diff == col_diff) then                   -- Bishop-like moves
            if from_row == to_row and from_col == to_col then
                return ukanren.mzero -- Can't stay in place
            end
            
            -- Check if path is clear
            if path_is_clear(board_state, from_row, from_col, to_row, to_col) then
                -- Can't land on our own pieces
                local target = board_state[to_row][to_col]
                if not target or target:sub(1,5) ~= piece.color then
                    return ukanren.unit(s_c)
                end
            end
        end
        
        return ukanren.mzero
    end
end

local function king_constraints(piece, board_state, from_row, from_col, to_row, to_col)
    return function(s_c)
        local row_diff = math.abs(to_row - from_row)
        local col_diff = math.abs(to_col - from_col)
        
        -- Regular king move: one square in any direction
        if row_diff <= 1 and col_diff <= 1 and (row_diff > 0 or col_diff > 0) then
            -- Can't land on our own pieces
            local target = board_state[to_row][to_col]
            if not target or target:sub(1,5) ~= piece.color then
                return ukanren.unit(s_c)
            end
        end
        
        -- Castling
        if row_diff == 0 and col_diff == 2 then
            local castling = board_state.castling
            local is_kingside = to_col > from_col
            local king_row = piece.color == "white" and 8 or 1
            
            -- Verify king hasn't moved and is in the correct position
            if from_row ~= king_row or from_col ~= 5 then
                return ukanren.mzero
            end
            
            -- Check if castling is available
            if piece.color == "white" and 
               ((is_kingside and not castling.white_kingside) or 
                (not is_kingside and not castling.white_queenside)) then
                return ukanren.mzero
            end
            
            if piece.color == "black" and 
               ((is_kingside and not castling.black_kingside) or 
                (not is_kingside and not castling.black_queenside)) then
                return ukanren.mzero
            end
            
            -- Check if path is clear
            local rook_col = is_kingside and 8 or 1
            local step = is_kingside and 1 or -1
            local col = from_col + step
            
            while col ~= rook_col do
                if board_state[from_row][col] then
                    return ukanren.mzero
                end
                col = col + step
            end
            
            -- Check if rook exists at the corner
            local rook_piece = board_state[from_row][rook_col]
            if not rook_piece or 
               rook_piece:sub(1,5) ~= piece.color or 
               rook_piece:match("_%a+$"):sub(2) ~= "rook" then
                return ukanren.mzero
            end
            
            -- Cannot castle out of, through, or into check
            -- This would require a check detector, which we'll handle separately
            
            return ukanren.unit(s_c)
        end
        
        return ukanren.mzero
    end
end

function pieces.is_valid_move(piece, board_state, from_row, from_col, to_row, to_col)
    local piece_type = pieces.get_piece_type(piece.type)
    if not piece_type then return false end
    
    local constraint = piece_type.move_constraints(piece, board_state, from_row, from_col, to_row, to_col)
    local result = constraint(ukanren.empty_env)
    
    -- If move is valid according to basic rules
    if ukanren.is_pair(result) then
        -- We'd check for check/checkmate/etc. here, but that requires a full board understanding
        -- For simplicity, we'll just return true for now
        return true
    end
    
    return false
end

-- Check if a king is in check
function pieces.is_in_check(board_state, king_color)
    local king_row, king_col
    
    -- Find the king
    for row = 1, 8 do
        for col = 1, 8 do
            local piece = board_state[row][col]
            if piece and piece:sub(1,5) == king_color and 
               piece:match("_%a+$"):sub(2) == "king" then
                king_row, king_col = row, col
                break
            end
        end
        if king_row then break end
    end
    
    if not king_row then return false end
    
    -- Check if any opponent piece can attack the king
    local enemy_color = king_color == "white" and "black" or "white"
    
    for row = 1, 8 do
        for col = 1, 8 do
            local piece = board_state[row][col]
            if piece and piece:sub(1,5) == enemy_color then
                local piece_obj = {
                    type = piece:match("_%a+$"):sub(2),
                    color = enemy_color,
                    row = row,
                    col = col
                }
                
                if pieces.is_valid_move(piece_obj, board_state, row, col, king_row, king_col) then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Register all piece types with their constraints
pieces.register_piece_type("pawn", pawn_constraints)
pieces.register_piece_type("knight", knight_constraints)
pieces.register_piece_type("bishop", bishop_constraints)
pieces.register_piece_type("rook", rook_constraints)
pieces.register_piece_type("queen", queen_constraints)
pieces.register_piece_type("king", king_constraints)

return pieces
