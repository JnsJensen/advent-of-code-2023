import strutils
import sequtils
import tables
import std/enumerate
import options
{.experimental: "caseStmtMacros".}
import fusion/matching
import lib

type
    Op = enum
        EQUALS = "="
        MINUS = "-"
    Lense = tuple[name: string, f: int]
    LenseMap = Table[int, seq[Lense]]

let input = strip readFile "inputs/day15.txt"
# let input = strip readFile "inputs/day15-kristoffer.txt"
# let input = strip readFile "inputs/day15-example.txt"

# echo input.split(",")

proc hash(input: string): int =
    for c in input:
        result += ord(c)
        result *= 17
        result = result mod 256

func exists(lenses: seq[Lense], name: string): Option[int] =
    for (lidx, lense) in enumerate(lenses):
        if lense.name == name:
            return some(lidx)
    return none(int)

func focusing_power(box: int, lenses: seq[Lense]): int =
    var powers: seq[int] = @[]
    for (lidx, lense) in enumerate(lenses):
        powers.add (box + 1) * (lidx + 1) * lense.f
    result = if powers.len > 0: powers.foldl(a + b) else: 0

var lense_map: LenseMap = initTable[int, seq[Lense]]()

for i in 0..255:
    lense_map[i] = @[]

for step in input.split(","):
    let split_step = step.split({'=', '-'})
    # echo "split_step ", split_step
    let name = split_step[0]
    let op = if split_step[1].len <= 0: Op.MINUS else: Op.EQUALS
    let box_number = hash(name)
    # echo "name ", name, " op ", op, " box ", box_number
    if op == Op.EQUALS:
        let lense = (name: name, f: split_step[1].parseInt())
        case exists(lense_map[box_number], name):
        of Some(@idx):  
            # echo box_number, " b replacing: ", lense_map[box_number]
            lense_map[box_number][idx] = lense
            # echo box_number, " a replacing: ", lense_map[box_number]
        of None():
            # echo box_number, " b adding: ", lense_map[box_number]
            lense_map[box_number].add lense
            # echo box_number, " a adding: ", lense_map[box_number]
    if op == Op.MINUS:
        case exists(lense_map[box_number], name):
        of Some(@idx):
            # echo box_number, " b deleting: ", lense_map[box_number]
            lense_map[box_number].delete idx
            # echo box_number, " a deleting: ", lense_map[box_number]
        of None():
            discard

var focusing_powers: seq[int] = @[]
for box_number in 0..255:
    let box = lense_map[box_number]
    let power = focusing_power(box_number, box)
    # if box.len > 0: echo box, " ", power
    focusing_powers.add power

echo focusing_powers.foldl(a + b)

# let chars: seq[char] = @['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
# echo chars.del 1
# input.split(",").map(hash).foldl(a + b).echo

# var vals: seq[int] = @[]
# for step in input.split(","):
#     vals.add hash(step)
# echo vals.foldl(a + b)
