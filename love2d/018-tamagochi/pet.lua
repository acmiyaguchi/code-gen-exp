local Pet = {}
Pet.__index = Pet

-- Pet life stages
local STAGES = {
    EGG = 1,
    BABY = 2,
    CHILD = 3,
    TEEN = 4,
    ADULT = 5,
    ELDER = 6
}

-- Time for each stage (in seconds)
local STAGE_DURATION = {
    [STAGES.EGG] = 60,     -- 1 minute as egg
    [STAGES.BABY] = 300,   -- 5 minutes as baby
    [STAGES.CHILD] = 600,  -- 10 minutes as child
    [STAGES.TEEN] = 900,   -- 15 minutes as teen
    [STAGES.ADULT] = 1800, -- 30 minutes as adult
    [STAGES.ELDER] = 1200  -- 20 minutes as elder
}

-- Stat decay rates (per second)
local DECAY_RATES = {
    hunger = 0.05,
    happiness = 0.03,
    energy = 0.02,
    cleanliness = 0.04
}

function Pet.new(name)
    local self = setmetatable({}, Pet)
    
    self.name = name or "Tama"
    self.age = 0
    self.stage = STAGES.EGG
    self.stageTime = 0
    self.isDead = false
    self.isSick = false
    
    -- Stats
    self.health = 100
    self.hunger = 0 -- 0 is full, 100 is starving
    self.happiness = 100
    self.energy = 100
    self.cleanliness = 100
    
    -- Animation
    self.animations = {}
    self.currentAnim = "idle"
    self.frame = 1
    self.frameTimer = 0
    self.frameInterval = 0.2 -- seconds between frames
    
    return self
end

function Pet:update(dt)
    -- Update stage time and check for evolution
    self.stageTime = self.stageTime + dt
    self.age = self.age + dt
    self:checkEvolution()
    
    -- Update stats
    if not self.isDead then
        self:updateStats(dt)
        self:updateAnimation(dt)
    end
end

function Pet:updateStats(dt)
    -- Decay stats over time
    self.hunger = math.min(100, self.hunger + DECAY_RATES.hunger * dt)
    self.happiness = math.max(0, self.happiness - DECAY_RATES.happiness * dt)
    self.energy = math.max(0, self.energy - DECAY_RATES.energy * dt)
    self.cleanliness = math.max(0, self.cleanliness - DECAY_RATES.cleanliness * dt)
    
    -- Calculate health based on other stats
    local avgStats = (
        (100 - self.hunger) + 
        self.happiness + 
        self.energy + 
        self.cleanliness
    ) / 4
    
    self.health = avgStats
    
    -- Check for sickness
    if self.health < 30 and not self.isSick and math.random() < 0.001 * dt then
        self.isSick = true
    end
    
    -- Check for death
    if self.health <= 0 and not self.isDead then
        self:die()
    end
end

function Pet:updateAnimation(dt)
    -- Update frame timer
    self.frameTimer = self.frameTimer + dt
    if self.frameTimer >= self.frameInterval then
        self.frameTimer = 0
        self.frame = self.frame + 1
        
        -- Loop animation
        if self.animations[self.currentAnim] and 
           self.frame > #self.animations[self.currentAnim] then
            self.frame = 1
        end
    end
    
    -- Choose appropriate animation based on state
    if self.isDead then
        self.currentAnim = "dead"
    elseif self.isSick then
        self.currentAnim = "sick"
    elseif self.hunger > 80 then
        self.currentAnim = "hungry"
    elseif self.energy < 20 then
        self.currentAnim = "tired"
    elseif self.happiness < 20 then
        self.currentAnim = "sad"
    elseif self.cleanliness < 20 then
        self.currentAnim = "dirty"
    else
        self.currentAnim = "idle"
    end
end

function Pet:draw(x, y)
    love.graphics.push()
    love.graphics.translate(x, y)
    
    -- Draw pet sprite
    local sprite = self:getCurrentSprite()
    if sprite then
        love.graphics.draw(sprite, 0, 0)
    else
        -- Placeholder drawing if no sprite exists
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", -25, -25, 50, 50)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(self.stage, -5, -5)
    end
    
    love.graphics.pop()
end

function Pet:getCurrentSprite()
    if self.animations[self.currentAnim] then
        return self.animations[self.currentAnim][self.frame]
    end
    return nil
end

function Pet:checkEvolution()
    if self.stageTime >= STAGE_DURATION[self.stage] and self.stage < STAGES.ELDER then
        self:evolve()
    end
end

function Pet:evolve()
    self.stage = self.stage + 1
    self.stageTime = 0
    -- TODO: Play evolution animation/sound
    return self.stage
end

function Pet:feed()
    if self.isDead or self.stage == STAGES.EGG then return false end
    
    self.hunger = math.max(0, self.hunger - 30)
    self.energy = math.min(100, self.energy + 5)
    
    -- Too much food could make it dirty
    self.cleanliness = math.max(0, self.cleanliness - 5)
    
    return true
end

function Pet:play()
    if self.isDead or self.stage == STAGES.EGG then return false end
    
    self.happiness = math.min(100, self.happiness + 25)
    self.energy = math.max(0, self.energy - 10)
    self.hunger = math.min(100, self.hunger + 5)
    
    return true
end

function Pet:clean()
    if self.isDead or self.stage == STAGES.EGG then return false end
    
    self.cleanliness = 100
    self.happiness = math.max(0, self.happiness - 5) -- Pets don't usually like baths
    
    return true
end

function Pet:sleep()
    if self.isDead or self.stage == STAGES.EGG then return false end
    
    self.energy = 100
    self.hunger = math.min(100, self.hunger + 10) -- Gets hungry while sleeping
    
    return true
end

function Pet:medicine()
    if self.isDead or self.stage == STAGES.EGG then return false end
    
    if self.isSick then
        self.isSick = false
        self.health = math.min(100, self.health + 20)
        return true
    end
    
    return false
end

function Pet:die()
    self.isDead = true
    -- TODO: Play death animation/sound
end

function Pet:getSaveData()
    return {
        name = self.name,
        age = self.age,
        stage = self.stage,
        stageTime = self.stageTime,
        isDead = self.isDead,
        isSick = self.isSick,
        health = self.health,
        hunger = self.hunger,
        happiness = self.happiness,
        energy = self.energy,
        cleanliness = self.cleanliness
    }
end

function Pet.loadFromData(data)
    local pet = Pet.new(data.name)
    
    pet.age = data.age
    pet.stage = data.stage
    pet.stageTime = data.stageTime
    pet.isDead = data.isDead
    pet.isSick = data.isSick
    pet.health = data.health
    pet.hunger = data.hunger
    pet.happiness = data.happiness
    pet.energy = data.energy
    pet.cleanliness = data.cleanliness
    
    return pet
end

return Pet
