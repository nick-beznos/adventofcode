import Foundation
import RegexBuilder

let inputURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let input = try String(contentsOf: inputURL!, encoding: String.Encoding.utf8)
let testURL = Bundle.main.url(forResource: "test", withExtension: "txt")
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
        return abs(self.x - coordinate.x) <= 1 && abs(self.y - coordinate.y) <= 1
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


func moveHead(_ head: Coordinate, direction: Direction) -> Coordinate {
    var newHead: Coordinate

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

    return newHead
}

func updateTailPosition(_ tail: Coordinate, head: Coordinate) -> Coordinate {
    if head.x == tail.x {
        return Coordinate(x: head.x, y: tail.y + (head.y > tail.y ? 1 : -1))
    }

    if head.y == tail.y {
        return Coordinate(x: tail.x + (head.x > tail.x ? 1 : -1), y: head.y)
    }

    //Diagonal move
    return Coordinate(x: tail.x + (head.x > tail.x ? 1 : -1), y: tail.y + (head.y > tail.y ? 1 : -1))
}


func task1() {
    var head = Coordinate(x: 0, y: 0)
    var tail = Coordinate(x: 0, y: 0)
    var uniqueTailCoordinates = Set<Coordinate>()

    for command in commands {
        for _ in 1...command.steps {
            head = moveHead(head, direction: command.dir)
            tail = updateTailPosition(tail, head: head)

            uniqueTailCoordinates.insert(tail)
        }
    }

    print(uniqueTailCoordinates.count)
}

func task2() async {
    var knots = Array(repeating: Coordinate(x: 11, y: 15), count: 10)
    var uniqueTailCoordinates = Set<Coordinate>()

    for command in commands {
        for _ in 1...command.steps {
            for (index, knot) in knots.enumerated() {
                let isHead = index == 0

                if isHead {
                    let newHead = moveHead(knot, direction: command.dir)
                    knots[0] = newHead
                } else {
                    if !knot.isCloseTo(knots[index - 1]) {
                        let updatedKnot = updateTailPosition(knot, head: knots[index - 1])
                        knots[index] = updatedKnot
                    }
                }
            }

//            await visualize(knots)

            uniqueTailCoordinates.insert(knots.last!)
        }
    }

    print(uniqueTailCoordinates.count)
}

func visualize(_ knots: [Coordinate]) async {
    //26x21
    var board = Array(repeating: Array(repeating: ".", count: 26), count: 21)


    for (index, knot) in knots.enumerated() {
        let char = index == 0 ? "H" : "\(index)"
        if board[knot.y][knot.x] == "." {
            board[knot.y][knot.x] = char
        }
    }

    print("\n")
    print(board.map({ $0.joined() }).joined(separator: "\n"))
    try! await Task.sleep(nanoseconds: UInt64(Double(NSEC_PER_SEC) * 0.1))

}

let commands: [Command] = parse(test)
//task1()

func evaluateFunc(_ code: () -> ()) {
    let start = DispatchTime.now()
    code()
    let finish = DispatchTime.now()

    let nanoTime = finish.uptimeNanoseconds - start.uptimeNanoseconds
    let timeInterval = Double(nanoTime) / Double(NSEC_PER_SEC)
    print("It took \(timeInterval) seconds to run this __chocolate_ice_cream_emoji__")
}

await task2()

