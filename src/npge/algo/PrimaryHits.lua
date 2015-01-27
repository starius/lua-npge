return function(blockset)
    local BlockSet = require 'npge.model.BlockSet'
    local level2bss = {}
    level2bss[1] = {}

    local Genomes = require 'npge.algo.Genomes'
    local has_genomes, _, genome2seqs = pcall(Genomes, blockset)
    if has_genomes then
        for genome, seqs in pairs(genome2seqs) do
            table.insert(level2bss[1], BlockSet(seqs, {}))
        end
    else
        for seq in blockset:iter_sequences() do
            table.insert(level2bss[1], BlockSet({seq}, {}))
        end
    end

    local function popBs()
        for level, bss in ipairs(level2bss) do
            if #bss > 0 then
                return table.remove(bss), level
            end
        end
    end

    local function pushBs(bs, level)
        if not level2bss[level] then
            level2bss[level] = {}
        end
        table.insert(level2bss[level], bs)
    end

    local niterations = #(level2bss[1]) - 1
    for i = 1, niterations do
        local a, level_a = assert(popBs())
        local b, level_b = assert(popBs())
        local Cover = require 'npge.algo.Cover'
        a = Cover(a)
        b = Cover(b)
        local Merge = require 'npge.algo.Merge'
        local ab = Merge(a, b)
        local HasOverlap = require 'npge.algo.HasOverlap'
        assert(not HasOverlap(ab))
        local BlastHitsUnwound =
            require 'npge.algo.BlastHitsUnwound'
        local hits = BlastHitsUnwound(ab)
        local BlocksWithoutOverlaps =
            require 'npge.algo.BlocksWithoutOverlaps'
        hits = BlocksWithoutOverlaps(hits)
        pushBs(hits, math.max(level_a, level_b) + 1)
    end
    local bs = assert(popBs())
    return bs
end