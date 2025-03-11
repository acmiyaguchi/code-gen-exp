Write a love2d program that plays a few nursery songs such as the following:

- mary had a little lamb
- twinkle twinkle little star
- london bridge

There should be a very small graphical interface that lets you select between songs, and to start, stop, or restart.
You have access to `love.audio` which has wrappers around `OpenAL`.
Use built-in love2d primitives to build up the music.
The music is not available and must be programmatically generated.

## Implementation Details

1. Create a table of songs with their note sequences and timings for:
   - Mary Had a Little Lamb
   - Twinkle Twinkle Little Star
   - London Bridge
2. Implement a note generation system using love.audio that can create tones for each note
3. Load the font for displaying text
4. Create a simple UI with:
   - List of available songs
   - Buttons for play, stop, and restart
   - Visual indication of currently selected/playing song
5. Handle mouse clicks to select songs and control playback
6. Implement keyboard shortcuts for playback control
7. Create a music sequencer that plays the notes in the correct order and timing