import sequtils
import strutils
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

let input = strip readFile "inputs/day23-example.txt"
let tile_grid: TileGrid = input.splitLines.mapIt(it.mapIt(parseEnum[Tile]($it)))
var direction_field: seq[seq[seq[Direction]]] = newSeqWith(
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

echo "direction field: ", direction_field

# var moving_positions: seq[Position] = @[(x: 1, y: 0)]
let ending_pos: Position = (x: tile_grid[0].high - 1, y: tile_grid.high)

var paths: seq[seq[Position]] = @[@[(x: 1, y: 0)]]

var prev_total_length = 0
while paths.mapIt(len it).foldl(a + b) != prev_total_length:
    prev_total_length = paths.mapIt(len it).foldl(a + b)
    var paths_to_add: seq[seq[Position]] = @[]
    var paths_to_remove: seq[int] = @[]
    for pidx, path in paths:
        let position = path[path.high]
        if position == ending_pos:
            continue
        let directions = direction_field[position.y][position.x]
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
                continue
            paths_to_remove.add(pidx)
            paths_to_add.add(path & @[new_position])
    # remove paths that have reached the end
    for pidx in paths_to_remove:
        paths.delete(pidx)
    # add new paths
    for path in paths_to_add:
        paths.add(path)
            
echo "paths: ", paths  
    