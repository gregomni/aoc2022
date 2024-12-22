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
    let etsGrid = Grid<Int?>(width: grid.xSize, height: grid.ySize, element: nil)
    for (i, score) in endToStart {
        etsGrid[i.x,i.y] = score
    }

    let limit = bestWithNoCheats - 100
    let cheatDistance = part1 ? 2 : 20
    var result = 0
    for (i, startMoves) in startToEnd {
        for x in i.x - cheatDistance ... i.x + cheatDistance {
            let xDistance = abs(i.x - x)
            let cheatLeft = cheatDistance - xDistance
            for y in i.y - cheatLeft ... i.y + cheatLeft {
                let pos = Grid<Int?>.Index(x: x, y: y)
                guard etsGrid.valid(index: pos) else { continue }
                guard let endMoves = etsGrid[pos] else { continue }
                let yDistance = abs(i.y - y)
                if startMoves + endMoves + xDistance + yDistance <= limit {
                    result += 1
                }
            }
        }
    }
    return result
}
