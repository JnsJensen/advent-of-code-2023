import sequtils
import strutils
import unpack
import std/strformat
import tables
import typetraits
import math
import lib
import std/algorithm
import std/sets

type
    Name = string
    Position = tuple[x: int, y: int, z: int]
    Brick = tuple[s: Position, e: Position]
    BrickGrid = seq[seq[seq[Name]]]

# proc y_view(brick_grid: BrickGrid, empty: string = "______|") =
#     for z in 0..brick_grid[0][0].high:
#         echo brick_grid
#             .mapIt(
#                 it.mapIt(it[z]).filterIt(it != empty)
#             )
#             .mapIt(if it.len > 0: it[0] else: empty)
#             .join("")

# let input = splitLines strip readFile "inputs/day22-example.txt"
let input = splitLines strip readFile "inputs/day22.txt"
let id_len = log10(input.len.tofloat).ceil.toInt
echo id_len

let empty = fmt"_{'_'.repeat(id_len)}_"

proc x_view(brick_grid: BrickGrid) =
    let max_z = brick_grid[0][0].high
    echo ""
    for z in 0..max_z:
        echo brick_grid
            .mapIt(
                it.mapIt(it[max_z - z]).filterIt(it != empty)
            )
            .mapIt(if it.len > 0: fmt"_{'0'.repeat(id_len - (len $it[0]))}{it[0]}_" else: empty)
            .join("|")

# fmt"{'0'.repeat(id_len - (len $it))}{it}"
var bricks = input.mapIt(it.split("~")
         .mapIt(it.split(",")
         .map(parseInt))
         .mapIt((x: it[0], y: it[1], z: it[2])))
         .mapIt((s: it[0], e: it[1]))

# echo bricks.pairs.toSeq.join("\n")

let x_bounds = concat(bricks.mapIt(it.s.x), bricks.mapIt(it.e.x)).minmax
let y_bounds = concat(bricks.mapIt(it.s.y), bricks.mapIt(it.e.y)).minmax
let z_bounds = concat(bricks.mapIt(it.s.z), bricks.mapIt(it.e.z)).minmax

echo "X bounds: ", x_bounds, " Y bounds: ", y_bounds, " Z bounds: ", z_bounds

var brick_grid = newSeqWith(
    x_bounds[1] - x_bounds[0] + 1,
    newSeqWith(
        y_bounds[1] - y_bounds[0] + 1,
        newSeqWith(
            z_bounds[1] - z_bounds[0] + 2,
            empty
        )
    )
)

for x in x_bounds[0]..x_bounds[1]:
    for y in y_bounds[0]..y_bounds[1]:
        brick_grid[x][y][0] = 'X'.repeat(id_len)

for id, b in bricks:
    # brick.unpackSeq(id, b)
    for x in b.s.x..b.e.x:
        for y in b.s.y..b.e.y:
            for z in b.s.z..b.e.z:
                brick_grid[x][y][z] = $id

x_view brick_grid

# returns how much a brick can move down before it hits another brick
proc can_move(brick: Brick): int =
    let x_range = brick.s.x..brick.e.x
    let y_range = brick.s.y..brick.e.y
    let z_bottom = @[brick.s.z, brick.e.z].min
    # echo "x_range: ", x_range, ", y_range: ", y_range, ", z_bottom: ", z_bottom
    # check under the brick
    result = 0
    for z in countdown(z_bottom-1, 1):
        # echo "checking layer ", z
        var empty_layer = true
        for x in x_range:
            for y in y_range:
                if brick_grid[x][y][z] != empty:
                    # echo brick_grid[x][y][z]
                    empty_layer = false
                    break
            if not empty_layer:
                break
        
        if empty_layer:
            result += 1
        else:
            break


proc move(id: int, brick: Brick, by: int): Brick =
    # wipe brick from grid
    for x in brick.s.x..brick.e.x:
        for y in brick.s.y..brick.e.y:
            for z in brick.s.z..brick.e.z:
                brick_grid[x][y][z] = empty
    
    # update brick
    result = (s: (x: brick.s.x, y: brick.s.y, z: brick.s.z - by),
              e: (x: brick.e.x, y: brick.e.y, z: brick.e.z - by))

    # insert brick with by as z offset
    for x in result.s.x..result.e.x:
        for y in result.s.y..result.e.y:
            for z in result.s.z..result.e.z:
                brick_grid[x][y][z] = $id
    

# for id, b in bricks:
#     let move_by = can_move(b)
#     bricks[id] = move(id, b, move_by)

for z in 1..brick_grid[0][0].high:
    for id, b in bricks:
        if @[b.s.z, b.e.z].min == z:
            let move_by = can_move(b)
            if move_by > 0:
                bricks[id] = move(id, b, move_by)

x_view brick_grid

proc support_cmp(a: tuple[id: int, ids: seq[int]], b: tuple[id: int, ids: seq[int]]): int =
    cmp(a.ids.len, b.ids.len)

var support_table: Table[int, seq[int]] = initTable[int, seq[int]]()
var unnecessary_bricks: seq[int] = @[]
var necessary_bricks: seq[int] = @[]
for z in 1..brick_grid[0][0].high:
    # echo z

    var support_bricks: seq[tuple[id: int, ids: seq[int]]] = @[]
    for id, b in bricks:
        if @[b.s.z, b.e.z].max != z:
            continue
        # echo "Brick ", id, " at z = ", z
        let x_range = b.s.x..b.e.x
        let y_range = b.s.y..b.e.y
        let z_bottom = @[b.s.z, b.e.z].max
        
        # sequence of bricks that this brick supports
        let supported_bricks = zip(toSeq 0..bricks.high, bricks).filterIt(
            @[it[1].s.z, it[1].e.z].min == z + 1 and
            (
                (
                    it[1].s.x in x_range or
                    it[1].e.x in x_range or
                    b.s.x in it[1].s.x..it[1].e.x or
                    b.e.x in it[1].s.x..it[1].e.x
                ) and
                (
                    it[1].s.y in y_range or
                    it[1].e.y in y_range or
                    b.s.y in it[1].s.y..it[1].e.y or
                    b.e.y in it[1].s.y..it[1].e.y
                )
            )
        ).mapIt(it[0])
        support_bricks.add((id: id, ids: supported_bricks))
        # echo "Brick ", id, " supports: ", supported_bricks.join(", ")

    # echo "Support bricks: ", support_bricks.sorted(support_cmp, Descending)

    for sidx, sbrick in support_bricks:
        # echo "Brick ", sbrick.id, " supports: ", sbrick.ids.join(", ")
        support_table[sbrick.id] = sbrick.ids

        let supported_by_other_bricks = toSeq flatten support_bricks
            .filterIt(it.id != sbrick.id).mapIt(it.ids)
        # echo supported_by_other_bricks

        let necessary = sbrick.ids.filterIt(it notin supported_by_other_bricks).len > 0
        if not necessary:
            unnecessary_bricks.add(sbrick.id)
            # echo "Brick ", sbrick.id, " is not necessary, with support: ", sbrick.ids.join(", ")
        else:
            necessary_bricks.add(sbrick.id)
    
echo "\nPart 1: ", unnecessary_bricks.len
# 803 -> too high

proc bricks_to_fall(id: int): seq[int] =
    if support_table[id].len == 0:
        return @[]
    else:
        for s in support_table[id]:
            result = concat(result, @[s], bricks_to_fall(s))

echo necessary_bricks
# echo "Part 2: ", necessary_bricks.mapIt(toHashSet(bricks_to_fall(it)).len).foldl(a + b)
echo "Part 2: ", necessary_bricks.mapIt(toHashSet(bricks_to_fall(it)))
# 95342 -> too high
