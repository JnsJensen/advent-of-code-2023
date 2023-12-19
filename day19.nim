import sequtils
import strutils
import tables
import unpack
import std/strformat
import std/math
import bigints
import std/setutils
import lib

type
    Category = enum
        x = "x"
        m = "m"
        a = "a"
        s = "s"
    Condition = enum
        LESS_THAN = "<"
        GREATER_THAN = ">"
        NONE = "|"
    Part = Table[Category, int]
    Name = string
    Rule = object
        category: Category
        condition: Condition
        compare_to: int
        destination: Name
    Workflow = seq[Rule]
    WorkflowMap = Table[Name, Workflow]
    PartsMap = Table[Name, seq[Part]]

# let input = strip readFile "inputs/day19.txt"
let input = strip readFile "inputs/day19-example.txt"
input.split("\n\n").unpackSeq(workflows_raw, parts_raw)

var parts: seq[Part] = @[]
for part in parts_raw.replace("{", "").replace("}", "").split("\n"):
    var table: Part = initTable[Category, int]()
    for pair in part.split(",").mapIt(it.split("=")):
        pair.unpackSeq(category, value)
        table[parseEnum[Category](category)] = parseInt(value)
    parts.add(table)
# echo parts

var workflows: WorkflowMap = initTable[Name, Workflow]()
for workflow in workflows_raw.split("\n"):
    workflow.split("{").unpackSeq(name, rules_raw)
    let rules_split = rules_raw.replace("}", "").split(",")
    let last_destination = rules_split[rules_split.high]
    
    var rules: seq[Rule] = rules_split[0..<rules_split.high].mapIt(it.split(":")).mapIt(
        Rule(
            category: parseEnum[Category]($it[0][0]),
            condition: parseEnum[Condition]($it[0][1]),
            compare_to: parseInt($it[0].split({'<', '>'})[1]),
            destination: $it[1]
        )
    )
    rules.add(Rule(
        condition: Condition.NONE,
        destination: last_destination
    ))

    workflows[name] = rules
# echo workflows
workflows["A"] = @[Rule(destination: "A", condition: Condition.NONE)]
workflows["R"] = @[Rule(destination: "R", condition: Condition.NONE)]

proc process_part(part: Part, workflow: Workflow): string =
    let head = workflow[0]

    # echo head

    if (head.destination == "A" or head.destination == "R") and head.condition == Condition.NONE:
        return head.destination
    else:
        let tail = workflow[1..workflow.high]
        let value = part[head.category]
        # echo head.category, " = ", value
        case head.condition
            of Condition.LESS_THAN:
                if value < head.compare_to:
                    # echo "PASS"
                    return process_part(part, workflows[head.destination])
                else:
                    # echo "FAIL"
                    return process_part(part, tail)
            of Condition.GREATER_THAN:
                if value > head.compare_to:
                    # echo "PASS"
                    return process_part(part, workflows[head.destination])
                else:
                    # echo "FAIL"
                    return process_part(part, tail)
            of Condition.NONE:
                return process_part(part, workflows[head.destination])

var parts_map: PartsMap = initTable[Name, seq[Part]]()

let accepted_parts = parts.filterIt(process_part(it, workflows["in"]) == "A")
echo "Part 1: ", accepted_parts.mapIt(
    it[Category.x] +
    it[Category.m] +
    it[Category.a] +
    it[Category.s]
).foldl(a + b)

# var total_combinations: BigInt = initBigInt(1)
# for i in 1..4:
#     total_combinations *= initBigInt(4000)
# total_combinations *= initBigInt(len parts)

# echo "int64 max = ", int64.high
var all_rules_for_A: seq[Rule] = @[]
let workflows_accepted = workflows.values.toSeq.filterIt(it[it.high].destination == "A")
all_rules_for_A.add toSeq flatten workflows_accepted[0..workflows_accepted.high-1]

echo all_rules_for_A
# echo "Part 2: ", total_combinations