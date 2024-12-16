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

    struct Score: Comparable {
        let s: Int
        var path: [Here]

        static func < (lhs: Score, rhs: Score) -> Bool {
            lhs.s < rhs.s
        }

        static var max = Score(s: .max, path: [])
    }

    struct Possibility: Comparable {
        let here: Here
        let score: Score

        static func < (lhs: Possibility, rhs: Possibility) -> Bool {
            lhs.score < rhs.score
        }
    }

    let grid = Grid(contents: contents)
    var moves = Heap<Possibility>()
    var best: [Here : Score] = [:]

    let start = grid.indices.first(where: { grid[$0] == "S" })!
    let end = grid.indices.first(where: { grid[$0] == "E" })!
    let begin = Here(here: start, facing: .right)
    moves.insert(Possibility(here: begin, score: Score(s: 0, path: [])))

    // Walk forward all the possibilities
    var bestRouteSoFar = Int.max
    while let move = moves.popMin() {
        let h = move.here
        if move.score > best[h, default: .max] { continue }
        for m in h.moves(in: grid) {
            let score = move.score.s + (m.facing == h.facing ? 1 : 1000)
            if bestRouteSoFar < score { continue }
            var newPath = [h]
            if let existingBest = best[m] {
                if existingBest.s < score { continue }
                if existingBest.s == score {
                    newPath.append(contentsOf: existingBest.path)
                }
            }
            let newScore = Score(s: score, path: newPath)
            best[m] = newScore
            if m.here == end {
                bestRouteSoFar = min(bestRouteSoFar, score)
            } else {
                moves.insert(Possibility(here: m, score: newScore))
            }
        }
    }

    // Find the best path to the end regardless of what facing you end up with
    var minScore = Score.max
    for d in Dir.allCases {
        if let s = best[Here(here: end, facing: d)], s < minScore {
            minScore = s
        }
    }

    // Trace the score path breadcrumbs back to count every place touched
    var fullPath: Set<Pos> = []
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
