import re

# read "inputs/day1.txt"
with open("inputs/day1.txt") as f:
    data = f.readlines()

cal_values = []
# go through each line of data
for line in data:
    pattern = re.compile(r'(\d)')
    matches = pattern.findall(line)

    # convert first and last value to int
    cal_value = int(f"{matches[0]}{matches[-1]}")
    cal_values.append(cal_value)

# sum all values
print(sum(cal_values))