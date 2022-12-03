import Algorithms
import Foundation

let fileURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let input = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)

var totalScore = 0
var totalScoreOfBadges = 0

let lowercaseOffset = 96
let uppercaseOffset = 38

func itemScore(_ item: Character) -> Int  {
    let scalars = item.unicodeScalars
    let ui32 = scalars[scalars.startIndex].value
    return Int(ui32) - (item.isUppercase ? uppercaseOffset : lowercaseOffset)
}

func splitInHalfs(text: String.SubSequence) -> [ArraySlice<Character>] {
    let chars = Array(text)
    let count = text.count / 2
    return stride(from: 0, to: chars.count, by: count)
        .map { chars[$0 ..< min($0 + count, chars.count)] }
}

input.split(whereSeparator: \.isNewline).forEach { line in
    let compartments = splitInHalfs(text: line)
    let commonElement = compartments[0].filter(compartments[1].contains)[0]
    totalScore += itemScore(commonElement)
}

print(totalScore)

let chunks = input.split(whereSeparator: \.isNewline).chunks(ofCount: 3)

chunks.forEach { chunk in
    let commonElement = chunk[chunk.startIndex].filter { element in
        chunk[chunk.startIndex + 1].contains(element) && chunk[chunk.startIndex + 2].contains(element)
    }

    totalScoreOfBadges += itemScore(Array(commonElement)[0])
}

print(totalScoreOfBadges)
