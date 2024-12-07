//
//  day7.swift
//  aoc
//
//  Created by Greg Titus on 12/6/24.
//

import Foundation

func daySeven(_ contents: String) -> Int {
    var result = 0

    contents.enumerateLines { line, _ in
        let colonParts = line.components(separatedBy: ":")
        let testValue = Int(colonParts[0])!
        let spaceParts = colonParts[1].components(separatedBy: " ")
        let operands = spaceParts.dropFirst().map { Int($0)! }

        func evaluate(_ testValue: Int, operands: [Int]) -> Bool {
            let operators: [(Int,Int)->Int] = [{$0 * $1}, {$0 + $1}, { Int($0.description + $1.description)! }]
            for o in operators {
                let v = o(operands[0], operands[1])
                if operands.count == 2 {
                    if v == testValue { return true }
                } else {
                    if evaluate(testValue, operands: [v] + operands.dropFirst(2)) {
                        return true
                    }
                }
            }
            return false
        }

        if evaluate(testValue, operands: operands) {
            result += testValue
        }
    }
    return result
}
