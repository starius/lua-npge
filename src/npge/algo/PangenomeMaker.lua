-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(bs, silent)
    -- input a blockset of good blocks only
    -- output: pangenome (partition, blocks are good or unique,
    --      no new good blocks can be found neither in blast
    --      hits, not in results of joining neighbour blocks)
    local algo = require 'npge.algo'
    assert(not algo.HasOverlap(bs))
    bs = algo.GoodSubblocks(bs)
    local bs1
    while not bs1 or bs1 ~= bs do
        if bs1 then
            bs = bs1
        end
        local bs_covered = algo.Cover(bs)
        -- blast
        local hits = algo.AddGoodBlast(bs_covered, bs_covered)
        bs1 = algo.BlocksWithoutOverlaps(bs, hits)
        -- join
        local joined = algo.Join(bs1)
        joined = algo.BetterSubblocks(joined, bs1)
        bs1 = algo.BlocksWithoutOverlaps(bs1, joined)
        -- extend
        local extended = algo.Extend(bs1)
        extended = algo.ExcludeSelfOverlap(extended)
        extended = algo.BetterSubblocks(extended, bs1)
        bs1 = algo.BlocksWithoutOverlaps(bs1, extended)
        -- print '.'
        if not silent then
            io.stderr:write('.')
            io.stderr:flush()
        end
    end
    -- prettify
    bs = algo.Cover(bs)
    local minor = algo.Align(algo.JoinMinor(bs))
    bs = algo.BlocksWithoutOverlaps(bs, minor)
    assert(bs:isPartition())
    bs = algo.Orient(bs)
    bs = algo.GiveNames(bs)
    return bs
end
