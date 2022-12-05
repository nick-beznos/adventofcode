import Foundation
import RegexBuilder

enum CrateMover {
    case crateMover9000
    case crateMover9001
}

let fileURL = Bundle.main.url(forResource: "Input", withExtension: nil)
let input = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)
let inputLines = input.split(whereSeparator: \.isNewline).map({ String($0) })

var numbersLineIndex = 0
var numbersLine = ""

func parseStacks() -> [String] {
    var result: [String] = []

    for (lineIndex, line) in inputLines.enumerated() {
        if String(line).firstMatch(of: .digit) != nil {
            numbersLineIndex = lineIndex
            numbersLine = line
            break
        }
    }

    for (stackIndex, stackNumber) in numbersLine.enumerated() {
        if String(stackNumber).firstMatch(of: .digit) != nil {
            var stack = ""
            var currentLineIndex = 0

            while currentLineIndex != numbersLineIndex {
                let charsInLine = Array(inputLines[currentLineIndex])
                currentLineIndex += 1
                guard stackIndex < charsInLine.count  else { continue }
                let char = charsInLine[stackIndex]
                if char.isLetter {
                    stack.append(char)
                }
            }

            result.append(stack)
        }
    }

    return result
}

func workDatCrane(_ crane: CrateMover) {
    var stacks = parseStacks()

    // move (crates) from (fromStackIndex) to (toStackIndex)
    let regex = Regex {
        "move "
        Capture(OneOrMore(.digit))
        " from "
        Capture(.digit)
        " to "
        Capture(.digit)
    }

    for (lineIndex, line) in inputLines.enumerated() {
        guard lineIndex > numbersLineIndex else { continue }
        if let match = line.wholeMatch(of: regex) {
            let crates = Int(match.1) ?? 0
            let fromStackIndex = (Int(match.2) ?? 1) - 1
            let toStackIndex = (Int(match.3) ??  1) - 1

            var cratesToMove: Substring = stacks[fromStackIndex].prefix(crates)

            switch crane {
            case .crateMover9000:
                cratesToMove = Substring(cratesToMove.reversed())
            case .crateMover9001:
                break
            }

            stacks[toStackIndex].insert(contentsOf: cratesToMove, at: stacks[toStackIndex].startIndex)
            stacks[fromStackIndex] = String(stacks[fromStackIndex].dropFirst(crates))
        }
    }
    print(String(stacks.map({ $0.first }).compactMap({ $0 ?? " " })))

}

workDatCrane(.crateMover9000)
workDatCrane(.crateMover9001)
