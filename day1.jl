# read inputs/day1.txt

numbers = "1234567890"
word_numbers = split("zero one two three four five six seven eight nine", " ")
# teens = split("ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen", " ")
# tens = split("twenty thirty forty fifty sixty seventy eighty ninety", " ")
# doubles = [w == "zero" ? t : t * w for t in tens for w in singles]

# word_numbers = vcat(singles, teens, doubles)
word_numbers_map = Dict(number => idx-1 for (idx, number) in enumerate(word_numbers))

all_numbers = vcat(split(numbers, ""), word_numbers)
# println(word_numbers)

# print(word_numbers_map)
# println(reverse(word_numbers))

function part1(input)
    calibration_values = []
    for l in split(input, "\n")[begin:end-1]
        numbers_in_line = [c for c in l if c in numbers]
        calibration_value = parse(Int, String([
            numbers_in_line[begin],
            numbers_in_line[end]
        ]))
        push!(calibration_values, calibration_value)
    end

    print("Part 1: ")
    println(sum(calibration_values))
end

function part2(input)
    # print(word_numbers)

    # find all number words in the line, replace them with the number
    # then do the same as part 1

    calibration_values = []
    for l in split(input, "\n")[begin:end-1]
        # size to calibration_value array
        calibration_value = ["0", "0"]
        front_found = back_found = false

        for i in range(1, length(l))
            front = SubString(l, 1:Int(i))
            back = SubString(l, (length(l)-Int(i)+1):length(l))
            # println(front, " ", back)
            for w in all_numbers
                if occursin(w, front) && front_found == false
                    #put at index 1
                    # insert!(calibration_value, 1, w)
                    calibration_value[1] = w
                    front_found = true
                end
                if occursin(w, back) && back_found == false
                    #put at index 2
                    # insert!(calibration_value, 2, w)
                    calibration_value[2] = w
                    back_found = true
                end
            end
        end

        # convert word mumbers in calibration_value to numbers
        for idx in range(1, length(calibration_value))
            num = calibration_value[idx]
            if num in word_numbers
                calibration_value[idx] = string(word_numbers_map[num])
            end
        end
        
        calibration_value = parse(Int, join(calibration_value))
        push!(calibration_values, calibration_value)
    end

    print("Part 2: ")
    println(sum(calibration_values))
end

open("inputs/day1.txt") do file
    f = read(file, String)
    part1(f)
    part2(f)
end