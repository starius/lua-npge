describe("algo.PangenomeMaker", function()
    it("converts blockset to pangenome", function()
        local config = require 'npge.config'
        local orig_MIN_LENGTH = config.general.MIN_LENGTH
        config.general.MIN_LENGTH = 60
        --
        local model = require 'npge.model'
        local s1 = model.Sequence('s1', [[
    TACCAGGGGAAGGGCCGAGGTGTCTGGTGATCA
TACGTATTGTGAATCTCTGGGGTGGCTGGTGATTGCGCAAACAAACTCACTCTGTAGGGA
    GGCAAAATAACCTCACATCTAGTCA
TACGTATTGTGAATCTCTGGGGTGGCTGGTGATTGCGCAAACAAACTCACTCTGTAGGGA
    AGTCGAGCCCGAGTGGATTAGTTACGAGTGC
        ]])
        local s2 = model.Sequence('s2', [[
    ATGGTGGCTCCGCAAAAAGCCGTTATAGCCGCAATGGCT
TACGTATTGTGAATCTCTGGGGTGGCTGGTGATTGCGCAAACAAACTCACTCTGTAGGGA
    TGACTAAGTTTCCCCTCAGCACTCTTCGCC
TCCCTACAGAGTGAGTTTGTTTGCGCAATCACCAGCCACCCCAGAGATTCACAATACGTA
    GATATTGGCTAATGCGAGTATCAGGCCGGGCA
        ]])
        local blockset = model.BlockSet({s1, s2}, {})
        --
        local algo = require 'npge.algo'
        local npg = algo.PangenomeMaker(blockset)
        assert.truthy(npg:is_partition())
        local good_blocks = algo.FilterGoodBlocks(npg):blocks()
        assert.equal(#good_blocks, 1)
        assert.equal(good_blocks[1]:size(), 4)
        --
        config.general.MIN_LENGTH = orig_MIN_LENGTH
    end)
end)