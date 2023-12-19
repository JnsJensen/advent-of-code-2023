import sequtils
import strutils
import std/strformat
import tables
import std/algorithm
import lib

type
    Card = enum
        JOKER = "X"
        TWO = "2"
        THREE = "3"
        FOUR = "4"
        FIVE = "5"
        SIX = "6"
        SEVEN = "7"
        EIGHT = "8"
        NINE = "9"
        TEN = "T"
        JACK = "J"
        QUEEN = "Q"
        KING = "K"
        ACE = "A"
    Hand = seq[Card]
    HandType = enum
        FIVE_OF_A_KIND
        FOUR_OF_A_KIND
        FULL_HOUSE
        THREE_OF_A_KIND
        TWO_PAIR
        ONE_PAIR
        HIGH_CARD
        NONE
    Bid = int
    Play = tuple[hand: Hand, bid: Bid, htype: HandType]

func count[T](seq: seq[T], item: T): int =
    var count = 0
    for i in seq:
        if i == item:
            count += 1
    return count

func count_all[T](sequence: seq[T]): Table[T, int] =
    result = initTable[T, int]()
    for item in sequence:
        result[item] = result.getOrDefault(item, 0) + 1

func hand_type(hand: Hand): HandType =
    let counts = count_all hand
    let vals = toSeq counts.values

    if any(vals, proc (it: int): bool = it == 5):
        result = HandType.FIVE_OF_A_KIND
    elif any(vals, proc (it: int): bool = it == 4):
        if counts.getOrDefault(Card.JOKER, 0) > 0:
            result = HandType.FIVE_OF_A_KIND
        else:
            result = HandType.FOUR_OF_A_KIND
    elif any(vals, proc (it: int): bool = it == 3) and any(vals, proc (it: int): bool = it == 2):
        if counts.getOrDefault(Card.JOKER, 0) > 0:
            result = HandType.FIVE_OF_A_KIND
        else:
            result = HandType.FULL_HOUSE
    elif any(vals, proc (it: int): bool = it == 3):
        if counts.getOrDefault(Card.JOKER, 0) > 0:
            result = HandType.FOUR_OF_A_KIND
        else:
            result = HandType.THREE_OF_A_KIND
    elif count(vals, 2) == 2:
        if counts.getOrDefault(Card.JOKER, 0) == 2:
            result = HandType.FOUR_OF_A_KIND
        elif counts.getOrDefault(Card.JOKER, 0) == 1:
            result = HandType.FULL_HOUSE
        else:
            result = HandType.TWO_PAIR
    elif count(vals, 2) == 1:
        if counts.getOrDefault(Card.JOKER, 0) > 0:
            result = HandType.THREE_OF_A_KIND
        else:
            result = HandType.ONE_PAIR
    else:
        if counts.getOrDefault(Card.JOKER, 0) > 0:
            result = HandType.ONE_PAIR
        else:
            result = HandType.HIGH_CARD

proc card_cmp(a: Card, b: Card): int =
    result = cmp(b, a)

proc hand_cmp(a: Hand, b: Hand): int =
    for i in 0..a.high:
        if a[i] != b[i]:
            return card_cmp(a[i], b[i])
    result = 0

proc play_cmp(a: Play, b: Play): int =
    if a.htype == b.htype:
        result = hand_cmp(a.hand, b.hand)
    else:
        result = cmp(a.htype, b.htype)

let input: string = strip readFile "inputs/day7.txt"
# let input: string = strip readFile "inputs/day7-example.txt"

var plays: seq[Play] =  input.split("\n").mapIt(it.split(" ")).mapIt(
    (
        hand: it[0].mapIt(parseEnum[Card](fmt"{it}")),
        bid: parseInt it[1],
        htype: HandType.NONE
    )
)

for p in 0..plays.high:
    plays[p].htype = hand_type(plays[p].hand)

let sorted_plays: seq[Play] = toSeq plays.sorted(play_cmp)
var sorted_bids: seq[int] = sorted_plays.mapIt(it.bid)

echo "Part 1: ", zip(toSeq reverse toSeq 1..sorted_bids.len, sorted_bids).mapIt(it[0] * it[1]).foldl(a + b)

var plays_jokers: seq[Play] =  input.split("\n").mapIt(it.split(" ")).mapIt(
    (
        hand: it[0].mapIt(if it == 'J': 'X' else: it).mapIt(parseEnum[Card](fmt"{it}")),
        bid: parseInt it[1],
        htype: HandType.NONE
    )
)

for p in 0..plays_jokers.high:
    plays_jokers[p].htype = hand_type(plays_jokers[p].hand)
    
let sorted_plays_jokers: seq[Play] = toSeq plays_jokers.sorted(play_cmp)
var sorted_bids_jokers: seq[int] = sorted_plays_jokers.mapIt(it.bid)

echo "Part 2: ", zip(toSeq reverse toSeq 1..sorted_bids_jokers.len, sorted_bids_jokers).mapIt(it[0] * it[1]).foldl(a + b)