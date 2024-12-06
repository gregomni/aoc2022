//
//  day6.swift
//  aoc
//
//  Created by Greg Titus on 12/5/24.
//

import Foundation
import RegexBuilder

func daySix(_ contents: String, _ part1: Bool = false) -> Int {
    typealias Dir = Grid<Square>.Direction
    struct Square {
        var directions: [Dir] = []
        var visited: Bool { !directions.isEmpty }
        var barrier = false

        init(_ c: Character) {
            switch c {
            case "<":
                directions.append(Dir.left)
            case ">":
                directions.append(Dir.right)
            case "^":
                directions.append(Dir.up)
            case "v":
                directions.append(Dir.down)
            case "#":
                barrier = true
            default:
                break
            }
        }
    }
    let grid = Grid(contents: contents, mapping: { Square($0) })
    let start = grid.indices.first(where: { grid[$0].visited })!

    func walk(_ grid: inout Grid<Square>) -> Bool {
        var position = start
        var direction = grid[position].directions.first!

        while true {
            let next = position.direction(direction)
            guard grid.valid(index: next) else { return false }
            if grid[next].barrier {
                direction = direction.turnClockwise()
            } else {
                position = next
            }
            if grid[position].directions.contains(direction) { return true }
            grid[position].directions.append(direction)
        }
    }

    var touched = Grid(copy: grid)
    _ = walk(&touched)

    if part1 {
        return touched.indices.filter({ touched[$0].visited }).count
    } else {
        var result = 0
        for i in grid.indices where touched[i].visited && i != start {
            var copy = Grid(copy: grid)
            copy[i].barrier = true
            if walk(&copy) {
                result += 1
            }
        }
        return result
    }
}

