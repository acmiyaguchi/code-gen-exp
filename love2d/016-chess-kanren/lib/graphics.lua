local graphics = {}

-- Board dimensions
local BOARD_SIZE = 400
local SQUARE_SIZE = BOARD_SIZE / 8

-- Colors
local colors = {
    light_square = {0.9, 0.9, 0.8},
    dark_square = {0.5, 0.6, 0.4},
    white_piece = {1, 1, 1},
    black_piece = {0.1, 0.1, 0.1},
    highlight = {0.8, 0.8, 0.2, 0.5},
    selected = {0.2, 0.6, 1, 0.6},
    background = {0.2, 0.2, 0.2},
    text = {1, 1, 1}
}

-- Text-based representations for pieces
local piece_symbols = {
    ["white_pawn"] = "P",
    ["white_rook"] = "R",
    ["white_knight"] = "N",
    ["white_bishop"] = "B",
    ["white_queen"] = "Q",
    ["white_king"] = "K",
    ["black_pawn"] = "p",
    ["black_rook"] = "r",
    ["black_knight"] = "n",
    ["black_bishop"] = "b",
    ["black_queen"] = "q",
    ["black_king"] = "k"
}

-- Font for pieces
local piece_font

function graphics.load()
    -- Load a larger font for the chess pieces
    piece_font = love.graphics.newFont(36)
end

function graphics.draw_board(board)
    -- Draw the background
    love.graphics.setColor(colors.background)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Draw the chess board squares
    for row = 1, 8 do
        for col = 1, 8 do
            -- Alternate colors for squares
            if (row + col) % 2 == 0 then
                love.graphics.setColor(colors.light_square)
            else
                love.graphics.setColor(colors.dark_square)
            end
            
            local x = (col - 1) * SQUARE_SIZE
            local y = (row - 1) * SQUARE_SIZE
            love.graphics.rectangle("fill", x, y, SQUARE_SIZE, SQUARE_SIZE)
        end
    end
    
    -- Draw the pieces
    if board then  -- Check if board exists
        for row = 1, 8 do
            if board[row] then  -- Check if this row exists
                for col = 1, 8 do
                    local piece = board[row][col]
                    if piece then
                        graphics.draw_piece(piece, row, col)
                    end
                end
            end
        end
    end
    
    -- Draw border around the board
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("line", 0, 0, BOARD_SIZE, BOARD_SIZE)
    
    -- Draw coordinates
    love.graphics.setColor(colors.text)
    local small_font = love.graphics.getFont()
    
    for i = 1, 8 do
        -- Draw row numbers
        love.graphics.print(9-i, BOARD_SIZE + 5, (i-1) * SQUARE_SIZE + SQUARE_SIZE/2 - 8)
        
        -- Draw column letters
        love.graphics.print(string.char(96+i), (i-1) * SQUARE_SIZE + SQUARE_SIZE/2 - 4, BOARD_SIZE + 5)
    end
end

function graphics.draw_piece(piece, row, col)
    local x = (col - 1) * SQUARE_SIZE
    local y = (row - 1) * SQUARE_SIZE
    
    -- Set the color based on piece color
    if piece:sub(1, 5) == "white" then
        love.graphics.setColor(colors.white_piece)
    else
        love.graphics.setColor(colors.black_piece)
    end
    
    -- Draw the piece symbol
    local symbol = piece_symbols[piece]
    local previous_font = love.graphics.getFont()
    love.graphics.setFont(piece_font)
    love.graphics.print(symbol, x + SQUARE_SIZE/2 - 10, y + SQUARE_SIZE/2 - 18)
    love.graphics.setFont(previous_font)
end

function graphics.draw_highlights(highlights)
    for _, highlight in ipairs(highlights) do
        local row, col, highlight_type = highlight[1], highlight[2], highlight[3]
        local x = (col - 1) * SQUARE_SIZE
        local y = (row - 1) * SQUARE_SIZE
        
        if highlight_type == "selected" then
            love.graphics.setColor(colors.selected)
            love.graphics.rectangle("fill", x, y, SQUARE_SIZE, SQUARE_SIZE)
        elseif highlight_type == "move" then
            love.graphics.setColor(colors.highlight)
            love.graphics.rectangle("fill", x, y, SQUARE_SIZE, SQUARE_SIZE)
        elseif highlight_type == "capture" then
            love.graphics.setColor(1, 0.3, 0.3, 0.6)
            love.graphics.rectangle("fill", x, y, SQUARE_SIZE, SQUARE_SIZE)
        end
    end
end

function graphics.draw_message(message)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 50, BOARD_SIZE/2 - 30, BOARD_SIZE - 100, 60)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(message, 50, BOARD_SIZE/2 - 15, BOARD_SIZE - 100, "center")
    
    -- Add a hint about restarting the game
    love.graphics.printf("Press R to restart", 50, BOARD_SIZE/2 + 10, BOARD_SIZE - 100, "center")
end

function graphics.screen_to_board(x, y)
    -- Convert screen coordinates to board position
    if x < 0 or y < 0 or x > BOARD_SIZE or y > BOARD_SIZE then
        return nil
    end
    
    local col = math.floor(x / SQUARE_SIZE) + 1
    local row = math.floor(y / SQUARE_SIZE) + 1
    
    return row, col
end

return graphics
