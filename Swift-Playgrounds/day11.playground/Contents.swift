import Foundation
import RegexBuilder

let inputURL = Bundle.main.url(forResource: "Input", withExtension: "txt")
let input = try String(contentsOf: inputURL!, encoding: String.Encoding.utf8)
let testURL = Bundle.main.url(forResource: "test", withExtension: "txt")
let test = try String(contentsOf: testURL!, encoding: String.Encoding.utf8)

enum Operation {
    case sum(Int)
    case multiplication(Int)
    case pow
}

typealias ItemForMonkeyIndexed = (Int, Int)

class Monkey {
    var items: [Int]
    let operation: Operation
    let test: Int
    let trueMonkeyIndex: Int
    let falseMonkeyIndex: Int
    var inspectionsCount: Int = 0

    init(items: [Int], operation: Operation, test: Int, trueMonkeyIndex: Int, falseMonkeyIndex: Int) {
        self.items = items
        self.operation = operation
        self.test = test
        self.trueMonkeyIndex = trueMonkeyIndex
        self.falseMonkeyIndex = falseMonkeyIndex
    }

    func doShenanigans(commonTest: Int) -> [ItemForMonkeyIndexed] {
        var itemsForMonkeys = [ItemForMonkeyIndexed]()

        for item in items {
            inspectionsCount += 1
            var newItem: Int

            switch operation {
            case .sum(let num):
                newItem = item + num
            case .multiplication(let num):
                newItem = item * num
            case .pow:
                newItem = item * item
            }

            newItem %= commonTest

            //            newItem /= 3

            switch (newItem % test) == 0 {
            case true:
                itemsForMonkeys.append((newItem, trueMonkeyIndex))
            case false:
                itemsForMonkeys.append((newItem, falseMonkeyIndex))
            }
        }
        items.removeAll()

        return itemsForMonkeys
    }
}

let regex = Regex {
    "Monkey "
    Capture(OneOrMore(.digit))
    ":\n  Starting items: "
    Capture(OneOrMore(.any))
    "\n  Operation: new = old "
    Capture(ChoiceOf {
        "*"
        "+"
    })
    " "
    Capture(ChoiceOf {
        OneOrMore(.digit)
        "old"
    })
    "\n  Test: divisible by "
    Capture(OneOrMore(.digit))
    "\n    If true: throw to monkey "
    Capture(OneOrMore(.digit))
    "\n    If false: throw to monkey "
    Capture(OneOrMore(.digit))
}

func parse(_ stringInput: String) -> [Monkey] {
    var result = [Monkey]()

    stringInput.components(separatedBy: "\n\n").forEach { rawMonkey in
        if let match = rawMonkey.wholeMatch(of: regex) {
            let items = String(match.2).components(separatedBy: ", ").compactMap({ Int($0) })

            var operation: Operation = .pow
            switch match.3 {
            case "+":
                operation = .sum(Int(match.4) ?? 0)
            case "*":
                if match.4 == "old" {
                    break
                } else {
                    operation = .multiplication(Int(match.4) ?? 1)
                }
            default: break
            }

            let monkey = Monkey(items: items,
                                operation: operation, test: Int(match.5) ?? 0, trueMonkeyIndex: Int(match.6)!, falseMonkeyIndex: Int(match.7)!)
            result.append(monkey)
        } else {
            print("cant parse \(rawMonkey)")
        }
    }

    return result
}

class SimianShenanigans {
    let monkeys: [Monkey]

    init(monkeys: [Monkey]) {
        self.monkeys = monkeys
    }

    func doShenanigans(rounds: Int) {
        let commonTest = monkeys.map({ $0.test }).reduce(1, *)
        for _ in 1...rounds {
            for monkey in monkeys {
                let itemsForMonkeys = monkey.doShenanigans(commonTest: commonTest)
                for (item, monkeyIndex) in itemsForMonkeys {
                    monkeys[monkeyIndex].items.append(item)
                }
            }
        }
        print("done with the Shenanigans")

        let businessLevel = monkeys.map({ $0.inspectionsCount }).sorted(by: { $0 > $1}).prefix(2).reduce(1, *)
        print(businessLevel)
    }
}

let shenanigans = SimianShenanigans(monkeys: parse(input))
shenanigans.doShenanigans(rounds: 10000)
