local board = require("board")
local utils = require("utils")

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
    local score = 0
    
    -- Count material
    for row = 1, 8 do
        for col = 1, 8 do
            local piece = board.get_piece(board_state, row, col)
            if piece then
                local value = piece_values[piece.type] or 0
                if piece.color == "white" then
                    score = score + value
                else
                    score = score - value
                end
            end
        end
    end
    
    -- Higher score is better for white, lower for black
    return score
end

-- Get all legal moves for a given color
function ai.get_all_legal_moves(board_state, color)
    local moves = {}
    
    for row = 1, 8 do
        for col = 1, 8 do
            local piece = board.get_piece(board_state, row, col)
            if piece and piece.color == color then
                local piece_moves = board.get_valid_moves(board_state, row, col)
                for _, move in ipairs(piece_moves) do
                    table.insert(moves, {
                        from_row = row,
                        from_col = col,
                        to_row = move.row,
                        to_col = move.col
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
function ai.choose_move(board, depth)
    -- Simple AI that makes random legal moves
    -- For a real chess AI, you'd implement minimax with alpha-beta pruning
    
    local possible_moves = {}
    
    -- Find all pieces of the current player
    for from_row = 1, 8 do
        for from_col = 1, 8 do
            local piece = board[from_row][from_col]
            if piece and piece:sub(1, 5) == "black" then
                -- Find all possible destinations
                for to_row = 1, 8 do
                    for to_col = 1, 8 do
                        local target = board[to_row][to_col]
                        if not target or target:sub(1, 5) == "white" then
                            -- In a real chess game, you'd validate moves based on piece type
                            -- For now, any move to an empty square or enemy piece is considered valid
                            table.insert(possible_moves, {from_row, from_col, to_row, to_col})
                        end
                    end
                end
            end
        end
    end
    
    -- Choose a random move
    if #possible_moves > 0 then
        local move = possible_moves[math.random(#possible_moves)]
        return move[1], move[2], move[3], move[4]
    else
        -- No moves available
        return nil
    end
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
