//
//  day25.swift
//  aoc
//
//  Created by Greg Titus on 12/25/24.
//

import Foundation

func dayTwentyFive(_ contents: String) -> Int {
    var keys: [[Int]] = []
    var locks: [[Int]] = []

    let parts = contents.components(separatedBy: "\n\n")
    for string in parts {
        let grid = Grid(contents: string)
        var counts: [Int] = []
        for x in 0 ..< grid.xSize {
            let count = (1 ..< (grid.ySize-1)).count(where: { grid[x,$0] == "#" })
            counts.append(count)
        }
        if grid[0,0] == "#" {
            locks.append(counts)
        } else {
            keys.append(counts)
        }
    }

    func fits(lock: [Int], key: [Int]) -> Bool {
        zip(lock, key).map({ $0.0 + $0.1 }).allSatisfy({ $0 <= 5 })
    }

    var result = 0
    for l in locks {
        for k in keys {
            if fits(lock: l, key: k) {
                result += 1
            }
        }
    }
    return result
}
