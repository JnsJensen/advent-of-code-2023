import strutils
import sequtils
import strformat
import std/enumerate
import lib
# import std/os

type
    Position = tuple[x: int, y: int]
    Direction = enum
        UP = "^"
        DOWN = "v"
        LEFT = "<"
        RIGHT = ">"
        # NONE = " "
    Laser = tuple[pos: Position, dir: Direction]
    LaserEntry = tuple[laser: Laser, history: seq[Laser]]
    Tile = enum
        EMPTY = "."
        MIRROR_UP = "/" 
        MIRROR_DOWN = "\\"
        SPLITTER_HOR = "-"
        SPLITTER_VER = "|"
    TileGrid = seq[seq[Tile]]
    EnergisedGrid = seq[seq[int]]

# let input = strip readFile "inputs/day16-example.txt"
let input = strip readFile "inputs/day16.txt"
let tile_grid: TileGrid = cast[seq[seq[char]]](input.split("\n")).mapIt(it.mapIt(parseEnum[Tile](fmt"{it}")))

# echo assemble tile_grid

proc check_bounds(position: Position, grid: TileGrid): bool =
    result = true
    if position.x < 0 or position.x >= grid[0].len:
        result = false
    elif position.y < 0 or position.y >= grid.len:
        result = false

var energised_grid: EnergisedGrid = newSeqWith(tile_grid.len, newSeqWith(tile_grid[0].len, 0))
energised_grid[0][0] = 1
var movement_grid: seq[seq[char]] = newSeqWith(tile_grid.len, newSeqWith(tile_grid[0].len, '.'))

let lasers: seq[LaserEntry] = @[(laser: (pos: (x: -1, y: 0), dir: Direction.RIGHT), history: @[])]

proc check_cycle(history: seq[Laser], laser: Laser): bool =
    result = false
    for (idx, laser_entry) in enumerate(history):
        if laser_entry.pos == laser.pos and laser_entry.dir == laser.dir:
            result = true
            break

proc move_lasers(laser_entries: seq[LaserEntry], grid: TileGrid): seq[LaserEntry] =
    result = laser_entries
    var new_laser_entries: seq[LaserEntry] = @[]
    # var remove_lasers: seq[Laser] = @[]
    let all_previous_histories = toSeq flatten laser_entries.mapIt(it.history)
    for (lidx, laser_entry) in enumerate(laser_entries):
        let new_position: Position = case laser_entry.laser.dir
            of Direction.UP: (x: laser_entry.laser.pos.x, y: laser_entry.laser.pos.y - 1)
            of Direction.DOWN: (x: laser_entry.laser.pos.x, y: laser_entry.laser.pos.y + 1)
            of Direction.LEFT: (x: laser_entry.laser.pos.x - 1, y: laser_entry.laser.pos.y)
            of Direction.RIGHT: (x: laser_entry.laser.pos.x + 1, y: laser_entry.laser.pos.y)
        
        if check_bounds(new_position, grid):
            let grid_tile = grid[new_position.y][new_position.x]
            case grid_tile:
                of Tile.EMPTY:
                    # echo "empty"
                    let new_laser = (pos: new_position, dir: laser_entry.laser.dir)
                    var new_history = laser_entry.history
                    new_history.add(new_laser)
                    if not check_cycle(all_previous_histories, new_laser):
                        new_laser_entries.add((laser: new_laser, history: new_history))
                of Tile.MIRROR_UP:
                    # echo "mirror up"
                    let new_laser = (pos: new_position, dir: case laser_entry.laser.dir
                        of Direction.UP: Direction.RIGHT
                        of Direction.DOWN: Direction.LEFT
                        of Direction.LEFT: Direction.DOWN
                        of Direction.RIGHT: Direction.UP)
                    var new_history = laser_entry.history
                    new_history.add(new_laser)
                    if not check_cycle(all_previous_histories, new_laser):
                        new_laser_entries.add((laser: new_laser, history: new_history))
                of Tile.MIRROR_DOWN:
                    # echo "mirror down"
                    let new_laser = (pos: new_position, dir: case laser_entry.laser.dir
                        of Direction.UP: Direction.LEFT
                        of Direction.DOWN: Direction.RIGHT
                        of Direction.LEFT: Direction.UP
                        of Direction.RIGHT: Direction.DOWN)
                    var new_history = laser_entry.history
                    new_history.add(new_laser)
                    if not check_cycle(all_previous_histories, new_laser):
                        new_laser_entries.add((laser: new_laser, history: new_history))
                of Tile.SPLITTER_HOR:
                    # echo "splitter hor"
                    case laser_entry.laser.dir
                        of Direction.LEFT:
                            # new_laser_entries.add((pos: new_position, dir: Direction.LEFT))
                            let new_laser = (pos: new_position, dir: Direction.LEFT)
                            var new_history = laser_entry.history
                            new_history.add(new_laser)
                            if not check_cycle(all_previous_histories, new_laser):
                                new_laser_entries.add((laser: new_laser, history: new_history))
                        of Direction.RIGHT:
                            # new_laser_entries.add((pos: new_position, dir: Direction.RIGHT))
                            let new_laser = (pos: new_position, dir: Direction.RIGHT)
                            var new_history = laser_entry.history
                            new_history.add(new_laser)
                            if not check_cycle(all_previous_histories, new_laser):
                                new_laser_entries.add((laser: new_laser, history: new_history))
                        else:
                            let new_laser1 = (pos: new_position, dir: case laser_entry.laser.dir
                                of Direction.UP: Direction.LEFT
                                of Direction.DOWN: Direction.RIGHT
                                of Direction.LEFT: Direction.LEFT
                                of Direction.RIGHT: Direction.RIGHT)
                            var new_history1 = laser_entry.history
                            new_history1.add(new_laser1)
                            if not check_cycle(all_previous_histories, new_laser1):
                                new_laser_entries.add((laser: new_laser1, history: new_history1))

                            let new_laser2 = (pos: new_position, dir: case laser_entry.laser.dir
                                of Direction.UP: Direction.RIGHT
                                of Direction.DOWN: Direction.LEFT
                                of Direction.LEFT: Direction.LEFT
                                of Direction.RIGHT: Direction.RIGHT)
                            var new_history2 = laser_entry.history
                            new_history2.add(new_laser2)
                            if not check_cycle(all_previous_histories, new_laser2):
                                new_laser_entries.add((laser: new_laser2, history: new_history2))
                of Tile.SPLITTER_VER:
                    # echo "splitter ver"
                    case laser_entry.laser.dir
                        of Direction.UP:
                            let new_laser = (pos: new_position, dir: Direction.UP)
                            var new_history = laser_entry.history
                            new_history.add(new_laser)
                            if not check_cycle(all_previous_histories, new_laser):
                                new_laser_entries.add((laser: new_laser, history: new_history))
                        of Direction.DOWN:
                            let new_laser = (pos: new_position, dir: Direction.DOWN)
                            var new_history = laser_entry.history
                            new_history.add(new_laser)
                            if not check_cycle(all_previous_histories, new_laser):
                                new_laser_entries.add((laser: new_laser, history: new_history))
                        else:
                            let new_laser1 = (pos: new_position, dir: case laser_entry.laser.dir
                                of Direction.UP: Direction.UP
                                of Direction.DOWN: Direction.DOWN
                                of Direction.LEFT: Direction.UP
                                of Direction.RIGHT: Direction.DOWN)
                            var new_history1 = laser_entry.history
                            new_history1.add(new_laser1)
                            if not check_cycle(all_previous_histories, new_laser1):
                                new_laser_entries.add((laser: new_laser1, history: new_history1))

                            let new_laser2 = (pos: new_position, dir: case laser_entry.laser.dir
                                of Direction.UP: Direction.UP
                                of Direction.DOWN: Direction.DOWN
                                of Direction.LEFT: Direction.DOWN
                                of Direction.RIGHT: Direction.UP)
                            var new_history2 = laser_entry.history
                            new_history2.add(new_laser2)
                            if not check_cycle(all_previous_histories, new_laser2):
                                new_laser_entries.add((laser: new_laser2, history: new_history2))
            energised_grid[new_position.y][new_position.x] += 1
            movement_grid[new_position.y][new_position.x] = cast[char](case laser_entry.laser.dir
                of Direction.UP: '^'
                of Direction.DOWN: 'v'
                of Direction.LEFT: '<'
                of Direction.RIGHT: '>')
    
    # echo "removing laser_entries ", laser_entries
    for laser_entry in laser_entries:
        result.delete(result.find(laser_entry))
    # check_cycles(new_laser_entries)
    result.add new_laser_entries

var all_starting_lasers: seq[LaserEntry] = @[]

for y in 0..tile_grid.high:
    all_starting_lasers.add((laser: (pos: (x: -1, y: y), dir: Direction.RIGHT), history: @[]))
    all_starting_lasers.add((laser: (pos: (x: tile_grid[0].len, y: y), dir: Direction.LEFT), history: @[]))

for x in 0..tile_grid[0].high:
    all_starting_lasers.add((laser: (pos: (x: x, y: -1), dir: Direction.DOWN), history: @[]))
    all_starting_lasers.add((laser: (pos: (x: x, y: tile_grid.len), dir: Direction.UP), history: @[]))
        

var energy: seq[int] = @[]
proc process_input(grid: TileGrid, starting_lasers: seq[LaserEntry]) =
    var moving_lasers = starting_lasers
    while moving_lasers.len > 0:
        moving_lasers = move_lasers(moving_lasers, tile_grid)
    energy.add energised_grid.mapIt(it.mapIt(if it > 0: 1 else: 0).foldl(a + b)).foldl(a + b)
    energised_grid = newSeqWith(tile_grid.len, newSeqWith(tile_grid[0].len, 0))
# var moving_lasers = lasers
# var count = 0
# while moving_lasers.len > 0:
#     count += 1
#     moving_lasers = move_lasers(moving_lasers, tile_grid)
#     echo assemble movement_grid
#     echo ""

process_input(tile_grid, lasers)
echo energy.foldl(a + b)

energy = @[]
var count = 0
for starting_laser in all_starting_lasers:
    count += 1
    echo "Processing laser ", count
    process_input(tile_grid, @[starting_laser])

echo max energy
# echo energised_grid.mapIt(it.mapIt(if it > 0: 1 else: 0).foldl(a + b)).foldl(a + b)