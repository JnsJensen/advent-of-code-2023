import strutils
import sequtils
import strformat
import std/enumerate

type
    Position = tuple[x: int, y: int]
    Galaxy = tuple[id: int, position: Position]
    CharGrid = seq[seq[char]]

# let input = strip readFile "inputs/day11-example.txt"
let input = strip readFile "inputs/day11.txt"

func make_char_grid(input: string): CharGrid =
    for line in input.split("\n"):
        result.add(line.toSeq())

func find_empty_cols(grid: CharGrid): seq[int] =
    for col in grid[0].low..grid[0].high:
        var empty = true
        for row in grid.low..grid.high:
            if grid[row][col] != '.':
                empty = false
                break
        if empty:
            result.add(col)

func find_empty_rows(grid: CharGrid): seq[int] =
    for row in grid.low..grid.high:
        if all(grid[row], proc(c: char): bool = c == '.'):
            result.add(row)

func expand_row(row: seq[char], col: seq[int]): seq[char] =
    result = row
    for (cidx, c) in enumerate(col):
        result.insert('.', c + cidx)

func expand_grid(grid: CharGrid): CharGrid =
    let empty_rows = find_empty_rows(grid)
    let empty_cols = find_empty_cols(grid)

    for (ridx, row) in enumerate(grid):
        let new_row = expand_row(row, empty_cols)
        result.add(new_row)
        if ridx in empty_rows:
            result.add(new_row)

func find_galaxies(grid: CharGrid): seq[Galaxy] =
    var galaxy_id = 0
    for (ridx, row) in enumerate(grid):
        for (cidx, col) in enumerate(row):
            if col == '#':
                result.add((id: galaxy_id, position: (x: cidx, y: ridx)))
                galaxy_id += 1

func grid_distance(a: Position, b: Position): int =
    abs(a.x - b.x) + abs(a.y - b.y)

var gaps_crossed = 0

proc grid_distance_expanded(
    a: Position,
    b: Position,
    expansion_rows: seq[int],
    expansion_cols: seq[int],
    expansion: int = 0
): int =
    let x_span = toSeq (if a.x < b.x: (a.x+1)..(b.x-1) else: (b.x+1)..(a.x-1))
    let y_span = toSeq (if a.y < b.y: (a.y+1)..(b.y-1) else: (b.y+1)..(a.y-1))

    # echo fmt"x_span: {x_span}"
    # echo fmt"y_span: {y_span}"
    
    var expanded_gaps = 0
    for col in expansion_cols:
        if col in x_span:
            # echo fmt"col: {col}"
            expanded_gaps += 1
    for row in expansion_rows:
        if row in y_span:
            # echo fmt"row: {row}"
            expanded_gaps += 1
    
    # echo fmt"expanded_gaps: {expanded_gaps}"
    # echo fmt"a: {a}, b: {b}"
    # echo fmt"{grid_distance(a, b)} + {expanded_gaps} * {expansion} = {grid_distance(a, b) + expanded_gaps * expansion}"

    gaps_crossed += expanded_gaps
    result = grid_distance(a, b) + expanded_gaps * (if expansion == 1: expansion else: expansion - 1)


let char_grid = make_char_grid input

# for row in char_grid:
#     echo row.join("")

let empty_cols = find_empty_cols char_grid
let empty_rows = find_empty_rows char_grid

echo fmt"empty_cols: {empty_cols}"
echo fmt"empty_rows: {empty_rows}"

# let expanded_grid = expand_grid char_grid

# for row in expanded_grid:
#     echo row.join("")

let galaxies = find_galaxies char_grid

var distances1: seq[int] = @[]
var distances2: seq[int] = @[]
var distances3: seq[int] = @[]
var ids_tried: seq[tuple[a: int, b: int]] = @[]

for galaxy in galaxies:
    # echo fmt"galaxy: {galaxy}"
    for other in galaxies:
        if (galaxy.id, other.id) in ids_tried:
            continue
        ids_tried.add((galaxy.id, other.id))
        ids_tried.add((other.id, galaxy.id))
        if galaxy.id != other.id:
            let distance1 = grid_distance_expanded(
                galaxy.position,
                other.position,
                empty_rows,
                empty_cols,
                expansion = 1_000_000
            )
            distances1.add(distance1)
            # let distance2 = grid_distance_expanded(
            #     galaxy.position,
            #     other.position,
            #     empty_rows,
            #     empty_cols,
            #     expansion = 10
            # )
            # distances2.add(distance2)
            # let distance3 = grid_distance_expanded(
            #     galaxy.position,
            #     other.position,
            #     empty_rows,
            #     empty_cols,
            #     expansion = 100
            # )
            # distances3.add(distance3)

echo fmt"distances: {distances1.foldl(a + b)}"
# echo fmt"distances: {distances2} = {distances2.foldl(a + b)}"
# echo fmt"distances: {distances3} = {distances3.foldl(a + b)}"
# echo distances1.len
# echo gaps_crossed/3