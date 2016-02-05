--[[ clink-autocompletion for CO2MPAS 
--]]
local handle = io.popen('co2mpas-autocompletions')
words_str = handle:read("*a")
handle:close()

function words_generator(prefix, first, last)
    local cmd = 'co2mpas'
    local prefix_len = #prefix
    
    --print('P:'..prefix..', F:'..first..', L:'..last..', l:'..rl_state.line_buffer)
    if prefix_len == 0 or rl_state.line_buffer:sub(1, cmd:len()) ~= cmd then
        return false
    end
    
    for w in string.gmatch(words_str, "%S+") do
        -- Add matching app-words.
        --
        if w:sub(1, prefix_len) == prefix then
            clink.add_match(w)
        end
        
        -- Add matching files & dirs.
        --
        full_path = true
        nf = clink.match_files(prefix..'*', full_path)
        if nf > 0 then
            clink.matches_are_files()
        end
    end
    return clink.match_count() > 0
end

sort_id = 100
clink.register_match_generator(words_generator)
