-- Nursery Songs Player
-- Plays three classic nursery songs with a simple UI

-- Define frequencies for musical notes (A4 = 440Hz reference)
local notes = {
  C4 = 261.63,
  D4 = 293.66,
  E4 = 329.63,
  F4 = 349.23,
  G4 = 392.00,
  A4 = 440.00,
  B4 = 493.88,
  C5 = 523.25,
  D5 = 587.33,
  E5 = 659.25,
  F5 = 698.46,
  G5 = 783.99,
  A5 = 880.00,
  REST = 0
}

-- Define songs with note sequences and durations
local songs = {
  {
    title = "Mary Had a Little Lamb",
    notes = {
      {note = "E4", duration = 0.5}, {note = "D4", duration = 0.5}, {note = "C4", duration = 0.5}, {note = "D4", duration = 0.5},
      {note = "E4", duration = 0.5}, {note = "E4", duration = 0.5}, {note = "E4", duration = 1.0},
      {note = "D4", duration = 0.5}, {note = "D4", duration = 0.5}, {note = "D4", duration = 1.0},
      {note = "E4", duration = 0.5}, {note = "G4", duration = 0.5}, {note = "G4", duration = 1.0},
      {note = "E4", duration = 0.5}, {note = "D4", duration = 0.5}, {note = "C4", duration = 0.5}, {note = "D4", duration = 0.5},
      {note = "E4", duration = 0.5}, {note = "E4", duration = 0.5}, {note = "E4", duration = 0.5}, {note = "E4", duration = 0.5},
      {note = "D4", duration = 0.5}, {note = "D4", duration = 0.5}, {note = "E4", duration = 0.5}, {note = "D4", duration = 0.5},
      {note = "C4", duration = 1.0}
    }
  },
  {
    title = "Twinkle Twinkle Little Star",
    notes = {
      {note = "C4", duration = 0.5}, {note = "C4", duration = 0.5}, {note = "G4", duration = 0.5}, {note = "G4", duration = 0.5},
      {note = "A4", duration = 0.5}, {note = "A4", duration = 0.5}, {note = "G4", duration = 1.0},
      {note = "F4", duration = 0.5}, {note = "F4", duration = 0.5}, {note = "E4", duration = 0.5}, {note = "E4", duration = 0.5},
      {note = "D4", duration = 0.5}, {note = "D4", duration = 0.5}, {note = "C4", duration = 1.0},
      {note = "G4", duration = 0.5}, {note = "G4", duration = 0.5}, {note = "F4", duration = 0.5}, {note = "F4", duration = 0.5},
      {note = "E4", duration = 0.5}, {note = "E4", duration = 0.5}, {note = "D4", duration = 1.0},
      {note = "G4", duration = 0.5}, {note = "G4", duration = 0.5}, {note = "F4", duration = 0.5}, {note = "F4", duration = 0.5},
      {note = "E4", duration = 0.5}, {note = "E4", duration = 0.5}, {note = "D4", duration = 1.0},
      {note = "C4", duration = 0.5}, {note = "C4", duration = 0.5}, {note = "G4", duration = 0.5}, {note = "G4", duration = 0.5},
      {note = "A4", duration = 0.5}, {note = "A4", duration = 0.5}, {note = "G4", duration = 1.0},
      {note = "F4", duration = 0.5}, {note = "F4", duration = 0.5}, {note = "E4", duration = 0.5}, {note = "E4", duration = 0.5},
      {note = "D4", duration = 0.5}, {note = "D4", duration = 0.5}, {note = "C4", duration = 1.0}
    }
  },
  {
    title = "London Bridge",
    notes = {
      {note = "G4", duration = 0.75}, {note = "A4", duration = 0.25}, {note = "G4", duration = 0.5}, {note = "F4", duration = 0.5},
      {note = "E4", duration = 0.5}, {note = "F4", duration = 0.5}, {note = "G4", duration = 1.0},
      {note = "D4", duration = 0.5}, {note = "E4", duration = 0.5}, {note = "F4", duration = 1.0},
      {note = "E4", duration = 0.5}, {note = "F4", duration = 0.5}, {note = "G4", duration = 1.0},
      {note = "G4", duration = 0.75}, {note = "A4", duration = 0.25}, {note = "G4", duration = 0.5}, {note = "F4", duration = 0.5},
      {note = "E4", duration = 0.5}, {note = "F4", duration = 0.5}, {note = "G4", duration = 1.0},
      {note = "D4", duration = 0.5}, {note = "G4", duration = 0.5}, {note = "E4", duration = 0.5}, {note = "C4", duration = 1.5}
    }
  }
}

-- UI state
local selectedSong = 1
local playing = false
local currentNote = 0
local noteTimer = 0
local soundSource = nil
local font = nil
local buttonHeight = 40
local songListHeight = 150
local buttons = {
  {text = "Play", x = 20, y = 200, width = 80, height = buttonHeight},
  {text = "Stop", x = 120, y = 200, width = 80, height = buttonHeight},
  {text = "Restart", x = 220, y = 200, width = 80, height = buttonHeight}
}

-- Generate a sound for a specific note
local function generateNote(noteFreq, duration)
  local sampleRate = 44100
  local samples = love.sound.newSoundData(math.floor(sampleRate * duration), sampleRate, 16, 1)
  
  if noteFreq == 0 then -- REST
    for i = 0, samples:getSampleCount() - 1 do
      samples:setSample(i, 0) -- Silence
    end
  else
    local volume = 0.5
    for i = 0, samples:getSampleCount() - 1 do
      -- Simple sine wave at the given frequency
      local t = i / sampleRate
      local sample = volume * math.sin(2 * math.pi * noteFreq * t)
      
      -- Simple envelope to avoid clicks
      if t < 0.02 then
        sample = sample * (t / 0.02) -- Fade in
      elseif t > duration - 0.02 then
        sample = sample * ((duration - t) / 0.02) -- Fade out
      end
      
      samples:setSample(i, sample)
    end
  end
  
  return love.audio.newSource(samples, "static")
end

-- Play the next note in the sequence
local function playNextNote()
  if not playing then return end
  
  currentNote = currentNote + 1
  local song = songs[selectedSong]
  
  if currentNote > #song.notes then
    playing = false
    currentNote = 0
    return
  end
  
  local noteData = song.notes[currentNote]
  local noteFreq = notes[noteData.note]
  
  if soundSource then
    soundSource:stop()
  end
  
  soundSource = generateNote(noteFreq, noteData.duration)
  soundSource:play()
  
  noteTimer = noteData.duration
end

-- Start playing the selected song
local function startPlaying()
  if playing then return end
  playing = true
  currentNote = 0
  playNextNote()
end

-- Stop playing the current song
local function stopPlaying()
  playing = false
  if soundSource then
    soundSource:stop()
  end
  currentNote = 0
end

-- Restart the current song
local function restartPlaying()
  stopPlaying()
  startPlaying()
end

function love.load()
  font = love.graphics.newFont(14)
  love.graphics.setFont(font)
  love.window.setTitle("Nursery Songs Player")
  love.window.setMode(400, 300)
end

function love.update(dt)
  if playing then
    noteTimer = noteTimer - dt
    if noteTimer <= 0 then
      playNextNote()
    end
  end
end

function love.draw()
  -- Draw background
  love.graphics.setColor(0.9, 0.9, 0.9)
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  
  -- Draw title
  love.graphics.setColor(0.2, 0.2, 0.8)
  love.graphics.printf("Nursery Songs Player", 0, 20, love.graphics.getWidth(), "center")
  
  -- Draw song list
  love.graphics.setColor(0.3, 0.3, 0.3)
  for i, song in ipairs(songs) do
    local y = 60 + (i - 1) * 30
    
    -- Highlight selected song
    if i == selectedSong then
      love.graphics.setColor(0.8, 0.8, 1.0)
      love.graphics.rectangle("fill", 10, y - 5, love.graphics.getWidth() - 20, 30)
      love.graphics.setColor(0.2, 0.2, 0.8)
    else
      love.graphics.setColor(0.3, 0.3, 0.3)
    end
    
    love.graphics.print(song.title, 20, y)
  end
  
  -- Draw buttons
  for _, button in ipairs(buttons) do
    if button.text == "Play" and playing then
      love.graphics.setColor(0.5, 0.8, 0.5) -- Green when playing
    else
      love.graphics.setColor(0.8, 0.8, 0.8)
    end
    
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
    love.graphics.printf(button.text, button.x, button.y + 12, button.width, "center")
  end
  
  -- Draw playing status
  love.graphics.setColor(0.2, 0.2, 0.2)
  local statusText = "Status: " .. (playing and "Playing" or "Stopped")
  love.graphics.print(statusText, 20, 260)
  if playing then
    love.graphics.print("Now playing: " .. songs[selectedSong].title, 180, 260)
  end
end

function love.mousepressed(x, y, button)
  if button == 1 then
    -- Check if a song was selected
    for i, _ in ipairs(songs) do
      local songY = 60 + (i - 1) * 30
      if x >= 10 and x <= love.graphics.getWidth() - 10 and
         y >= songY - 5 and y <= songY + 25 then
        selectedSong = i
        if playing then
          restartPlaying()
        end
        return
      end
    end
    
    -- Check if a button was clicked
    for i, button in ipairs(buttons) do
      if x >= button.x and x <= button.x + button.width and
         y >= button.y and y <= button.y + button.height then
        if i == 1 then     -- Play
          startPlaying()
        elseif i == 2 then -- Stop
          stopPlaying()
        elseif i == 3 then -- Restart
          restartPlaying()
        end
        return
      end
    end
  end
end

function love.keypressed(key)
  if key == "space" then
    if playing then
      stopPlaying()
    else
      startPlaying()
    end
  elseif key == "r" then
    restartPlaying()
  elseif key == "up" or key == "down" then
    local change = key == "up" and -1 or 1
    selectedSong = selectedSong + change
    if selectedSong < 1 then selectedSong = #songs end
    if selectedSong > #songs then selectedSong = 1 end
    if playing then
      restartPlaying()
    end
  end
end
