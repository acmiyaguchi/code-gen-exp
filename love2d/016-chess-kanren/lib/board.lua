local utils = require("lib.utils")
-- Don't require minikanren_interface here to avoid circular dependency

local board = {}

-- Initialize a new chess board with pieces in starting positions
function board.new()
    local b = {}
    
    -- Initialize empty board
    for row = 1, 8 do
        b[row] = {}
        for col = 1, 8 do
            b[row][col] = nil
        end
    end
    
    -- Set up white pieces
    b[8][1] = "white_rook"
    b[8][2] = "white_knight"
    b[8][3] = "white_bishop"
    b[8][4] = "white_queen"
    b[8][5] = "white_king"
    b[8][6] = "white_bishop"
    b[8][7] = "white_knight"
    b[8][8] = "white_rook"
    
    for col = 1, 8 do
        b[7][col] = "white_pawn"
    end
    
    -- Set up black pieces
    b[1][1] = "black_rook"
    b[1][2] = "black_knight"
    b[1][3] = "black_bishop"
    b[1][4] = "black_queen"
    b[1][5] = "black_king"
    b[1][6] = "black_bishop"
    b[1][7] = "black_knight"
    b[1][8] = "black_rook"
    
    for col = 1, 8 do
        b[2][col] = "black_pawn"
    end
    
    -- Additional state information
    b.current_turn = "white"
    b.castling = {
        white_kingside = true,
        white_queenside = true,
        black_kingside = true,
        black_queenside = true
    }
    b.en_passant = nil
    
    return b
end

function board.current_turn(b)
    return b.current_turn
end

function board.move_piece(b, from_row, from_col, to_row, to_col)
    -- Save the piece being moved
    local piece = b[from_row][from_col]
    
    -- If no piece, return false
    if not piece then
        return false
    end
    
    -- Perform the move
    b[to_row][to_col] = piece
    b[from_row][from_col] = nil
    
    -- Switch turns
    if b.current_turn == "white" then
        b.current_turn = "black"
    else
        b.current_turn = "white"
    end
    
    return true
end

function board.is_game_over(b)
    -- For now, just a placeholder
    -- In a real implementation, check for checkmate, stalemate, etc.
    return false, ""
end

function board.get_valid_moves(board_state, from_row, from_col)
    local valid_moves = {}
    local piece = board_state[from_row][from_col]
    
    if not piece then
        return valid_moves
    end
    
    -- Check all possible board positions
    for to_row = 1, 8 do
        for to_col = 1, 8 do
            -- A move is valid if:
            -- 1. The destination is different from the start
            -- 2. Either empty or contains an enemy piece
            if (to_row ~= from_row or to_col ~= from_col) then
                local target = board_state[to_row][to_col]
                if not target or target:sub(1,5) ~= piece:sub(1,5) then
                    -- For now, allowing any move - we'll add proper piece movement rules later
                    table.insert(valid_moves, {to_row, to_col})
                end
            end
        end
    end
    
    return valid_moves
end

return board
