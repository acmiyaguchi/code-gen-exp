local Parser = {}

-- Parses the Othello text file from Project Gutenberg
function Parser.parse_play_file(filename)
    -- Use love.filesystem instead of io
    if not love.filesystem.getInfo(filename) then
        error("Could not find file: " .. filename)
    end
    
    local content = love.filesystem.read(filename)
    if not content then
        error("Could not read file: " .. filename)
    end
    
    -- Find the start of the actual play content
    -- Project Gutenberg files typically have headers before the actual content
    local play_start = content:find("THE TRAGEDY OF OTHELLO, MOOR OF VENICE")
    if not play_start then
        -- Try alternative title format
        play_start = content:find("OTHELLO")
        if not play_start then
            error("Could not find the beginning of the play in the file")
        end
    end
    
    local play_end = content:find("End of Project Gutenberg's Othello")
    if not play_end then
        play_end = content:find("End of the Project Gutenberg")
        if not play_end then
            play_end = #content
        end
    end
    
    content = content:sub(play_start, play_end)
    
    -- Parse the play into Acts and Scenes
    local play_data = {}
    local current_act = nil
    local current_scene = nil
    local current_content = {}
    
    for line in content:gmatch("[^\r\n]+") do
        -- Check for Act designation
        local act_num = line:match("^ACT (%w+)")
        if act_num then
            -- Convert Roman numerals if needed
            if type(act_num) == "string" then
                if act_num == "I" then act_num = 1
                elseif act_num == "II" then act_num = 2
                elseif act_num == "III" then act_num = 3
                elseif act_num == "IV" then act_num = 4
                elseif act_num == "V" then act_num = 5
                else act_num = tonumber(act_num) or #play_data + 1 end
            end
            
            -- Save previous scene if applicable
            if current_act and current_scene then
                if not play_data[current_act] then play_data[current_act] = {} end
                play_data[current_act][current_scene] = table.concat(current_content, "\n")
            end
            
            current_act = act_num
            current_scene = nil
            current_content = {}
        end
        
        -- Check for Scene designation
        local scene_num = line:match("^SCENE (%w+)")
        if scene_num then
            -- Convert Roman numerals if needed
            if type(scene_num) == "string" then
                if scene_num == "I" then scene_num = 1
                elseif scene_num == "II" then scene_num = 2
                elseif scene_num == "III" then scene_num = 3
                elseif scene_num == "IV" then scene_num = 4
                elseif scene_num == "V" then scene_num = 5
                else scene_num = tonumber(scene_num) or 1 end
            end
            
            -- Save previous scene if applicable
            if current_act and current_scene then
                if not play_data[current_act] then play_data[current_act] = {} end
                play_data[current_act][current_scene] = table.concat(current_content, "\n")
            end
            
            current_scene = scene_num
            current_content = {}
        end
        
        -- Collect content lines
        if current_act and current_scene then
            table.insert(current_content, line)
        end
    end
    
    -- Add the last scene
    if current_act and current_scene and #current_content > 0 then
        if not play_data[current_act] then play_data[current_act] = {} end
        play_data[current_act][current_scene] = table.concat(current_content, "\n")
    end
    
    return play_data
end

-- Processes a scene text into chunks for display as bubbles
-- Improved to ensure a character's complete speech is in one bubble
function Parser.process_scene_into_bubbles(scene_text, max_chars_per_bubble)
    max_chars_per_bubble = max_chars_per_bubble or 1500  -- Increased to allow for longer speeches
    local bubbles = {}
    
    -- First, split the text into lines
    local lines = {}
    for line in scene_text:gmatch("([^\r\n]+)") do
        if #line > 0 then
            table.insert(lines, line)
        end
    end
    
    -- Find all character names for better recognition
    local character_names = {}
    local i = 1
    while i <= #lines do
        local line = lines[i]
        local name = line:match("^%s*([A-Z][A-Z%s]+)%s*$")
        if name and #name < 30 then
            character_names[name] = true
        end
        i = i + 1
    end
    
    -- Special character name patterns that might be mixed case
    local special_patterns = {
        "^%s*Enter ",
        "^%s*Exit ",
        "^%s*Re%-enter ",
        "^%s*Exeunt",
        "^%s*%[",
        "^%s*To ",
        "^%s*Scene:"
    }
    
    -- Function to check if a line is a stage direction
    local function is_stage_direction(line)
        for _, pattern in ipairs(special_patterns) do
            if line:match(pattern) then
                return true
            end
        end
        return line:match("%]%s*$") ~= nil
    end
    
    -- Group content by character or stage direction
    local i = 1
    while i <= #lines do
        local line = lines[i]
        
        -- Check if this is a stage direction
        if is_stage_direction(line) then
            -- Add stage direction as its own bubble
            table.insert(bubbles, line)
            i = i + 1
        -- Check if this is a character name
        elseif line:match("^%s*([A-Z][A-Z%s]+)%s*$") and character_names[line:match("^%s*([A-Z][A-Z%s]+)%s*$")] then
            local current_character = line:match("^%s*([A-Z][A-Z%s]+)%s*$")
            local speech_lines = {line}  -- Start with character name
            local current_length = #line
            i = i + 1
            
            -- Collect all lines until we hit another character name or stage direction
            while i <= #lines do
                local next_line = lines[i]
                
                -- Stop if we hit another character name or stage direction
                if (next_line:match("^%s*([A-Z][A-Z%s]+)%s*$") and character_names[next_line:match("^%s*([A-Z][A-Z%s]+)%s*$")]) 
                    or is_stage_direction(next_line) then
                    break
                end
                
                -- Add this line to the current speech
                table.insert(speech_lines, next_line)
                current_length = current_length + #next_line
                i = i + 1
                
                -- Break into multiple bubbles if speech becomes too long
                if current_length > max_chars_per_bubble then
                    break
                end
            end
            
            -- Add complete speech bubble
            table.insert(bubbles, table.concat(speech_lines, "\n"))
        else
            -- Other text (scene descriptions, etc.)
            table.insert(bubbles, line)
            i = i + 1
        end
    end
    
    return bubbles
end

return Parser
