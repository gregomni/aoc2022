//
//  day18.swift
//  aoc
//
//  Created by Greg Titus on 12/17/24.
//

import Foundation
import Collections

func dayEighteen(_ contents: String, part1: Bool = false) -> Int {
    let size = 71

    typealias Pos = Grid<Square>.Index
    struct Square {
        var corrupt = false
        var best = Int.max
        var from: Pos? = nil
    }

    let grid = Grid(width: size, height: size, element: Square())
    let corruptions = contents.matches(of: /([0-9]+),([0-9]+)/).map { Pos(x: Int($0.1)!, y: Int($0.2)!) }
    let start = Pos(x: 0, y: 0)
    let end = Pos(x: size-1, y: size-1)

    struct Move : Comparable {
        let position: Pos
        let steps: Int

        static func < (lhs: Move, rhs: Move) -> Bool { lhs.steps < rhs.steps }
    }

    func solve(_ grid: Grid<Square>) -> Int? {
        var spots = Heap([Move(position: start, steps: 0)])
        while let m = spots.popMin() {
            let newSteps = m.steps+1
            for i in grid.cardinalDirections(from: m.position) {
                if !grid[i].corrupt, grid[i].best > newSteps {
                    grid[i].best = newSteps
                    grid[i].from = m.position
                    spots.insert(Move(position: i, steps: newSteps))
                }
                guard i != end else { return newSteps }
            }
        }
        return nil
    }

    func solveAndGetPath() -> Set<Pos>? {
        let copy = Grid(copy: grid)
        guard solve(copy) != nil else { return nil }
        var result: Set<Pos> = []
        var i = end
        while i != start {
            result.insert(i)
            i = copy[i].from!
        }
        return result
    }

    for i in corruptions[..<1024] {
        grid[i].corrupt = true
    }
    if part1 { return solve(grid)! }

    var path = solveAndGetPath()!
    for i in corruptions[1024...] {
        grid[i].corrupt = true
        if path.contains(i) {
            if let newPath = solveAndGetPath() {
                path = newPath
            } else {
                print(i)
                break
            }
        }
    }
    return 0
}
