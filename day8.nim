import std/strutils
import sequtils
import tables
import std/enumerate
import std/math

type
    Direction = enum
        LEFT = "L"
        RIGHT = "R"
    # Node = tuple[id: string, left: string, right: string]
    Node = tuple[id: string, left: string, right: string]


let input = readFile "inputs/day8.txt"
# let input = readFile "inputs/day8-example.txt"

let input_processed = input.strip.split("\n\n")

let instructions = input_processed[0].mapIt(if it == 'R': Direction.RIGHT else: Direction.LEFT)
# echo instructions.mapIt(if it == 'R': Direction.RIGHT else: Direction.LEFT)

var nodes: Table[string, Node] = initTable[string, Node]()
# var first_id = ""

var all_starting_ids: seq[string] = @[]
var all_ending_ids: seq[string] = @[]

for (lidx, line) in enumerate(input_processed[1].split("\n")):
    let line_split = line.split({'=', ','}).mapIt(it.strip.replace("(", "").replace(")", ""))

    # if lidx == 0:
    #     first_id = line_split[0]
    if line_split[0].endsWith("A"):
        all_starting_ids.add(line_split[0])
    elif line_split[0].endsWith("Z"):
        all_ending_ids.add(line_split[0])
    
    nodes[line_split[0]] = (
        id: line_split[0],
        left: line_split[1],
        right: line_split[2]
    )

func step(nodes: Table[string, Node], node: Node, direction: Direction): Node =
    case direction:
    of Direction.LEFT:
        result = nodes[node.left]
    of Direction.RIGHT:
        result = nodes[node.right]

# echo nodes

var current_node = nodes["AAA"]
var count_p1 = 0
var found_p1 = false

echo instructions.join("")
# echo first_id

while not found_p1:
    for instruction in instructions:
        count_p1 += 1
        current_node = step(nodes, current_node, instruction)
        if current_node.id == "ZZZ":
            echo "Found it!"
            echo "Part 1: ", count_p1
            found_p1 = true

echo "Starting nodes: ", all_starting_ids.join(", ")
echo "Ending nodes:   ", all_ending_ids.join(", ")

var current_nodes: seq[Node] = all_starting_ids.mapIt(nodes[it])
# var found_node_amount: seq[bool] = all_starting_ids.mapIt(false)
var found_p2 = false
var cycles_found: seq[int] = all_starting_ids.mapIt(-1)
var count_p2 = 0

while not found_p2:
    for instruction in instructions:
        count_p2 += 1
        for (idx, node) in enumerate(current_nodes):
            current_nodes[idx] = step(nodes, node, instruction)
        
        for (nidx, node) in enumerate current_nodes:
            if node.id.endsWith("Z"):
                if cycles_found[nidx] == -1:
                    cycles_found[nidx] = count_p2

        if -1 notin cycles_found:
            echo "Found it!"
            echo "Step: ", count_p2, " Current nodes: ", current_nodes.mapIt(it.id).join(", ")
            echo "      ", len cycles_found, " cycles found: ", cycles_found
            found_p2 = true
            break

echo "Part 2: with cycels ", cycles_found.join(", "), " and lcm = ", lcm cycles_found
