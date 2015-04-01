-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("block.extend", function()
    it("extend fragment to left and to right",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("seq", "ATGC")
        local f = model.Fragment(s, 1, 1, 1)
        local block = model.Block({f})
        local extend = require 'npge.block.extend'
        local block2 = extend(block, 1)
        assert.equal(block2, model.Block({
            model.Fragment(s, 0, 2, 1),
        }))
    end)

    it("extend fragment to left only",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("seq", "ATGC")
        local f = model.Fragment(s, 1, 1, 1)
        local block = model.Block({f})
        local extend = require 'npge.block.extend'
        local block2 = extend(block, 1, 0)
        assert.equal(block2, model.Block({
            model.Fragment(s, 0, 1, 1),
        }))
    end)

    it("extend fragment to right only",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("seq", "ATGC")
        local f = model.Fragment(s, 1, 1, 1)
        local block = model.Block({f})
        local extend = require 'npge.block.extend'
        local block2 = extend(block, 0, 1)
        assert.equal(block2, model.Block({
            model.Fragment(s, 1, 2, 1),
        }))
    end)

    it("extend fragment to left only (negative ori)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("seq", "ATGC")
        local f = model.Fragment(s, 1, 1, -1)
        local block = model.Block({f})
        local extend = require 'npge.block.extend'
        local block2 = extend(block, 1, 0)
        assert.equal(block2, model.Block({
            model.Fragment(s, 2, 1, -1),
        }))
    end)

    it("extend fragment on circular sequence (parted)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "ATGC")
        local f = model.Fragment(s, 0, 0, 1)
        local block = model.Block({f})
        local extend = require 'npge.block.extend'
        local block2 = extend(block, 1, 0)
        assert.equal(block2, model.Block({
            model.Fragment(s, 3, 0, 1),
        }))
    end)

    it("extend fragment on linear sequence (stop 0)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&l", "ATGC")
        local f = model.Fragment(s, 0, 0, 1)
        local block = model.Block({f})
        local extend = require 'npge.block.extend'
        local block2 = extend(block, 1, 0)
        assert.equal(block2, model.Block({
            model.Fragment(s, 0, 0, 1),
        }))
    end)

    it("extend fragment on linear sequence (stop last)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&l", "ATGC")
        local f = model.Fragment(s, 3, 3, 1)
        local block = model.Block({f})
        local extend = require 'npge.block.extend'
        local block2 = extend(block, 0, 1)
        assert.equal(block2, model.Block({
            model.Fragment(s, 3, 3, 1),
        }))
    end)

    it("extend fragment on circular sequence (whole)",
    function()
        local model = require 'npge.model'
        local s = model.Sequence("g&c&c", "ATGC")
        local f = model.Fragment(s, 0, 0, 1)
        local block = model.Block({f})
        local extend = require 'npge.block.extend'
        local block2 = extend(block, 2)
        local f2 = block2:fragments()[1]
        assert.equal(f2:length(), 4)
    end)

    it("extend block of 2 fragments",
    function()
        local model = require 'npge.model'
        local s1 = model.Sequence("g1&c&c", "ATGC")
        local s2 = model.Sequence("g2&c&c", "ATGC")
        local block = model.Block({
            model.Fragment(s1, 0, 0, 1),
            model.Fragment(s2, 1, 1, -1),
        })
        local extend = require 'npge.block.extend'
        local block2 = extend(block, 1)
        assert.equal(block2, model.Block({
            model.Fragment(s1, 3, 1, 1),
            model.Fragment(s2, 2, 0, -1),
        }))
    end)
end)
