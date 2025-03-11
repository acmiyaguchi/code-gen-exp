-- Nursery Songs Player
-- Plays three classic nursery songs with a simple UI

-- Import songs data
local songsData = require("songs")
local notes = songsData.notes
local songs = songsData.songs
local noteColors = songsData.noteColors

-- UI state
local selectedSong = 1
local playing = false
local currentNote = 0
local noteTimer = 0
local soundSource = nil
local font = nil
local buttonHeight = 40
local songListHeight = 150
-- Note visualization parameters
local visualizationY = 300  -- Increased from 280 to add more space
local noteWidth = 20
local noteHeight = 30
local visualizationWidth = 320
-- Lyrics display options
local showFullLyrics = false
local lyricsY = 390 -- Position for the lyrics display
local buttons = {
  {text = "Play", x = 20, y = 200, width = 80, height = buttonHeight},
  {text = "Stop", x = 120, y = 200, width = 80, height = buttonHeight},
  {text = "Restart", x = 220, y = 200, width = 80, height = buttonHeight},
  {text = "Lyrics", x = 320, y = 200, width = 80, height = buttonHeight}  -- New button for toggling lyrics view
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
  love.window.setMode(400, 530)  -- Increased height to accommodate the lyrics view
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
  love.graphics.print(statusText, 20, 265)  -- Increased from 255
  if playing then
    love.graphics.print("Now playing: " .. songs[selectedSong].title, 180, 265)  -- Increased from 255
  end
  
  -- Draw note visualization
  drawNoteVisualization()
  
  -- Draw lyrics if playing or if full lyrics view is enabled
  if playing or showFullLyrics then
    drawLyrics()
  end
end

-- Draw visual representation of notes being played
function drawNoteVisualization()
  local song = songs[selectedSong]
  
  -- Draw visualization background
  love.graphics.setColor(0.95, 0.95, 0.95)
  love.graphics.rectangle("fill", 40, visualizationY, visualizationWidth, noteHeight + 20)
  love.graphics.setColor(0.3, 0.3, 0.3)
  love.graphics.rectangle("line", 40, visualizationY, visualizationWidth, noteHeight + 20)
  
  -- Draw title for visualization
  love.graphics.setColor(0.2, 0.2, 0.6)
  love.graphics.printf("Note Visualization", 40, visualizationY - 20, visualizationWidth, "center")
  
  -- Draw keyboard-like reference at the bottom
  local keyWidth = visualizationWidth / 14
  local keyY = visualizationY + noteHeight + 25
  local noteNames = {"C4", "D4", "E4", "F4", "G4", "A4", "B4", "C5", "D5", "E5", "F5", "G5", "A5", "REST"}
  
  for i, noteName in ipairs(noteNames) do
    local x = 40 + (i-1) * keyWidth
    -- Draw color indicator
    love.graphics.setColor(noteColors[noteName])
    love.graphics.rectangle("fill", x, keyY, keyWidth - 2, 10)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", x, keyY, keyWidth - 2, 10)
    -- Draw note name
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(noteName:gsub("4", ""):gsub("5", ""), x, keyY + 12, keyWidth - 2, "center")
  end
  
  if not playing or #song.notes == 0 then
    -- If not playing, just show a placeholder
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.printf("Press Play to Start", 40, visualizationY + 10, visualizationWidth, "center")
    return
  end
  
  -- Draw timeline indicator (vertical line showing current position)
  love.graphics.setColor(0, 0, 0)
  love.graphics.line(120, visualizationY, 120, visualizationY + noteHeight)
  love.graphics.setColor(0.3, 0.3, 0.3)
  love.graphics.printf("Now", 110, visualizationY + noteHeight + 2, 20, "center")
  
  -- Calculate how much of the current note has been played
  local noteDuration = song.notes[currentNote] and song.notes[currentNote].duration or 0
  local noteProgress = noteDuration > 0 and 1 - (noteTimer / noteDuration) or 0
  
  -- Draw current and upcoming notes
  local position = 0
  local startNote = math.max(1, currentNote)
  local endNote = math.min(#song.notes, currentNote + 10)
  
  -- Draw past notes (faded)
  for i = math.max(1, currentNote - 5), currentNote - 1 do
    local noteData = song.notes[i]
    local noteColor = noteColors[noteData.note] or {0.5, 0.5, 0.5}
    love.graphics.setColor(noteColor[1], noteColor[2], noteColor[3], 0.3)  -- Faded
    local noteX = 120 - (position + noteData.duration * 40)
    love.graphics.rectangle("fill", noteX, visualizationY + 5, noteData.duration * 40, noteHeight - 10)
    position = position + noteData.duration
  end
  
  -- Reset position for current and upcoming notes
  position = 0
  
  -- Draw current note
  if currentNote > 0 and currentNote <= #song.notes then
    local noteData = song.notes[currentNote]
    local noteColor = noteColors[noteData.note] or {0.5, 0.5, 0.5}
    love.graphics.setColor(noteColor)
    
    -- Current note is drawn with a highlight effect
    love.graphics.rectangle("fill", 120, visualizationY + 5, noteData.duration * 40, noteHeight - 10)
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.printf(noteData.note, 120, visualizationY + 10, noteData.duration * 40, "center")
    
    position = noteData.duration
  end
  
  -- Draw upcoming notes
  for i = currentNote + 1, endNote do
    local noteData = song.notes[i]
    local noteColor = noteColors[noteData.note] or {0.5, 0.5, 0.5}
    love.graphics.setColor(noteColor)
    
    local noteX = 120 + (position * 40)
    if noteX < 40 + visualizationWidth then  -- Only draw if visible
      love.graphics.rectangle("fill", noteX, visualizationY + 5, noteData.duration * 40, noteHeight - 10)
      love.graphics.setColor(0, 0, 0, 0.7)
      if noteData.duration > 0.3 then -- Only draw text if there's enough room
        love.graphics.printf(noteData.note, noteX, visualizationY + 10, noteData.duration * 40, "center")
      end
    end
    
    position = position + noteData.duration
  end
end

-- Draw the lyrics for the current song
function drawLyrics()
  local song = songs[selectedSong]
  if not song.lyrics then return end

  love.graphics.setColor(0.2, 0.2, 0.6)
  love.graphics.printf("Lyrics", 40, lyricsY - 20, visualizationWidth, "center")
  
  -- Create a lyrics display area
  love.graphics.setColor(0.95, 0.95, 0.95)
  love.graphics.rectangle("fill", 40, lyricsY, visualizationWidth, showFullLyrics and 120 or 30)
  love.graphics.setColor(0.3, 0.3, 0.3)
  love.graphics.rectangle("line", 40, lyricsY, visualizationWidth, showFullLyrics and 120 or 30)
  
  if showFullLyrics then
    -- Show complete lyrics, with the current part highlighted
    local fullText = ""
    local highlightStart, highlightEnd = 0, 0
    local currentPosition = 0
    local totalWidth = 0
    
    -- Build the complete lyrics text and determine highlight positions
    for i, lyric in ipairs(song.lyrics) do
      if i > 1 then
        fullText = fullText .. " "
        currentPosition = currentPosition + 1
      end
      
      if lyric.startNote <= currentNote and 
         (i == #song.lyrics or song.lyrics[i+1].startNote > currentNote) then
        highlightStart = currentPosition
        highlightEnd = currentPosition + #lyric.text
      end
      
      fullText = fullText .. lyric.text
      currentPosition = currentPosition + #lyric.text
    end
    
    -- Draw the full text with proper wrapping
    love.graphics.setColor(0.2, 0.2, 0.2)
    local text = love.graphics.newText(font, fullText)
    love.graphics.printf(fullText, 50, lyricsY + 10, visualizationWidth - 20, "left")
    
    -- Draw highlight under current lyric if playing
    if playing and highlightStart > 0 then
      -- We need to calculate the position based on the wrapped text
      -- This is simplified and might need adjustment for more precise highlighting
      local firstLine = fullText:sub(1, highlightStart)
      local currentWord = fullText:sub(highlightStart + 1, highlightEnd)
      local y = lyricsY + 10
      
      -- Count lines to determine Y position
      local lines = 0
      for _ in firstLine:gmatch("\n") do
        lines = lines + 1
      end
      y = y + (lines * font:getHeight())
      
      -- Calculate X position (approximate)
      local prefix = firstLine:match("([^\n]*)$") or ""
      local x = 50 + font:getWidth(prefix)
      
      -- Draw the highlight
      love.graphics.setColor(0.8, 0.8, 1.0, 0.5)
      love.graphics.rectangle("fill", x, y, font:getWidth(currentWord), font:getHeight())
    end
  else
    -- Show current and upcoming lyrics only (sliding view)
    local currentLyric = ""
    local nextLyric = ""
    local previousLyric = ""
    
    for i, lyric in ipairs(song.lyrics) do
      if lyric.startNote == currentNote then
        currentLyric = lyric.text
        if i < #song.lyrics then
          nextLyric = song.lyrics[i+1].text
        end
        if i > 1 then
          previousLyric = song.lyrics[i-1].text
        end
        break
      elseif lyric.startNote > currentNote then
        if nextLyric == "" then
          nextLyric = lyric.text
        end
        break
      else
        previousLyric = lyric.text
      end
    end
    
    -- Draw previous lyric (faded)
    love.graphics.setColor(0.4, 0.4, 0.4, 0.5)
    love.graphics.printf(previousLyric, 60, lyricsY + 8, 80, "right")
    
    -- Draw current lyric (highlighted)
    love.graphics.setColor(0, 0, 0.8)
    love.graphics.printf(currentLyric, 150, lyricsY + 8, 100, "center")
    
    -- Draw next lyric (normal)
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.printf(nextLyric, 260, lyricsY + 8, 100, "left")
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
        elseif i == 4 then -- Toggle lyrics view
          showFullLyrics = not showFullLyrics
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
  elseif key == "l" then
    -- Toggle lyrics display mode
    showFullLyrics = not showFullLyrics
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
