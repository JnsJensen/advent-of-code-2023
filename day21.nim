import strutils
import sequtils
import std/enumerate
import os
import std/algorithm
import lib

type
    Position = tuple[x: int, y: int]
    Tile = enum
        Garden = "."
        Rock = "#"
        Occupied = "O"
        Start = "S"
    TileGrid = seq[seq[Tile]]

# let input = strip readFile "inputs/day21-example.txt"
let input = strip readFile "inputs/day21.txt"

var tile_grid: TileGrid = input.split("\n").mapIt(it.mapIt(parseEnum[Tile]($it)))
let clean_grid = tile_grid.mapIt(it.mapIt(if it == Tile.Start: Tile.Garden else: it))
echo assemble tile_grid

var starting_pos: Position = (x: 0, y: 0)
for (y, x) in enumerate tile_grid.mapIt(it.find(Tile.Start)):
    if x != -1:
        starting_pos = (x: x, y: y)
        break

tile_grid[starting_pos.y][starting_pos.x] = Tile.Occupied

echo assemble tile_grid

proc pos_cmp(a, b: Position): int =
    if a.y == b.y:
        return cmp(a.x, b.x)
    else:
        return cmp(a.y, b.y)

proc find_adjacents(
    tile_grid: TileGrid,
    tile_type: Tile,
    filter: seq[Tile] = @[Tile.Occupied, Tile.Start, Tile.Rock, Tile.Garden]
): seq[Position] =
    for x in 0..tile_grid[0].high:
        for y in 0..tile_grid.high:
            let tile = tile_grid[y][x]
            if tile == tile_type:
                let affected_positions: seq[Position] = @[
                    if y > 0 and tile_grid[y - 1][x] in filter:
                        (x: x, y: y - 1)
                    else: (x: -1, y: -1),

                    if x < tile_grid[0].high and tile_grid[y][x + 1] in filter:
                        (x: x + 1, y: y)
                    else: (x: -1, y: -1),

                    if y < tile_grid.high and tile_grid[y + 1][x] in filter:
                        (x: x, y: y + 1)
                    else: (x: -1, y: -1),

                    if x > 0 and tile_grid[y][x - 1] in filter:
                        (x: x - 1, y: y)
                    else: (x: -1, y: -1),
                ].filterIt(it.x != -1)
                for position in affected_positions:
                    if position notin result:
                        result.add(position)


proc step(tile_grid: TileGrid, affected_positions: seq[Position]): TileGrid =
    result = clean_grid
    result[starting_pos.y][starting_pos.x] = Tile.Garden
    for position in affected_positions:
        result[position.y][position.x] = Tile.Occupied

for _ in 1..64:
    let affected_positions = find_adjacents(tile_grid, Tile.Occupied, filter = @[Tile.Garden])
    # echo affected_positions
    tile_grid = step(tile_grid, affected_positions)
    # sleep 500
    # echo assemble tile_grid, "\n"

echo tile_grid.mapIt(it.filterIt(it == Tile.Occupied).len).foldl(a + b)

# let rock_adjacents = find_adjacents(clean_grid, Tile.Rock, filter = @[Tile.Garden])
# echo rock_adjacents.sorted(pos_cmp)

# let occupied_adjacents = find_adjacents(tile_grid, Tile.Occupied)
# echo occupied_adjacents.sorted(pos_cmp).filterIt(clean_grid[it.y][it.x] == Tile.Rock).len

# var count = 0
# for x in 0..tile_grid[0].high:
#     for y in 0..tile_grid.high:
#         let tile = tile_grid[y][x]
#         if tile == Tile.Occupied and (x: x, y: y) in garden_adjacents:
#             count.inc

# echo count