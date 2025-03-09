local ukanren = require("ukanren")
local pieces = require("pieces")
local utils = require("utils")

local minikanren_interface = {}

-- Convert board state to miniKanren format
function minikanren_interface.board_to_kanren(board_state)
    local kanren_board = {}
    
    -- Add piece positions
    for row = 1, 8 do
        for col = 1, 8 do
            local piece = board_state.squares[row][col].piece
            if piece then
                table.insert(kanren_board, {
                    type = piece.type,
                    color = piece.color,
                    row = row,
                    col = col,
                })
            end
        end
    end
    
    -- Add game state information
    kanren_board.turn = board_state.turn
    kanren_board.en_passant = board_state.en_passant
    kanren_board.castling = board_state.castling
    
    return kanren_board
end

-- Convert kanren result to a move
function minikanren_interface.kanren_to_move(kanren_result)
    -- Handle the format of moves from miniKanren
    -- This will depend on how moves are represented in your miniKanren constraints
    return {
        from_row = kanren_result.from_row,
        from_col = kanren_result.from_col,
        to_row = kanren_result.to_row,
        to_col = kanren_result.to_col
    }
end

-- Run a move query with miniKanren
local function run_move_query(query)
    local s_c = ukanren.empty_env
    local result = query(s_c)
    
    -- Process the result stream from miniKanren
    local moves = {}
    
    -- Helper function to extract results from the stream
    local function extract_results(stream)
        if stream == nil or stream == {} then
            return
        end
        
        if ukanren.is_pair(stream) then
            -- Process the current result
            local subst = ukanren.car(stream)
            if subst then
                table.insert(moves, subst)
            end
            -- Process the rest of the stream
            extract_results(ukanren.cdr(stream))
        elseif type(stream) == "function" then
            -- Delayed stream, force it
            extract_results(stream())
        end
    end
    
    extract_results(result)
    return moves
end

-- Check if a move is valid (using piece movement rules)
function minikanren_interface.is_valid_move(board_state, from_row, from_col, to_row, to_col, check_only)
    -- Simple bounds check
    if from_row < 1 or from_row > 8 or from_col < 1 or from_col > 8 or
       to_row < 1 or to_row > 8 or to_col < 1 or to_col > 8 then
        return false
    end
    
    -- Get the piece being moved
    local piece = board_state.squares[from_row][from_col].piece
    
    -- Make sure there is a piece to move and it belongs to the current player
    if not piece or (not check_only and piece.color ~= board_state.turn) then
        return false
    end
    
    -- Get the move function for this piece type
    local piece_type = pieces.get_piece_type(piece.type)
    if not piece_type or not piece_type.move_func then
        return false
    end
    
    -- Use the piece's move function to check if the move is valid
    local is_valid = piece_type.move_func(piece, board_state, from_row, from_col, to_row, to_col, check_only)
    
    -- If we're just checking for attack patterns (for check detection), don't check for check
    if check_only or not is_valid then
        return is_valid
    end
    
    -- If not check_only, also need to ensure move doesn't leave king in check
    local test_board = utils.deep_copy(board_state)
    
    -- Execute the move on the test board
    -- (Don't use board.move_piece here since it updates turn)
    local test_piece = test_board.squares[from_row][from_col].piece
    test_board.squares[from_row][from_col].piece = nil
    test_board.squares[to_row][to_col].piece = test_piece
    if test_piece then
        test_piece.row = to_row
        test_piece.col = to_col
    end
    
    -- Check if king is in check after the move
    local king_row, king_col
    local king_color = piece.color
    
    -- Find the king
    for r = 1, 8 do
        for c = 1, 8 do
            local p = test_board.squares[r][c].piece
            if p and p.type == "king" and p.color == king_color then
                king_row, king_col = r, c
                break
            end
        end
        if king_row then break end
    end
    
    if not king_row then
        -- King not found (shouldn't happen in a valid game)
        return false
    end
    
    -- Check if any opponent piece can attack the king
    local opponent_color = king_color == "white" and "black" or "white"
    for r = 1, 8 do
        for c = 1, 8 do
            local p = test_board.squares[r][c].piece
            if p and p.color == opponent_color then
                local piece_type = pieces.get_piece_type(p.type)
                if piece_type and piece_type.move_func(p, test_board, r, c, king_row, king_col, true) then
                    -- King is in check after the move
                    return false
                end
            end
        end
    end
    
    return true
end

-- Get all valid moves for a piece
function minikanren_interface.get_valid_moves(board_state, piece)
    local valid_moves = {}
    
    -- For each square on the board
    for to_row = 1, 8 do
        for to_col = 1, 8 do
            -- Check if the move is valid
            if minikanren_interface.is_valid_move(board_state, piece.row, piece.col, to_row, to_col) then
                table.insert(valid_moves, {
                    from_row = piece.row,
                    from_col = piece.col,
                    to_row = to_row,
                    to_col = to_col
                })
            end
        end
    end
    
    return valid_moves
end

-- Check if a square is under attack by a specific color
function minikanren_interface.is_square_attacked(board_state, row, col, attacker_color)
    for r = 1, 8 do
        for c = 1, 8 do
            local piece = board_state.squares[r][c].piece
            if piece and piece.color == attacker_color then
                if minikanren_interface.is_valid_move(board_state, r, c, row, col, true) then
                    return true
                end
            end
        end
    end
    return false
end

return minikanren_interface