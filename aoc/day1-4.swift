//
//  day1.swift
//  aoc
//
//  Created by Greg Titus on 11/27/24.
//

import Foundation
import RegexBuilder

func dayOne(_ contents: String) -> Int {
    var aArray: [Int] = []
    var bCounts: [Int:Int] = [:]
    contents.enumerateLines { line, _ in
        let parts = line.components(separatedBy: "   ")
        let a = Int(parts[0])!
        let b = Int(parts[1])!

        aArray.append(a)
        bCounts[b, default: 0] += 1
    }
    return aArray.reduce(0) { result, a in result + a * (bCounts[a] ?? 0) }
}

func dayTwo(_ contents: String) -> Int {
    func testArray(_ array: [Int]) -> Bool {
        var last: Int? = nil
        var sign: Int? = nil
        for i in array {
            if let last {
                let diff = i - last
                if abs(diff) > 3 || abs(diff) < 1 {
                    return false
                } else if let sign, sign != diff.signum() {
                    return false
                }
                sign = diff.signum()
            }
            last = i
        }
        return true
    }

    var safe = 0
    contents.enumerateLines { line, _ in
        let array = line.components(separatedBy: " ").map({ Int($0)! })
        if testArray(array) {
            safe += 1
        } else {
            for i in array.indices {
                var a = array
                a.remove(at: i)
                if testArray(a) {
                    safe += 1
                    break
                }
            }
        }
    }
    return safe
}

func dayThree(_ contents: String, part2: Bool = true) -> Int {
    var result = 0
    var enabled = true
    for match in contents.matches(of: /do\(\)|don't\(\)|mul\(([0-9]+),([0-9]+)\)/) {
        switch match.0 {
        case "do()":
            enabled = true
        case "don't()":
            if part2 { enabled = false }
        default:
            if enabled {
                result += Int(match.1!)! * Int(match.2!)!
            }
        }
    }
    return result
}

func dayFour_part1(_ contents: String) -> Int {
    let theRest = Array("MAS")
    let grid = Grid(contents: contents)
    var result = 0
    for index in grid.indices {
        guard grid[index] == "X" else { continue }
        for dx in -1 ... 1 {
            for dy in -1 ... 1 {
                if dx == 0, dy == 0 { continue }
                if (Array(grid.walk(dx: dx, dy: dy, from: index).elements().prefix(3)) == theRest) {
                    result += 1
                }
            }
        }
    }
    return result
}

func dayFour(_ contents: String) -> Int {
    let grid = Grid(contents: contents)
    var result = 0
    for index in grid.indices {
        guard grid[index] == "A" else { continue }
        let i = index.vector(dx: 1, dy: 1)
        let j = index.vector(dx: -1, dy: -1)
        let k = index.vector(dx: 1, dy: -1)
        let l = index.vector(dx: -1, dy: 1)
        guard grid.valid(index: i), grid.valid(index: j), grid.valid(index: k), grid.valid(index: l) else { continue }

        if grid[i] == "M" && grid[j] == "S" || grid[i] == "S" && grid[j] == "M" {
            if grid[k] == "M" && grid[l] == "S" || grid[k] == "S" && grid[l] == "M" {
                result += 1
            }
        }
    }
    return result
}
