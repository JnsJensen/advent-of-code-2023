import strutils
import sequtils
import std/enumerate

# let input = strip readFile "inputs/day13-example.txt"
let input = strip readFile "inputs/day13.txt"

iterator reverse[T](numbers: seq[T]): T =
    for i in 0 ..< numbers.len:
        yield numbers[numbers.len - i - 1]

func find_reflection_potentials[T](line: seq[T]): seq[int] =
    for c in 0 .. line.high - 1:
        let cidx = if c < int(line.high / 2): c else: line.high - c - 1
        let first_part = line[c-cidx..c]
        let second_part = toSeq reverse line[c+1..c+1+cidx]
        if first_part == second_part:
            result.add(c)

func swap(c: char): char =
    case c:
        of '.': '#'
        of '#': '.'
        else: c

func fix_smudge(line: seq[char], idx: int): seq[char] =
    result = line
    result[idx] = swap line[idx]

func fix_smudge(map: seq[seq[char]], idx: tuple[x: int, y: int]): seq[seq[char]] =
    result = map
    result[idx.y][idx.x] = swap map[idx.y][idx.x]

func transpose[T](matrix: seq[seq[T]]): seq[seq[T]] =
    for i in 0 .. matrix[0].high:
        var row: seq[T] = @[]
        for j in 0 .. matrix.high:
            row.add(matrix[j][i])
        result.add(row)
    toSeq reverse result

func common_elements[T](a: seq[T], b: seq[T]): seq[T] =
    for item in a:
        if item in b:
            result.add(item)

func common_elements[T](a: seq[seq[T]]): seq[T] =
    for item in a[0]:
        var found = true
        for i in 1 .. a.high:
            if item notin a[i]:
                found = false
                break
        if found:
            result.add(item)

func remove_elements[T](a: seq[T], b: seq[T]): seq[T] =
    for item in a:
        if item notin b:
            result.add(item)

var rows: seq[int] = @[]
var cols: seq[int] = @[]
var rows_smudge: seq[int] = @[]
var cols_smudge: seq[int] = @[]

for (midx, map) in enumerate input.split("\n\n"):
    let regular = cast[seq[seq[char]]](map.split("\n"))
    let transposed = transpose regular

    var reg_smudge_found = false
    var trans_smudge_found = false

    let reg_ref = common_elements regular.map(find_reflection_potentials)
    let trans_ref = common_elements transposed.map(find_reflection_potentials)

    for r in 0..regular.high:
        for c in 0..regular[r].high:
            let reg_fixed = fix_smudge(regular, (x: c, y: r))
            let trans_fixed = transpose reg_fixed

            var reg_fix_ref = common_elements reg_fixed.map(find_reflection_potentials)
            var trans_fix_ref = common_elements trans_fixed.map(find_reflection_potentials)

            reg_fix_ref = remove_elements(reg_fix_ref, reg_ref)
            trans_fix_ref = remove_elements(trans_fix_ref, trans_ref)

            if not reg_smudge_found and reg_fix_ref.len > 0:
                # echo "added to rows_smudge"
                rows_smudge.add reg_fix_ref.mapIt(it + 1)
                reg_smudge_found = true
            if not trans_smudge_found and trans_fix_ref.len > 0:
                # echo "added to cols_smudge"
                cols_smudge.add trans_fix_ref.mapIt(it + 1)
                trans_smudge_found = true


    rows.add reg_ref.mapIt(it + 1)
    cols.add trans_ref.mapIt(it + 1)

func calc_result(rows: seq[int], cols: seq[int]): int =
    let row_score = if rows.len > 0: rows.foldl(a + b) else: 0
    let col_score = if cols.len > 0: cols.foldl(a + b) else: 0
    result = row_score + 100 * col_score

echo calc_result(rows, cols)
echo calc_result(rows_smudge, cols_smudge)