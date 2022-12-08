import Foundation

let fileURL = Bundle.main.url(forResource: "Input", withExtension: nil)
let input = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)

let grid = input.split(whereSeparator: \.isNewline).map({ $0.map({ Int("\($0)")! }) })

let maxX = grid.first!.count - 1
let maxY = grid.count - 1

struct Coordinate {
    let x: Int
    let y: Int
}

func isVisible(at coordinate: Coordinate) -> Bool {
    guard !(coordinate.x == 0 || coordinate.x == maxX || coordinate.y == 0 || coordinate.y == maxY) else { return true }
    let hight = grid[coordinate.y][coordinate.x]
    let column = grid.map({ $0[coordinate.x] })

    let isVisibleFromLeft = !grid[coordinate.y][0...(coordinate.x - 1)].contains(where: { $0 >= hight })
    let isVisibleFromRight = !grid[coordinate.y][(coordinate.x + 1)...maxX].contains(where: { $0 >= hight })

    let isVisibleFromTop = !column[0...(coordinate.y - 1)].contains(where: { $0 >= hight })
    let isVisibleFromBottom = !column[(coordinate.y + 1)...maxY].contains(where: { $0 >= hight })

    let isVisible = isVisibleFromLeft || isVisibleFromRight || isVisibleFromTop || isVisibleFromBottom

    return isVisible
}

func visibleTrees() -> [Int] {
    var visibleTrees = [Int]()

    for (y, row) in grid.enumerated() {
        for (x, tree) in row.enumerated() {
            if isVisible(at: Coordinate(x: x, y: y)) {
                visibleTrees.append(tree)
            }
        }
    }
    return visibleTrees
}

func scenicScoreForTree(at coordinate: Coordinate) -> Int {
    guard !(coordinate.x == 0 || coordinate.x == maxX || coordinate.y == 0 || coordinate.y == maxY) else { return 0 }
    let hight = grid[coordinate.y][coordinate.x]
    let column = grid.map({ $0[coordinate.x] })

    let scoreLeft = trees(in: Array(grid[coordinate.y][0...(coordinate.x - 1)]), untilHeight: hight, forLeftOrTop: true).count
    let scoreRight = trees(in: Array(grid[coordinate.y][(coordinate.x + 1)...maxX]), untilHeight: hight, forLeftOrTop: false).count
    let scoreTop = trees(in: Array(column[0...(coordinate.y - 1)]), untilHeight: hight, forLeftOrTop: true).count
    let scoreBottom = trees(in: Array(column[(coordinate.y + 1)...maxY]), untilHeight: hight, forLeftOrTop: false).count

    let score = scoreLeft * scoreRight * scoreTop * scoreBottom

    return score
}

func trees(in trees: [Int], untilHeight height: Int, forLeftOrTop: Bool) -> [Int] {
    var input = trees
    var result = [Int]()
    if forLeftOrTop {
        input = trees.reversed()
    }

    for treeHeight in input {
        if treeHeight < height {
            result.append(treeHeight)
        } else {
            result.append(treeHeight)
            return result
        }
    }

    return result
}

let treesInSight = visibleTrees()
print("Visible trees count is \(treesInSight.count)")

/// PART 2

func scenicScores() -> [Int] {
    var scenicScores = [Int]()

    for (y, row) in grid.enumerated() {
        for (x, _) in row.enumerated() {
            scenicScores.append(scenicScoreForTree(at: Coordinate(x: x, y: y)))
        }
    }

    return scenicScores
}

func evaluateFunc(_ code: () -> ()) {
    let start = DispatchTime.now()
    code()
    let finish = DispatchTime.now()

    let nanoTime = finish.uptimeNanoseconds - start.uptimeNanoseconds
    let timeInterval = Double(nanoTime) / 1_000_000_000
    print("It took \(timeInterval) seconds to run this 💩")
}

evaluateFunc {
    let bestTreeScore = scenicScores().sorted().last!
    print("The highest scenic score possible is \(bestTreeScore)")
}
