import std/strutils
import sequtils
import std/sets
import std/math
import std/enumerate
import std/strformat

let input = readFile "inputs/day3.txt"
# let input = readFile "inputs/day3-example.txt"
let symbols = "!@#$%^&*()_+-=[]{}|;':\",/<>?\\`~"

proc even(n: int): bool = n mod 2 == 0

iterator window[T](sequence: seq[T], size: int, edges: bool = false, step: int = 1): seq[T] =
    var i = if edges: 0 else: int size/2
    var endat = if edges: sequence.len else: sequence.len - int size/2

    while i < endat:
        var start = i - (int size/2)
        var ending = i + (int size/2)

        if start < 0:
            start = 0
        if ending >= sequence.len:
            ending = sequence.len-1
        
        yield sequence[start..ending]
        inc(i, step)

iterator distinct_pairs[T](sequence: seq[T]): tuple[lower: T, upper: T] =
    var i = 0
    while i < sequence.len - 1:
        yield (sequence[i], sequence[i+1])
        inc(i, 2)

proc is_symbol(c: char): bool = c in symbols
proc contains_symbol(s: string): bool = any(s, isSymbol)

proc number_edges(sequence: string): seq[int] =
    var prev_is_digit = false
    for i, c in sequence.pairs:
        let is_digit = isDigit c
        if prev_is_digit != is_digit:
            result.add if is_digit: i else: i-1
        prev_is_digit = is_digit

    if isDigit sequence[sequence.len-1]:
        result.add sequence.len-1

proc expanded_bounds(bound: tuple[lower: int, upper: int], max: int): tuple[lower: int, upper: int] =
    (
        lower: if bound.lower == 0: bound.lower else: bound.lower - 1,
        upper: if bound.upper == max: bound.upper else: bound.upper + 1
    )

var part_numbers: seq[int] = @[]
var lines = splitLines(input.strip)

for (idx, window) in enumerate window(sequence = lines, size = 3, edges = true):
    let mid = (if len(window) == 2: (if idx == 0: 0 else: 1) else: 1)
    let mid_seq = window[mid]
    if mid_seq.len == 0:
        continue
    let switches = number_edges(mid_seq)

    for bound in distinct_pairs(sequence = switches):
        let number = parseInt(mid_seq[bound.lower..bound.upper])
        let expanded_bounds = expanded_bounds(bound, mid_seq.len-1)

        if any(
            window.mapIt(it[expanded_bounds.lower..expanded_bounds.upper]),
            contains_symbol
        ):
            part_numbers.add number

echo fmt"PART 1: part number sum = {part_numbers.foldl(a + b)}"

proc gear_indices(sequence: string): seq[int] =
    for i, c in sequence.pairs:
        if c == '*':
            result.add i

var gear_products: seq[int] = @[]

for (idx, windows) in enumerate window(sequence = lines, size = 3, edges = true):
    let mid = (if len(windows) == 2: (if idx == 0: 0 else: 1) else: 1)
    let mid_seq = windows[mid]
    if mid_seq.len == 0:
        continue

    let gear_indices = gear_indices(mid_seq)
    var parts_per_gear: seq[seq[int]] = newSeq[seq[int]](gear_indices.len)

    let all_switches = windows.map(number_edges)

    for (sidx, switches) in enumerate(all_switches):
        let sequence = windows[sidx]
        for bound in distinct_pairs(sequence = switches):
            let number = parseInt(sequence[bound.lower..bound.upper])
            let expanded_bounds = expanded_bounds(bound, sequence.len-1)

            # check if any of the gear indices are in the expanded bounds
            for (gidx, gear_index) in enumerate(gear_indices):
                if gear_index in expanded_bounds.lower..expanded_bounds.upper:
                    parts_per_gear[gidx].add number
    
    let product_seq = parts_per_gear.filterIt(it.len == 2).mapIt(it.foldl(a * b))

    for product in product_seq:
        gear_products.add product
    
let gear_products_sum = gear_products.foldl(a + b)
echo fmt"PART 2: gear products sum = {gear_products_sum}"