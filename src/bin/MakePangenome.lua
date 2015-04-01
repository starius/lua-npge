#!/usr/bin/env lua

-- lua-npge, Nucleotide PanGenome explorer (Lua module)
-- Copyright (C) 2014-2015 Boris Nagaev
-- See the LICENSE file for terms of use.

local npge = require 'npge'
local algo = require 'npge.algo'

local fname = assert(arg[1])
local bs = algo.ReadSequencesFromFasta( io.lines(fname))
local bs = algo.PrimaryHits(bs)
local bs = algo.PangenomeMaker(bs)
for part in algo.BlockSetToLua(bs) do
    io.write(part)
end
