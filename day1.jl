# read inputs/day1.txt

numbers = "1234567890"
word_numbers = split("one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen twenty", " ")

function part1(file)
    calibration_values = [
        parse(Int, String([
            first([
                c for c in l
                if c in numbers
            ]),
            last([
                c for c in l
                if c in numbers
            ])
        ]))
        for l in eachline(file)
    ]
    print("Part 1: ")
    println(sum(calibration_values))
end

function part2(file)
    print(word_numbers)

    print("Part 2: ")
end

open("inputs/day1.txt") do file
    part1(file)
    part2(file)
end