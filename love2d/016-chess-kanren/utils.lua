local utils = {}

-- Square size constant for conversions
local SQUARE_SIZE = 64
local BOARD_OFFSET_X = 50
local BOARD_OFFSET_Y = 50

-- Convert grid coordinates to pixel coordinates
function utils.grid_to_pixels(row, col)
    local x = BOARD_OFFSET_X + (col - 1) * SQUARE_SIZE
    local y = BOARD_OFFSET_Y + (8 - row) * SQUARE_SIZE
    return x, y
end

-- Convert pixel coordinates to grid coordinates
function utils.pixels_to_grid(x, y)
    local col = math.floor((x - BOARD_OFFSET_X) / SQUARE_SIZE) + 1
    local row = 8 - math.floor((y - BOARD_OFFSET_Y) / SQUARE_SIZE)
    
    -- Check if coordinates are inside the board
    if row >= 1 and row <= 8 and col >= 1 and col <= 8 then
        return row, col
    else
        return nil, nil
    end
end

-- Convert algebraic notation to grid coordinates
function utils.algebraic_to_grid(notation)
    if type(notation) ~= "string" or #notation ~= 2 then
        return nil, nil
    end
    
    local col = string.byte(notation:sub(1, 1)) - string.byte('a') + 1
    local row = tonumber(notation:sub(2, 2))
    
    if row >= 1 and row <= 8 and col >= 1 and col <= 8 then
        return row, col
    else
        return nil, nil
    end
end

-- Convert grid coordinates to algebraic notation
function utils.grid_to_algebraic(row, col)
    if row >= 1 and row <= 8 and col >= 1 and col <= 8 then
        local file = string.char(string.byte('a') + col - 1)
        return file .. tostring(row)
    else
        return nil
    end
end

-- Deep copy a table
function utils.deep_copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[utils.deep_copy(orig_key)] = utils.deep_copy(orig_value)
        end
        setmetatable(copy, utils.deep_copy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

return utils
