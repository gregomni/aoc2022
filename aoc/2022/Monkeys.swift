//
//  Monkeys.swift
//  aoc
//
//  Created by Greg Titus on 12/10/22.
//

import Foundation
import RegexBuilder

typealias ItemType = Int

struct Monkey {
    let number: Int
    var items: [ItemType]
    let operation: (ItemType) -> ItemType
    let test: ItemType
    let trueThrow: Int
    let falseThrow: Int
    var inspections: Int = 0
}

func monkeys(_ contents: String, rounds: Int = 10000) -> Int {
    let monkeyRegex = Regex {
        "Monkey "
        Capture { OneOrMore(.digit) } transform: { Int($0)! }
        ":\n  Starting items: "
        Capture {
            ZeroOrMore { OneOrMore(.digit); ", " }
            OneOrMore(.digit)
        }
        "\n  Operation: new = old "
        Capture { ChoiceOf { "*"; "+" } }
        " "
        Capture { ChoiceOf { "old"; OneOrMore(.digit) } }
        "\n  Test: divisible by "
        Capture { OneOrMore(.digit) } transform: { ItemType($0)! }
        "\n    If true: throw to monkey "
        Capture { OneOrMore(.digit) } transform: { Int($0)! }
        "\n    If false: throw to monkey "
        Capture { OneOrMore(.digit) } transform: { Int($0)! }
    }

    var monkeys = contents.matches(of: monkeyRegex).map { match in
        let (_, number, list, op, operand, test, trueThrow, falseThrow) = match.output
        let items = list.components(separatedBy: ", ").map({ ItemType($0)! })
        let operation: (ItemType) -> ItemType

        if let i = ItemType(operand) {
            operation = op == "*" ? { $0 * i } : { $0 + i }
        } else {
            operation = op == "*" ? { $0 * $0 } : { $0 + $0 }
        }
        return Monkey(number: number, items: items, operation: operation, test: test, trueThrow: trueThrow, falseThrow: falseThrow)
    }

    let maxWorry = monkeys.reduce(1) { $0 * $1.test }

    for _ in 0 ..< rounds {
        for index in 0 ..< monkeys.count {
            var m = monkeys[index]
            while let item = m.items.first {
                let newItem = m.operation(item) % maxWorry
                let test = newItem % m.test == 0

                monkeys[test ? m.trueThrow : m.falseThrow].items.append(newItem)
                m.items.remove(at: 0)
                m.inspections += 1
            }
            monkeys[index] = m
        }
    }

    let results = Array(monkeys.map({ $0.inspections }).sorted().reversed())
    return results[0] * results[1]
}


