import re

# read "inputs/day1.txt"
with open("inputs/day1.txt") as f:
    data = f.readlines()

words_to_numbers = {
    "one": "1",
    "two": "2",
    "three": "3",
    "four": "4",
    "five" : "5",
    "six": "6",
    "seven": "7",
    "eight": "8",
    "nine": "9",
    "zero": "0"
}

cal_values = []
# go through each line of data
for line in data:
    pattern = re.compile(r'(\d|one|two|three|four|five|six|seven|eight|nine)')
    matches = pattern.findall(line)

    # convert words to numbers
    for i in range(len(matches)):
        if matches[i] in words_to_numbers.keys():
            matches[i] = words_to_numbers[matches[i]]

    print(matches)

    # convert first and last value to int
    cal_value = int(f"{matches[0]}{matches[-1]}")
    cal_values.append(cal_value)

# sum all values
print(sum(cal_values))