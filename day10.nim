import std/strutils
import options
import std/enumerate
import std/strformat
import sequtils

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
    Position = tuple[x: int, y: int]

func even(n: int): bool = n mod 2 == 0
func odd(n: int): bool = n mod 2 == 1

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

let input = strip readFile "inputs/day10-example.txt"
# let input = strip readFile "inputs/day10.txt"

var grid: PieceGrid = @[]
var start: Position = (x: 0, y: 0)

for (lidx, line) in enumerate(input.split("\n")):
    var row: seq[Piece] = @[]
    for (cidx, c) in enumerate(line):
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
var startPipe: Pipe

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

func is_horizontal(piece: Piece): bool =
    if isNone piece:
        return false
    let pipe = get piece
    return pipe.c1 == LEFT or pipe.c1 == RIGHT or pipe.c2 == LEFT or pipe.c2 == RIGHT

func is_vertical(piece: Piece): bool =
    if isNone piece:
        return false
    let pipe = get piece
    return pipe.c1 == UP or pipe.c1 == DOWN or pipe.c2 == UP or pipe.c2 == DOWN

proc check_enclosed(pos: Position): bool =
    var
        up = false
        down = false
        left = false
        right = false
        up_amount = 0
        down_amount = 0
        left_amount = 0
        right_amount = 0

    var moving_pos = pos
    while true:
        moving_pos = walk(UP, moving_pos)
        if moving_pos.x < 0 or moving_pos.y < 0 or moving_pos.y > loop_grid.high or moving_pos.x > loop_grid[moving_pos.y].high:
            break
        if loop_grid[moving_pos.y][moving_pos.x] == LOOP:
            let piece = grid[moving_pos.y][moving_pos.x]
            if is_horizontal(piece):
                up = true
                up_amount += 1
    
    moving_pos = pos
    while true:
        moving_pos = walk(DOWN, moving_pos)
        if moving_pos.x < 0 or moving_pos.y < 0 or moving_pos.y > loop_grid.high or moving_pos.x > loop_grid[moving_pos.y].high:
            break
        if loop_grid[moving_pos.y][moving_pos.x] == LOOP:
            let piece = grid[moving_pos.y][moving_pos.x]
            if is_horizontal(piece):
                down = true
                down_amount += 1
    
    moving_pos = pos
    while true:
        moving_pos = walk(LEFT, moving_pos)
        if moving_pos.x < 0 or moving_pos.y < 0 or moving_pos.y > loop_grid.high or moving_pos.x > loop_grid[moving_pos.y].high:
            break
        if loop_grid[moving_pos.y][moving_pos.x] == LOOP:
            let piece = grid[moving_pos.y][moving_pos.x]
            if is_vertical(piece):
                left = true
                left_amount += 1
    
    moving_pos = pos
    while true:
        moving_pos = walk(RIGHT, moving_pos)
        # echo fmt"pos: {moving_pos}"
        # echo fmt"moving_pos.x < 0: {moving_pos.x < 0}"
        # echo fmt"moving_pos.y < 0: {moving_pos.y < 0}"
        # echo fmt"moving_pos.y > loop_grid.high: {moving_pos.y > loop_grid.high}"
        # echo fmt"moving_pos.x > loop_grid[moving_pos.y].high: {moving_pos.x > loop_grid[moving_pos.y].high}"
        if moving_pos.x < 0 or moving_pos.y < 0 or moving_pos.y > loop_grid.high or moving_pos.x > loop_grid[moving_pos.y].high:
            # echo "break"
            break
        if loop_grid[moving_pos.y][moving_pos.x] == LOOP:
            # echo "LOOP"
            let piece = grid[moving_pos.y][moving_pos.x]
            if is_vertical(piece):
                right = true
                right_amount += 1
    
    echo fmt"up: {up_amount}, down: {down_amount}, left: {left_amount}, right: {right_amount}"
    echo fmt"up: {up}, down: {down}, left: {left}, right: {right}"

    if up and down and left and right:
    #     and
    #    all([up_amount, down_amount, left_amount, right_amount], even) or
    #    all([up_amount, down_amount, left_amount, right_amount], odd):
        return true
    return false

# var enclosed_area = 0
# for r in 0 ..< loop_grid.len:
#     for c in 0 ..< loop_grid[r].len:
#         if loop_grid[r][c] == OUTSIDE:
#             if check_enclosed((x: c, y: r)):
#                 loop_grid[r][c] = INSIDE
#                 enclosed_area += 1


echo fmt"loop_grid.high: {loop_grid.high}"
echo fmt"loop_grid[0].high: {loop_grid[0].high}"
echo check_enclosed((x: 13, y: 5))

# mask the grid with the loop grid
# var masked_grid: PieceGrid = @[]


for row in loop_grid:
    echo row.join("")

echo int steps.len / 2
# echo enclosed_area