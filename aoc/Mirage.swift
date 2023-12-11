//
//  Mirage.swift
//  aoc
//
//  Created by Greg Titus on 12/10/23.
//

import Foundation

extension Array<Int> {
    func differences() -> [Int] {
        var last: Int? = nil
        var result: [Int] = []
        for i in self {
            if let l = last {
                result.append(i - l)
            }
            last = i
        }
        return result
    }
}

func mirage(_ contents: String) -> Int {
    var total = 0
    contents.enumerateLines { line, _ in
        let numbers = line.components(separatedBy: " ").map({ Int($0)! })
        var diffs: [[Int]] = [numbers]

        while !diffs.last!.allSatisfy({ $0 == 0 }) {
            diffs.append(diffs.last!.differences())
        }

        var change = 0
        for diff in diffs.reversed() {
            change = diff.first! - change
        }
        total += change
    }
    return total
}

