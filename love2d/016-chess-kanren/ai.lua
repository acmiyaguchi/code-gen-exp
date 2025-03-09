local board = require("board")
local minikanren = require("minikanren_interface")

local ai = {}

-- Piece values for board evaluation
local piece_values = {
    pawn = 1,
    knight = 3,
    bishop = 3,
    rook = 5,
    queen = 9,
    king = 0  -- King's value isn't used directly as losing it means game over
}

-- Position values for pieces (encourages better positioning)
local position_values = {
    -- Pawns are encouraged to advance
    pawn = {
        {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
        {0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5},
        {0.1, 0.1, 0.2, 0.3, 0.3, 0.2, 0.1, 0.1},
        {0.05, 0.05, 0.1, 0.25, 0.25, 0.1, 0.05, 0.05},
        {0.0, 0.0, 0.0, 0.2, 0.2, 0.0, 0.0, 0.0},
        {0.05, -0.05, -0.1, 0.0, 0.0, -0.1, -0.05, 0.05},
        {0.05, 0.1, 0.1, -0.2, -0.2, 0.1, 0.1, 0.05},
        {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0}
    },
    -- Knights prefer central positions
    knight = {
        {-0.5, -0.4, -0.3, -0.3, -0.3, -0.3, -0.4, -0.5},
        {-0.4, -0.2, 0.0, 0.0, 0.0, 0.0, -0.2, -0.4},
        {-0.3, 0.0, 0.1, 0.15, 0.15, 0.1, 0.0, -0.3},
        {-0.3, 0.05, 0.15, 0.2, 0.2, 0.15, 0.05, -0.3},
        {-0.3, 0.0, 0.15, 0.2, 0.2, 0.15, 0.0, -0.3},
        {-0.3, 0.05, 0.1, 0.15, 0.15, 0.1, 0.05, -0.3},
        {-0.4, -0.2, 0.0, 0.05, 0.05, 0.0, -0.2, -0.4},
        {-0.5, -0.4, -0.3, -0.3, -0.3, -0.3, -0.4, -0.5}
    },
    -- Bishops prefer diagonals and avoid corners
    bishop = {
        {-0.2, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, -0.2},
        {-0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.1},
        {-0.1, 0.0, 0.1, 0.1, 0.1, 0.1, 0.0, -0.1},
        {-0.1, 0.05, 0.1, 0.1, 0.1, 0.1, 0.05, -0.1},
        {-0.1, 0.0, 0.1, 0.1, 0.1, 0.1, 0.0, -0.1},
        {-0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, -0.1},
        {-0.1, 0.05, 0.0, 0.0, 0.0, 0.0, 0.05, -0.1},
        {-0.2, -0.1, -0.1, -0.1, -0.1, -0.1, -0.1, -0.2}
    },
    -- Rooks prefer open files and 7th rank
    rook = {
        {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
        {0.05, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.05},
        {-0.05, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.05},
        {-0.05, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.05},
        {-0.05, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.05},
        {-0.05, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.05},
        {-0.05, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.05},
        {0.0, 0.0, 0.0, 0.5, 0.5, 0.0, 0.0, 0.0}
    },
    -- Queens combine rook and bishop influence
    queen = {
        {-0.2, -0.1, -0.1, -0.05, -0.05, -0.1, -0.1, -0.2},
        {-0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.1},
        {-0.1, 0.0, 0.05, 0.05, 0.05, 0.05, 0.0, -0.1},
        {-0.05, 0.0, 0.05, 0.05, 0.05, 0.05, 0.0, -0.05},
        {0.0, 0.0, 0.05, 0.05, 0.05, 0.05, 0.0, -0.05},
        {-0.1, 0.05, 0.05, 0.05, 0.05, 0.05, 0.0, -0.1},
        {-0.1, 0.0, 0.05, 0.0, 0.0, 0.0, 0.0, -0.1},
        {-0.2, -0.1, -0.1, -0.05, -0.05, -0.1, -0.1, -0.2}
    },
    -- King prefers safety in early/mid game
    king = {
        {-0.3, -0.4, -0.4, -0.5, -0.5, -0.4, -0.4, -0.3},
        {-0.3, -0.4, -0.4, -0.5, -0.5, -0.4, -0.4, -0.3},
        {-0.3, -0.4, -0.4, -0.5, -0.5, -0.4, -0.4, -0.3},
        {-0.3, -0.4, -0.4, -0.5, -0.5, -0.4, -0.4, -0.3},
        {-0.2, -0.3, -0.3, -0.4, -0.4, -0.3, -0.3, -0.2},
        {-0.1, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.1},
        {0.2, 0.2, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2},
        {0.2, 0.3, 0.1, 0.0, 0.0, 0.1, 0.3, 0.2}
    }
}

-- Flip position table for black pieces
local function get_position_value(piece_type, color, row, col)
    if not position_values[piece_type] then return 0 end
    
    local table_row = row
    if color == "black" then
        -- Flip the row for black pieces
        table_row = 9 - row
    end
    
    return position_values[piece_type][table_row][col]
end

-- Evaluate the board state (higher is better for white, lower for black)
function ai.evaluate_board(board_state)
    local score = 0
    
    -- Count material and position value
    for row = 1, 8 do
        for col = 1, 8 do
            local piece = board_state.squares[row][col].piece
            if piece then
                local material_value = piece_values[piece.type] or 0
                local position_bonus = get_position_value(piece.type, piece.color, row, col)
                
                -- Add to score if white, subtract if black
                local value = material_value + position_bonus
                if piece.color == "white" then
                    score = score + value
                else
                    score = score - value
                end
            end
        end
    end
    
    -- Check for checkmate/stalemate
    local game_over, result = board.is_game_over(board_state)
    if game_over then
        if result:find("Checkmate") then
            if result:find("Black wins") then
                score = -1000  -- Black winning is bad for white (very negative)
            else
                score = 1000   -- White winning is good for white (very positive)
            end
        elseif result:find("Stalemate") or result:find("Draw") then
            -- Draw is neutral
            score = 0
        end
    end
    
    return score
end

-- Minimax algorithm with alpha-beta pruning
function ai.minimax(board_state, depth, alpha, beta, maximizing_player)
    -- Terminal conditions: depth = 0 or game is over
    if depth == 0 then
        return ai.evaluate_board(board_state), nil, nil, nil, nil
    end
    
    local game_over, result = board.is_game_over(board_state)
    if game_over then
        return ai.evaluate_board(board_state), nil, nil, nil, nil
    end
    
    -- Variables to track best move found
    local best_score, best_from_row, best_from_col, best_to_row, best_to_col
    
    -- Current player's color
    local current_color = board_state.turn
    
    if (maximizing_player and current_color == "white") or 
       (not maximizing_player and current_color == "black") then
        -- Maximizing player (White)
        best_score = -math.huge
        
        -- For each piece of the current player
        for from_row = 1, 8 do
            for from_col = 1, 8 do
                local piece = board_state.squares[from_row][from_col].piece
                if piece and piece.color == current_color then
                    -- Get all valid moves for this piece
                    local valid_moves = minikanren.get_valid_moves(board_state, piece)
                    
                    -- Try each move
                    for _, move in ipairs(valid_moves) do
                        local new_board = board.deep_copy(board_state)
                        board.move_piece(new_board, move.from_row, move.from_col, move.to_row, move.to_col)
                        
                        -- Recursive minimax call
                        local score = ai.minimax(new_board, depth - 1, alpha, beta, not maximizing_player)
                        
                        -- Update best score and move
                        if score > best_score then
                            best_score = score
                            best_from_row = move.from_row
                            best_from_col = move.from_col
                            best_to_row = move.to_row
                            best_to_col = move.to_col
                        end
                        
                        -- Alpha-beta pruning
                        alpha = math.max(alpha, best_score)
                        if beta <= alpha then
                            break
                        end
                    end
                end
            end
        end
    else
        -- Minimizing player (Black)
        best_score = math.huge
        
        -- For each piece of the current player
        for from_row = 1, 8 do
            for from_col = 1, 8 do
                local piece = board_state.squares[from_row][from_col].piece
                if piece and piece.color == current_color then
                    -- Get all valid moves for this piece
                    local valid_moves = minikanren.get_valid_moves(board_state, piece)
                    
                    -- Try each move
                    for _, move in ipairs(valid_moves) do
                        local new_board = board.deep_copy(board_state)
                        board.move_piece(new_board, move.from_row, move.from_col, move.to_row, move.to_col)
                        
                        -- Recursive minimax call
                        local score = ai.minimax(new_board, depth - 1, alpha, beta, not maximizing_player)
                        
                        -- Update best score and move
                        if score < best_score then
                            best_score = score
                            best_from_row = move.from_row
                            best_from_col = move.from_col
                            best_to_row = move.to_row
                            best_to_col = move.to_col
                        end
                        
                        -- Alpha-beta pruning
                        beta = math.min(beta, best_score)
                        if beta <= alpha then
                            break
                        end
                    end
                end
            end
        end
    end
    
    return best_score, best_from_row, best_from_col, best_to_row, best_to_col
end

-- Choose the best move for the current player
function ai.choose_move(board_state, depth)
    local current_color = board_state.turn
    local maximizing = current_color == "white"
    
    -- Call minimax to find the best move
    local _, from_row, from_col, to_row, to_col = ai.minimax(
        board_state, 
        depth, 
        -math.huge,  -- Alpha
        math.huge,   -- Beta
        maximizing
    )
    
    return from_row, from_col, to_row, to_col
end

return ai
