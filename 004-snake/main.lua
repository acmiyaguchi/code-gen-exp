local snake = {}
local food = {}
local gridSize = 20
local boardWidth = 30
local boardHeight = 20
local direction = 'right'
local gameOver = false
local moveDelay = 0.1
local moveTimer = 0
local score = 0
local highScore = 0
local leaderboard = {}
local playerName = ""
local enteringName = false

function love.load()
    love.window.setMode(boardWidth * gridSize, boardHeight * gridSize)
    resetGame()
end

function resetGame()
    snake = {
        {x = 5, y = 5},
        {x = 4, y = 5},
        {x = 3, y = 5}
    }
    direction = 'right'
    gameOver = false
    score = 0
    playerName = ""
    enteringName = false
    placeFood()
end

function placeFood()
    food.x = love.math.random(1, boardWidth)
    food.y = love.math.random(1, boardHeight)
end

function love.update(dt)
    if gameOver then
        return
    end

    moveTimer = moveTimer + dt
    if moveTimer >= moveDelay then
        moveTimer = moveTimer - moveDelay

        if love.keyboard.isDown('up') and direction ~= 'down' then
            direction = 'up'
        elseif love.keyboard.isDown('down') and direction ~= 'up' then
            direction = 'down'
        elseif love.keyboard.isDown('left') and direction ~= 'right' then
            direction = 'left'
        elseif love.keyboard.isDown('right') and direction ~= 'left' then
            direction = 'right'
        end

        moveSnake()
        checkCollision()
    end
end

function moveSnake()
    local head = {x = snake[1].x, y = snake[1].y}

    if direction == 'up' then
        head.y = head.y - 1
    elseif direction == 'down' then
        head.y = head.y + 1
    elseif direction == 'left' then
        head.x = head.x - 1
    elseif direction == 'right' then
        head.x = head.x + 1
    end

    table.insert(snake, 1, head)

    if head.x == food.x and head.y == food.y then
        placeFood()
        score = score + 1
        if score > highScore then
            highScore = score
        end
    else
        table.remove(snake)
    end
end

function checkCollision()
    local head = snake[1]

    if head.x < 1 or head.x > boardWidth or head.y < 1 or head.y > boardHeight then
        gameOver = true
    end

    for i = 2, #snake do
        if head.x == snake[i].x and head.y == snake[i].y then
            gameOver = true
        end
    end
end

function love.draw()
    if gameOver then
        love.graphics.print("Game Over! Press R to restart", 10, 10)
        love.graphics.print("High Score: " .. highScore, 10, 30)
        if enteringName then
            love.graphics.print("Enter your name: " .. playerName, 10, 50)
        else
            love.graphics.print("Press N to enter your name", 10, 50)
        end
        drawLeaderboard()
        return
    end

    for _, segment in ipairs(snake) do
        love.graphics.rectangle('fill', (segment.x - 1) * gridSize, (segment.y - 1) * gridSize, gridSize, gridSize)
    end

    love.graphics.rectangle('fill', (food.x - 1) * gridSize, (food.y - 1) * gridSize, gridSize, gridSize)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("High Score: " .. highScore, 10, 30)
end

function drawLeaderboard()
    love.graphics.print("Leaderboard:", 10, 70)
    for i, entry in ipairs(leaderboard) do
        love.graphics.print(i .. ". " .. entry.name .. ": " .. entry.score, 10, 70 + i * 20)
    end
end

function love.keypressed(key)
    if key == 'r' then
        resetGame()
    elseif key == 'n' and gameOver and not enteringName then
        enteringName = true
    elseif enteringName then
        if key == 'backspace' then
            playerName = playerName:sub(1, -2)
        elseif key == 'return' then
            table.insert(leaderboard, {name = playerName, score = score})
            table.sort(leaderboard, function(a, b) return a.score > b.score end)
            enteringName = false
        else
            playerName = playerName .. key
        end
    end
end