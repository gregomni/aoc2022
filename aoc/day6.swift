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
    var grid = Grid(contents: contents, mapping: { Square($0) })

    func walk(_ grid: inout Grid<Square>, from: Grid<Square>.Index) -> Bool {
        var position = from
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

    let start = grid.indices.first(where: { grid[$0].visited })!
    if part1 {
        _ = walk(&grid, from: start)
        return grid.indices.filter({ grid[$0].visited }).count
    } else {
        var touched = Grid(copy: grid)
        _ = walk(&touched, from: start)

        var result = 0
        for i in grid.indices where touched[i].visited && i != start {
            var copy = Grid(copy: grid)
            copy[i].barrier = true
            if walk(&copy, from: start) {
                result += 1
            }
        }
        return result
    }
}

