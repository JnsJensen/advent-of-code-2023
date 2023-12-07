import std/strutils
import sequtils
import std/strformat
import std/math
import std/enumerate

type
    Card = tuple[
        id: int,
        numbers: seq[int],
        winning: seq[int],
        points: int,
        amount: int,
    ]

let input = readFile "inputs/day4.txt"
# let input = readFile "inputs/day4-example.txt"

var cards: seq[Card] = @[]
for line in splitLines input.strip:
    let parsed_line = line.split({':', '|'}).mapIt(it.split(' ').filterIt(it.len > 0))
    
    var card: Card = (
        id: parsed_line[0][1].parseInt,
        numbers: parsed_line[1].mapIt(it.parseInt),
        winning: parsed_line[2].mapIt(it.parseInt),
        points: 0,
        amount: 1,
    )

    for number in card.numbers:
        if number in card.winning:
            if card.points == 0:
                card.points = 1
            else:
                card.points *= 2
    
    cards.add card

let result = cards.mapIt(it.points).foldl(a + b)
echo fmt"PART 1: {result}"

for (ci, card) in enumerate(cards):
    let amount = log2(float(card.points))
    let wins = if amount < 0: 0 else: int amount + 1

    for wi in 1..wins:
        cards[ci+wi].amount += 1 * card.amount

echo fmt"PART 2: {cards.mapIt(it.amount).foldl(a + b)}"