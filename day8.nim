import std/strutils
import sequtils
import tables
import std/enumerate

type
    Direction = enum
        LEFT = "L"
        RIGHT = "R"
    # Node = tuple[id: string, left: string, right: string]
    Node = tuple[id: string, left: string, right: string]


let input = readFile "inputs/day8.txt"

let input_processed = input.strip.split("\n\n")

let instructions = input_processed[0].mapIt(if it == 'R': Direction.RIGHT else: Direction.LEFT)
# echo instructions.mapIt(if it == 'R': Direction.RIGHT else: Direction.LEFT)

var nodes: Table[string, Node] = initTable[string, Node]()
var first_id = ""

for (lidx, line) in enumerate(input_processed[1].split("\n")):
    let line_split = line.split({'=', ','}).mapIt(it.strip.replace("(", "").replace(")", ""))

    if lidx == 0:
        first_id = line_split[0]
    
    nodes[line_split[0]] = (
        id: line_split[0],
        left: line_split[1],
        right: line_split[2]
    )

# echo nodes

var current_node = nodes[first_id]
var count = 0
var found = false

while not found:
    for instruction in instructions:
        count += 1
        # echo instruction.typeof
        # echo current_node

        case instruction:
        of Direction.LEFT:
            current_node = nodes[current_node.left]
        of Direction.RIGHT:
            current_node = nodes[current_node.right]
        else:
            echo "Unknown instruction"

        if current_node.id == "ZZZ":
            echo "Found it!"
            echo count
            found = true
