-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

local model = require 'npge.model'

describe("npge.model.Fragment", function()
    it("creates fragment", function()
        local s = model.Sequence("test_name", "ATGC")
        local f = model.Fragment(s, 0, 3, 1)
        assert.are.equal(f:sequence(), s)
        assert.are.equal(f:start(), 0)
        assert.are.equal(f:stop(), 3)
        assert.are.equal(f:ori(), 1)
    end)

    it("has type 'Fragment'", function()
        local s = model.Sequence("G&C&c", "ATGC")
        local f = model.Fragment(s, 1, 2, 1)
        assert.are.equal(f:type(), "Fragment")
    end)

    local Fragment = require 'npge.model.Fragment'
    local function fragmentGen(seq, start, stop, ori)
        return function()
            return Fragment(seq, start, stop, ori)
        end
    end

    it("throws on bad fragment", function()
        -- linear
        local s = model.Sequence("genome&chromosome&l", "ATGC")
        assert.has.errors(fragmentGen(nil, 1, 2, 1))
        assert.has.errors(fragmentGen(s, 100, 110, 1))
        assert.has.errors(fragmentGen(s, 1, 2, 10))
        assert.has.errors(fragmentGen(s, 0, 4, 1))
        assert.has.errors(fragmentGen(s, 2, 1, 1))
        assert.has.errors(fragmentGen(s, 1, 2, -1))
    end)

    it("no throw on parted fragments on circular", function()
        -- circular
        local s = model.Sequence("genome&chromosome&c", "ATGC")
        assert.has_no.errors(fragmentGen(s, 2, 1, 1))
        assert.has_no.errors(fragmentGen(s, 1, 2, -1))
    end)

    it("is equal #Fragment_eq", function()
        local s = model.Sequence("genome&chromosome&c", "ATGC")
        local s2 = model.Sequence("genome&chromosome&l", "ATGC")
        local f = Fragment(s, 1, 2, 1)
        assert.are.equal(Fragment(s, 1, 2, 1), f)
        assert.are.equal(f, f)
        assert.are_not.equal(Fragment(s, 1, 2, -1), f)
        assert.are_not.equal(Fragment(s2, 1, 2, 1), f)
    end)

    it("is less", function()
        local s1 = model.Sequence("ABC&chromosome&c", "ATGC")
        local s2 = model.Sequence("CDF&chromosome&c", "ATGC")
        assert(Fragment(s1, 0, 0, 1) < Fragment(s2, 0, 0, 1))
        assert(Fragment(s2, 0, 0, 1) > Fragment(s1, 0, 0, 1))
        assert(Fragment(s2, 0, 0, 1) > Fragment(s1, 0, 0, 1))
        assert(Fragment(s1, 0, 0, 1) < Fragment(s2, 0, 0, 1))
        assert(Fragment(s1, 0, 0, 1) <= Fragment(s1, 0, 0, 1))
        assert(Fragment(s1, 0, 0, 1) >= Fragment(s1, 0, 0, 1))
        assert(Fragment(s1, 0, 1, 1) < Fragment(s1, 1, 1, 1))
        assert(Fragment(s1, 0, 1, 1) < Fragment(s1, 0, 2, 1))
        assert(Fragment(s2, 0, 1, 1) > Fragment(s1, 0, 2, 1))
        assert(Fragment(s1, 0, 0, -1) < Fragment(s1, 0, 0, 1))
        assert(Fragment(s2, 0, 0, -1) > Fragment(s1, 0, 0, 1))
        -- non-parted < parted
        assert(Fragment(s1, 0, 3, 1) < Fragment(s1, 3, 0, 1))
    end)

    it("sorts fragments", function()
        local s1 = model.Sequence("ABC&chromosome&c", "ATGC")
        local s2 = model.Sequence("CDF&chromosome&c", "ATGC")
        local fragments_shuf = {
            Fragment(s2, 0, 0, 1),
            Fragment(s2, 0, 1, 1),
            Fragment(s1, 0, 0, 1),
            Fragment(s1, 0, 1, 1),
            Fragment(s1, 1, 0, -1),
            Fragment(s2, 1, 0, -1),
            Fragment(s2, 1, 1, -1),
            Fragment(s1, 1, 1, -1),
        }
        local fragments_sorted = {
            Fragment(s1, 0, 0, 1),
            Fragment(s1, 1, 0, -1),
            Fragment(s1, 0, 1, 1),
            Fragment(s1, 1, 1, -1),
            Fragment(s2, 0, 0, 1),
            Fragment(s2, 1, 0, -1),
            Fragment(s2, 0, 1, 1),
            Fragment(s2, 1, 1, -1),
        }
        table.sort(fragments_shuf)
        assert.same(fragments_shuf, fragments_sorted)
    end)

    it("doesn't throw in 'a < b' if a or b is parted",
    function()
        local s1 = model.Sequence("ABC&chromosome&c", "ATGC")
        local b
        assert.has_not_error(function()
            b = Fragment(s1, 0, 1, -1) < Fragment(s1, 0, 2, 1)
        end)
    end)

    it("has common positions with other fragment", function()
        local s1 = model.Sequence("ABC&chromosome&c", "ATGC")
        local F = Fragment
        assert.equal(F(s1, 0, 0, 1):common(F(s1, 0, 0, 1)), 1)
        assert.equal(F(s1, 0, 0, 1):common(F(s1, 0, 1, 1)), 1)
        assert.equal(F(s1, 0, 0, 1):common(F(s1, 1, 1, 1)), 0)
        assert.equal(F(s1, 1, 0, 1):common(F(s1, 2, 3, 1)), 2)
        assert.equal(F(s1, 0, 3, -1):common(F(s1, 0, 3, 1)), 2)
        assert.equal(F(s1, 0, 3, -1):common(F(s1, 2, 1, 1)), 2)
    end)

    it("has no common with fragment from other sequence",
    function()
        local s1 = model.Sequence("ABC&chromosome&c", "ATGC")
        local s2 = model.Sequence("CDE&chromosome&c", "ATGC")
        local F = Fragment
        assert.equal(F(s1, 0, 3, -1):common(F(s2, 2, 1, 1)), 0)
    end)

    it("gets id", function()
        local s = model.Sequence("G&C&c", "ATGC")
        local f = Fragment(s, 1, 2, 1)
        assert.are.equal(f:id(), "G&C&c_1_2_1")
    end)

    it("detects parted fragments", function()
        local s = model.Sequence("genome&chromosome&c", "ATGC")
        assert.is_true(Fragment(s, 1, 2, -1):parted())
        assert.is_false(Fragment(s, 1, 2, 1):parted())
        assert.is_true(Fragment(s, 2, 1, 1):parted())
        assert.is_false(Fragment(s, 1, 1, -1):parted())
    end)

    it("gets parts of parted fragment (positive)", function()
        local s = model.Sequence("genome&chromosome&c", "ATGC")
        local a, b = Fragment(s, 2, 0, 1):parts()
        assert.are.equal(a:start(), 2)
        assert.are.equal(a:stop(), 3)
        assert.are.equal(a:ori(), 1)
        assert.are.equal(b:start(), 0)
        assert.are.equal(b:stop(), 0)
        assert.are.equal(b:ori(), 1)
    end)

    it("parts() throws if fragment is not parted", function()
        local s = model.Sequence("genome&chromosome&c", "ATGC")
        local f = Fragment(s, 0, 0, 1)
        assert.has_error(function()
            local a, b = f:parts()
        end)
    end)

    it("gets parts of parted fragment (negative)", function()
        local s = model.Sequence("genome&chromosome&c", "ATGC")
        local a, b = Fragment(s, 1, 2, -1):parts()
        assert.are.equal(a:start(), 1)
        assert.are.equal(a:stop(), 0)
        assert.are.equal(a:ori(), -1)
        assert.are.equal(b:start(), 3)
        assert.are.equal(b:stop(), 2)
        assert.are.equal(b:ori(), -1)
    end)

    it("detects length of fragment", function()
        local s = model.Sequence("genome&chromosome&c", "ATGC")
        assert.are.equal(Fragment(s, 1, 2, -1):length(), 4)
        assert.are.equal(Fragment(s, 1, 3, -1):length(), 3)
        assert.are.equal(Fragment(s, 1, 2, 1):length(), 2)
        assert.are.equal(Fragment(s, 1, 3, 1):length(), 3)
        assert.are.equal(Fragment(s, 2, 1, 1):length(), 4)
        assert.are.equal(Fragment(s, 3, 1, 1):length(), 3)
        assert.are.equal(Fragment(s, 2, 1, -1):length(), 2)
        assert.are.equal(Fragment(s, 3, 1, -1):length(), 3)
    end)

    it("gets text of fragment", function()
        local s = model.Sequence("genome&chromosome&c", "ATGC")
        assert.are.equal(Fragment(s, 0, 0, 1):text(), "A")
        assert.are.equal(Fragment(s, 0, 0, -1):text(), "T")
        assert.are.equal(Fragment(s, 0, 1, 1):text(), "AT")
        assert.are.equal(Fragment(s, 0, 1, -1):text(), "TGCA")
        assert.are.equal(Fragment(s, 1, 0, 1):text(), "TGCA")
    end)

    it("makes string representation of fragment", function()
        local s = model.Sequence("genome&chromosome&c", "ATGC")
        local f = Fragment(s, 1, 2, -1)
        assert.truthy(tostring(f))
    end)
end)
