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

func grid_distance_expanded(
    a: Position,
    b: Position,
    expansion_rows: seq[int],
    expansion_cols: seq[int],
    expansion: int = 0
): int =
    let x_span = toSeq (if a.x < b.x: (a.x+1)..(b.x-1) else: (b.x+1)..(a.x-1))
    let y_span = toSeq (if a.y < b.y: (a.y+1)..(b.y-1) else: (b.y+1)..(a.y-1))
    
    var expanded_gaps = 0
    for col in expansion_cols:
        if col in x_span:
            expanded_gaps += 1
    for row in expansion_rows:
        if row in y_span:
            expanded_gaps += 1
    
    result = grid_distance(a, b) + expanded_gaps * (if expansion == 1: expansion else: expansion - 1)

func calc_all_distances(galaxies: seq[Galaxy], expansion_rows: seq[int] = @[], expansion_cols: seq[int] = @[], expansion: int = 0): seq[int] =
    var ids_tried: seq[tuple[a: int, b: int]] = @[]
    for galaxy in galaxies:
        for other in galaxies:
            if (galaxy.id, other.id) in ids_tried:
                continue
            ids_tried.add((galaxy.id, other.id))
            ids_tried.add((other.id, galaxy.id))
            if galaxy.id != other.id:
                result.add(
                    grid_distance_expanded(
                        galaxy.position,
                        other.position,
                        expansion_rows,
                        expansion_cols,
                        expansion = expansion
                    )
                )

let char_grid = make_char_grid input

let empty_cols = find_empty_cols char_grid
let empty_rows = find_empty_rows char_grid

echo fmt"empty_cols: {empty_cols}"
echo fmt"empty_rows: {empty_rows}"

let galaxies = find_galaxies char_grid

let distances_exp_1 = calc_all_distances(galaxies, expansion_rows = empty_rows, expansion_cols = empty_cols, expansion = 1)
let distances_exp_1m = calc_all_distances(galaxies, expansion_rows = empty_rows, expansion_cols = empty_cols, expansion = 1_000_000)

echo fmt"part 1: {distances_exp_1.foldl(a + b)}"
echo fmt"part 2: {distances_exp_1m.foldl(a + b)}"