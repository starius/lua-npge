return function(lines, blockset_with_sequences)
    -- lines is iterator (like file:lines())
    local bs1 = blockset_with_sequences
    local blockname2fragments = {}
    local name, description, text_lines
    local try_add_seq = function()
        if name then
            -- add sequence
            local ev = require 'npge.util.extract_value'
            local blockname = assert(ev(description, "block"))
            local seqname, start, stop =
                assert(name:match("([^_]+)_(%d+)_(-?%d+)"))
            start = tonumber(start)
            stop = tonumber(stop)
            local ori = 1
            if stop == -1 then
                -- special case: fragment of length 1, ori=-1
                stop = start
                ori = -1
            elseif stop < start then
                ori = -1
            end
            local seq = assert(bs1:sequence_by_name(seqname))
            local Fragment = require 'npge.model.Fragment'
            local fragment = Fragment(seq, start, stop, ori)
            local text = table.concat(text_lines)
            if not blockname2fragments[blockname] then
                blockname2fragments[blockname] = {}
            end
            table.insert(blockname2fragments[blockname],
                {fragment, text})
            name = nil
            description = nil
            text_lines = nil
        end
    end
    for line in lines do
        if line:sub(1, 1) == '>' then
            try_add_seq()
            local header = line:sub(2, -1)
            local split = require 'npge.util.split'
            header = split(header, '%s+', 1)
            name = header[1]
            description = header[2]
            text_lines = {}
        elseif #line > 0 then
            assert(name)
            table.insert(text_lines, line)
        end
    end
    -- add last sequence
    try_add_seq()
    --
    local blocks = {}
    for blockname, fragments in pairs(blockname2fragments) do
        local Block = require 'npge.model.Block'
        table.insert(blocks, Block(fragments))
    end
    local BlockSet = require 'npge.model.BlockSet'
    return BlockSet(bs1:sequences(), blocks)
end