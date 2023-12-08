import tables
import std/strutils
import sequtils
import std/enumerate

type
    GardenItem = enum
        SEED = "seed"
        SOIL = "soil"
        FERTILIZER = "fertilizer"
        WATER = "water"
        LIGHT = "light"
        TEMPERATURE = "temperature"
        HUMIDITY = "humidity"
    Range = tuple[source: int, destination: int, length: int]
    SeedRange = tuple[lower: int, upper: int]
    GardenMap = tuple[
        garden_type: GardenItem,
        ranges: seq[Range]
    ]

iterator distinct_pairs[T](sequence: seq[T]): tuple[lower: T, upper: T] =
    var i = 0
    while i < sequence.len - 1:
        yield (sequence[i], sequence[i+1])
        inc(i, 2)

let input = readFile "inputs/day5.txt"
# let input = readFile "inputs/day5-example.txt"
# 44187305 -> too low

let split_input = input.strip.split("\n\n")

let seeds_sequence = split_input[0].split(":")
var seeds = seeds_sequence[1].strip.split(" ").map(parseInt)
echo seeds

func apply_map(seed: int, garden_map: GardenMap): int =
    result = seed
    for r in garden_map.ranges:
        if seed >= r.source and seed <= r.source + r.length - 1:
            result = r.destination + seed - r.source
            break

proc apply_map_seed_range(seed_range: SeedRange, garden_map: GardenMap): seq[SeedRange] =
    var check_again: seq[SeedRange] = @[seed_range]
    echo seed_range

    echo garden_map.garden_type

    for r in garden_map.ranges:
        let r_end = r.source + r.length - 1

        var to_be_deleted: seq[int] = @[]
        var to_be_added: seq[SeedRange] = @[]
        for (sidx, s) in enumerate(check_again):
            echo s
            if s.lower < r.source and s.upper > r.source:
                to_be_added.add((lower: s.lower, upper: r.source - 1))
                # check_again.add((lower: s.lower, upper: r.source - 1))
                # echo "added lower: ", s.lower, " upper: ", r.source - 1
            if s.upper > r_end and s.lower < r_end:
                to_be_added.add((lower: r.destination + r.length, upper: s.upper))
                # check_again.add((lower: r.destination + r.length, upper: s.upper))
                # echo "added lower: ", r.destination + r.length, " upper: ", s.upper

            let highest_start = max(s.lower, r.source)
            let lowest_end = min(s.upper, r_end)
            # echo "highest_start: ", highest_start
            # echo "lowest_end: ", lowest_end
            # let start_offset = highest_start - s.lower
            # let end_offset = lowest_end - s.lower
            if highest_start <= lowest_end:
                result.add((
                    lower: r.destination + highest_start - r.source,
                    upper: r.destination + lowest_end - r.source
                ))
            else:
                break
            to_be_deleted.add(sidx)
        
        for idx in to_be_deleted:
            check_again.delete(idx)
        check_again.add(to_be_added)
    result.add(check_again)

proc to_garden_map(item: string): GardenMap =
    let split_item = item.splitLines.mapIt(it.split(" "))
    let ranges = split_item[1..split_item.high].mapIt(it.map(parseInt))
    let garden_type = parseEnum[GardenItem](split_item[0][0].split("-")[0])

    result = (garden_type: garden_type, ranges: @[])

    for r in ranges:
        result.ranges.add((source: r[1], destination: r[0], length: r[2]))

var locations: seq[int] = newSeq[int](seeds.len)

for item in split_input[1..split_input.high]:
    let garden_map = to_garden_map(item)

    for (sidx, seed) in enumerate(seeds):
        locations[sidx] = apply_map(seed, garden_map)

echo min locations

var seed_ranges: seq[SeedRange] = @[]

for item in split_input[1..split_input.high]:
    let garden_map = to_garden_map(item)

    for seed_range in distinct_pairs(seeds):
        # echo seed_range
        seed_ranges.add(apply_map_seed_range((
            lower: seed_range.lower,
            upper: seed_range.lower + seed_range.upper - 1
        ), garden_map))

echo seed_ranges
echo seed_ranges.mapIt(it.lower).min