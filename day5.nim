import tables
import std/strutils
import sequtils
import std/enumerate

let input = readFile "inputs/day5.txt"
# let input = readFile "inputs/day5-example.txt"

let split_input = input.strip.split("\n\n")

func make_ranges(sequence: seq[int]): tuple[source: seq[int], destination: seq[int]] =
    let destination_start = sequence[0]
    let source_start = sequence[1]
    let length = sequence[2]

    (
        source: toSeq source_start..source_start + length - 1,
        destination: toSeq destination_start..destination_start + length - 1
    )

iterator range_iterator(range: tuple[source: seq[int], destination: seq[int]]): tuple[source: int, destination: int] =
    for (idx, item) in enumerate(range.source):
        yield (source: item, destination: range.destination[idx])

# func make_table(ranges: tuple[source: seq[int], destination: seq[int]]): Table[int, int] =
#     var table = initTable[int, int]()

#     for r in range_iterator(ranges):
#         table[r.source] = r.destination

#     table

func extend_table(table: var Table[int, int], ranges: tuple[source: seq[int], destination: seq[int]]) =
    for r in range_iterator(ranges):
        table[r.source] = r.destination

let seeds_sequence = split_input[0].split(":")
var seeds = seeds_sequence[1].strip.split(" ").map(parseInt)
echo seeds

for (idx, item) in enumerate(split_input[1..split_input.high]):
    let split_item = item.splitLines.mapIt(it.split(" "))
    let map_ranges = split_item[1..split_item.high].mapIt(it.map(parseInt))

    var type_table = initTable[int, int]()
    for r in map_ranges:
        let ranges = make_ranges(r)
        extend_table(type_table, ranges)

    for (sidx, seed) in enumerate(seeds):
        if type_table.contains(seed):
            seeds[sidx] = type_table[seed]

    # echo map_type, type_table

echo min seeds