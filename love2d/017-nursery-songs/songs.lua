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
