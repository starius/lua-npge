# Library NPGe

This document is for developers and advanced users only.
End users should read [README](README.md) first.

## Installation

Requirements:

  * [Lua][lua] >= 5.1 or [LuaJIT][luajit]
  * [LuaRocks][luarocks]
  * [C++ compiler][gcc]
  * [Boost][boost]
  * NCBI [blast+][blast]

[lua]: http://www.lua.org/
[luajit]: http://luajit.org/
[luarocks]: https://luarocks.org/
[gcc]: https://gcc.gnu.org/
[boost]: http://www.boost.org/
[blast]: http://www.ncbi.nlm.nih.gov/BLAST/

```bash
$ git clone https://github.com/npge/lua-npge
$ cd lua-npge
$ sudo luarocks make
```

To install the library for current user only, use the following
command instead:

```bash
$ luarocks make --local
```

When installing for current user only, use the following
command to "enable" the library in Lua:

```bash
$ eval `luarocks path`
$ export PATH=~/.luarocks/bin:$PATH
```

You should repeat these command each time before using
npge. Otherwise you can append them to `~/.bashrc`.

Other important thing on Linux is to set environment
variable `LD_PRELOAD` to value
`/lib/x86_64-linux-gnu/libpthread.so.0`:
```bash
$ export LD_PRELOAD=/lib/x86_64-linux-gnu/libpthread.so.0
```
Otherwise it can crash in multithreaded mode.
(Not checked: for 32-bit Linux it should be
`/lib/i386-linux-gnu/libpthread.so.0`.)

Test if Lua can load NPGe:

```bash
$ lua -e 'require "npge"'
```

This command should produce no output in case of success.

On linux we recommend to use `luaprompt` as Lua interpreter:

```bash
$ sudo aptitude install libncurses5-dev
$ sudo luarocks install luaprompt \
    HISTORY_LIBDIR=/usr/lib/x86_64-linux-gnu/ \
    READLINE_LIBDIR=/usr/lib/x86_64-linux-gnu/
$ luap
>
```

Now you are ready to use NPGe:

```lua
> npge = require 'npge'
```

## Data structures provided by NPGe

Ses also [specs](spec/model).

Data structures provide low level access to NPG.
All data structures are immutable: no changes after creation.
Functions creating new instances of NPG data structures
live in table `npge.model`. Create an alias for it:

```lua
model = npge.model
```

Short description of NPG data structures:

 - `Sequence` stores string representing genome sequence
    (e.g., chromosome, plasmid or contig).
    It can represent temporary generated sequence
    (e.g., consensus of a block).
 - `Fragment` points to some fragment of Sequence
    (direct or reverse).
 - `Block` is a collection of fragments + alignment.
 - `BlockSet` is a collection of Sequences + a collection of
    Blocks. Fragments of the blocks belong to the sequences.

### Sequence

`Sequence` stores string representing genome sequence
(e.g., chromosome, plasmid or contig).
It can represent temporary generated sequence
(e.g., consensus of a block).

Sequence has the following properties:

  * `name` (e.g., "BRUAB&chr1&c")
  * `text` (e.g., "ATTCCC")
  * `description` (e.g., "Brucella")

To create a sequence, call the following function:

```lua
>  seq = model.Sequence("BRUAB&chr1&c", "ATTCCC", "Brucella")
```
Text can contain gaps, they are ignored.
All letters are uppercased.
Letters from [IUPAC code for incomplete nucleic acid
specification][n] ("N", "R", "Y", "M", "K", "S", "W",
"H", "B", "V", "D") are replaced with "N".
All unknown letters are skipped.

Description is optional. Default description is "".

[n]: http://www.chem.qmul.ac.uk/iubmb/misc/naseq.html

Methods:

```lua
>  seq:name()
"BRUAB&chr1&c"

>  seq:text()
"ATTCCC"

>  seq:length()
6

>  seq:description()
"Brucella"

>  seq:genome()
"BRUAB"

>  seq:chromosome()
"chr1"

>  seq:circular()
true

>  seq:sub(0, 2)
"ATT"
```

Sequences can be compared with operator `==`. Comparison
ignores all properties but sequence name.

Sequence has nice string representation:
```
>  tostring(seq)
"Sequence BRUAB&chr1&c of length 6"
```

### Fragment

Fragment points to some fragment of Sequence
(direct or reverse).

Fragment has the following properties:

  * `sequence` -- a pointer to Sequence object
  * `start` -- 0-based integer
  * `stop` -- 0-based integer
  * `ori` -- `1` or `-1`

Creation:
```lua
>  start = 0
>  stop = 2
>  ori = 1
>  fr = model.Fragment(seq, start, stop, ori)
>  fr
Fragment BRUAB&chr1&c_0_2_1 of length 3
```

Reverse fragment:
```lua
>  start = 2
>  stop = 0
>  ori = -1
>  fr = model.Fragment(seq, start, stop, ori)
>  fr
Fragment BRUAB&chr1&c_2_0_-1 of length 3
```

A fragment crossing the "beginning" of a circular sequence
is called *parted fragment*:
```lua
>  start = 4
>  stop = 1
>  ori = 1
>  fr = model.Fragment(seq, start, stop, ori)
>  fr
Fragment BRUAB&chr1&c_4_1_1 of length 4 (parted)
```

Methods:

```lua
>  fr
Fragment BRUAB&chr1&c_4_1_1 of length 4 (parted)

>  fr:sequence()
Sequence BRUAB&chr1&c of length 6

>  fr:sequence() == seq
true

>  fr:start()
4

>  fr:stop()
1

>  fr:ori()
1

>  fr:id()
"BRUAB&chr1&c_4_1_1"

>  fr:text()
"CCAT"

>  fr:parted()
true
```

Method `:parts()` returns two fragments. First of them has
start position of the parent fragment:

```lua
>  part1, part2 = fr:parts() -- only for parted fragments

>  part1
Fragment BRUAB&chr1&c_4_5_1 of length 2

>  part2
Fragment BRUAB&chr1&c_0_1_1 of length 2
```

Fragments can be compared with operator `==`. Comparison
succeeds iff all properties of fragments are equal.

```lua
>  part1 == model.Fragment(seq, 4, 5, 1)
true

>  part1 == part2
true
```

Fragments can be compared with operators `<`, `>`, `<=`, `>=`.
Fragments are compared as tuples
(sequence.name, min-pos, max-pos, ori). Min-pos is minimum of
start and stop. Max-pos is maximum of start and stop.

```lua
>  part1 < part2
false
```

Counting shared positions of two fragments:
```lua
>  fr:common(part1)
2

>  part1:common(fr)
2

>  part1:common(part2)
0
```

### Block

Block is a collection of fragments + alignment.

There are two methods to create a block:

```lua
>  bl1 = model.Block({part1, part2})

>  bl1:text(part1)
"CC"

>  bl1:text(part2)
"AT"
```

```lua
>  bl2 = model.Block({{part1, "C-C"}, {part2, "AT-"}})

>  bl2:text(part1)
"C-C"

>  bl2:text(part2)
"AT-"
```

Methods:

```lua
>  bl2:size()
2

>  bl2:length()
3

>  bl2:text(part1)
"C-C"

-- convert alignment (block) and fragment positions

>  bl2:fragment2block(part1, 0)
0
>  bl2:fragment2block(part1, 1)
2

>  bl2:block2fragment(part1, 0)
0
>  bl2:block2fragment(part1, 1)
-1
>  bl2:block2fragment(part1, 2)
1

>  bl2:block2left(part1, 0)
0
>  bl2:block2left(part1, 1)
0
>  bl2:block2left(part1, 2)
1

>  bl2:block2right(part1, 0)
0
>  bl2:block2right(part1, 1)
1
>  bl2:block2right(part1, 2)
1

-- get fragments and/or alignment rows

>  bl2:fragments()
{ Fragment BRUAB&chr1&c_0_1_1 of length 2,
  Fragment BRUAB&chr1&c_4_5_1 of length 2,  }

-- iterate fragments of block
-- example: generate fasta

>  for f in bl2:iterFragments() do
>> print(">" .. f:id())
>> print(bl2:text(f))
>> end

>BRUAB&chr1&c_0_1_1
AT-
>BRUAB&chr1&c_4_5_1
C-C
```

### BlockSet

BlockSet is a collection of Sequences + a collection of
Blocks. Fragments of the blocks belong to the sequences.

Creation:

```lua
>  seq = model.Sequence("BRUAB&chr1&c", "ATTCCC", "Brucella")
>  fr = model.Fragment(seq, 4, 1, 1)
>  part1, part2 = fr:parts()
>  fr2 = model.Fragment(seq, 3, 2, -1)
>  block1 = model.Block({part1, part2})
>  block2 = model.Block({fr2})
>  bs = model.BlockSet({seq}, {block1, block2})
>  bs
BlockSet of 1 sequences and 2 blocks (partition)
```

The label "partition" means that each nucleotide is covered
by exactly one fragment.

Methods:

```lua
>  bs:size()
2

>  bs:isPartition()
true

>  bs:sequences()
{ Sequence BRUAB&chr1&c of length 6,  }

>  bs:blocks()
{ Block of 2 fragments, length 2,
  Block of 1 fragments, length 2,  }

>  for seq in bs:iterSequences() do
>> print(seq:name())
>> end
BRUAB&chr1&c

>  for b in bs:iterBlocks() do
>> print(b:size() .. " fragments")
>> end
2 fragments
1 fragments
```

BlockSet stores names of blocks:

```lua
>  bs = model.BlockSet({seq}, {xxx=block1, yyy=block2})

>  bs:blockByName("xxx")
Block of 2 fragments, length 2
>  bs:blockByName("yyy")
Block of 1 fragments, length 2
>  bs:nameByBlock(block1)
"xxx"
>  bs:nameByBlock(block2)
"yyy"

>  for b, name in bs:iterBlocks() do
>> print("block " .. name .. " has size " .. b:size())
>> end
block xxx has size 2
block yyy has size 1

>  bs:blocks(true)
{
  xxx = Block of 2 fragments, length 2,
  yyy = Block of 1 fragments, length 2,
}
```

If you provide a list of blocks without names, then block names
are keys of a Lua table converted to strings: "1", "2", etc.

Get block by fragment:
```lua
>  bs:blockByFragment(part1)
Block of 2 fragments, length 2
>  bs:blockByFragment(part2)
Block of 2 fragments, length 2
>  bs:blockByFragment(fr2)
Block of 1 fragments, length 2
```

BlockSet can find overlapping fragments very fast:

```lua
>  bs:overlappingFragments(model.Fragment(seq, 1, 2, 1))
{ Fragment BRUAB&chr1&c_0_1_1 of length 2,
  Fragment BRUAB&chr1&c_3_2_-1 of length 2,  }
```

Get a list of fragments by sequence ordered by positions:
```lua
>  bs:fragments(seq)
{ Fragment BRUAB&chr1&c_0_1_1 of length 2,
  Fragment BRUAB&chr1&c_3_2_-1 of length 2,
  Fragment BRUAB&chr1&c_4_5_1 of length 2,  }

>  for f in bs:iterFragments(seq) do
>> print(f:id())
>> end
BRUAB&chr1&c_0_1_1
BRUAB&chr1&c_3_2_-1
BRUAB&chr1&c_4_5_1
```

BlockSet can find previous and next fragment for the given
fragment. These methods respect sequence's orientation and
ignore fragment's orientation.

```lua
>  bs:next(part1)
Fragment BRUAB&chr1&c_0_1_1 of length 2
>  bs:next(part2)
Fragment BRUAB&chr1&c_3_2_-1 of length 2
>  bs:next(fr2)
Fragment BRUAB&chr1&c_4_5_1 of length 2

>  bs:prev(fr2)
Fragment BRUAB&chr1&c_0_1_1 of length 2
```

Get information about sequences:
```lua
>  bs:sequences()
{ Sequence BRUAB&chr1&c of length 6,  }

>  for seq in bs:iterSequences() do
>> print(seq:name())
>> end
BRUAB&chr1&c

>  bs:hasSequence(seq)
true

>  bs:sequenceByName("BRUAB&chr1&c")
Sequence BRUAB&chr1&c of length 6
```

BlockSets can be compared with operator `==`. Comparison
succeeds if blocksets have same sets of sequences and
sets of blocks. To compare only sets of sequences use method
`sameSequences`.

## Configuration

Parameters of NPGe algorithms are located in `npge.config`.

Create an alias for it:

```lua
>  config = npge.config
```

There are following configuration parameters:

  * `blast`
    * `blast.EVALUE = 0.001` -- E-value filter for blast
    * `blast.DUST = false` -- Filter out low complexity regions
  * `util`
    * `util.WORKERS = 1` -- Number of parallel workers
  * `general`
    * `general.MIN_LENGTH = 100` -- Minimum acceptable length of fragment (b.p.)
    * `general.MIN_END = 10` -- Minimum number of end good columns
    * `general.MIN_IDENTITY = 0.9` -- Minimum acceptable block identity (0.9 is 90%)
    * `general.FRAME_LENGTH = 100` -- Length of alignment checker frame (b.p.)
  * `alignment`
    * `alignment.ANCHOR = 7` -- Min equal aligned part
    * `alignment.MISMATCH_CHECK = 1` -- Min number of equal columns around single mismatch
    * `alignment.GAP_CHECK = 2` -- Min number of equal columns around single gap

This list is generated from file `src/npge/config.lua` by function
`npge.util.configGenerator({markdown=true})`.

To change configuration, create file `npge.conf` in current directory.
Example:

```lua
general.MIN_LENGTH = 200
alignment.GAP_CHECK = 3
```

To apply a transient change from Lua, use the following code:

```lua
>  npge = require 'npge'
>  config = npge.config
>  reverting_function = config:updateKeys {
>> general = {MIN_LENGTH = 200},
>> alignment = {GAP_CHECK = 3} }
>  config.general
{
  MIN_LENGTH = 200,
  MIN_END = 10,
  MIN_IDENTITY = 0.9,
  FRAME_LENGTH = 100,
}
>  reverting_function()
>  config.general
{
  MIN_LENGTH = 100,
  MIN_END = 10,
  MIN_IDENTITY = 0.9,
  FRAME_LENGTH = 100,
}


```
## Alignment and string functions of NPGe

These functions helps dealing with DNA sequences and alignments
in Lua. A sequence is represented with Lua string. An alignment
is represented with Lua list of strings.

Only these functions must be used from other modules to deal
with content of DNA sequences. Don't write dozens of consensus
getting functions!

Alignment and string functions are in `npge.alignment`.
Create an alias for it:

```lua
>  alignment = npge.alignment
```

### Complement sequence

```lua
>  alignment.complement('AAG')
"CTT"

>  alignment.complementRows({'AAG', 'GGG'})
{ "CTT", "CCC",  }
```

### Consensus

```lua
>  alignment.consensus({'AAG', 'AAC', 'A-C'})
"AAC"

>  alignment.consensus({'AAG'})
"AAG"
```

### Filter out unknown letters

All letters are uppercased.
Letters from [IUPAC code for incomplete nucleic acid
specification][n] ("N", "R", "Y", "M", "K", "S", "W",
"H", "B", "V", "D") are replaced with "N".
All unknown letters are skipped.

```lua
>  alignment.toAtgcn("A-T~G")
"ATG"

>  alignment.toAtgcnAndGap("A-T~G")
"A-TG"
```

### Join alignments

```lua
>  alignment.join({
>> "AT",
>> "A-",
>> }, {
>> "CC",
>> "CG",
>> })
{
  "ATCC",
  "A-CG",
}
```

### Unwinding gapped rows

A "row" is a sequence with gaps.

"Unwinding" means making a row from two rows:

  * *consensus* with gaps added,
  * *original* row which is in the alignment
    producing the consensus.

Example:
```
Original alignment:

   AAGC
   ATGT
   AT-C  <-- original
   ====
   ATGC  <-- consensus

Alignment of consensuses:

   A-TGC  <-- consensus of alignment 1
   AATGC

Result of unwinding:

>  alignment.unwindRow('A-TGC', 'AT-C')
"A-T-C"
```

Result of unwinding is used when a block build on consensuses
is converted into a block built on original sequences (function
`npge.block.unwind`).

### Scoring an alignment

Calculate identity:

```lua
>  ident, good, all = alignment.identity({'AAG', 'AAC', 'A-C'})
>  print(ident, good, all)
0.33333333333333        1       3
```

Function `alignment.goodColumns` takes an alignment and
returns a list of integers, which are scores of corresponding
columns. Normally score belongs to the interval [0, 100].
100 corresponds to perfect column (no gaps, no N's all letters
are equal), 0 corresponds to bad column.

Example:

```lua
>  alignment.goodColumns({
>> "AAATTT",
>> "A--TAT",
>> })
{ 100, 20, 20, 100, 0, 100, }

>  alignment.goodColumns({
>> "AAA-----ATTATTCN",
>> "GGGGGGGGATTATTC-",
>> })
{ 0, 0, 0, 48, 48, 48, 48, 48,
  100, 100, 100, 100, 100, 100, 100,
  0, }
```

Scores of a column with a gap depends on neighbour columns
(whether they also have a gap).

Function `goodSlices` takes a list returned by `goodColumns`
as well as some constants and returns a list of good slices.
Each slice is a tuple {start, stop}. Indices start and stop
are 0-based.

```lua
>  frame_length = 4
>  frame_end = 1
>  min_identity = 1.0
>  min_length = 3
>  good_col = alignment.goodColumns({
>> "AAA-----ATTATTCN",
>> "GGGGGGGGATTATTC-",
>> })
>  good_col
{ 0, 0, 0, 48, 48, 48, 48, 48,
  100, 100, 100, 100, 100, 100, 100,
  0, }
>  alignment.goodSlices(good_col, frame_length, frame_end,
>> min_identity, min_length)
{
  { 8, 14,  },
}
```

### Make alignment

There are several functions which build an alignment.
They split input to alignable and non-alignable parts
and return both of them.

Function `alignment.moveIdentical` takes a list of sequences
and tries to align them without gaps and without mismatches
from left to right. It returns an alignment and a list of
remaining parts of sequences:

```lua
>  alignment.moveIdentical({
>> 'ATGC',
>> 'ATC',
>> })
{ "AT",
  "AT", }
{ "GC",
  "C", }
```

Function `alignment.left` is similar to
`alignment.moveIdentical`, but it allows gaps and mismatches.
It is regulated by NPGe configuration `npge.config.alignment`
(see above).

```lua
>  alignment.left({
>> 'AGTATGA',
>> 'AGATGTTT',
>> })
{ "AGTATG",
  "AG-ATG", }
{ "A",
  "TTT", }
```

Function `alignment.anchor` takes a list of sequences and
tries to find an anchor. An anchor is a sequence of length
`npge.config.alignment.ANCHOR` which belongs to all sequences.
If it can't find an anchor, it returns nothing.
If it succeeds, it returns three lists:

  * a list of parts of sequences *before* the anchor
  * a list of anchor sequences
  * a list of parts of sequences *after* the anchor

```lua
>  npge.config.alignment.ANCHOR
7
>  alignment.anchor({
>> 'AAAATTATTCN',
>> 'GGGGGGGGATTATTC',
>> })
{ "AAA",
  "GGGGGGGG",  }
{ "ATTATTC",
  "ATTATTC",  }
{ "N",
  "",  }
```

Function `alignment.alignRows` takes a list of sequences
and returns an alignment. Second argument `only_left` is
optional. If it is truthy, the sequences are considered
aligned only from left, right ends are considered not aligned.

```lua
>  alignment.alignRows({
>> 'AAAATTATTCN',
>> 'GGGGGGGGATTATTC',
>> })
{ "AAA-----ATTATTCN",
  "GGGGGGGGATTATTC-",  }
```

Function `alignment.alignRows` uses previously defined
functions (`moveIdentical`, `left`, `anchor`, `complementRows`,
`identity`, `join`).

## Module npge.fragment

Module `npge.fragment` includes functions operating on objects
of class `Fragment`.

```lua
>  seq_name, start, stop, ori = npge.fragment.parseId("A_0_100_1")
>  print(seq_name, start, stop, ori)
A       0       100     1

>  s = npge.model.Sequence("s", "ATGCTT")
>  f = model.Fragment(s, 1, 3, 1)
>  f
Fragment s_1_3_1 of length 3
>  npge.fragment.reverse(f)
Fragment s_3_1_-1 of length 3

>  npge.fragment.sub(f, 2, 1, -1)
"GC"
>  f1 = npge.fragment.subfragment(f, 2, 1, -1)
>  f1
Fragment s_3_2_-1 of length 2
>  f1:text()
"GC"

>  npge.fragment.hasPos(f, 0)
false
>  npge.fragment.hasPos(f, 2)
true

>  npge.fragment.fragmentToSequence(f, 0)
1
>  npge.fragment.fragmentToSequence(f, 1)
2
>  npge.fragment.sequenceToFragment(f, 1)
0
>  npge.fragment.sequenceToFragment(f, 2)
1

>  small_fragment = npge.model.Fragment(s, 2, 2, 1)
>  large_fragment = npge.model.Fragment(s, 1, 2, 1)
>  npge.fragment.isSubfragmentOf(small_fragment, large_fragment)
true
>  npge.fragment.isSubfragmentOf(large_fragment, small_fragment)
false
>  npge.fragment.exclude(large_fragment, small_fragment)
Fragment s_1_1_1 of length 1
```