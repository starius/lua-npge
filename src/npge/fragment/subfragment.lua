-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2016 Boris Nagaev
-- See the LICENSE file for terms of use.

return function(self, start, stop, ori)
    -- ori is related to source fragment
    local start2 = self:start() + self:ori() * start
    local stop2 = self:start() + self:ori() * stop
    local ori2 = self:ori() * ori
    local fixPosition = require 'npge.sequence.fixPosition'
    start2 = fixPosition(self:sequence(), start2)
    stop2 = fixPosition(self:sequence(), stop2)
    local Fragment = require 'npge.model.Fragment'
    local f = Fragment(self:sequence(), start2, stop2, ori2)
    local iso = require 'npge.fragment.isSubfragmentOf'
    assert(iso(f, self))
    return f
end
