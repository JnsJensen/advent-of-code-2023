import strutils
import sequtils
import std/enumerate
import strformat
import lib

type
    Rock = enum
        SQUARE = "#"
        ROUND = "O"
        EMPTY = "."
    Disc = seq[seq[Rock]]

# let input = strip readFile "inputs/day14.txt"
let input = strip readFile "inputs/day14-example.txt"

func find_square_rock(row: seq[Rock]): seq[int] =
    for (cidx, c) in enumerate(row):
        if c == Rock.SQUARE:
            result.add(cidx)
    

func find_round_rocks(row: seq[Rock]): seq[int] =
    for (cidx, c) in enumerate(row):
        if c == Rock.ROUND:
            result.add(cidx)

proc assemble_disc(input: Disc): string =
    input.mapIt(it.join("")).join("\n")

let disc: Disc = cast[seq[seq[char]]](input.split("\n")).mapIt(it.mapIt(parseEnum[Rock](fmt"{it}")))
echo assemble_disc disc, "\n"
echo assemble_disc rotate disc, "\n"
echo assemble_disc rotate rotate disc, "\n"
# var grid: seq[seq[Rock]] = rotate input.split("\n").map(split)

# .mapIt(it.mapIt(parseEnum[Rock](it))) #.mapIt(it.mapIt(parseEnum[Rock](it)))

# echo grid.mapIt(it.join("")).join("\n")

var weights: seq[int] = @[]
for line in disc:
    var square_rocks: seq[int] = @[-1]
    square_rocks.add find_square_rock(line) 
    square_rocks.add int.high
    let round_rocks = find_round_rocks(line)

    echo square_rocks, round_rocks


    for square_pair in pairs(square_rocks):
        var round_in_interval: seq[int] = @[]
        for (ridx, round) in enumerate(round_rocks):
            if round in square_pair.lower .. square_pair.upper:
                round_in_interval.add round
        for idx in 0 .. round_in_interval.high:
            round_in_interval[idx] = disc[0].len - (idx + 1 + square_pair.lower)
        echo "round_in_interval: ", round_in_interval

        weights.add round_in_interval

echo weights.foldl(a + b)