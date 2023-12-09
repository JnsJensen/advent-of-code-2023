import std/strutils
import sequtils
import std/enumerate

let lines = strip readFile "inputs/day9.txt"
  
iterator diff(numbers: seq[int]): int =
    for i in 0 ..< numbers.len - 1:
        yield numbers[i+1] - numbers[i]

iterator reverse[T](numbers: seq[T]): T =
    for i in 0 ..< numbers.len:
        yield numbers[numbers.len - i - 1]

func all_zeros(numbers: seq[int]): bool =
    all(numbers, proc (x: int): bool = x == 0)

proc predict(diffs: var seq[seq[int]], add: bool = true): bool =
    var last_diff = -1
    for (didx, diff) in enumerate(reverse(diffs).toSeq):
        let reversed_idx = diffs.len - didx - 1
        if all_zeros(diff):
            # echo "ALL ZEROS adding 0 to ", diffs[reversed_idx]
            diffs[reversed_idx].add(0)
            last_diff = 0
        else:
            let last_val = diffs[reversed_idx][diffs[reversed_idx].high]
            # echo "NOT ALL ZEROS ", last_diff, " ", last_val
            var new_val: int = 0
            if add:
                new_val = last_val + last_diff
            else:
                new_val = last_val - last_diff
            diffs[reversed_idx].add(new_val)
        last_diff = diffs[reversed_idx][diffs[reversed_idx].high]
    
    return true
    
var predictions: seq[int] = @[]
var reverse_predictions: seq[int] = @[]
for line in lines.split("\n"):
    var numbers = line.split(" ").map(parseInt)

    var diffs: seq[seq[int]] = @[numbers]
    while all_zeros(numbers) == false:
        numbers = diff(numbers).toSeq
        diffs.add(numbers)
    discard predict(diffs)
    predictions.add(diffs[0][diffs[0].high])

    var reverse_diffs = diffs.mapIt(reverse(it).toSeq)
    discard predict(reverse_diffs, add = false)

    reverse_predictions.add(reverse_diffs[0][reverse_diffs[0].high])

echo predictions.foldl(a + b)
echo reverse_predictions.foldl(a + b)