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
function Parser.process_scene_into_bubbles(scene_text, max_chars_per_bubble)
    max_chars_per_bubble = max_chars_per_bubble or 500
    local bubbles = {}
    
    -- First, split the text into paragraphs
    local paragraphs = {}
    for para in scene_text:gmatch("([^\n]+)") do
        if #para > 0 then
            table.insert(paragraphs, para)
        end
    end
    
    local current_bubble = {}
    local current_length = 0
    
    for _, para in ipairs(paragraphs) do
        -- If adding this paragraph would exceed max_chars, create a new bubble
        if current_length + #para > max_chars_per_bubble and #current_bubble > 0 then
            table.insert(bubbles, table.concat(current_bubble, "\n"))
            current_bubble = {}
            current_length = 0
        end
        
        -- Add the paragraph to the current bubble
        table.insert(current_bubble, para)
        current_length = current_length + #para
        
        -- Check if paragraph is a character name or stage direction
        -- If so, start a new bubble after the next paragraph
        if para:match("^%s*[A-Z]+%s*$") or para:match("^%s*%[") then
            -- Keep collecting until we have a meaningful chunk
            if current_length > 200 then
                table.insert(bubbles, table.concat(current_bubble, "\n"))
                current_bubble = {}
                current_length = 0
            end
        end
    end
    
    -- Add the last bubble if it's not empty
    if #current_bubble > 0 then
        table.insert(bubbles, table.concat(current_bubble, "\n"))
    end
    
    return bubbles
end

return Parser
