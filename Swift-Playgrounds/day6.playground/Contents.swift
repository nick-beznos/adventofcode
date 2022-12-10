import Foundation
import RegexBuilder

let fileURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let input = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)

let array = Array(input)

func findStartIndexWithRange(_ initialStartIndex: Int, _ initialEndIndex: Int) -> Int {
    var startIndex = initialStartIndex
    var endIndex = initialEndIndex

    var startMarker = 0

    var keepSearching = true

    while keepSearching {
        guard array.count > endIndex + 1 else {
            keepSearching = false
            break
        }

        let checkedValues = array[startIndex...endIndex]
        let uniqueValues = Array(Set(checkedValues))

        if checkedValues.count == uniqueValues.count {
            keepSearching = false
            startMarker = endIndex + 1
        }

        startIndex += 1
        endIndex += 1
    }

    return startMarker
}

print(findStartIndexWithRange(0, 3))
print(findStartIndexWithRange(0, 13))
