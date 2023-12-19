import std/strutils
import options
import std/enumerate
import lib

type
    Direction = enum
        UP
        RIGHT
        DOWN
        LEFT
    TileType = enum
        LOOP = "L"
        OUTSIDE = "O"
        INSIDE = "I"
    Pipe = tuple[c1: Direction, c2: Direction]
    Piece = Option[Pipe]
    PieceGrid = seq[seq[Piece]]
    LoopGrid = seq[seq[TileType]]
    CharGrid = seq[seq[char]]
    Position = tuple[x: int, y: int]

func opposite(direction: Direction): Direction =
    case direction:
    of UP:
        DOWN
    of DOWN:
        UP
    of LEFT:
        RIGHT
    of RIGHT:
        LEFT

proc walk(direction: Direction, pos: Position): Position =
    case direction:
    of UP:
        result = (x: pos.x, y: pos.y - 1)
    of DOWN:
        result = (x: pos.x, y: pos.y + 1)
    of LEFT:
        result = (x: pos.x - 1, y: pos.y)
    of RIGHT:
        result = (x: pos.x + 1, y: pos.y)

# let input = strip readFile "inputs/day10-example.txt"
let input = strip readFile "inputs/day10.txt"

var grid: PieceGrid = @[]
var char_grid: CharGrid = @[]
var start: Position = (x: 0, y: 0)

for (lidx, line) in enumerate(input.split("\n")):
    var row: seq[Piece] = @[]
    var char_row: seq[char] = @[]
    for (cidx, c) in enumerate(line):
        char_row.add c
        case c:
        of 'F':
            row.add some (c1: DOWN, c2: RIGHT)
        of '7':
            row.add some (c1: DOWN, c2: LEFT)
        of 'L':
            row.add some (c1: UP, c2: RIGHT)
        of 'J':
            row.add some (c1: UP, c2: LEFT)
        of '-':
            row.add some (c1: LEFT, c2: RIGHT)
        of '|':
            row.add some (c1: UP, c2: DOWN)
        of 'S':
            row.add none Pipe
            start = (x: cidx, y: lidx)
        else:
            row.add none Pipe
    grid.add row
    char_grid.add char_row

func valid_connection(pipe: Pipe, direction: Direction): bool =
    case direction:
    of UP:
        pipe.c1 == DOWN or pipe.c2 == DOWN
    of DOWN:
        pipe.c1 == UP or pipe.c2 == UP
    of LEFT:
        pipe.c1 == RIGHT or pipe.c2 == RIGHT
    of RIGHT:
        pipe.c1 == LEFT or pipe.c2 == LEFT

# infer what type of pipe the start is
# var startPipe: Pipe

# in all 4 adjacent cells, add a pipe
var connections: seq[Direction] = @[]
for (pos, direction) in [
    ((start.x, start.y - 1), UP),
    ((start.x + 1, start.y), RIGHT),
    ((start.x, start.y + 1), DOWN),
    ((start.x - 1, start.y), LEFT)
]:
    let (x, y) = pos
    if x < 0 or y < 0 or y >= grid.len or x >= grid[y].len:
        continue
    let piece = grid[y][x]
    if isSome piece:
        if valid_connection(piece.get, direction):
            connections.add direction
    else:
        echo "no piece"
        continue

grid[start.y][start.x] = some (c1: connections[0], c2: connections[1])

# for row in grid:
#     echo row
# echo ""

var steps: seq[Direction] = @[]
var pos = start
var ended = false
var came_from: Option[Direction] = none Direction

var loop_grid: LoopGrid = newSeq[seq[TileType]](grid.len)
for r in 0 ..< grid.len:
    loop_grid[r] = newSeq[TileType](grid[r].len)
    for c in 0 ..< grid[r].len:
        loop_grid[r][c] = OUTSIDE

# echo loop_grid
loop_grid[start.y][start.x] = LOOP

while not ended:
    let piece = grid[pos.y][pos.x]

    if pos.x == start.x and pos.y == start.y and isSome came_from:
        ended = true
        break

    let pipe = get piece
    let next_direction = if isNone came_from:
        pipe.c1 else:
            if pipe.c1 == came_from.get:
                pipe.c2
            else: pipe.c1

    came_from = some opposite next_direction
    pos = walk(next_direction, pos)
    loop_grid[pos.y][pos.x] = LOOP
    steps.add next_direction

func is_7(pipe: Pipe): bool =
    return pipe.c1 == DOWN and pipe.c2 == LEFT or
        pipe.c1 == LEFT and pipe.c2 == DOWN

func is_J(pipe: Pipe): bool =
    return pipe.c1 == UP and pipe.c2 == LEFT or
        pipe.c1 == LEFT and pipe.c2 == UP

func is_F(pipe: Pipe): bool =
    return pipe.c1 == DOWN and pipe.c2 == RIGHT or
        pipe.c1 == RIGHT and pipe.c2 == DOWN

func is_L(pipe: Pipe): bool =
    return pipe.c1 == UP and pipe.c2 == RIGHT or
        pipe.c1 == RIGHT and pipe.c2 == UP

func is_vertical(pipe: Pipe): bool =
    return pipe.c1 == UP and pipe.c2 == DOWN or
        pipe.c1 == DOWN and pipe.c2 == UP

proc check_enclosed(pos: Position): bool =
    var left_amount = 0
    var prev = ""
    var moving_pos = pos
    while true:
        moving_pos = walk(LEFT, moving_pos)
        if moving_pos.x < 0 or moving_pos.y < 0 or moving_pos.y > loop_grid.high or moving_pos.x > loop_grid[moving_pos.y].high:
            break
        if loop_grid[moving_pos.y][moving_pos.x] == LOOP:
            let piece = grid[moving_pos.y][moving_pos.x]
            let pipe = get piece
            if is_vertical(pipe):
                # echo "vertical"
                left_amount += 1
            elif is_7(pipe):
                prev = "7"
            elif is_J(pipe):
                prev = "J"
            elif is_F(pipe):
                if prev == "J":
                    left_amount += 1
                prev = "F"
            elif is_L(pipe):
                if prev == "7":
                    left_amount += 1
                prev = "L"
                
    return odd left_amount

var enclosed_area = 0
for r in 0 ..< loop_grid.len:
    for c in 0 ..< loop_grid[r].len:
        if loop_grid[r][c] == OUTSIDE:
            if check_enclosed((x: c, y: r)):
                loop_grid[r][c] = INSIDE
                enclosed_area += 1

for row in loop_grid:
    echo row.join("")

echo int steps.len / 2
echo enclosed_area