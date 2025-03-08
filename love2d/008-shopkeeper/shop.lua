local Shop = {}
Shop.__index = Shop

function Shop.new(items)
    local self = setmetatable({}, Shop)
    self.items = items or {}
    self.tab = "buy" -- "buy" or "sell"
    self.selectedItem = 1
    self.quantity = 1
    self.maxQuantity = 99
    self.closed = true
    self.message = ""
    self.messageTimer = 0
    return self
end

function Shop:open(playerRef)
    self.player = playerRef
    self.closed = false
    self.tab = "buy"
    self.selectedItem = 1
    self.quantity = 1
    self.message = "Welcome to my shop!"
    self.messageTimer = 3
end

function Shop:close()
    self.closed = true
end

function Shop:update(dt)
    -- Update message timer
    if self.messageTimer > 0 then
        self.messageTimer = self.messageTimer - dt
    end
end

function Shop:draw()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    -- Draw shop background
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", 50, 50, windowWidth - 100, windowHeight - 100)
    
    -- Draw border
    love.graphics.setColor(0.8, 0.7, 0.2)
    love.graphics.rectangle("line", 50, 50, windowWidth - 100, windowHeight - 100)
    
    -- Draw title
    love.graphics.setColor(1, 0.9, 0.4)
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.print("Shop", windowWidth/2 - 30, 70)
    love.graphics.setFont(love.graphics.newFont(14))
    
    -- Draw player gold
    love.graphics.print("Your Gold: " .. self.player.gold, 70, 70)
    
    -- Draw tabs
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.rectangle("fill", 70, 100, 100, 30)
    love.graphics.rectangle("fill", 180, 100, 100, 30)
    
    if self.tab == "buy" then
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setColor(0.8, 0.8, 0.8)
    end
    love.graphics.print("Buy", 105, 107)
    
    if self.tab == "sell" then
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setColor(0.8, 0.8, 0.8)
    end
    love.graphics.print("Sell", 215, 107)
    
    -- Draw items based on tab
    if self.tab == "buy" then
        self:drawBuyTab()
    else
        self:drawSellTab()
    end
    
    -- Draw message if active
    if self.messageTimer > 0 then
        love.graphics.setColor(1, 1, 0)
        love.graphics.printf(self.message, 100, windowHeight - 150, windowWidth - 200, "center")
    end
    
    -- Draw instructions
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("Arrow keys to navigate, SPACE to select, ESC to close", 70, windowHeight - 80)
end

function Shop:drawBuyTab()
    love.graphics.setColor(1, 1, 1)
    
    -- Draw column headers
    love.graphics.print("Item", 70, 150)
    love.graphics.print("Price", 320, 150)
    love.graphics.print("Description", 400, 150)
    
    -- Draw items
    for i, item in ipairs(self.items) do
        if i == self.selectedItem then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(1, 1, 1)
        end
        
        love.graphics.print(item.name, 70, 150 + i * 25)
        love.graphics.print(item.price, 320, 150 + i * 25)
        love.graphics.print(item.description, 400, 150 + i * 25)
    end
    
    -- Draw selected item details
    if #self.items > 0 and self.selectedItem <= #self.items then
        local item = self.items[self.selectedItem]
        local y = 350
        
        love.graphics.setColor(0.2, 0.8, 0.2)
        love.graphics.print("Selected: " .. item.name, 70, y)
        love.graphics.print("Quantity: " .. self.quantity, 70, y + 30)
        love.graphics.print("Total cost: " .. (item.price * self.quantity), 70, y + 60)
        
        -- Draw quantity adjustment
        love.graphics.print("[-] < " .. self.quantity .. " > [+]", 250, y + 30)
        
        -- Draw buy button
        love.graphics.setColor(0.2, 0.6, 0.2)
        love.graphics.rectangle("fill", 250, y + 60, 100, 30)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Buy", 285, y + 67)
    end
end

function Shop:drawSellTab()
    love.graphics.setColor(1, 1, 1)
    
    -- Draw column headers
    love.graphics.print("Item", 70, 150)
    love.graphics.print("Quantity", 320, 150)
    love.graphics.print("Value", 400, 150)
    
    -- Draw player inventory
    for i, item in ipairs(self.player.inventory) do
        if i == self.selectedItem then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(1, 1, 1)
        end
        
        love.graphics.print(item.name, 70, 150 + i * 25)
        love.graphics.print(item.quantity, 320, 150 + i * 25)
        
        -- Find item sell value (half of buy price)
        local value = 0
        for _, shopItem in ipairs(self.items) do
            if shopItem.name == item.name then
                value = math.floor(shopItem.price * 0.5)
                break
            end
        end
        
        love.graphics.print(value, 400, 150 + i * 25)
    end
    
    -- Draw selected item details
    if #self.player.inventory > 0 and self.selectedItem <= #self.player.inventory then
        local item = self.player.inventory[self.selectedItem]
        local y = 350
        
        -- Find item sell value
        local value = 0
        for _, shopItem in ipairs(self.items) do
            if shopItem.name == item.name then
                value = math.floor(shopItem.price * 0.5)
                break
            end
        end
        
        love.graphics.setColor(0.2, 0.8, 0.2)
        love.graphics.print("Selected: " .. item.name, 70, y)
        love.graphics.print("Quantity: " .. self.quantity .. " / " .. item.quantity, 70, y + 30)
        love.graphics.print("Total value: " .. (value * self.quantity), 70, y + 60)
        
        -- Draw quantity adjustment
        love.graphics.print("[-] < " .. self.quantity .. " > [+]", 250, y + 30)
        
        -- Draw sell button
        love.graphics.setColor(0.6, 0.2, 0.2)
        love.graphics.rectangle("fill", 250, y + 60, 100, 30)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Sell", 285, y + 67)
    end
end

function Shop:handleInput(key)
    if key == "escape" then
        self:close()
    elseif key == "tab" then
        if self.tab == "buy" then
            self.tab = "sell"
        else
            self.tab = "buy"
        end
        self.selectedItem = 1
        self.quantity = 1
    elseif key == "up" then
        self.selectedItem = math.max(1, self.selectedItem - 1)
        self.quantity = 1
    elseif key == "down" then
        if self.tab == "buy" then
            self.selectedItem = math.min(#self.items, self.selectedItem + 1)
        else
            self.selectedItem = math.min(#self.player.inventory, self.selectedItem + 1)
        end
        self.quantity = 1
    elseif key == "left" then
        self.quantity = math.max(1, self.quantity - 1)
    elseif key == "right" then
        local maxQ = self.maxQuantity
        
        if self.tab == "sell" and self.selectedItem <= #self.player.inventory then
            maxQ = self.player.inventory[self.selectedItem].quantity
        end
        
        self.quantity = math.min(maxQ, self.quantity + 1)
    elseif key == "space" or key == "return" then
        self:handleTransaction()
    end
end

function Shop:handleMouseClick(x, y, button)
    if button ~= 1 then return end
    
    -- Check for tab clicks
    if y >= 100 and y <= 130 then
        if x >= 70 and x <= 170 then
            self.tab = "buy"
            self.selectedItem = 1
            self.quantity = 1
        elseif x >= 180 and x <= 280 then
            self.tab = "sell"
            self.selectedItem = 1
            self.quantity = 1
        end
    end
    
    -- Check for item selection
    local startY = 175
    local itemCount
    if self.tab == "buy" then
        itemCount = #self.items
    else
        itemCount = #self.player.inventory
    end
    
    for i = 1, itemCount do
        if y >= startY + (i-1) * 25 and y <= startY + i * 25 then
            self.selectedItem = i
            self.quantity = 1
        end
    end
    
    -- Check for quantity buttons
    if y >= 380 and y <= 400 then
        if x >= 250 and x <= 270 then
            -- Decrease quantity
            self.quantity = math.max(1, self.quantity - 1)
        elseif x >= 295 and x <= 315 then
            -- Increase quantity
            local maxQ = self.maxQuantity
            if self.tab == "sell" and self.selectedItem <= #self.player.inventory then
                maxQ = self.player.inventory[self.selectedItem].quantity
            end
            self.quantity = math.min(maxQ, self.quantity + 1)
        end
    end
    
    -- Check for buy/sell button
    if y >= 410 and y <= 440 and x >= 250 and x <= 350 then
        self:handleTransaction()
    end
end

function Shop:handleTransaction()
    if self.tab == "buy" then
        if #self.items > 0 and self.selectedItem <= #self.items then
            local item = self.items[self.selectedItem]
            local success, message = shopkeeper:buyItem(item.name, self.quantity)
            
            self.message = message
            self.messageTimer = 3
        end
    else -- sell tab
        if #self.player.inventory > 0 and self.selectedItem <= #self.player.inventory then
            local item = self.player.inventory[self.selectedItem]
            local success, message = shopkeeper:sellItem(item.name, self.quantity)
            
            self.message = message
            self.messageTimer = 3
        end
    end
end

return Shop