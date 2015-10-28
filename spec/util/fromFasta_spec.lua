-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.util.fromFasta", function()
    it("parses fasta representation", function()
        local fromFasta = require 'npge.util.fromFasta'
        local fasta = [[
>foo descr
ATGC

>bar several words
AAA
TTT]]
        local textToIt = require 'npge.util.textToIt'
        local lines = textToIt(fasta)
        local parser = fromFasta(lines)
        local foo_name, foo_descr, foo_text = parser()
        assert.truthy(foo_name, "foo")
        assert.truthy(foo_descr, "descr")
        assert.truthy(foo_text, "ATGC")
        local bar_name, bar_descr, bar_text = parser()
        assert.truthy(bar_name, "bar")
        assert.truthy(bar_descr, "several words")
        assert.truthy(bar_text, "AAATTT")
    end)
end)