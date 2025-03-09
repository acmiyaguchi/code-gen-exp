local input = {}
local graphics = require("lib.graphics")
local board = require("lib.board")
local minikanren_interface = require("lib.minikanren_interface")

function input.handle_mouse_click(x, y, chess_board, selected_piece)
    -- Convert screen position to board coordinates
    local row, col = graphics.screen_to_board(x, y)
    
    -- If click is outside the board
    if not row or not col then
        return "deselect"
    end
    
    -- If a piece is already selected
    if selected_piece then
        local from_row, from_col = selected_piece[1], selected_piece[2]
        
        -- Check if clicked on the same piece (deselect)
        if from_row == row and from_col == col then
            return "deselect"
        end
        
        -- Check if the move is valid using miniKanren
        if minikanren_interface.is_valid_move(chess_board, from_row, from_col, row, col) then
            return "move", {
                from_row = from_row,
                from_col = from_col,
                to_row = row,
                to_col = col
            }
        end
        
        -- Not a valid move, check if selecting another piece of same color
        local piece = chess_board[row][col]
        if piece and piece:sub(1, 5) == board.current_turn(chess_board) then
            return "select", {row, col}
        else
            return "deselect"
        end
    else
        -- No piece selected yet, check if selecting a piece of current turn
        local piece = chess_board[row][col]
        if piece and piece:sub(1, 5) == board.current_turn(chess_board) then
            return "select", {row, col}
        end
    end
    
    return "none"
end

function input.get_highlighted_squares(chess_board, selected_piece)
    if not selected_piece then
        return {}
    end
    
    local row, col = selected_piece[1], selected_piece[2]
    local highlights = {
        {row, col, "selected"}  -- Selected piece
    }
    
    -- Get valid moves using miniKanren
    local valid_moves = minikanren_interface.get_valid_moves(chess_board, {
        row = row,
        col = col
    })
    
    for _, move in ipairs(valid_moves) do
        local to_row, to_col = move.to_row, move.to_col
        if chess_board[to_row][to_col] then
            -- Capture move
            table.insert(highlights, {to_row, to_col, "capture"})
        else
            -- Regular move
            table.insert(highlights, {to_row, to_col, "move"})
        end
    end
    
    return highlights
end

return input
