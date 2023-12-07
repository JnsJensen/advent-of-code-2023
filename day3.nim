import std/strutils
import sequtils

let input = readFile "inputs/day3.txt"



for index, line in (splitLines input).pairs:
    echo index