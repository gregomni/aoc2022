//
//  day20.swift
//  aoc
//
//  Created by Greg Titus on 12/19/24.
//

import Foundation
import Collections

func dayTwenty(_ contents: String, part1: Bool = true) -> Int {
    typealias Pos = Grid<Character>.Index
    typealias Dir = Grid<Character>.Direction

    struct Possibility: Comparable {
        let move: Pos
        let score: Int

        static func < (lhs: Possibility, rhs: Possibility) -> Bool {
            lhs.score < rhs.score
        }
    }

    let grid = Grid(contents: contents)

    let start = grid.indices.first(where: { grid[$0] == "S" })!
    let end = grid.indices.first(where: { grid[$0] == "E" })!

    func search(_ grid: Grid<Character>, from start: Pos, to end: Pos) -> [Pos : Int] {
        var best: [Pos : Int] = [:]
        var bestRouteSoFar = Int.max
        var examine = Heap<Possibility>()
        examine.insert(Possibility(move: start, score: 0))

        while let possibility = examine.popMin() {
            let move = possibility.move
            if possibility.score >= bestRouteSoFar { continue }
            if possibility.score > best[move, default: .max] { continue }
            for m in grid.cardinalDirections(from: move) where grid[m] != "#" {
                let score = possibility.score + 1
                if score >= best[m, default: .max] { continue }
                best[m] = score
                if m == end {
                    bestRouteSoFar = min(bestRouteSoFar, score)
                } else {
                    examine.insert(Possibility(move: m, score: score))
                }
            }
        }
        return best
    }

    let startToEnd = search(grid, from: start, to: end)
    let bestWithNoCheats = startToEnd[end]!
    let endToStart = search(grid, from: end, to: start)

    let limit = bestWithNoCheats - 100
    let cheatDistance = part1 ? 2 : 20
    var result = 0
    for i in grid.indices {
        guard let startMoves = startToEnd[i] else { continue }
        for j in grid.indices {
            guard let endMoves = endToStart[j] else { continue }
            let distance = abs(i.x - j.x) + abs(i.y - j.y)
            guard distance <= cheatDistance else { continue }
            if startMoves + endMoves + distance <= limit {
                result += 1
            }
        }
    }
    return result
}
