
local UI = {}

-- Constants
UI.NAV_HEIGHT = 60
UI.BUBBLE_WIDTH = 800
UI.BUBBLE_PADDING = 20

-- Colors will be set in init()
UI.colors = {}

-- Fonts will be loaded in init()
UI.fonts = {}

function UI.init()
    -- Initialize colors
    UI.colors = {
        background = {0.1, 0.1, 0.15, 1.0},
        text = {0.9, 0.9, 0.9, 1.0},
        bubble = {0.2, 0.2, 0.25, 0.9},
        nav_bar = {0.15, 0.15, 0.2, 0.95},
        button = {0.3, 0.3, 0.4, 0.9},
        act = {0.25, 0.25, 0.35, 0.9},
        act_selected = {0.3, 0.3, 0.45, 0.9},
        scene = {0.2, 0.2, 0.3, 0.9}
    }
    
    -- Initialize fonts
    UI.fonts = {
        title = love.graphics.newFont(36),
        subtitle = love.graphics.newFont(24),
        normal = love.graphics.newFont(16),
        small = love.graphics.newFont(12),
        menu_act = love.graphics.newFont(18),
        menu_scene = love.graphics.newFont(16),
        button = love.graphics.newFont(16)
    }
end

-- Helper function to draw a rounded rectangle
function UI.draw_rounded_rect(x, y, width, height, color, radius)
    radius = radius or 10
    
    love.graphics.setColor(color)
    
    -- Draw the rectangle with rounded corners
    love.graphics.rectangle("fill", x + radius, y, width - 2 * radius, height)
    love.graphics.rectangle("fill", x, y + radius, width, height - 2 * radius)
    
    -- Draw the corner circles
    love.graphics.circle("fill", x + radius, y + radius, radius)
    love.graphics.circle("fill", x + width - radius, y + radius, radius)
    love.graphics.circle("fill", x + radius, y + height - radius, radius)
    love.graphics.circle("fill", x + width - radius, y + height - radius, radius)
end

-- Helper function to check if a point is inside a rectangle
function UI.is_point_in_rect(x, y, rect)
    return x >= rect.x and x <= rect.x + rect.width and
           y >= rect.y and y <= rect.y + rect.height
end

-- Helper function to calculate the height of wrapped text
function UI.calculate_text_height(text, font, width)
    local _, lines = font:getWrap(text, width)
    return #lines * font:getHeight()
end

return UI
