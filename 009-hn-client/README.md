# Hacker News Client for LÖVE2D

A simple Hacker News client application built with the LÖVE2D framework. This client allows you to browse the top stories from Hacker News and view their comments.

## Features

- View a list of top stories from Hacker News
- View story details including title, author, score, and posting time
- Read comments for each story
- Open story links in your default web browser
- Auto-refresh stories list every 5 minutes

## Controls

- **Left Mouse Button**: Select stories, press buttons
- **Mouse Wheel**: Scroll through content
- **Escape**: Go back from story detail to main list
- **Ctrl+R**: Refresh current view

## Project Structure

- `main.lua` - Main application entry point and state management
- `api.lua` - Hacker News API interface
- `ui.lua` - UI components and rendering
- `utils.lua` - Utility functions for time formatting, text processing, etc.
- `https.lua` - Mock HTTP request module

## Implementation Notes

This is a simplified implementation with the following limitations:

1. The HTTP requests are mocked for demonstration purposes. In a real application, you would replace the `https.lua` module with a proper HTTP client using libraries like luasocket or lua-http.

2. The JSON parsing is stubbed and would need a proper JSON library like dkjson or lua-cjson in a real implementation.

3. Only a limited number of top-level comments are shown to maintain performance.

4. Comment threading is not implemented; only top-level comments are displayed.

## Running the Application

1. Install [LÖVE2D](https://love2d.org/)
2. Clone this repository
3. Run the application with:

```
love /path/to/009-hn-client
```

## Future Improvements

- Implement full comment threading
- Add user profiles and story submission
- Add search functionality
- Support for dark mode
- Offline caching of stories and comments
