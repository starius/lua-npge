-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

describe("npge.alignment.goodColumns", function()
    it("gets type of alignment columns", function()
        local goodColumns = require 'npge.alignment.goodColumns'
        assert.same(goodColumns({
            "NAAATTTG--GG",
            "NA-ATTTG--GG",
        }), {0, 100, 0, 100, 100, 100, 100, 100,
             0, 0, 100, 100})
        assert.same(goodColumns({
            "AAT-AG",
            "ACTGTG",
            "ACTG-G",
        }), {100, 0, 100, 0, 0, 100})
        assert.same(goodColumns({
            "AAATTT",
            "A--TTT",
        }), {100, 20, 20, 100, 100, 100})
        assert.same(goodColumns({
            "AAAAAAAA",
            "A------A",
        }), {100, 53, 53, 53, 53, 53, 53, 100})
    end)

    it("returns empty table if input is empty", function()
        local goodColumns = require 'npge.alignment.goodColumns'
        assert.same(goodColumns({}), {})
        assert.same(goodColumns({""}), {})
        assert.same(goodColumns({"", ""}), {})
    end)

    it("throws for invalid input", function()
        local goodColumns = require 'npge.alignment.goodColumns'
        assert.has_error(function()
            goodColumns({
                "AAT-AG",
                "ACTGTGA",
            })
        end)
        assert.has_error(function()
            goodColumns({
                "AAT-AG",
                "",
            })
        end)
    end)
end)
