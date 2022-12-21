//
//  MonkeyShouts.swift
//  aoc
//
//  Created by Greg Titus on 12/20/22.
//

import Foundation
import RegexBuilder

enum Shout {
    enum Operator: String {
        case plus = "+"
        case minus = "-"
        case multiply = "*"
        case divide = "/"
    }
    case number(Int)
    case operation(String, Operator, String)
    case unknown
}

func monkeyShouts(_ contents: String, part2: Bool = true) -> Int {
    let regex = Regex {
        let name = Capture { OneOrMore(.anyOf("abcdefghijklmnopqrstuvwxyz")) } transform: { String($0) }
        let op = Capture { ChoiceOf { "+"; "-"; "*"; "/" } } transform: { Shout.Operator(rawValue: String($0))! }

        name; ": "
        ChoiceOf {
            Capture { OneOrMore(.digit) } transform: { Int($0)! }
            Regex { name; " "; op; " "; name }
        }
    }

    var shouts: [String : Shout] = [:]
    contents.enumerateLines { line, _ in
        let match = line.firstMatch(of: regex)!
        let name = match.output.1

        if part2, name == "humn" {
            shouts[name] = Shout.unknown
        } else if let number = match.output.2 {
            shouts[name] = Shout.number(number)
        } else {
            shouts[name] = Shout.operation(match.output.3!, match.output.4!, match.output.5!)
        }
    }

    func numberFor(monkey: String) -> Int? {
        let shout = shouts[monkey]!
        switch shout {
        case .number(let i):
            return i
        case .operation(let a, let op, let b):
            guard let aNumber = numberFor(monkey: a) else { return nil }
            guard let bNumber = numberFor(monkey: b) else { return nil }
            switch op {
            case .plus:
                return aNumber + bNumber
            case .minus:
                return aNumber - bNumber
            case .multiply:
                return aNumber * bNumber
            case .divide:
                return aNumber / bNumber
            }
        case .unknown:
            return nil
        }
    }

    func findUnknown(_ name: String, equals e: Int) -> Int {
        let shout = shouts[name]!
        let equalTo: Int

        switch shout {
        case .number(_):
            assertionFailure("shouldn't get a constant, we're in the subtree of the unknown")
            return -1
        case .operation(let a, let op, let b):
            // equals = n op unknown
            if let n = numberFor(monkey: a) {
                switch op {
                case .plus:
                    equalTo = e - n
                case .minus:
                    equalTo = -(e - n)
                case .multiply:
                    equalTo = e / n
                case .divide:
                    equalTo = n / e
                }
                return findUnknown(b, equals: equalTo)
            } else {
                let n = numberFor(monkey: b)!
                switch op {
                case .plus:
                    equalTo = e - n
                case .minus:
                    equalTo = e + n
                case .multiply:
                    equalTo = e / n
                case .divide:
                    equalTo = e * n
                }
                return findUnknown(a, equals: equalTo)
            }
        case .unknown:
            return e
        }
    }

    if part2 {
        guard case let .operation(a, _, b) = shouts["root"]! else { return 0 }
        if let lhs = numberFor(monkey: a) {
            return findUnknown(b, equals: lhs)
        } else {
            let rhs = numberFor(monkey: b)!
            return findUnknown(a, equals: rhs)
        }
    } else {
        return numberFor(monkey: "root")!
    }
}
