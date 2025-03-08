local Shopkeeper = {}
Shopkeeper.__index = Shopkeeper

function Shopkeeper.new()
    local self = setmetatable({}, Shopkeeper)
    self.state = 'idle'
    self.timer = 0
    self.x = 200
    self.y = 200
    self.width = 32
    self.height = 64
    
    -- Personality traits
    self.name = "Harold"
    self.mood = "neutral" -- neutral, happy, angry
    self.greetingCount = 0
    
    -- Movement
    self.targetX = self.x
    self.targetY = self.y
    self.moveCooldown = 0
    
    -- Shop items with prices
    self.items = {
        {name = "Potion", price = 50, description = "Restores 50 HP"},
        {name = "Hi-Potion", price = 150, description = "Restores 150 HP"},
        {name = "Ether", price = 100, description = "Restores 30 MP"},
        {name = "Phoenix Down", price = 300, description = "Revives a fallen ally"},
        {name = "Antidote", price = 80, description = "Cures poison"},
        {name = "Bronze Sword", price = 450, description = "A basic sword"}
    }
    
    return self
end

function Shopkeeper:update(dt)
    self.timer = self.timer + dt
    
    -- Handle state-specific logic
    if self.state == 'idle' then
        self:idleUpdate(dt)
    elseif self.state == 'greeting' then
        self:greetingUpdate(dt)
    elseif self.state == 'browsing' then
        self:browsingUpdate(dt)
    elseif self.state == 'transaction' then
        self:transactionUpdate(dt)
    elseif self.state == 'angry' then
        self:angryUpdate(dt)
    end
    
    -- Check for player proximity
    if player then
        self:checkPlayerProximity()
    end
end

function Shopkeeper:draw()
    -- Draw shopkeeper based on state
    if self.state == 'idle' then
        love.graphics.setColor(0.5, 0.5, 0.5)
    elseif self.state == 'greeting' then
        love.graphics.setColor(0.2, 0.8, 0.2)
    elseif self.state == 'browsing' then
        love.graphics.setColor(0.2, 0.2, 0.8)
    elseif self.state == 'transaction' then
        love.graphics.setColor(0.8, 0.8, 0.2)
    elseif self.state == 'angry' then
        love.graphics.setColor(0.8, 0.2, 0.2)
    end
    
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw name
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.name, self.x, self.y - 20)
    
    -- Draw state indicator
    love.graphics.print(self.state, self.x, self.y + self.height + 5)
end

function Shopkeeper:idleUpdate(dt)
    -- Move around randomly within the shop area
    self.moveCooldown = self.moveCooldown - dt
    
    if self.moveCooldown <= 0 then
        -- Decide whether to move
        if math.random() < 0.05 then
            -- Choose a new destination within shop bounds
            self.targetX = 150 + math.random(250)
            self.targetY = 150 + math.random(150)
            self.moveCooldown = math.random(3, 8)
        end
    end
    
    -- Move towards target position
    local dx = self.targetX - self.x
    local dy = self.targetY - self.y
    local distance = math.sqrt(dx*dx + dy*dy)
    
    if distance > 5 then
        local speed = 30
        local nx = dx / distance
        local ny = dy / distance
        self.x = self.x + nx * speed * dt
        self.y = self.y + ny * speed * dt
    end
end

function Shopkeeper:greetingUpdate(dt)
    -- Look at player
    self.targetX = self.x
    self.targetY = self.y
end

function Shopkeeper:browsingUpdate(dt)
    -- Just wait while player is browsing
end

function Shopkeeper:transactionUpdate(dt)
    -- Handle transaction animation or behavior
    self.mood = "happy"
end

function Shopkeeper:angryUpdate(dt)
    -- Chase player or show anger
    self.mood = "angry"
end

function Shopkeeper:checkPlayerProximity()
    local distance = math.sqrt((self.x - player.x)^2 + (self.y - player.y)^2)
    local oldState = self.state
    
    if distance < 80 then
        if self.state == 'idle' then
            self.state = 'greeting'
            self.greetingCount = self.greetingCount + 1
        end
    else
        if self.state == 'greeting' then
            self.state = 'idle'
        end
    end
    
    -- If state changed, reset some behaviors
    if oldState ~= self.state then
        if self.state == 'greeting' then
            -- Make shopkeeper stop moving when greeting
            self.targetX = self.x
            self.targetY = self.y
        end
    end
end

function Shopkeeper:getGreetingDialogue()
    if self.greetingCount == 1 then
        return {
            {text = "Welcome to my shop, traveler! First time here?", speaker = self.name},
            {
                text = "What can I do for you today?",
                speaker = self.name,
                options = {
                    {text = "I'd like to see your wares.", nextState = "exit", action = "shop"},
                    {text = "Just looking around.", nextState = "exit"},
                    {text = "Who are you?", nextState = 3}
                }
            },
            {
                text = "I'm " .. self.name .. ", the owner of this humble shop. Been here for fifteen years selling the finest goods in town!",
                speaker = self.name,
                options = {
                    {text = "Show me what you're selling.", nextState = "exit", action = "shop"},
                    {text = "Good to meet you. I'll be on my way.", nextState = "exit"}
                }
            }
        }
    else
        return {
            {text = "Welcome back! What can I do for you today?", speaker = self.name},
            {
                text = "Need something?",
                speaker = self.name,
                options = {
                    {text = "Show me what you've got.", nextState = "exit", action = "shop"},
                    {text = "Just passing by.", nextState = "exit"},
                    {text = "Tell me about this place.", nextState = 3}
                }
            },
            {
                text = "This shop has been in my family for generations. We sell only the finest goods sourced from all over the realm!",
                speaker = self.name,
                options = {
                    {text = "I'd like to see your inventory.", nextState = "exit", action = "shop"},
                    {text = "Interesting. I'll be going now.", nextState = "exit"}
                }
            }
        }
    end
end

function Shopkeeper:buyItem(itemName, quantity)
    -- Find the requested item
    for _, item in ipairs(self.items) do
        if item.name == itemName then
            local totalCost = item.price * quantity
            
            if player.gold >= totalCost then
                -- Transaction successful
                player.gold = player.gold - totalCost
                
                -- Add item to player inventory
                local found = false
                for _, playerItem in ipairs(player.inventory) do
                    if playerItem.name == itemName then
                        playerItem.quantity = playerItem.quantity + quantity
                        found = true
                        break
                    end
                end
                
                if not found then
                    table.insert(player.inventory, {name = itemName, quantity = quantity})
                end
                
                self.state = "transaction"
                return true, "Thank you for your purchase!"
            else
                return false, "Sorry, you don't have enough gold."
            end
        end
    end
    
    return false, "I don't have that item."
end

function Shopkeeper:sellItem(itemName, quantity)
    -- Find the item in player inventory
    for i, playerItem in ipairs(player.inventory) do
        if playerItem.name == itemName then
            if playerItem.quantity >= quantity then
                -- Find item price
                local sellPrice = 0
                for _, item in ipairs(self.items) do
                    if item.name == itemName then
                        sellPrice = math.floor(item.price * 0.5) -- Sell at half price
                        break
                    end
                end
                
                -- Transaction successful
                player.gold = player.gold + (sellPrice * quantity)
                
                -- Remove item from player inventory
                playerItem.quantity = playerItem.quantity - quantity
                if playerItem.quantity <= 0 then
                    table.remove(player.inventory, i)
                end
                
                self.state = "transaction"
                return true, "Thank you for your business!"
            else
                return false, "You don't have that many."
            end
        end
    end
    
    return false, "You don't have that item."
end

return Shopkeeper
