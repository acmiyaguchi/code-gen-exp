local ukanren = require("lib.vendor.ukanren")
local pieces = require("lib.pieces")
local utils = require("lib.utils")

local minikanren_interface = {}

-- Check if a move is valid using simple rules first, then enhance with miniKanren later
function minikanren_interface.is_valid_move(board_state, from_row, from_col, to_row, to_col)
    -- Simple bounds check
    if from_row < 1 or from_row > 8 or from_col < 1 or from_col > 8 or
       to_row < 1 or to_row > 8 or to_col < 1 or to_col > 8 then
        return false
    end
    
    -- Get the piece being moved
    local piece = board_state[from_row][from_col]
    if not piece then return false end
    
    local piece_type = piece:match("_%a+$"):sub(2)
    local color = piece:sub(1,5)
    
    -- Get the target square
    local target = board_state[to_row][to_col]
    if target and target:sub(1,5) == color then
        return false  -- Can't capture own piece
    end
    
    -- Basic move validation based on piece type
    local piece_info = pieces.get_piece_type(piece_type)
    if not piece_info then return false end
    
    return piece_info.move_func({type = piece_type, color = color}, board_state, from_row, from_col, to_row, to_col)
end

-- Get all valid moves for a piece
function minikanren_interface.get_valid_moves(board_state, piece)
    local valid_moves = {}
    local from_row, from_col = piece.row, piece.col
    
    -- Check all possible squares
    for to_row = 1, 8 do
        for to_col = 1, 8 do
            if minikanren_interface.is_valid_move(board_state, from_row, from_col, to_row, to_col) then
                table.insert(valid_moves, {
                    to_row = to_row,
                    to_col = to_col
                })
            end
        end
    end
    
    return valid_moves
end

-- Placeholder functions for future miniKanren integration
minikanren_interface.board_to_kanren = function(board_state) return board_state end
minikanren_interface.kanren_to_move = function(result) return result end

return minikanren_interface