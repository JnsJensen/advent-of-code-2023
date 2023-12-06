import std/strutils
import sequtils

type
    Color = enum
        RED = "red"
        GREEN = "green"
        BLUE = "blue"
    Draw = tuple[amount: int, color: Color]
    Game = tuple[id: int, draws: seq[Draw]]

let input = readFile "inputs/day2.txt"
var games: seq[Game] = @[]

for line in splitLines input:
    case line
    of "": continue
    let game_line = line.split(":").mapIt(it.split(";"))
    var game: Game = (id: game_line[0][0].split(" ")[1].parseInt(), draws: @[])
    for draw in game_line[1]:
        let split_draws = draw.split(",").mapIt(it.split(" "))

        for draw in split_draws:
            let draw: Draw = (amount: draw[1].parseInt(), color: parseEnum[Color](draw[2]))
            game.draws.add(draw)
    games.add(game)

proc is_possible(game: Game): bool =
    for draw in game.draws:
        case draw.color
        of Color.RED:
            if draw.amount > 12:
                return false
        of Color.GREEN:
            if draw.amount > 13:
                return false
        of Color.BLUE:
            if draw.amount > 14:
                return false
    return true

let result1 = games.filter(is_possible).mapIt(it.id).foldl(a + b)
echo result1

proc find_min_colors(game: Game): tuple[red: int, green: int, blue: int] =
    var min_red: Draw = (amount: 0, color: Color.RED)
    var min_green: Draw = (amount: 0, color: Color.GREEN)
    var min_blue: Draw = (amount: 0, color: Color.BLUE)
    for draw in game.draws:
        case draw.color
        of Color.RED:
            if draw.amount > min_red.amount:
                min_red = draw
        of Color.GREEN:
            if draw.amount > min_green.amount:
                min_green = draw
        of Color.BLUE:
            if draw.amount > min_blue.amount:
                min_blue = draw
    return (red: min_red.amount, green: min_green.amount, blue: min_blue.amount)

let result2 = games.map(find_min_colors).mapIt(it.red * it.green * it.blue).foldl(a + b)
echo result2