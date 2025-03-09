local utils = require("utils")
local minikanren = require("minikanren_interface")

local input = {}

-- Handle mouse click on the chess board
function input.handle_mouse_click(x, y, board_state, selected_piece)
    -- Convert screen coordinates to board grid
    local row, col = utils.pixels_to_grid(x, y)
    
    -- Check if click is within board boundaries
    if not row or not col then
        return "invalid", nil
    end
    
    -- Get the piece at the clicked position
    local clicked_piece = board_state.squares[row][col].piece
    
    -- If a piece is already selected
    if selected_piece then
        -- If clicking on the selected piece again, deselect it
        if selected_piece.row == row and selected_piece.col == col then
            return "deselect", nil
        end
        
        -- If clicking on another piece of the same color, select that piece instead
        if clicked_piece and clicked_piece.color == selected_piece.color then
            return "select", clicked_piece
        end
        
        -- Check if the move to the clicked square is valid
        if minikanren.is_valid_move(
            board_state, 
            selected_piece.row, 
            selected_piece.col, 
            row, 
            col
        ) then
            -- Return the move
            return "move", {
                from_row = selected_piece.row,
                from_col = selected_piece.col,
                to_row = row,
                to_col = col
            }
        else
            -- Invalid move, deselect
            return "deselect", nil
        end
    else
        -- No piece selected yet
        if clicked_piece and clicked_piece.color == board_state.turn then
            -- Select the piece
            return "select", clicked_piece
        end
    end
    
    return "invalid", nil
end

-- Get squares to highlight based on selected piece
function input.get_highlighted_squares(board_state, selected_piece)
    local highlights = {}
    
    -- If no piece is selected, nothing to highlight
    if not selected_piece then
        return highlights
    end
    
    -- Highlight the selected piece
    table.insert(highlights, {
        row = selected_piece.row,
        col = selected_piece.col,
        type = "select"
    })
    
    -- Get all valid moves for the selected piece
    local valid_moves = minikanren.get_valid_moves(board_state, selected_piece)
    
    -- Add highlights for valid moves
    for _, move in ipairs(valid_moves) do
        table.insert(highlights, {
            row = move.to_row,
            col = move.to_col,
            type = "move"
        })
    end
    
    -- Highlight the king if in check
    local is_in_check = board.is_in_check(board_state)
    if is_in_check then
        local king_color = board_state.turn
        
        -- Find the king
        for row = 1, 8 do
            for col = 1, 8 do
                local piece = board_state.squares[row][col].piece
                if piece and piece.type == "king" and piece.color == king_color then
                    table.insert(highlights, {
                        row = row,
                        col = col,
                        type = "check"
                    })
                    break
                end
            end
        end
    end
    
    return highlights
end

return input
