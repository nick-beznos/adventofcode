import UIKit
import Foundation

extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

struct ParsingError: LocalizedError {
    let incorrectInput: String

    init(incorrectInput: String) {
        self.incorrectInput = incorrectInput
    }

    var errorDescription: String {
        "Can't parse \(incorrectInput)"
    }
}

enum Shape: Int, CaseIterable {
    case rock = 1
    case paper = 2
    case scissors = 3

    static var allCases: [Shape] {
        return [.rock, .paper, .scissors]
    }

    static func winningShape(lhs: Self, rhs: Self) -> Shape? {
        guard lhs != rhs else { return nil }

        return lhs.isWinning(against: rhs) ? lhs : rhs
    }

    func shapeForOutcome(_ outcome: Outcome) -> Shape {
        switch outcome {
        case .win:
            for shape in Shape.allCases {
                guard shape != self else { continue }
                if isWinning(against: shape) {
                    return shape
                }
            }
            return self // improve
        case .draw:
            return self
        case .lose:
            for shape in Shape.allCases {
                guard shape != self else { continue }
                if !isWinning(against: shape) {
                    return shape
                }
            }
            return self // improve
        }
    }

    private func isWinning(against opposingShape: Shape) -> Bool {
        switch self {
        case .rock:
            return opposingShape == .scissors
        case .paper:
            return opposingShape == .rock
        case .scissors:
            return opposingShape == .paper

        }
    }
}

enum Outcome: Int {
    case win = 6
    case draw = 3
    case lose = 0

    func inverted() -> Outcome {
        switch self {
        case .win:
            return .lose
        case .draw:
            return .draw
        case .lose:
            return .win
        }
    }
}

struct Calculations {
    func outcomeOf(_ leftHandShape: Shape, _ rightHandShape: Shape) -> (Outcome, Outcome) {
        let winningShape = Shape.winningShape(lhs: leftHandShape, rhs: rightHandShape)
        guard winningShape != nil else { return (.draw, .draw) }

        return winningShape == leftHandShape ? (.win, .lose) : (.lose, .win)
    }

}

func parseInputForFirstTask(_ input: String) throws -> [(Shape, Shape)] {
    return try input.replacingOccurrences(of: " ", with: "").split(whereSeparator: \.isNewline).map { line in
        let lhChar = String(line)[0]
        let rhChar = String(line)[1]

        let leftHandShape: Shape
        let rightHandShape: Shape

        switch lhChar {
        case "A":
            leftHandShape = .rock
        case "B":
            leftHandShape = .paper
        case "C":
            leftHandShape = .scissors
        default:
            throw(ParsingError(incorrectInput: String(line)))
        }

        switch rhChar {
        case "X":
            rightHandShape = .rock
        case "Y":
            rightHandShape = .paper
        case "Z":
            rightHandShape = .scissors
        default:
            throw(ParsingError(incorrectInput: String(line)))
        }

        return (leftHandShape, rightHandShape)
    }
}

func firstTask() {
    do {
        let strategyGuide = try parseInputForFirstTask(input)

        let calculations = Calculations()

        var leftHandScore = 0
        var rightHandScore = 0

        strategyGuide.forEach { (leftHandShape, rightHandShape) in
            let outcome = calculations.outcomeOf(leftHandShape, rightHandShape)
            leftHandScore += outcome.0.rawValue + leftHandShape.rawValue
            rightHandScore += outcome.1.rawValue + rightHandShape.rawValue
        }

        print("leftHandScore = \(leftHandScore), rightHandScore = \(rightHandScore)")

    } catch let error {
        print("Something went wrong!")
        if let error = error as? ParsingError {
            print(error.errorDescription)
        }

    }
}

func parseInputForSecondTask(_ input: String) throws -> [(Shape, Outcome)] {
    return try input.replacingOccurrences(of: " ", with: "").split(whereSeparator: \.isNewline).map { line in
        let lhChar = String(line)[0]
        let rhChar = String(line)[1]

        let leftHandShape: Shape
        let outcome: Outcome

        switch lhChar {
        case "A":
            leftHandShape = .rock
        case "B":
            leftHandShape = .paper
        case "C":
            leftHandShape = .scissors
        default:
            throw(ParsingError(incorrectInput: String(line)))
        }

        switch rhChar {
        case "X":
            outcome = .lose
        case "Y":
            outcome = .draw
        case "Z":
            outcome = .win
        default:
            throw(ParsingError(incorrectInput: String(line)))
        }

        return (leftHandShape, outcome)
    }
}

func secondTask() {
    do {
        let strategyGuide = try parseInputForSecondTask(input)
        let calculations = Calculations()
        var rightHandScore = 0
        var leftHandScore = 0

        strategyGuide.map { (leftHandShape, outcome) in
            let rightHandShape = leftHandShape.shapeForOutcome(outcome.inverted())
            return (leftHandShape, rightHandShape)
        }.forEach { (leftHandShape, rightHandShape) in
            let outcome = calculations.outcomeOf(leftHandShape, rightHandShape)
            leftHandScore += outcome.0.rawValue + leftHandShape.rawValue
            rightHandScore += outcome.1.rawValue + rightHandShape.rawValue
        }

        print("leftHandScore = \(leftHandScore), rightHandScore = \(rightHandScore)")

    } catch let error {
        print("Something went wrong!")
        if let error = error as? ParsingError {
            print(error.errorDescription)
        }

    }
}

firstTask()
secondTask()
