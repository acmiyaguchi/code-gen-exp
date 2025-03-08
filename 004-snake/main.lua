local snake = {}
local food = {}
local gridSize = 20
local boardWidth = 30
local boardHeight = 20
local direction = 'right'
local gameOver = false
local moveDelay = 0.1
local moveTimer = 0

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
        return
    end

    for _, segment in ipairs(snake) do
        love.graphics.rectangle('fill', (segment.x - 1) * gridSize, (segment.y - 1) * gridSize, gridSize, gridSize)
    end

    love.graphics.rectangle('fill', (food.x - 1) * gridSize, (food.y - 1) * gridSize, gridSize, gridSize)
end

function love.keypressed(key)
    if key == 'r' then
        resetGame()
    end
end