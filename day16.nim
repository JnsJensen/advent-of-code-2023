import strutils
import sequtils
import strformat
import std/enumerate
import std/os

type
    Position = tuple[x: int, y: int]
    Direction = enum
        UP = "^"
        DOWN = "v"
        LEFT = "<"
        RIGHT = ">"
        # NONE = " "
    Laser = tuple[pos: Position, dir: Direction]
    Tile = enum
        EMPTY = "."
        MIRROR_UP = "/" 
        MIRROR_DOWN = "\\"
        SPLITTER_HOR = "-"
        SPLITTER_VER = "|"
    TileGrid = seq[seq[Tile]]
    EnergisedGrid = seq[seq[int]]

proc assemble[T](input: seq[seq[T]]): string =
    input.mapIt(it.join("")).join("\n")

let input = strip readFile "inputs/day16-example.txt"
let tile_grid: TileGrid = cast[seq[seq[char]]](input.split("\n")).mapIt(it.mapIt(parseEnum[Tile](fmt"{it}")))

echo assemble tile_grid

proc check_bounds(position: Position, grid: TileGrid): bool =
    result = true
    if position.x < 0 or position.x >= grid[0].len:
        result = false
    elif position.y < 0 or position.y >= grid.len:
        result = false

var energised_grid: EnergisedGrid = newSeqWith(tile_grid.len, newSeqWith(tile_grid[0].len, 0))
energised_grid[0][0] = 1
var movement_grid: seq[seq[char]] = newSeqWith(tile_grid.len, newSeqWith(tile_grid[0].len, '.'))

let lasers: seq[Laser] = @[(pos: (x: 0, y: 0), dir: Direction.RIGHT)]

proc move_lasers(lasers: seq[Laser], grid: TileGrid): seq[Laser] =
    result = lasers
    var new_lasers: seq[Laser] = @[]
    # var remove_lasers: seq[Laser] = @[]
    for (lidx, laser) in enumerate(lasers):
        let new_position: Position = case laser.dir
            of Direction.UP: (x: laser.pos.x, y: laser.pos.y - 1)
            of Direction.DOWN: (x: laser.pos.x, y: laser.pos.y + 1)
            of Direction.LEFT: (x: laser.pos.x - 1, y: laser.pos.y)
            of Direction.RIGHT: (x: laser.pos.x + 1, y: laser.pos.y)
        
        if check_bounds(new_position, grid):
            let grid_tile = grid[new_position.y][new_position.x]
            case grid_tile:
                of Tile.EMPTY:
                    # echo "empty"
                    new_lasers.add((pos: new_position, dir: laser.dir))
                of Tile.MIRROR_UP:
                    # echo "mirror up"
                    new_lasers.add((pos: new_position, dir: case laser.dir
                        of Direction.UP: Direction.RIGHT
                        of Direction.DOWN: Direction.LEFT
                        of Direction.LEFT: Direction.DOWN
                        of Direction.RIGHT: Direction.UP))
                of Tile.MIRROR_DOWN:
                    # echo "mirror down"
                    new_lasers.add((pos: new_position, dir: case laser.dir
                        of Direction.UP: Direction.LEFT
                        of Direction.DOWN: Direction.RIGHT
                        of Direction.LEFT: Direction.UP
                        of Direction.RIGHT: Direction.DOWN))
                of Tile.SPLITTER_HOR:
                    echo "splitter hor"
                    case laser.dir
                        of Direction.LEFT:
                            new_lasers.add((pos: new_position, dir: Direction.LEFT))
                        of Direction.RIGHT:
                            new_lasers.add((pos: new_position, dir: Direction.RIGHT))
                        else:
                            new_lasers.add((pos: new_position, dir: case laser.dir
                                of Direction.UP: Direction.LEFT
                                of Direction.DOWN: Direction.RIGHT
                                of Direction.LEFT: Direction.LEFT
                                of Direction.RIGHT: Direction.RIGHT))
                            new_lasers.add((pos: new_position, dir: case laser.dir
                                of Direction.UP: Direction.RIGHT
                                of Direction.DOWN: Direction.LEFT
                                of Direction.LEFT: Direction.LEFT
                                of Direction.RIGHT: Direction.RIGHT))
                of Tile.SPLITTER_VER:
                    echo "splitter ver"
                    case laser.dir
                        of Direction.UP:
                            new_lasers.add((pos: new_position, dir: Direction.UP))
                        of Direction.DOWN:
                            new_lasers.add((pos: new_position, dir: Direction.DOWN))
                        else:
                            new_lasers.add((pos: new_position, dir: case laser.dir
                                of Direction.UP: Direction.UP
                                of Direction.DOWN: Direction.DOWN
                                of Direction.LEFT: Direction.UP
                                of Direction.RIGHT: Direction.DOWN))
                            new_lasers.add((pos: new_position, dir: case laser.dir
                                of Direction.UP: Direction.UP
                                of Direction.DOWN: Direction.DOWN
                                of Direction.LEFT: Direction.DOWN
                                of Direction.RIGHT: Direction.UP))
            energised_grid[new_position.y][new_position.x] += 1
            movement_grid[new_position.y][new_position.x] = cast[char](case laser.dir
                of Direction.UP: '^'
                of Direction.DOWN: 'v'
                of Direction.LEFT: '<'
                of Direction.RIGHT: '>')
    
    echo "removing lasers ", lasers
    for laser in lasers:
        result.delete(result.find(laser))
    result.add new_lasers

var moving_lasers = lasers
var count = 0
while lasers.len > 0:
    count += 1
    moving_lasers = move_lasers(moving_lasers, tile_grid)
    # echo len moving_lasers
    echo moving_lasers
    echo assemble energised_grid
    echo assemble movement_grid
    sleep(500)
    # if count > 20:
    #     break

echo assemble energised_grid