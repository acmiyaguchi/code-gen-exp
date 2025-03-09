local board = require("board")
local graphics = require("graphics")
local input = require("input")
local ai = require("ai")

-- Game state
local game_state = {
    board = nil,
    selected_piece = nil,
    highlighted_squares = {},
    ai_thinking = false,
    game_over = false,
    message = ""
}

function love.load()
    -- Initialize game board
    game_state.board = board.new()
    
    -- Load graphics assets
    graphics.load()
end

function love.update(dt)
    -- If it's the AI's turn (black) and the game is not over
    if not game_state.game_over and board.current_turn(game_state.board) == "black" and not game_state.ai_thinking then
        game_state.ai_thinking = true
        
        -- Use a small delay to make AI's move visible
        love.timer.delay(0.5, function()
            local from_row, from_col, to_row, to_col = ai.choose_move(game_state.board, 3)
            if from_row then
                -- Execute the AI's move
                board.move_piece(game_state.board, from_row, from_col, to_row, to_col)
                
                -- Check for game over
                local game_over, result = board.is_game_over(game_state.board)
                if game_over then
                    game_state.game_over = true
                    game_state.message = result
                end
            else
                -- AI couldn't find a move
                game_state.game_over = true
                game_state.message = "Stalemate"
            end
            
            game_state.ai_thinking = false
        end)
    end
end

function love.draw()
    -- Draw the chess board and pieces
    graphics.draw_board(game_state.board)
    
    -- Draw highlighted squares (selected piece, valid moves)
    graphics.draw_highlights(game_state.highlighted_squares)
    
    -- Display messages (check, checkmate, etc.)
    if game_state.message ~= "" then
        graphics.draw_message(game_state.message)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    -- Only process clicks if it's the player's turn and game is not over
    if game_state.game_over or board.current_turn(game_state.board) ~= "white" then
        return
    end
    
    if button == 1 then -- Left click
        -- Handle piece selection and movement
        local action, result = input.handle_mouse_click(x, y, game_state.board, game_state.selected_piece)
        
        if action == "select" then
            game_state.selected_piece = result
            game_state.highlighted_squares = input.get_highlighted_squares(game_state.board, result)
        elseif action == "move" then
            -- result contains from_row, from_col, to_row, to_col
            board.move_piece(game_state.board, result.from_row, result.from_col, result.to_row, result.to_col)
            
            -- Reset selection state
            game_state.selected_piece = nil
            game_state.highlighted_squares = {}
            
            -- Check for game over
            local game_over, result = board.is_game_over(game_state.board)
            if game_over then
                game_state.game_over = true
                game_state.message = result
            end
        elseif action == "deselect" then
            game_state.selected_piece = nil
            game_state.highlighted_squares = {}
        end
    end
end

function love.keyreleased(key)
    -- Reset the game when R is pressed
    if key == "r" then
        game_state.board = board.new()
        game_state.selected_piece = nil
        game_state.highlighted_squares = {}
        game_state.game_over = false
        game_state.message = ""
    elseif key == "escape" then
        love.event.quit()
    end
end
