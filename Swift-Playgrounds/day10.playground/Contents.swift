import Foundation
import RegexBuilder

let inputURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let input = try String(contentsOf: inputURL!, encoding: String.Encoding.utf8)
let testURL = Bundle.main.url(forResource: "test", withExtension: "txt")
let test = try String(contentsOf: testURL!, encoding: String.Encoding.utf8)

enum Instruction {
    case noop
    case addx(Int)
}

let regex = Regex {
    "addx "
    Capture(OneOrMore(.any))
}

func parse(_ stringInput: String) -> [Instruction] {
    var result: [Instruction] = []

    stringInput.split(whereSeparator: \.isNewline).map { line in
        if line == "noop" {
            result.append(.noop)
        } else if let match = line.wholeMatch(of: regex) {
            result.append(.addx(Int(match.1)!))
        }
    }

    return result
}

func task1() {
    let instructions = parse(input)
    var cyclesToCheckSignalAt = [20, 60, 100, 140, 180, 220]
    var signalStrengths = [Int]()
    var x = 1
    var cycle = 1

    for instruction in instructions {
        var newCycles = 0
        var newValue = 0

        switch instruction {
        case .noop:
            newCycles = 1
        case .addx(let value):
            newCycles = 2
            newValue = value
        }

        for c in 1...newCycles {
            cycle += 1
            if c == newCycles {
                x += newValue
            }

            for (index, controlCycle) in cyclesToCheckSignalAt.enumerated() {
                if controlCycle == cycle {
                    print(x)
                    signalStrengths.append(x * cycle)
                    cyclesToCheckSignalAt.remove(at: index)
                    break
                }
            }

        }
    }

    print(signalStrengths.reduce(0, +))

}

//task1()

func task2() {
    let instructions = parse(input)
    var cyclesToCheckSignalAt = [40, 80, 120, 160, 200, 240]
    var spritePosition = [0, 1, 2]
    var x = 1
    var cycle = 0

    var image = ""

    for instruction in instructions {
        var newCycles = 0
        var newValue = 0

        switch instruction {
        case .noop:
            newCycles = 1
        case .addx(let value):
            newCycles = 2
            newValue = value
        }

        for c in 1...newCycles {
            let isInSprite = spritePosition.contains(cycle % 40)
            image += isInSprite ? "#" : "."
            
            cycle += 1
            if c == newCycles {
                x += newValue
                spritePosition = [x - 1, x, x + 1]
            }

            for (index, controlCycle) in cyclesToCheckSignalAt.enumerated() {
                if controlCycle == cycle {


                    cyclesToCheckSignalAt.remove(at: index)
                    print(image)
                    image = ""
                    break
                }
            }

        }
    }
}

task2()
