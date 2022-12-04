import Foundation
import RegexBuilder

let fileURL = Bundle.main.url(forResource: "Input", withExtension: nil)
let input = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)

let regex = Regex {
    Capture(OneOrMore(.digit))
    "-"
    Capture(OneOrMore(.digit))
    ","
    Capture(OneOrMore(.digit))
    "-"
    Capture(OneOrMore(.digit))
}

//let inputRanges: [(ClosedRange, ClosedRange)] = [(1...2, 3...5), (1...4, 4...6), (1...4, 3...6), (1...4, 1...5), (1...4, 1...4), (1...4, 2...3)]
//3 from 6

let inputRanges = input.split(whereSeparator: \.isNewline).map { line in
    let match = String(line).wholeMatch(of: regex)!

    let lhsStartIndex = Int(match.1) ?? 0
    let lhsEndIndex = Int(match.2) ?? 0
    let rhsStartIndex = Int(match.3) ?? 0
    let rhsEndIndex = Int(match.4) ?? 0

    return (lhsStartIndex...lhsEndIndex, rhsStartIndex...rhsEndIndex)
}

let pairsWithFullyOverlappingRanges = inputRanges.filter { (lhsRange, rhsRange) in
    guard lhsRange.overlaps(rhsRange) else { return false }
    //if start indexes are the same than either one of ranges is inside of the other one
    guard lhsRange.startIndex != rhsRange.startIndex else { return true }
    var ranges = [lhsRange, rhsRange].sorted { $0.startIndex < $1.startIndex }
    return ranges[0].contains(ranges[1].upperBound)
}

print(pairsWithFullyOverlappingRanges.count)


let pairsWithOverlappingRanges = inputRanges.filter { $0.overlaps($1) }

print(pairsWithOverlappingRanges.count)
