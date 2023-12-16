import tables
import std/strutils
import sequtils
import std/enumerate
import strformat

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

iterator flatten[T](source: openArray[T]): auto =
    when T isnot seq:
        for element in source:
            yield element
    else:
        for each in source:
            for e in flatten(each):
                yield e

iterator distinct_pairs[T](sequence: seq[T]): tuple[lower: T, upper: T] =
    var i = 0
    while i < sequence.len - 1:
        yield (sequence[i], sequence[i+1])
        inc(i, 2)

let input = readFile "inputs/day5.txt"

# let input = readFile "inputs/day5-example.txt"
# let input = readFile "inputs/day5-test.txt"
# let input = readFile "inputs/day5-kevork.txt"
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

    echo fmt"gardentype: {garden_map.garden_type}"

    for r in garden_map.ranges:
        let r_source_upper = r.source + r.length - 1
        let r_destination_upper = r.destination + r.length - 1

        var dont_check_again: seq[int] = @[]
        var to_be_checked_again: seq[SeedRange] = @[]
        for (sidx, s) in enumerate(check_again):
            # if s.lower <= 82 and s.upper >= 82:
            echo "s: ", s
            echo "r: ", r, " r_source_upper: ", r_source_upper,
                    " r_destination_upper: ", r_destination_upper
            # echo s
            # if s.lower < r.source and s.upper > r.source:
            #     to_be_checked_again.add((lower: s.lower, upper: r.source - 1))
            #     # check_again.add((lower: s.lower, upper: r.source - 1))
            #     # echo "added lower: ", s.lower, " upper: ", r.source - 1
            # if s.upper > r_source_upper and s.lower < r_source_upper:
            #     to_be_checked_again.add((lower: r.destination + r.length,
            #             upper: s.upper))
            #     # check_again.add((lower: r.destination + r.length, upper: s.upper))
            #     # echo "added lower: ", r.destination + r.length, " upper: ", s.upper

            # let highest_start = max(s.lower, r.source)
            # let lowest_end = min(s.upper, r_source_upper)
            # # echo "highest_start: ", highest_start
            # # echo "lowest_end: ", lowest_end
            # # let start_offset = highest_start - s.lower
            # # let end_offset = lowest_end - s.lower
            # if highest_start <= lowest_end:
            #     result.add((
            #         lower: r.destination + highest_start - r.source,
            #         upper: r.destination + lowest_end - r.source
            #     ))
            # else:
            #     break

            # Possible cases for seed ranges and their intersections with a garden map range
            # Garden Map:              |-------------|
            # See Ranges: 1 |--------|                 |--------| 5
            #                   2 |----|----|   |----|----| 4
            #                          3 |---------|
            #                 6 |------|-------------|------|

            if s.lower < r.source and s.upper > r_source_upper: # Case 6
                echo "case 6"
                to_be_checked_again.add((lower: s.lower, upper: r.source - 1))
                echo fmt"check_again {(lower: s.lower, upper: r.source - 1)}"
                to_be_checked_again.add((lower: r_source_upper + 1,
                        upper: s.upper))
                echo fmt"check_again {(lower: r_source_upper + 1, upper: s.upper)}"
                result.add((lower: r.destination, upper: r_destination_upper))
                echo fmt"result {(lower: r.destination, upper: r_destination_upper)}"
                dont_check_again.add(sidx)
            elif s.lower < r.source:
                if s.upper < r.source: # Case 1
                    echo "case 1"
                    continue
                elif s.upper < r_source_upper: # Case 2
                    echo "case 2"
                    to_be_checked_again.add((lower: s.lower, upper: r.source - 1))
                    echo fmt"check_again {(lower: s.lower, upper: r.source - 1)}"
                    let offset = s.upper - r.source
                    echo fmt"offset {offset}"
                    result.add((lower: r.destination, upper: r.destination + offset))
                    echo fmt"result {(lower: r.destination, upper: r.destination + offset)}"
                    dont_check_again.add(sidx)
            elif s.upper > r_source_upper:
                if s.lower > r_source_upper: # Case 5
                    echo "case 5"
                    continue
                elif s.lower > r.source: # Case 4
                    echo "case 4"
                    to_be_checked_again.add((lower: r_source_upper + 1,
                            upper: s.upper))
                    echo fmt"check_again {(lower: r_source_upper + 1, upper: s.upper)}"
                    let offset = r_source_upper - s.lower
                    echo fmt"offset {offset}"
                    result.add((lower: r_destination_upper - offset,
                            upper: r_destination_upper))
                    echo fmt"result {(lower: r_destination_upper - offset, upper: r_destination_upper)}"
                    dont_check_again.add(sidx)
            elif s.lower >= r.source and s.upper <= r_source_upper: # Case 3
                echo "case 3"
                let offset = s.lower - r.source
                echo fmt"offset {offset}"
                result.add((lower: r.destination + offset,
                        upper: r.destination + offset + s.upper - s.lower))
                echo fmt"result {(lower: r.destination + offset, upper: r.destination + offset + s.upper - s.lower)}"
                dont_check_again.add(sidx)


            # dont_check_again.add(sidx)

        for idx in dont_check_again:
            check_again.delete(idx)
        check_again.add(to_be_checked_again)
    result.add(check_again)
    echo fmt"result {result}"
    echo ""

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

var seed_ranges: seq[SeedRange]

for seed in distinct_pairs(seeds):
    seed_ranges.add((lower: seed.lower, upper: seed.lower + seed.upper - 1))

for item in split_input[1..split_input.high]:
    let garden_map = to_garden_map(item)

    var resulting_seed_ranges: seq[SeedRange] = @[]
    for seed_range in seed_ranges:
        # echo seed_range
        resulting_seed_ranges.add(apply_map_seed_range(seed_range, garden_map))
    seed_ranges = flatten(resulting_seed_ranges).toSeq

echo seed_ranges
echo seed_ranges.mapIt(it.lower).min
