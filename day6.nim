import sequtils
import strutils

let input = strip readFile "inputs/day6.txt"
# let input = strip readFile "inputs/day6-example.txt"

var split_input = input.split("\n").mapIt(it.split(" ").filterIt(it.len > 0))
split_input = split_input.mapIt(it[1..it.high])

let times = split_input[0].map(parseInt)
let distances = split_input[1].map(parseInt)

func get_result(times: seq[int], distances: seq[int]): int =
    var counts: seq[int] = newSeqWith(times.len, 0)
    for i in 0..times.high:
        let time = times[i]
        let distance = distances[i]

        for v in 0..time:
            let t = time - v
            let d = t * v

            if d > distance:
                counts[i] += 1

    return counts.foldl(a * b)

echo "Part 1: ", get_result(times, distances)
echo "Part 2: ", get_result(@[parseInt(split_input[0].join())], @[parseInt(split_input[1].join())])