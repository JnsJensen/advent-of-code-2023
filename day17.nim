import strutils
import sequtils
import strformat
import std/algorithm

type
    Position = tuple[x: int, y: int]
    Direction = enum
        UP = "^"
        DOWN = "v"
        LEFT = "<"
        RIGHT = ">"
    HeatGrid = seq[seq[int]]
    HeatDirection = tuple[dir: Direction, heat: int]
    State = tuple[pos: Position, dir: Direction]
    StateHistory = seq[State]

proc assemble[T](input: seq[seq[T]]): string =
    input.mapIt(it.join("")).join("\n")

proc move_pos(pos: var Position, dir: Direction) =
    case dir
    of Direction.UP: pos.y -= 1
    of Direction.DOWN: pos.y += 1
    of Direction.LEFT: pos.x -= 1
    of Direction.RIGHT: pos.x += 1

proc move(state: var State) =
    move_pos(state.pos, state.dir)

proc heat_cmp(a, b: HeatDirection): int =
    cmp(a.heat, b.heat)

func opposite(dir: Direction): Direction =
    case dir
    of Direction.UP: Direction.DOWN
    of Direction.DOWN: Direction.UP
    of Direction.LEFT: Direction.RIGHT
    of Direction.RIGHT: Direction.LEFT

func dir_to_char(dir: Direction): char =
    case dir
    of Direction.UP: '^'
    of Direction.DOWN: 'v'
    of Direction.LEFT: '<'
    of Direction.RIGHT: '>'

let input = strip readFile "inputs/day17-example.txt"
let heat_grid: HeatGrid = input.split("\n").mapIt(it.mapIt(parseInt fmt"{it}"))
var movement_grid: seq[seq[char]] = newSeqWith(heat_grid.len, newSeqWith(heat_grid[0].len, '.'))

let starting_pos: Position = (x: 0, y: 0)
let ending_pos: Position = (x: heat_grid[0].high, y: heat_grid.high)
var state: State = (pos: starting_pos, dir: Direction.DOWN)
var state_history: StateHistory = @[state]

while state.pos != ending_pos:
    movement_grid[state.pos.y][state.pos.x] = dir_to_char state.dir

    var heats: seq[HeatDirection] = @[
        (dir: Direction.UP, heat: if state.pos.y == heat_grid.low : int.high else: heat_grid[state.pos.y - 1][state.pos.x]),
        (dir: Direction.DOWN, heat: if state.pos.y == heat_grid.high : int.high else: heat_grid[state.pos.y + 1][state.pos.x]),
        (dir: Direction.LEFT, heat: if state.pos.x == heat_grid[0].low : int.high else: heat_grid[state.pos.y][state.pos.x - 1]),
        (dir: Direction.RIGHT, heat: if state.pos.x == heat_grid[0].high : int.high else: heat_grid[state.pos.y][state.pos.x + 1])
    ]

    echo heats
    heats.sort(heat_cmp)
    echo heats

    for heat in heats:
        let dir = heat.dir
        var new_pos = state.pos
        move_pos(new_pos, dir)
        if (heat.dir != opposite state.dir) and (new_pos notin state_history.mapIt(it.pos)):
            state.dir = heat.dir
            break

    move(state)
    state_history.add(state)

    echo assemble movement_grid

echo assemble heat_grid