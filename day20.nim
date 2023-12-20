import strutils
import sequtils
import tables
import unpack

type
    Name = string
    Signal = enum
        HIGH
        LOW
    Event = object
        sender: Name
        signal: Signal
        destination: Name
    State = seq[Event]

type Module = ref object of RootObj
    name: Name
    destinations: seq[Name]
method dissiminate(self: Module, signal: Signal, state: var State) {.base.} =
    for destination in self.destinations:
        state.add(Event(
            sender: self.name,
            signal: signal,
            destination: destination
        ))
method handle_signal(self: Module, signal: Signal, sender: Name, state: var State): Signal {.base.} =
    self.dissiminate(signal, state)

type ModuleTable = Table[Name, Module]

type FlipFlop = ref object of Module
    on: var bool = false
method handle_signal(self: FlipFlop, signal: Signal, sender: Name, state: var State): Signal =
    case signal:
        of Signal.HIGH:
            return
        of Signal.LOW:
            if self.on:
                self.on = false
                result = Signal.LOW
            else:
                self.on = true
                result = Signal.HIGH    
    self.dissiminate(result, state)
proc newFlipFlop(name: Name, destinations: seq[Name]): FlipFlop =
    new(result)
    result.name = name
    result.destinations = destinations
    result.on = false

type Conjuctive = ref object of Module
    signals: TableRef[Name, Signal]
method handle_signal(self: Conjuctive, signal: Signal, sender: Name, state: var State): Signal =
    self.signals[sender] = signal
    if self.signals.values.toSeq.allIt(it == Signal.HIGH):
        result = Signal.HIGH
    else:
        result = Signal.LOW
    
    self.dissiminate(result, state)

type Broadcast = ref object of Module
method handle_signal(self: Broadcast, signal: Signal, sender: Name, state: var State): Signal =
    for destination in self.destinations:
        state.add(Event(
            sender: self.name,
            signal: signal,
            destination: destination
        ))
    result = signal

    self.dissiminate(result, state)

let input = strip readFile "inputs/day20-example.txt"

# var states: seq[State] = @[]
var modules: ModuleTable = initTable[Name, Module]()

for line in input.split("\n"):
    line.split(" -> ").unpackSeq(module_raw, destinations_raw)
    let destinations = destinations_raw.split(", ")
    let dest_signals: TableRef[Name, Signal] = newTable destinations.mapIt((it, Signal.LOW))
    echo dest_signals

    if module_raw == "broadcaster":
        modules[module_raw] = Broadcast(
            name: module_raw,
            destinations: destinations
        )
    else:
        let module_type = module_raw[0]
        let name = module_raw[1..module_raw.high]
        case module_type:
        of '%':
            modules[name] = newFlipFlop(
                name,
                destinations
            )
        of '&':
            echo "conjuctive"
        else:
            echo "WHAT"
        # of '%':
        #     modules[name] = FlipFlop(
        #         name: name,
        #         destinations: destinations
        #     )
        # of '&':
        #     modules[name] = Conjuctive(
        #         name: name,
        #         destinations: destinations,
        #         signals: dest_signals
        #     )
        # else:
        #     echo "WHAT"
        # if module_raw.startsWith("%"):
        # modules[module_raw] = FlipFlop(
        #     name: module_raw[1..cast[seq[char]](module_raw).high],
        #     destinations: destinations
        # )
        # elif module_raw.startsWith("&"):
        #     modules[module_raw] = Conjuctive(
        #         name: module_raw[1..module_raw.high],
        #         destinations: destinations,
        #         signals: dest_signals
        #     )
        # else:
        #     echo "WHAT"
        


# echo modules.pairs.toSeq.mapIt(it).join("\n")
