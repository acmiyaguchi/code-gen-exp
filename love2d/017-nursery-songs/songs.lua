-- Song definitions for Nursery Songs Player

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
    },
    lyrics = {
      {text = "Ma", startNote = 1}, {text = "ry", startNote = 2}, 
      {text = "had", startNote = 3}, {text = "a", startNote = 4},
      {text = "lit", startNote = 5}, {text = "tle", startNote = 6}, 
      {text = "lamb,", startNote = 7},
      {text = "lit", startNote = 9}, {text = "tle", startNote = 10}, 
      {text = "lamb,", startNote = 11},
      {text = "lit", startNote = 13}, {text = "tle", startNote = 14}, 
      {text = "lamb,", startNote = 15},
      {text = "Ma", startNote = 17}, {text = "ry", startNote = 18}, 
      {text = "had", startNote = 19}, {text = "a", startNote = 20},
      {text = "lit", startNote = 21}, {text = "tle", startNote = 22}, 
      {text = "lamb,", startNote = 23},
      {text = "its", startNote = 25}, {text = "fleece", startNote = 26}, 
      {text = "was", startNote = 27}, {text = "white", startNote = 28},
      {text = "as", startNote = 29}, {text = "snow.", startNote = 30}
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
    },
    lyrics = {
      {text = "Twin", startNote = 1}, {text = "kle,", startNote = 2}, 
      {text = "twin", startNote = 3}, {text = "kle,", startNote = 4},
      {text = "lit", startNote = 5}, {text = "tle", startNote = 6}, 
      {text = "star,", startNote = 7},
      {text = "how", startNote = 9}, {text = "I", startNote = 10}, 
      {text = "won", startNote = 11}, {text = "der", startNote = 12},
      {text = "what", startNote = 13}, {text = "you", startNote = 14}, 
      {text = "are!", startNote = 15},
      {text = "Up", startNote = 17}, {text = "a", startNote = 18}, 
      {text = "bove", startNote = 19}, {text = "the", startNote = 20},
      {text = "world", startNote = 21}, {text = "so", startNote = 22}, 
      {text = "high,", startNote = 23},
      {text = "like", startNote = 25}, {text = "a", startNote = 26}, 
      {text = "dia", startNote = 27}, {text = "mond", startNote = 28},
      {text = "in", startNote = 29}, {text = "the", startNote = 30}, 
      {text = "sky.", startNote = 31},
      {text = "Twin", startNote = 33}, {text = "kle,", startNote = 34}, 
      {text = "twin", startNote = 35}, {text = "kle,", startNote = 36},
      {text = "lit", startNote = 37}, {text = "tle", startNote = 38}, 
      {text = "star,", startNote = 39},
      {text = "how", startNote = 41}, {text = "I", startNote = 42}, 
      {text = "won", startNote = 43}, {text = "der", startNote = 44},
      {text = "what", startNote = 45}, {text = "you", startNote = 46}, 
      {text = "are!", startNote = 47}
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
    },
    lyrics = {
      {text = "Lon", startNote = 1}, {text = "don", startNote = 2}, 
      {text = "Bridge", startNote = 3}, {text = "is", startNote = 4},
      {text = "fall", startNote = 5}, {text = "ing", startNote = 6}, 
      {text = "down,", startNote = 7},
      {text = "fall", startNote = 9}, {text = "ing", startNote = 10}, 
      {text = "down,", startNote = 11},
      {text = "fall", startNote = 13}, {text = "ing", startNote = 14}, 
      {text = "down.", startNote = 15},
      {text = "Lon", startNote = 17}, {text = "don", startNote = 18}, 
      {text = "Bridge", startNote = 19}, {text = "is", startNote = 20},
      {text = "fall", startNote = 21}, {text = "ing", startNote = 22}, 
      {text = "down,", startNote = 23},
      {text = "My", startNote = 25}, {text = "fair", startNote = 26}, 
      {text = "La", startNote = 27}, {text = "dy.", startNote = 28}
    }
  },
  {
    title = "Moonlight Melody",
    notes = {
      -- Opening phrase
      {note = "G4", duration = 0.75}, {note = "E4", duration = 0.5}, {note = "C4", duration = 0.75},
      {note = "D4", duration = 0.5}, {note = "E4", duration = 0.5}, {note = "G4", duration = 1.0},
      {note = "REST", duration = 0.25},
      
      -- Second phrase - ascending
      {note = "A4", duration = 0.5}, {note = "G4", duration = 0.25}, {note = "A4", duration = 0.25}, 
      {note = "B4", duration = 0.5}, {note = "C5", duration = 0.5}, {note = "B4", duration = 0.5},
      {note = "A4", duration = 0.75}, {note = "REST", duration = 0.25},
      
      -- Third phrase - gentle descent
      {note = "G4", duration = 0.5}, {note = "F4", duration = 0.25}, {note = "E4", duration = 0.75},
      {note = "D4", duration = 0.5}, {note = "C4", duration = 0.75}, {note = "D4", duration = 0.25},
      {note = "REST", duration = 0.25},
      
      -- Fourth phrase - development
      {note = "E4", duration = 0.5}, {note = "G4", duration = 0.25}, {note = "A4", duration = 0.75},
      {note = "G4", duration = 0.5}, {note = "E4", duration = 0.5}, {note = "D4", duration = 0.5},
      {note = "REST", duration = 0.25},
      
      -- Fifth phrase - building tension
      {note = "C4", duration = 0.5}, {note = "E4", duration = 0.5}, {note = "G4", duration = 0.5},
      {note = "C5", duration = 0.75}, {note = "B4", duration = 0.25}, {note = "A4", duration = 0.5},
      {note = "REST", duration = 0.25},
      
      -- Final phrase - resolution
      {note = "G4", duration = 0.75}, {note = "E4", duration = 0.5}, {note = "C4", duration = 0.75},
      {note = "D4", duration = 0.5}, {note = "C4", duration = 1.25},
      {note = "REST", duration = 0.5}
    },
    lyrics = {
      {text = "Gen", startNote = 1}, {text = "tle", startNote = 2}, 
      {text = "moon", startNote = 3}, {text = "beams", startNote = 4},
      {text = "shin", startNote = 5}, {text = "ing", startNote = 6}, 
      
      {text = "Stars", startNote = 9}, {text = "a", startNote = 10}, 
      {text = "bove", startNote = 11}, {text = "are", startNote = 12},
      {text = "bright", startNote = 13}, {text = "ly", startNote = 14}, 
      
      {text = "Twink", startNote = 17}, {text = "ling", startNote = 18}, 
      {text = "in", startNote = 19}, {text = "the", startNote = 20},
      {text = "night", startNote = 21}, {text = "sky", startNote = 22}, 
      
      {text = "Dreams", startNote = 25}, {text = "a", startNote = 26}, 
      {text = "wait", startNote = 27}, {text = "as", startNote = 28},
      {text = "time", startNote = 29}, {text = "goes", startNote = 30}, 
      
      {text = "Soft", startNote = 33}, {text = "ly", startNote = 34}, 
      {text = "drift", startNote = 35}, {text = "ing", startNote = 36},
      {text = "to", startNote = 37}, {text = "sleep", startNote = 38}, 
      
      {text = "Un", startNote = 41}, {text = "der", startNote = 42}, 
      {text = "this", startNote = 43}, {text = "moon", startNote = 44},
      {text = "light", startNote = 45}, {text = "mel", startNote = 46}, 
      {text = "o", startNote = 47}, {text = "dy", startNote = 48}
    }
  }
}

-- Color definitions for note visualization
local noteColors = {
  C4 = {1, 0.2, 0.2},
  D4 = {1, 0.5, 0.2},
  E4 = {1, 1, 0.2},
  F4 = {0.2, 1, 0.2},
  G4 = {0.2, 0.8, 1},
  A4 = {0.4, 0.2, 1},
  B4 = {0.8, 0.2, 1},
  C5 = {1, 0.2, 0.6},
  D5 = {1, 0.5, 0.7},
  E5 = {0.9, 0.9, 0.5},
  F5 = {0.5, 1, 0.5},
  G5 = {0.5, 0.8, 1},
  A5 = {0.6, 0.4, 1},
  REST = {0.8, 0.8, 0.8}
}

return {
  notes = notes,
  songs = songs,
  noteColors = noteColors
}
