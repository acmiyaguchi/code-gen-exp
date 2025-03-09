local ukanren = require("lib.vendor.ukanren")
local pieces = require("lib.pieces")
local utils = require("lib.utils")

local minikanren_interface = {}

-- Check if a move is valid using simple rules first, then enhance with miniKanren later
function minikanren_interface.is_valid_move(board_state, from_row, from_col, to_row, to_col)
    -- Simple bounds check
    if from_row < 1 or from_row > 8 or from_col < 1 or from_col > 8 or
       to_row < 1 or to_row > 8 or to_col < 1 or to_col > 8 then
        return false
    end
    
    -- Get the piece being moved
    local piece = board_state[from_row][from_col]
    if not piece then return false end
    
    -- Create piece object
    local piece_obj = {
        type = piece:match("_%a+$"):sub(2),
        color = piece:sub(1,5),
        row = from_row,
        col = from_col
    }
    
    -- Check if it's this player's turn
    if piece_obj.color ~= board_state.current_turn then
        return false
    end
    
    -- Use pieces module for miniKanren-based validation
    local basic_valid = pieces.is_valid_move(piece_obj, board_state, from_row, from_col, to_row, to_col)
    
    -- If move is valid according to piece rules, make sure it doesn't cause check
    if basic_valid then
        return not minikanren_interface.move_causes_check(board_state, from_row, from_col, to_row, to_col)
    end
    
    return false
end

-- Get all valid moves for a piece
function minikanren_interface.get_valid_moves(board_state, piece)
    local valid_moves = {}
    local from_row, from_col = piece.row, piece.col
    
    -- Check all possible squares
    for to_row = 1, 8 do
        for to_col = 1, 8 do
            if minikanren_interface.is_valid_move(board_state, from_row, from_col, to_row, to_col) then
                table.insert(valid_moves, {
                    to_row = to_row,
                    to_col = to_col
                })
            end
        end
    end
    
    return valid_moves
end

-- Placeholder functions for future miniKanren integration
minikanren_interface.board_to_kanren = function(board_state) return board_state end
minikanren_interface.kanren_to_move = function(result) return result end

-- Evaluate a position using miniKanren constraints
function minikanren_interface.evaluate_position(board_state)
    local score = 0
    local piece_values = {
        pawn = 1,
        knight = 3,
        bishop = 3,
        rook = 5,
        queen = 9,
        king = 100
    }
    
    -- Create a miniKanren query to evaluate the position
    local query = function(s_c)
        local score_var = ukanren.var('score')
        local pieces_var = ukanren.var('pieces')
        
        -- Convert board to a list of pieces for miniKanren
        local pieces_list = {}
        for row = 1, 8 do
            for col = 1, 8 do
                local piece = board_state[row][col]
                if piece then
                    local piece_type = piece:match("_%a+$"):sub(2)
                    local color = piece:sub(1,5)
                    local value = piece_values[piece_type] or 0
                    table.insert(pieces_list, {
                        type = piece_type,
                        color = color,
                        value = value,
                        row = row,
                        col = col
                    })
                end
            end
        end
        
        -- Create a constraint that sums piece values
        return ukanren.conj(
            ukanren.eq(pieces_var, pieces_list),
            function(sc)
                local total = 0
                for _, piece in ipairs(pieces_list) do
                    if piece.color == "white" then
                        total = total + piece.value
                    else
                        total = total - piece.value
                    end
                end
                return ukanren.eq(score_var, total)(sc)
            end
        )(s_c)
    end
    
    -- Run the query and get the first result
    local result = query(ukanren.empty_env)
    if ukanren.is_pair(result) then
        local subst = ukanren.car(result)
        if subst then
            for k, v in pairs(subst) do
                if ukanren.is_var(k) and k[1] == 'score' then
                    return v
                end
            end
        end
    end
    return score
end

-- MiniKanren-based minimax calculation
function minikanren_interface.minimax_score(board_state, depth, alpha, beta, maximizing)
    if depth == 0 then
        return minikanren_interface.evaluate_position(board_state)
    end
    
    local color = maximizing and "white" or "black"
    local moves = {}
    
    -- Get all possible moves using miniKanren
    for row = 1, 8 do
        for col = 1, 8 do
            local piece = board_state[row][col]
            if piece and piece:sub(1,5) == color then
                local valid_moves = minikanren_interface.get_valid_moves(board_state, {
                    row = row,
                    col = col
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
    
    if maximizing then
        local max_eval = -math.huge
        for _, move in ipairs(moves) do
            local new_board = utils.deep_copy(board_state)
            new_board[move.to_row][move.to_col] = new_board[move.from_row][move.from_col]
            new_board[move.from_row][move.from_col] = nil
            
            local eval = minikanren_interface.minimax_score(new_board, depth - 1, alpha, beta, false)
            max_eval = math.max(max_eval, eval)
            alpha = math.max(alpha, eval)
            if beta <= alpha then break end
        end
        return max_eval
    else
        local min_eval = math.huge
        for _, move in ipairs(moves) do
            local new_board = utils.deep_copy(board_state)
            new_board[move.to_row][move.to_col] = new_board[move.from_row][move.from_col]
            new_board[move.from_row][move.from_col] = nil
            
            local eval = minikanren_interface.minimax_score(new_board, depth - 1, alpha, beta, true)
            min_eval = math.min(min_eval, eval)
            beta = math.min(beta, eval)
            if beta <= alpha then break end
        end
        return min_eval
    end
end

-- Check if the current player is in check
function minikanren_interface.is_in_check(board_state)
    local current_color = board_state.current_turn
    return pieces.is_in_check(board_state, current_color)
end

-- Check if a move would put or leave the player in check (illegal)
function minikanren_interface.move_causes_check(board_state, from_row, from_col, to_row, to_col)
    -- Make a copy of the board
    local test_board = utils.deep_copy(board_state)
    
    -- Execute the move temporarily
    local piece = test_board[from_row][from_col]
    test_board[to_row][to_col] = piece
    test_board[from_row][from_col] = nil
    
    -- Check if the player's king is in check after the move
    local piece_color = piece:sub(1,5)
    return pieces.is_in_check(test_board, piece_color)
end

-- Check if the game is in checkmate or stalemate
function minikanren_interface.is_checkmate_or_stalemate(board_state)
    local current_color = board_state.current_turn
    local in_check = pieces.is_in_check(board_state, current_color)
    
    -- Check if any legal moves exist
    local has_legal_moves = false
    
    for row = 1, 8 do
        for col = 1, 8 do
            local piece = board_state[row][col]
            if piece and piece:sub(1,5) == current_color then
                local piece_obj = {
                    type = piece:match("_%a+$"):sub(2),
                    color = current_color,
                    row = row,
                    col = col
                }
                
                -- Check potential moves for this piece
                for to_row = 1, 8 do
                    for to_col = 1, 8 do
                        if row ~= to_row or col ~= to_col then
                            if pieces.is_valid_move(piece_obj, board_state, row, col, to_row, to_col) then
                                -- Check if move leaves king in check
                                if not minikanren_interface.move_causes_check(board_state, row, col, to_row, to_col) then
                                    has_legal_moves = true
                                    break
                                end
                            end
                        end
                    end
                    if has_legal_moves then break end
                end
            end
            if has_legal_moves then break end
        end
        if has_legal_moves then break end
    end
    
    if not has_legal_moves then
        if in_check then
            return true, current_color == "white" and "Black wins by checkmate!" or "White wins by checkmate!"
        else
            return true, "Stalemate! The game is a draw."
        end
    end
    
    return false, ""
end

return minikanren_interface