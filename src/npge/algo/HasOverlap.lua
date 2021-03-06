-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(blockset)
    for seq in blockset:iterSequences() do
        local prev, prev_parent
        for parent, part in blockset:iterFragments(seq) do
            if prev and prev:common(part) > 0 then
                return true, prev_parent, parent
            end
            prev = part
            prev_parent = parent
        end
    end
    return false
end
