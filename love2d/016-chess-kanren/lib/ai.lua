local board = require("lib.board")
local utils = require("lib.utils")
local minikanren_interface = require("lib.minikanren_interface")

local ai = {}

-- Piece values for evaluation
local piece_values = {
    pawn = 1,
    knight = 3,
    bishop = 3,
    rook = 5,
    queen = 9,
    king = 100
}

-- Simple board evaluation function
function ai.evaluate_board(board_state)
    local kanren_board = minikanren_interface.board_to_kanren(board_state)
    return minikanren_interface.evaluate_position(kanren_board)
end

-- Get all legal moves for a given color using miniKanren
function ai.get_all_legal_moves(board_state, color)
    local moves = {}
    
    for row = 1, 8 do
        for col = 1, 8 do
            local piece = board_state[row][col]
            if piece and piece:sub(1,5) == color then
                local valid_moves = minikanren_interface.get_valid_moves(board_state, {
                    row = row,
                    col = col,
                    type = piece:match("_%a+$"):sub(2),
                    color = color
                })
                
                for _, move in ipairs(valid_moves) do
                    table.insert(moves, {
                        from_row = row,
                        from_col = col,
                        to_row = move.to_row,
                        to_col = move.to_col
                    })
                end
            end
        end
    end
    
    return moves
end

-- Simple minimax with alpha-beta pruning
function ai.minimax(board_state, depth, alpha, beta, maximizing_player)
    if depth == 0 then
        return ai.evaluate_board(board_state)
    end
    
    local color = maximizing_player and "white" or "black"
    local moves = ai.get_all_legal_moves(board_state, color)
    
    if #moves == 0 then
        -- No moves available - could be checkmate or stalemate
        return maximizing_player and -1000 or 1000
    end
    
    if maximizing_player then
        local max_eval = -math.huge
        for _, move in ipairs(moves) do
            -- Make a copy of the board to simulate the move
            local new_board = utils.deep_copy(board_state)
            board.move_piece(new_board, move.from_row, move.from_col, move.to_row, move.to_col)
            
            local eval = ai.minimax(new_board, depth - 1, alpha, beta, false)
            max_eval = math.max(max_eval, eval)
            alpha = math.max(alpha, eval)
            if beta <= alpha then break end
        end
        return max_eval
    else
        local min_eval = math.huge
        for _, move in ipairs(moves) do
            -- Make a copy of the board to simulate the move
            local new_board = utils.deep_copy(board_state)
            board.move_piece(new_board, move.from_row, move.from_col, move.to_row, move.to_col)
            
            local eval = ai.minimax(new_board, depth - 1, alpha, beta, true)
            min_eval = math.min(min_eval, eval)
            beta = math.min(beta, eval)
            if beta <= alpha then break end
        end
        return min_eval
    end
end

-- Choose the best move for the AI
function ai.choose_move(board_state, depth)
    local moves = ai.get_all_legal_moves(board_state, "black")
    if #moves == 0 then return nil end
    
    -- Use miniKanren to evaluate moves
    local best_move = nil
    local best_score = math.huge
    
    for _, move in ipairs(moves) do
        local new_board = utils.deep_copy(board_state)
        board.move_piece(new_board, move.from_row, move.from_col, move.to_row, move.to_col)
        
        local score = minikanren_interface.minimax_score(new_board, depth - 1, -math.huge, math.huge, true)
        if score < best_score then
            best_score = score
            best_move = move
        end
    end
    
    if best_move then
        return best_move.from_row, best_move.from_col, best_move.to_row, best_move.to_col
    end
    return nil
end

function ai.copy_board(chess_board)
    local copy = {}
    
    -- Copy board array
    for i = 1, 8 do
        copy[i] = {}
        for j = 1, 8 do
            copy[i][j] = chess_board[i][j]
        end
    end
    
    -- Copy metadata
    copy.turn = chess_board.turn
    
    -- Copy move history
    copy.move_history = {}
    for i, move in ipairs(chess_board.move_history) do
        copy.move_history[i] = {
            piece = move.piece,
            from_row = move.from_row,
            from_col = move.from_col,
            to_row = move.to_row,
            to_col = move.to_col
        }
    end
    
    return copy
end

return ai
