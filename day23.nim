import sequtils
import strutils
import std/algorithm
import lib

type
    Position = tuple[x: int, y: int]
    Direction = enum
        Up = "^"
        Right = ">"
        Down = "v"
        Left = "<"
    Tile = enum
        Path = "."
        Wall = "#"
        StepU = "^"
        StepR = ">"
        StepD = "v"
        StepL = "<"
    TileGrid = seq[seq[Tile]]
    DirectionField = seq[seq[seq[Direction]]]
    # DirectionGrid = seq[seq[Direction]]

let input = strip readFile "inputs/day23-example.txt"
# let input = strip readFile "inputs/day23.txt"
let tile_grid: TileGrid = input.splitLines.mapIt(it.mapIt(parseEnum[Tile]($it)))

proc make_direction_field(tile_grid: TileGrid): DirectionField =

    var direction_field: DirectionField = newSeqWith(
        tile_grid.len,
        newSeqWith(
            tile_grid[0].len,
            newSeq[Direction]()
        )
    )
    echo assemble tile_grid

    # for every tile, make a list of possible directions to walk in

    for y in 0..tile_grid.high:
        for x in 0..tile_grid[0].high:
            let tile = tile_grid[y][x]
            case tile:
            of Tile.Wall:
                continue
            of Tile.Path:
                let adjacents = (
                    up: if y > 0: tile_grid[y-1][x] else: Tile.Wall,
                    right: if x < tile_grid[0].high: tile_grid[y][x+1] else: Tile.Wall,
                    down: if y < tile_grid.high: tile_grid[y+1][x] else: Tile.Wall,
                    left: if x > 0: tile_grid[y][x-1] else: Tile.Wall,
                )
                if adjacents.up == Tile.Path or adjacents.up == Tile.StepU:
                    direction_field[y][x].add(Direction.Up)
                if adjacents.right == Tile.Path or adjacents.right == Tile.StepR:
                    direction_field[y][x].add(Direction.Right)
                if adjacents.down == Tile.Path or adjacents.down == Tile.StepD:
                    direction_field[y][x].add(Direction.Down)
                if adjacents.left == Tile.Path or adjacents.left == Tile.StepL:
                    direction_field[y][x].add(Direction.Left)
            of Tile.StepU:
                direction_field[y][x].add(Direction.Up)
            of Tile.StepR:
                direction_field[y][x].add(Direction.Right)
            of Tile.StepD:
                direction_field[y][x].add(Direction.Down)
            of Tile.StepL:
                direction_field[y][x].add(Direction.Left)

    return direction_field


let direction_field = make_direction_field(tile_grid)
let ending_pos: Position = (x: tile_grid[0].high - 1, y: tile_grid.high)

var paths: seq[seq[Position]] = @[@[(x: 1, y: 0)]]

proc walk_all_paths(tile_grid: TileGrid, direction_field: DirectionField, paths: var seq[seq[Position]]) =
    var prev_total_length = 0
    while paths.mapIt(len it).foldl(a + b) != prev_total_length:
        prev_total_length = paths.mapIt(len it).foldl(a + b)

        var paths_to_add: seq[seq[Position]] = @[]
        # var paths_to_remove: seq[seq[Position]] = @[]

        for pidx, path in paths:
            let position = path[path.high]
            if position == ending_pos:
                continue
            let directions = direction_field[position.y][position.x]

            var new_positions: seq[Position] = @[]
            for direction in directions:
                let new_position = case direction:
                of Direction.Up:
                    (x: position.x, y: position.y - 1)
                of Direction.Right:
                    (x: position.x + 1, y: position.y)
                of Direction.Down:
                    (x: position.x, y: position.y + 1)
                of Direction.Left:
                    (x: position.x - 1, y: position.y)
                if new_position in path:
                    # paths_to_remove.add(path)
                    continue
                new_positions.add(new_position)
            
            for npidx, new_position in new_positions:
                # if new_position in path:
                #     paths_to_remove.add(path)
                if npidx == 0:
                    paths[pidx].add(new_position)
                else:
                    paths_to_add.add(path & @[new_position])

        # for path in paths_to_remove:
        #     paths.delete(paths.find(path))
        paths.add paths_to_add

proc len_cmp[T](a: seq[T], b: seq[T]): int =
    cmp(a.len, b.len)

walk_all_paths(tile_grid, direction_field, paths)

paths.sort(len_cmp, Descending)

echo "paths: ", paths.mapIt(it.len - 1)
# 2315 -> too low
# 2442 -> correct

var path_grid: TileGrid = newSeqWith(
    tile_grid.len,
    newSeqWith(
        tile_grid[0].len,
        Tile.Path
    )
)
for position in paths[0]:
    path_grid[position.y][position.x] = Tile.StepR

echo assemble path_grid, "\n"

var tile_grid_2: TileGrid = tile_grid
for y in 0..tile_grid_2.high:
    for x in 0..tile_grid_2[0].high:
        let tile = tile_grid_2[y][x]
        if tile == Tile.StepR or tile == Tile.StepL or tile == Tile.StepU or tile == Tile.StepD:
            tile_grid_2[y][x] = Tile.Path

let direction_field_2 = make_direction_field(tile_grid_2)
var paths2: seq[seq[Position]] = @[@[(x: 1, y: 0)]]
walk_all_paths(tile_grid_2, direction_field_2, paths2)
paths2 = paths2.filterIt(it[^1] == ending_pos)
paths2.sort(len_cmp, Descending)

echo "paths2: ", paths2.mapIt(it.len - 1)

var path_grid_2: TileGrid = newSeqWith(
    tile_grid_2.len,
    newSeqWith(
        tile_grid_2[0].len,
        Tile.Path
    )
)
for position in paths2[0]:
    path_grid_2[position.y][position.x] = Tile.StepR

echo assemble path_grid_2, "\n"