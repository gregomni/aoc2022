//
//  day10.swift
//  aoc
//
//  Created by Greg Titus on 12/9/24.
//

import Foundation

func dayTen(_ contents: String) -> Int {
    let grid = Grid(contents: contents, mapping: { $0.wholeNumberValue! })

    func summits(from: Grid<Int>.Index) -> Int {
        let nextHeight = grid[from] + 1
        var result = 0
        for next in grid.cardinalDirections(from: from) where grid[next] == nextHeight {
            if nextHeight == 9 {
                result += 1
            } else {
                result += summits(from: next)
            }
        }
        return result
    }

    let trailheads = grid.indices.filter { grid[$0] == 0 }
    return trailheads.map({ summits(from: $0) }).reduce(0, +)
}
