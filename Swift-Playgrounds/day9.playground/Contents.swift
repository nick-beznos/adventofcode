import Foundation
import RegexBuilder

let inputURL = Bundle.main.url(forResource: "Input", withExtension: nil)
let input = try String(contentsOf: inputURL!, encoding: String.Encoding.utf8)
let testURL = Bundle.main.url(forResource: "test", withExtension: nil)
let test = try String(contentsOf: testURL!, encoding: String.Encoding.utf8)

enum Direction {
    case `left`
    case `right`
    case up
    case down
}

struct Command {
    let dir: Direction
    let steps: Int
}

struct Coordinate: Hashable {
    let x: Int
    let y: Int
    var lastDirection: Direction?

    func isCloseTo(_ coordinate: Coordinate) -> Bool {
        var coordinatesInRadius = [Coordinate]()
        for ix in [-1, 0, 1] {
            for iy in [-1, 0, 1] {
                coordinatesInRadius.append(Coordinate(x: x + ix, y: y + iy))
            }
        }

        return coordinatesInRadius.contains(where: { $0 == coordinate})
    }
}

let regex = Regex {
    Capture(.word)
    " "
    Capture(OneOrMore(.digit))
}

func parse(_ stringInput: String) -> [Command] {
    var result: [Command] = []

    stringInput.split(whereSeparator: \.isNewline).map { line in
        if let match = line.wholeMatch(of: regex) {
            switch String(match.1) {
            case "L": result.append(Command(dir: .left, steps: Int(match.2) ?? 0))
            case "R": result.append(Command(dir: .right, steps: Int(match.2) ?? 0))
            case "U": result.append(Command(dir: .up, steps: Int(match.2) ?? 0))
            case "D": result.append(Command(dir: .down, steps: Int(match.2) ?? 0))
            default:
                print("Error parsing \(line)")
            }
        }
    }

    return result
}


func move(head: Coordinate, tail: Coordinate, direction: Direction) -> (Coordinate, Coordinate) {
    var newHead: Coordinate
    var newTail: Coordinate

    switch direction {
    case .left:
        newHead = Coordinate(x: head.x - 1, y: head.y)
    case .right:
        newHead = Coordinate(x: head.x + 1, y: head.y)
    case .up:
        newHead = Coordinate(x: head.x, y: head.y - 1)
    case .down:
        newHead = Coordinate(x: head.x, y: head.y + 1)
    }

//    print("\(newHead.x) \(newHead.y)")

    newTail = simulateNewTailPosition(tail: tail, head: head, newHead: newHead)

    return (newHead, newTail)
}

func simulateNewTailPosition(tail: Coordinate, head: Coordinate, newHead: Coordinate) -> Coordinate {
    guard newHead != tail else { return tail }
    if tail.isCloseTo(newHead) {
        return tail
    } else {
        return head
    }
}


func task1() {
    var head = Coordinate(x: 0, y: 0)
    var tail = Coordinate(x: 0, y: 0)
    var uniqueTailCoordinates = Set<Coordinate>()

    for command in commands {
//        print("\(command.dir) \(command.steps)")
        for _ in 1...command.steps {
            let move = move(head: head, tail: tail, direction: command.dir)
            head = move.0
            tail = move.1

            uniqueTailCoordinates.insert(tail)
        }
    }

    print(uniqueTailCoordinates.count)
}

func task2() {
    var knots = Array(repeating: Coordinate(x: 0, y: 0), count: 10)
    var uniqueTailCoordinates = Set<Coordinate>()

    for command in commands {
//        print("\(command.dir) \(command.steps)")
        for _ in 1...command.steps {
            for (index, knot) in knots.enumerated() {
                guard index + 1 != knots.count else { continue }
                let tail = knots[index + 1]
                let move = move(head: knot, tail: tail, direction: knot.lastDirection ?? command.dir)

                var updatedHead = move.0
                var updatedTail = move.1
                updatedHead.lastDirection = command.dir

                if tail != updatedTail {
                    updatedTail.lastDirection = knot.lastDirection
                }

                knots[index + 1] = updatedHead
                knots[index] = updatedTail
            }

            uniqueTailCoordinates.insert(knots.last!)
        }
    }

    print(uniqueTailCoordinates.count)
}

let commands: [Command] = parse(test)
//task1()
func evaluateFunc(_ code: () -> ()) {
    let start = DispatchTime.now()
    code()
    let finish = DispatchTime.now()

    let nanoTime = finish.uptimeNanoseconds - start.uptimeNanoseconds
    let timeInterval = Double(nanoTime) / 1_000_000_000
    print("It took \(timeInterval) seconds to run this __chocolate_ice_cream_emoji__")
}

evaluateFunc {
    task2()
}

