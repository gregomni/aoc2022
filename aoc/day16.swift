//
//  day16.swift
//  aoc
//
//  Created by Greg Titus on 12/15/24.
//

import Foundation
import Collections

func daySixteen(_ contents: String) -> Int {
    typealias Pos = Grid<Character>.Index
    typealias Dir = Grid<Character>.Direction
    
    struct Here: Hashable {
        var here: Pos
        var facing: Dir

        func moves(in grid: Grid<Character>) -> [Here] {
            var result: [Here] = []
            let next = here.direction(facing)
            if grid[next] != "#" {
                result.append(Here(here: next, facing: facing))
            }
            let cw = here.direction(facing.turnClockwise())
            if grid[cw] != "#" {
                result.append(Here(here: cw, facing: facing.turnClockwise()))
            }
            let ccw = here.direction(facing.turnCCW())
            if grid[ccw] != "#" {
                result.append(Here(here: ccw, facing: facing.turnCCW()))
            }
            return result
        }
    }

    struct Score: ScoreType {
        let s: Int
        var path: [Here] = []

        static func < (lhs: Score, rhs: Score) -> Bool { lhs.s < rhs.s }
        static var max = Score(s: .max)

        func combineEqualScores(_ other: Self) -> Self {
            return Score(s: s, path: path + other.path)
        }
    }

    let grid = Grid(contents: contents)
    let start = grid.indices.first(where: { grid[$0] == "S" })!
    let end = grid.indices.first(where: { grid[$0] == "E" })!
    let begin = PossibleMove(move: Here(here: start, facing: .right), score: Score(s: 0))

    // Walk forward all the possibilities
    let best = grid.bestMoves(from: begin, to: { $0.here == end }, generator: { grid, possibility in
        possibility.move.moves(in: grid).map { move in
            let score = possibility.score.s + (move.facing == possibility.move.facing ? 1 : 1000)
            return PossibleMove(move: move, score: Score(s: score, path: [possibility.move]))
        }
    })

    // Find the best path to the end regardless of what facing you end up with
    var minScore = Score.max
    for d in Dir.allCases {
        if let s = best[Here(here: end, facing: d)], s < minScore {
            minScore = s
        }
    }

    // Trace the score path breadcrumbs back to count every place touched
    var fullPath: Set<Pos> = [end]
    var backtrack = Set(minScore.path)
    while !backtrack.isEmpty {
        let track = backtrack.removeFirst()
        fullPath.insert(track.here)
        for back in best[track]?.path ?? [] {
            backtrack.insert(back)
        }
    }
/*
    for p in fullPath {
        grid[p] = "O"
    }
    grid.printGrid()
 */
    return fullPath.count
}
