-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("util.ends_with", function()
    it("check if a string has a suffix", function()
        local ends_with = require 'npge.util.ends_with'
        assert.truthy(ends_with("asdfg", "dfg"))
        assert.truthy(ends_with("asdfg", "g"))
        assert.truthy(ends_with("asdfg", ""))
        assert.truthy(ends_with("asdfg", "asdfg"))
        assert.falsy(ends_with("asdfg", "asd"))
        assert.falsy(ends_with("asdfg", "df"))
        assert.falsy(ends_with("asdfg", "a"))
    end)
end)
