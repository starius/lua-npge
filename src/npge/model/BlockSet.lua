
local BlockSet = {}
local BlockSet_mt = {}
local bs_mt = {}

BlockSet_mt.__index = BlockSet_mt
bs_mt.__index = bs_mt

local is_prepangenome = function(seq2fragments)
    for seq, fragments in pairs(seq2fragments) do
        local lengths_sum = 0
        local prev
        for _, fragment in ipairs(fragments) do
            lengths_sum = lengths_sum + fragment:size()
            if prev and prev:common(fragment) > 0 then
                return false
            end
            prev = fragment
        end
        if lengths_sum ~= seq:size() then
            return false
        end
    end
    return true
end

BlockSet_mt.__call = function(self, sequences, blocks)
    local name2seq = {}
    local seq2fragments = {}
    for _, sequence in ipairs(sequences) do
        assert(sequence:type() == 'Sequence')
        assert(not name2seq[sequence:name()])
        name2seq[sequence:name()] = sequence
        seq2fragments[sequence] = {}
    end
    local parent_of_parts = {}
    for _, block in ipairs(blocks) do
        for fragment in block:iter_fragments() do
            local seq = fragment:seq()
            local name = seq:name()
            assert(name2seq[name])
            if not fragment:parted() then
                table.insert(seq2fragments[seq], fragment)
            else
                local a, b = fragment:parts()
                table.insert(seq2fragments[seq], a)
                table.insert(seq2fragments[seq], b)
                parent_of_parts[a] = fragment
                parent_of_parts[b] = fragment
            end
        end
    end
    for seq, fragments in pairs(seq2fragments) do
        table.sort(fragments)
    end
    local prepangenome = is_prepangenome(seq2fragments)
    local bs = {_name2seq=name2seq, _blocks=blocks,
        _seq2fragments=seq2fragments,
        _parent_of_parts=parent_of_parts,
        _prepangenome=prepangenome}
    return setmetatable(bs, bs_mt)
end

bs_mt.type = function(self)
    return "BlockSet"
end

bs_mt.size = function(self)
    return #(self._blocks)
end

bs_mt.is_prepangenome = function(self)
    return self._prepangenome
end

bs_mt.blocks = function(self)
    local blocks = {}
    for _, block in ipairs(self._blocks) do
        table.insert(blocks, block)
    end
    return blocks
end

bs_mt.iter_blocks = function(self)
    local index, block
    return function()
        index, block = next(self._blocks, index)
        return block
    end
end

bs_mt.seqs = function(self)
    local seqs = {}
    for name, seq in pairs(self._name2seq) do
        table.insert(seqs, seq)
    end
    return seqs
end

bs_mt.iter_seqs = function(self)
    local name, seq
    return function()
        name, seq = next(self._name2seq, name)
        return seq
    end
end

bs_mt.overlapping_fragments = function(self, fragment)
    local arrays_concat = require 'npge.util.arrays_concat'
    local unique = require 'npge.util.unique'
    if fragment:parted() then
        local a, b = fragment:parts()
        return unique(arrays_concat(
            self:overlapping_fragments(a),
            self:overlapping_fragments(b)))
    end
    local seq = fragment:seq()
    local fragments = self._seq2fragments[seq]
    assert(fragments, "Sequence not in blockset")
    local result = {}
    local add_fragment_or_parent = function(f)
        local parent = self._parent_of_parts[f]
        if parent then
            f = parent
        end
        table.insert(result, f)
    end
    local upper = require('npge.util.binary_search').upper
    local index = upper(fragments, fragment)
    for i = index, #fragments do
        if fragment:common(fragments[i]) > 0 then
            add_fragment_or_parent(fragments[i])
        else
            break
        end
    end
    for i = index - 1, 1, -1 do
        if fragment:common(fragments[i]) > 0 then
            add_fragment_or_parent(fragments[i])
        else
            break
        end
    end
    return unique(result)
end

return setmetatable(BlockSet, BlockSet_mt)

