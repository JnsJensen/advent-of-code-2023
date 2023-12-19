import strutils
import sequtils
import std/enumerate
import lib

type
    Position = tuple[x: int, y: int]
    Direction = enum
        UP = "U"
        RIGHT = "R"
        DOWN = "D"
        LEFT = "L"
    Tile = enum
        EMPTY = "."
        HOLE = "#"
    Color = string
    TileGrid = seq[seq[Tile]]
    Instruction = tuple[direction: Direction, steps: int, color: Color]

proc move(direction: Direction, pos: var Position, steps: int = 1) =
    case direction:
    of UP: pos.y -= steps
    of RIGHT: pos.x += steps
    of DOWN: pos.y += steps
    of LEFT: pos.x -= steps

# let input = strip readFile "inputs/day18-example.txt"
let input: string = strip readFile "inputs/day18.txt"

var instructions: seq[Instruction] = input.split("\n").map(proc (it: string): Instruction =
    let split = it.split(" ")
    let direction = parseEnum[Direction] split[0]
    let steps = parseInt split[1]
    let color = split[2].replace("(", "").replace(")", "")
    return (direction, steps, color)
)

var bounds_pos: Position = (x: 0, y: 0)
var bounds_history: seq[Position] = @[bounds_pos]
for instruction in instructions:
    move(instruction.direction, bounds_pos, instruction.steps)
    bounds_history.add bounds_pos

let x_bounds = bounds_history.mapIt(it.x).minmax
let y_bounds = bounds_history.mapIt(it.y).minmax
echo "x_bounds: " & $x_bounds & ", y_bounds: " & $y_bounds

var pos: Position = (x: abs x_bounds[0], y: abs y_bounds[0])

let width = x_bounds[0].abs + x_bounds[1].abs + 1
let height = y_bounds[0].abs + y_bounds[1].abs + 1

var tile_grid: TileGrid = newSeqWith[TileGrid](height, newSeqWith[Tile](width, Tile.EMPTY))

proc handle_instruction(pos: var Position, instruction: Instruction) =
    case instruction.direction
    of Direction.UP:
        for i in 0 ..< instruction.steps:
            tile_grid[pos.y - i][pos.x] = Tile.HOLE
        pos.y -= instruction.steps
    of Direction.RIGHT:
        for i in 0 ..< instruction.steps:
            tile_grid[pos.y][pos.x + i] = Tile.HOLE
        pos.x += instruction.steps
    of Direction.DOWN:
        for i in 0 ..< instruction.steps:
            tile_grid[pos.y + i][pos.x] = Tile.HOLE
        pos.y += instruction.steps
    of Direction.LEFT:
        for i in 0 ..< instruction.steps:
            tile_grid[pos.y][pos.x - i] = Tile.HOLE
        pos.x -= instruction.steps

proc check_bounds(position: Position, grid: TileGrid): bool =
    result = true
    if position.x < 0 or position.x >= grid[0].len:
        result = false
    elif position.y < 0 or position.y >= grid.len:
        result = false

proc check_enclosed(pos: Position, grid: TileGrid, ignore: seq[Position]): bool =
    var wall_count = 0
    var prev = Tile.EMPTY
    var moving_pos = pos
    while true:
        move(Direction.LEFT, moving_pos)
        if check_bounds(moving_pos, grid) == false:
            break
        if grid[moving_pos.y][moving_pos.x] == Tile.HOLE and
           prev == Tile.EMPTY and
           not ignore.contains(moving_pos):
            wall_count += 1
        prev = grid[moving_pos.y][moving_pos.x]
    result = odd wall_count

func is_cap(instructions: seq[Instruction]): bool =
    assert instructions.len == 3
    result = false
    if instructions[instructions.low].direction == Direction.UP and
       instructions[instructions.high].direction == Direction.DOWN or
       instructions[instructions.low].direction == Direction.DOWN and
       instructions[instructions.high].direction == Direction.UP:
        result = true

let first_instruction = instructions[instructions.low]
let last_instruction = instructions[instructions.high]

instructions.add first_instruction
instructions.insert(last_instruction, instructions.low)

var ignore_walls: seq[Position] = @[]
var prev_pos: Position = pos
for (iidx, instruction_window) in enumerate window(
    sequence = instructions,
    size = 3,
):
    let instruction = instruction_window[1]
    prev_pos = pos
    handle_instruction(pos, instruction)
    if is_cap(instruction_window):
        let xs = @[prev_pos.x, pos.x]
        for i in min(xs) .. max(xs):
            ignore_walls.add (x: i, y: prev_pos.y)

var to_be_dug: seq[Position] = @[]
for y in tile_grid.low..tile_grid.high:
    for x in tile_grid[y].low..tile_grid[y].high:
        if check_enclosed((x: x, y: y), tile_grid, ignore_walls):
            to_be_dug.add (x: x, y: y)

for pos in to_be_dug:
    tile_grid[pos.y][pos.x] = Tile.HOLE

echo assemble tile_grid
echo tile_grid.mapIt(len it.filterIt(it == Tile.HOLE)).foldl(a + b)