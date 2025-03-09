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
    
    -- Check if move is valid using miniKanren
    local minikanren_interface = require("lib.minikanren_interface")
    if not minikanren_interface.is_valid_move(b, from_row, from_col, to_row, to_col) then
        return false
    end
    
    -- Special case: castling
    local piece_type = piece:match("_%a+$"):sub(2)
    if piece_type == "king" and math.abs(to_col - from_col) == 2 then
        -- This is a castling move
        local is_kingside = to_col > from_col
        local rook_col = is_kingside and 8 or 1
        local new_rook_col = is_kingside and 6 or 4
        
        -- Move the rook as well
        local rook = b[from_row][rook_col]
        b[from_row][new_rook_col] = rook
        b[from_row][rook_col] = nil
    end
    
    -- Special case: en passant
    if piece_type == "pawn" then
        -- Check if this is a double pawn move
        if math.abs(to_row - from_row) == 2 then
            -- Set en passant target square
            b.en_passant = {
                row = (from_row + to_row) / 2, -- Middle square
                col = from_col
            }
        elseif b.en_passant and to_row == b.en_passant.row and to_col == b.en_passant.col then
            -- This is an en passant capture
            local captured_row = from_row -- Same row as the capturing pawn
            local captured_col = to_col   -- Same column as the target square
            b[captured_row][captured_col] = nil
        else
            -- Clear en passant if it wasn't used
            b.en_passant = nil
        end
    else
        -- Clear en passant if not a pawn move
        b.en_passant = nil
    end
    
    -- Update castling rights
    if piece_type == "king" then
        if piece:sub(1,5) == "white" then
            b.castling.white_kingside = false
            b.castling.white_queenside = false
        else
            b.castling.black_kingside = false
            b.castling.black_queenside = false
        end
    elseif piece_type == "rook" then
        if from_row == 8 and from_col == 1 then
            b.castling.white_queenside = false
        elseif from_row == 8 and from_col == 8 then
            b.castling.white_kingside = false
        elseif from_row == 1 and from_col == 1 then
            b.castling.black_queenside = false
        elseif from_row == 1 and from_col == 8 then
            b.castling.black_kingside = false
        end
    end
    
    -- Check for pawn promotion
    if piece_type == "pawn" then
        if (piece:sub(1,5) == "white" and to_row == 1) or
           (piece:sub(1,5) == "black" and to_row == 8) then
            -- Automatically promote to queen for simplicity
            local color = piece:sub(1,5)
            piece = color .. "_queen"
        end
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
    local minikanren_interface = require("lib.minikanren_interface")
    return minikanren_interface.is_checkmate_or_stalemate(b)
end

-- Get a piece at the specified position
function board.get_piece(board_state, row, col)
    if row < 1 or row > 8 or col < 1 or col > 8 then
        return nil
    end
    
    local piece_str = board_state[row][col]
    if not piece_str then
        return nil
    end
    
    -- Convert string representation to piece object
    local color = piece_str:sub(1,5)
    local piece_type = piece_str:match("_%a+$"):sub(2)
    
    return {
        type = piece_type,
        color = color,
        row = row,
        col = col
    }
end

return board
