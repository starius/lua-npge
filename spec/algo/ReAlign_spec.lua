describe("algo.ReAlign", function()
    it("aligns blockset, keep block with better identity (1)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 1
        config.alignment.GAP_CHECK = 1
        --
        local model = require 'npge.model'
        local s1 = model.Sequence('s1', "ATGCTTGCTATTTAATGC")
        local s2 = model.Sequence('s2', "ATGCATGC")
        local f1 = model.Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = model.Fragment(s2, 0, s2:length() - 1, 1)
        local block = model.Block({f1, f2})
        local blockset = model.BlockSet({s1, s2}, {block})
        --
        local ReAlign = require 'npge.algo.ReAlign'
        local blockset_aligned = ReAlign(blockset)
        assert.equal(blockset_aligned,
            model.BlockSet({s1, s2}, {
                model.Block({
                    {f1, "ATGCTTGCTATTTAATGC"},
                    {f2, "ATGC----------ATGC"},
                }),
            }))
        --
        config.alignment = orig
    end)

    it("aligns blockset, keep block with better identity (2)",
    function()
        local config = require 'npge.config'
        local clone = require 'npge.util.clone'.dict
        local orig = clone(config.alignment)
        config.alignment.MISMATCH_CHECK = 1
        config.alignment.GAP_CHECK = 1
        --
        local model = require 'npge.model'
        local s1 = model.Sequence('s1', "ATGCTTGCTATTTAATGC")
        local s2 = model.Sequence('s2', "ATGCATGC")
        local f1 = model.Fragment(s1, 0, s1:length() - 1, 1)
        local f2 = model.Fragment(s2, 0, s2:length() - 1, 1)
        local block = model.Block({
            {f1, "ATGCTTGCTATTTAATGC"},
            {f2, "ATGC----------ATGC"},
        })
        local blockset = model.BlockSet({s1, s2}, {block})
        --
        local ReAlign = require 'npge.algo.ReAlign'
        local blockset_aligned = ReAlign(blockset)
        assert.equal(blockset_aligned,
            model.BlockSet({s1, s2}, {
                model.Block({
                    {f1, "ATGCTTGCTATTTAATGC"},
                    {f2, "ATGC----------ATGC"},
                }),
            }))
        --
        config.alignment = orig
    end)
end)
