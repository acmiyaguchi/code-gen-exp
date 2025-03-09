local utils = {}

-- Visual settings (should match graphics.lua)
local SQUARE_SIZE = 64  -- Size of each square in pixels
local BOARD_OFFSET_X = 50  -- Board position on screen
local BOARD_OFFSET_Y = 50

-- Convert chess grid coordinates (row, col) to screen pixels (x, y)
function utils.grid_to_pixels(row, col)
    local x = BOARD_OFFSET_X + (col - 1) * SQUARE_SIZE
    local y = BOARD_OFFSET_Y + (row - 1) * SQUARE_SIZE
    return x, y
end

-- Convert screen pixels (x, y) to chess grid coordinates (row, col)
function utils.pixels_to_grid(x, y)
    -- Check if click is within board boundaries
    if x < BOARD_OFFSET_X or x >= BOARD_OFFSET_X + 8 * SQUARE_SIZE or
       y < BOARD_OFFSET_Y or y >= BOARD_OFFSET_Y + 8 * SQUARE_SIZE then
        return nil, nil
    end
    
    local col = math.floor((x - BOARD_OFFSET_X) / SQUARE_SIZE) + 1
    local row = math.floor((y - BOARD_OFFSET_Y) / SQUARE_SIZE) + 1
    
    return row, col
end

-- Create a deep copy of a table
function utils.deep_copy(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do res[utils.deep_copy(k)] = utils.deep_copy(v) end
    return res
end

-- Format a chess move in algebraic notation
function utils.move_to_algebraic(from_row, from_col, to_row, to_col, piece_type, is_capture)
    local files = "abcdefgh"
    local from_file = files:sub(from_col, from_col)
    local from_rank = 9 - from_row
    local to_file = files:sub(to_col, to_col)
    local to_rank = 9 - to_row
    
    if piece_type == "pawn" then
        if is_capture then
            return from_file .. "x" .. to_file .. to_rank
        else
            return to_file .. to_rank
        end
    else
        local piece_symbols = {
            knight = "N",
            bishop = "B",
            rook = "R",
            queen = "Q",
            king = "K"
        }
        
        local piece_symbol = piece_symbols[piece_type] or ""
        if is_capture then
            return piece_symbol .. "x" .. to_file .. to_rank
        else
            return piece_symbol .. to_file .. to_rank
        end
    end
end

-- Format time in MM:SS format
function utils.format_time(seconds)
    local minutes = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d", minutes, secs)
end

return utils
