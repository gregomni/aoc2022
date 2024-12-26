//
//  day6.swift
//  aoc
//
//  Created by Greg Titus on 12/5/24.
//

import Foundation
import RegexBuilder

func daySix(_ contents: String) -> Int {
    struct Square {
        var directions = 0
        var visited: Bool { directions != 0 }
        var barrier = false

        init(_ c: Character) {
            switch c {
            case "^":
                directions = (1 << Direction.up.rawValue)
            case "#":
                barrier = true
            default:
                break
            }
        }
    }
    var grid = Grid(contents: contents, mapping: { Square($0) })
    let start = grid.indices.first(where: { grid[$0].visited })!

    // guard walks, returning false if stepping out of the grid, or true if in a loop
    func newBarrierWalk(_ grid: inout Grid<Square>, from start: Position, in d: Direction) -> Bool {
        var position = start
        var direction = d

        while true {
            let next = position.direction(direction)
            guard grid.valid(index: next) else { return false }
            if grid[next].barrier {
                direction = direction.turnClockwise()
                if (grid[position].directions & (1 << direction.rawValue)) != 0 { return true }
                grid[position].directions |= (1 << direction.rawValue)
            } else {
                position = next
            }
        }
    }

    // original walk
    var placedAlready: Set<Position> = [start]
    func walk(_ grid: inout Grid<Square>, start: Grid<Square>.Index = start) -> Int {
        var result = 0

        var position = start
        var direction = Direction.up

        while true {
            let next = position.direction(direction)
            guard grid.valid(index: next) else { return result }
            if grid[next].barrier {
                direction = direction.turnClockwise()
                grid[position].directions |= (1 << direction.rawValue)
            } else {
                let ifTurned = direction.turnClockwise()
                if !placedAlready.contains(next) {
                    placedAlready.insert(next)
                    var copy = Grid(copy: grid)
                    copy[next].barrier = true
                    if newBarrierWalk(&copy, from: position, in: ifTurned) {
                        result += 1
                    }
                }
                position = next
            }
        }
    }
    return walk(&grid)
}

