//
//  day20.swift
//  aoc
//
//  Created by Greg Titus on 12/19/24.
//

import Foundation

func dayTwenty(_ contents: String, part1: Bool = false) -> Int {
    typealias Pos = Grid<Character>.Index

    let grid = Grid(contents: contents)
    let start = grid.indices.first(where: { grid[$0] == "S" })!
    let end = grid.indices.first(where: { grid[$0] == "E" })!

    let startToEnd = grid.bestManhattanMoves(from: start, to: end)
    let bestWithNoCheats = startToEnd[end]!
    let endToStart = grid.bestManhattanMoves(from: end, to: start)

    let limit = bestWithNoCheats - 100
    let cheatDistance = part1 ? 2 : 20
    var result = 0
    for i in grid.indices {
        guard let startMoves = startToEnd[i] else { continue }
        for x in i.x - cheatDistance ... i.x + cheatDistance {
            for y in i.y - cheatDistance ... i.y + cheatDistance {
                let distance = abs(i.x - x) + abs(i.y - y)
                guard distance <= cheatDistance else { continue }
                guard let endMoves = endToStart[Pos(x: x, y: y)] else { continue }
                if startMoves + endMoves + distance <= limit {
                    result += 1
                }
            }
        }
    }
    return result
}
