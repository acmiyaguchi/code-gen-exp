# Hacker News Client for LÖVE2D

A simple Hacker News client application built with the LÖVE2D framework. This client allows you to browse the top stories from Hacker News and view their comments.

## Features

- View a list of sample stories similar to those on Hacker News
- View story details including title, author, score, and posting time
- Read comments for each story
- Open story links in your default web browser
- Auto-refresh stories list every 5 minutes

## Requirements

- LÖVE2D version 11.5
- No additional libraries required

## Implementation Notes

This client uses sample data that mimics the Hacker News API format, but doesn't require an internet connection. This approach was chosen for compatibility with LÖVE2D 11.5, which doesn't include built-in HTTPS support.

## Running the Application

1. Install [LÖVE2D](https://love2d.org/) version 11.5
2. Clone this repository
3. Run the application with:

```
love /path/to/009-hn-client
```

## Controls

- **Left Mouse Button**: Select stories, press buttons
- **Mouse Wheel**: Scroll through content
- **Escape**: Go back from story detail to main list
- **Ctrl+R**: Refresh current view

## Project Structure

- `main.lua` - Main application entry point and state management
- `api.lua` - API interface (works with mock data)
- `ui.lua` - UI components and rendering
- `utils.lua` - Utility functions for time formatting, text processing, etc.
- `https.lua` - Mock HTTP module providing sample data
- `conf.lua` - Application configuration

## Future Improvements

- Implement real HTTP requests when used with LÖVE 12.0
- Add user profiles and story submission
- Add search functionality
- Support for dark mode
- Add more sample stories and comments
