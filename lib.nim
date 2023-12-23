import strutils
import sequtils

proc assemble*[T](input: seq[seq[T]]): string =
    input.mapIt(it.join("")).join("\n")

iterator flatten*[T](source: openArray[T]): auto =
    when T isnot seq:
        for element in source:
            yield element
    else:
        for each in source:
            for e in flatten(each):
                yield e

iterator cpairs*[T](sequence: seq[T]): tuple[lower: T, upper: T] =
    var i = 0
    while i < sequence.len - 1:
        yield (sequence[i], sequence[i+1])
        inc(i, 1)

iterator reverse*[T](numbers: seq[T]): T =
    for i in 0 ..< numbers.len:
        yield numbers[numbers.len - i - 1]

func rotate*[T](matrix: seq[seq[T]]): seq[seq[T]] =
    for i in 0 .. matrix[0].high:
        var row: seq[T] = @[]
        for j in 0 .. matrix.high:
            row.add(matrix[j][i])
        result.add(row)
    toSeq reverse result

func even*(n: int): bool = n mod 2 == 0
func odd*(n: int): bool = n mod 2 == 1

iterator window*[T](sequence: seq[T], size: int, edges: bool = false, step: int = 1): seq[T] =
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