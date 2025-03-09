local utils = require("utils")

local graphics = {}

-- Visual settings
local SQUARE_SIZE = 64  -- Size of each square in pixels
local BOARD_OFFSET_X = 50  -- Board position on screen
local BOARD_OFFSET_Y = 50
local BOARD_SIZE = SQUARE_SIZE * 8  -- Full board size

-- Colors
local COLORS = {
    white_square = {0.9, 0.9, 0.8},
    black_square = {0.5, 0.6, 0.4},
    highlight_select = {0.9, 0.9, 0.2, 0.7},
    highlight_move = {0.2, 0.9, 0.2, 0.7},
    highlight_check = {0.9, 0.2, 0.2, 0.7},
    text = {0.1, 0.1, 0.1}
}

-- Piece images
local piece_images = {}

-- Load piece images
function graphics.load()
    -- Load piece images
    local piece_types = {"pawn", "rook", "knight", "bishop", "queen", "king"}
    local colors = {"white", "black"}
    
    for _, color in ipairs(colors) do
        for _, piece_type in ipairs(piece_types) do
            local filename = "assets/pieces/" .. color .. "_" .. piece_type .. ".png"
            local image = love.graphics.newImage(filename)
            piece_images[color .. "_" .. piece_type] = image
        end
    end
end

-- Draw a chess piece
function graphics.draw_piece(piece, x, y)
    if not piece then return end
    
    local image = piece_images[piece.color .. "_" .. piece.type]
    if image then
        love.graphics.draw(image, x, y, 0, SQUARE_SIZE / image:getWidth(), SQUARE_SIZE / image:getHeight())
    else
        -- Fallback if image not found (should not happen)
        love.graphics.setColor(piece.color == "white" and {1, 1, 1} or {0, 0, 0})
        love.graphics.circle("fill", x + SQUARE_SIZE/2, y + SQUARE_SIZE/2, SQUARE_SIZE/3)
        love.graphics.setColor(1, 1, 1)
    end
end

-- Draw the chess board and pieces
function graphics.draw_board(board_state)
    -- Draw the board squares
    for row = 1, 8 do
        for col = 1, 8 do
            local x, y = utils.grid_to_pixels(row, col)
            
            -- Determine square color
            local is_light_square = (row + col) % 2 == 0
            if is_light_square then
                love.graphics.setColor(COLORS.white_square)
            else
                love.graphics.setColor(COLORS.black_square)
            end
            
            -- Draw square
            love.graphics.rectangle("fill", x, y, SQUARE_SIZE, SQUARE_SIZE)
            
            -- Draw piece if present
            love.graphics.setColor(1, 1, 1)
            local piece = board_state.squares[row][col].piece
            if piece then
                graphics.draw_piece(piece, x, y)
            end
        end
    end
    
    -- Draw board border
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("line", BOARD_OFFSET_X, BOARD_OFFSET_Y, BOARD_SIZE, BOARD_SIZE)
    
    -- Draw rank and file labels
    love.graphics.setColor(COLORS.text)
    for i = 1, 8 do
        -- Draw rank numbers (1-8) on the left
        love.graphics.print(9 - i, BOARD_OFFSET_X - 20, BOARD_OFFSET_Y + (i - 0.5) * SQUARE_SIZE - 10)
        
        -- Draw file letters (A-H) on the bottom
        love.graphics.print(string.char(64 + i), BOARD_OFFSET_X + (i - 0.5) * SQUARE_SIZE - 5, BOARD_OFFSET_Y + BOARD_SIZE + 10)
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
    
    -- Draw captured pieces
    graphics.draw_captured_pieces(board_state)
end

-- Draw captured pieces on the side of the board
function graphics.draw_captured_pieces(board_state)
    local white_x = BOARD_OFFSET_X + BOARD_SIZE + 20
    local white_y = BOARD_OFFSET_Y
    local black_x = BOARD_OFFSET_X + BOARD_SIZE + 20
    local black_y = BOARD_OFFSET_Y + BOARD_SIZE/2
    
    -- White's captured pieces
    for i, piece in ipairs(board_state.captured_pieces.white) do
        local col = (i - 1) % 8
        local row = math.floor((i - 1) / 8)
        local x = white_x + col * (SQUARE_SIZE / 2)
        local y = white_y + row * (SQUARE_SIZE / 2)
        
        -- Draw at half size
        local image = piece_images[piece.color .. "_" .. piece.type]
        if image then
            love.graphics.draw(image, x, y, 0, SQUARE_SIZE/2 / image:getWidth(), SQUARE_SIZE/2 / image:getHeight())
        end
    end
    
    -- Black's captured pieces
    for i, piece in ipairs(board_state.captured_pieces.black) do
        local col = (i - 1) % 8
        local row = math.floor((i - 1) / 8)
        local x = black_x + col * (SQUARE_SIZE / 2)
        local y = black_y + row * (SQUARE_SIZE / 2)
        
        -- Draw at half size
        local image = piece_images[piece.color .. "_" .. piece.type]
        if image then
            love.graphics.draw(image, x, y, 0, SQUARE_SIZE/2 / image:getWidth(), SQUARE_SIZE/2 / image:getHeight())
        end
    end
end

-- Draw highlighted squares (for selected piece and valid moves)
function graphics.draw_highlights(highlighted_squares)
    for _, highlight in ipairs(highlighted_squares) do
        local x, y = utils.grid_to_pixels(highlight.row, highlight.col)
        
        if highlight.type == "select" then
            love.graphics.setColor(COLORS.highlight_select)
        elseif highlight.type == "move" then
            love.graphics.setColor(COLORS.highlight_move)
        elseif highlight.type == "check" then
            love.graphics.setColor(COLORS.highlight_check)
        end
        
        love.graphics.rectangle("fill", x, y, SQUARE_SIZE, SQUARE_SIZE)
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

-- Draw a message on screen
function graphics.draw_message(message)
    local font = love.graphics.getFont()
    local text_width = font:getWidth(message)
    local text_height = font:getHeight()
    
    local x = (love.graphics.getWidth() - text_width) / 2
    local y = BOARD_OFFSET_Y + BOARD_SIZE + 40
    
    -- Draw background
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", x - 10, y - 5, text_width + 20, text_height + 10)
    
    -- Draw text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(message, x, y)
end

return graphics
