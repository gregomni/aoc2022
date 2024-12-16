//
//  day16.swift
//  aoc
//
//  Created by Greg Titus on 12/15/24.
//

import Foundation

func daySixteen(_ contents: String) -> Int {
    typealias Pos = Grid<Character>.Index
    typealias Dir = Grid<Character>.Direction
    
    struct Here: Hashable {
        var here: Pos
        var facing: Dir

        func moves(in grid: Grid<Character>) -> [Here] {
            var result: [Here] = []
            let next = here.direction(facing)
            if grid.valid(index: next), grid[next] != "#" {
                result.append(Here(here: next, facing: facing))
            }
            let cw = here.direction(facing.turnClockwise())
            if grid.valid(index: cw), grid[cw] != "#" {
                result.append(Here(here: cw, facing: facing.turnClockwise()))
            }
            let ccw = here.direction(facing.turnCCW())
            if grid.valid(index: ccw), grid[ccw] != "#" {
                result.append(Here(here: ccw, facing: facing.turnCCW()))
            }
            return result
        }
    }

    struct Score: Comparable {
        let s: Int
        var path: Set<Pos>

        static func < (lhs: Score, rhs: Score) -> Bool {
            lhs.s < rhs.s
        }

        static var max = Score(s: .max, path: [])
    }

    let grid = Grid(contents: contents)
    var moves = Set<Here>()
    var been: [Here : Score] = [:]

    let start = grid.indices.first(where: { grid[$0] == "S" })!
    let end = grid.indices.first(where: { grid[$0] == "E" })!
    let begin = Here(here: start, facing: .right)
    moves.insert(begin)
    been[begin] = Score(s: 0, path: [start])

    while !moves.isEmpty {
        let h = moves.removeFirst()
        let s = been[h, default: .max]
        for m in h.moves(in: grid) {
            var newS: Score
            var newP = s.path
            newP.insert(m.here)
            if m.facing == h.facing {
                newS = Score(s: s.s+1, path: newP)
            } else {
                newS = Score(s: s.s+1001, path: newP)
            }
            if newS <= been[m, default: .max] {
                if let oldS = been[m], oldS.s == newS.s {
                    var newP = oldS.path
                    newP.formUnion(newS.path)
                    if newP.count == oldS.path.count {
                        continue
                    }
                    newS = Score(s: newS.s, path: newP)
                }
                moves.insert(m)
                been[m] = newS
            }
        }
    }
    
    var minScore = Score.max
    for d in Dir.allCases {
        let s = been[Here(here: end, facing: d), default: .max]
        if s < minScore {
            minScore = s
        }
    }
    /*
    for p in paths {
        grid[p] = "O"
    }
    grid.printGrid()
     */
    return minScore.path.count
}
