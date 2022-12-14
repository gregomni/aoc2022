//
//  RopeBridge.swift
//  aoc
//
//  Created by Greg Titus on 12/9/22.
//

import Foundation

func ropeBridge(_ contents: String, number: Int = 10) -> Int {
    struct Position : Hashable {
        var x: Int = 0
        var y: Int = 0

        mutating func up() { y += 1 }
        mutating func down() { y -= 1 }
        mutating func left() { x -= 1 }
        mutating func right() { x += 1 }

        func adjacent(_ other: Position) -> Bool {
            abs(self.x - other.x) <= 1 && abs(self.y - other.y) <= 1
        }
        mutating func follow(_ head: Position) {
            if adjacent(head) { return }

            let deltaX = head.x < x ? -1 : 1
            let deltaY = head.y < y ? -1 : 1

            if head.x == x {
                y += deltaY
            } else if head.y == y {
                x += deltaX
            } else {
                x += deltaX
                y += deltaY
            }
        }
    }

    var visited: Set<Position> = []
    var knots = Array(repeating: Position(), count: number)

    visited.insert(knots.last!)

    contents.enumerateLines { line, _ in
        let move = line.first!
        let count = Int(line.suffix(from: line.index(line.startIndex, offsetBy: 2)))!

        for _ in 0 ..< count {
            switch move {
            case "U": knots[0].up()
            case "D": knots[0].down()
            case "L": knots[0].left()
            case "R": knots[0].right()
            default:
                preconditionFailure("bad move")
            }

            for i in 1 ..< number {
                knots[i].follow(knots[i-1])
            }

            visited.insert(knots.last!)
        }
    }
    return visited.count
}
