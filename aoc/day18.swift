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
    }
    struct Score: ScoreType {
        var best = 0
        var from: Pos? = nil
        func combineEqualPaths(lhs: Score, rhs: Score) -> Score { return lhs }
        static func < (lhs: Score, rhs: Score) -> Bool { lhs.best < rhs.best }
    }

    let grid = Grid(width: size, height: size, element: Square())
    let corruptions = contents.matches(of: /([0-9]+),([0-9]+)/).map { Pos(x: Int($0.1)!, y: Int($0.2)!) }
    let start = Pos(x: 0, y: 0)
    let end = Pos(x: size-1, y: size-1)

    func solveAndGetPath() -> Set<Pos>? {
        let best = grid.bestMoves(from: PossibleMove(move: start, score: Score()), to: { $0 == end }) { grid, possible in
            grid.cardinalDirections(from: possible.move)
                .filter({ !grid[$0].corrupt })
                .map({ PossibleMove(move: $0, score: Score(best: possible.score.best+1, from: possible.move)) })
        }
        guard best[end] != nil else { return nil }
        var result: Set<Pos> = []
        var i = end
        while i != start {
            result.insert(i)
            i = best[i]!.from!
        }
        return result
    }

    for i in corruptions[..<1024] {
        grid[i].corrupt = true
    }
    if part1 { return grid.manhattanMoveDistance(from: start, to: end, allowed: { !$0.corrupt })! }

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
