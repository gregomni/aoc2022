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

extension BidirectionalCollection {
    func allPairs() -> [(Element,Element)] {
        switch self.count {
        case 0, 1:
            return []
        case 2:
            return [(first!, last!)]
        default:
            let firstless = self.dropFirst()
            let pairs = firstless.map { (first!, $0) }
            return pairs + firstless.allPairs()
        }
    }
}

func dayEight(_ contents: String) -> Int {
    struct Square {
        let antenna: Character
        var antinodes = 0

        init(_ antenna: Character) {
            self.antenna = antenna
        }
    }
    let grid = Grid(contents: contents, mapping: { Square($0) })

    var freqs: Set<Character> = ["."]
    for i in grid.indices {
        let freq = grid[i].antenna
        guard !freqs.contains(freq) else { continue }
        freqs.insert(freq)

        let all = grid.indices.filter { grid[$0].antenna == freq }
        for (var j, var k) in all.allPairs() {
            let dx = j.x - k.x
            let dy = j.y - k.y

            while grid.valid(index: j) {
                grid[j].antinodes += 1
                j = grid.at(x: j.x - dx, y: j.y - dy)
            }
            while grid.valid(index: k) {
                grid[k].antinodes += 1
                k = grid.at(x: k.x + dx, y: k.y + dy)
            }
        }
    }

    return grid.count(where: { $0.antinodes > 0 })
}
