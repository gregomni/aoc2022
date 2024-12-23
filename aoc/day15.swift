//
//  day15.swift
//  aoc
//
//  Created by Greg Titus on 12/14/24.
//

import Foundation

func dayFifteen(_ contents: String, part1: Bool = false) -> Int {
    let middle = contents.firstMatch(of: /\n\n/)!

    let singleWide = String(contents.prefix(upTo: middle.startIndex))
    let doubleWide = singleWide.map({
        switch $0 {
        case ".":
            return ".."
        case "@":
            return "@."
        case "#":
            return "##"
        case "O":
            return "[]"
        default:
            return String($0)
        }
    }).joined()

    let grid = Grid(contents: part1 ? singleWide : doubleWide)
    let movements = String(contents.suffix(from: middle.endIndex))

    var position = grid.indices.first(where: { grid[$0] == "@" })!
    grid[position] = "."

    func move(_ d: Direction, from pos: Position, trial: Bool = false) -> Bool {
        let moved = pos.direction(d)
        defer {
            if (!trial) {
                grid[moved] = grid[pos]
            }
        }

        switch grid[moved] {
        case "#":
            return false
        case ".":
            return true
        case "O":
            return move(d, from: moved, trial: trial)
        case "[":
            if d == .up || d == .down {
                let l = move(d, from: moved, trial: trial)
                let r = move(d, from: moved.direction(.right), trial: trial)
                if !trial {
                    grid[moved.direction(.right)] = "."
                }
                return l && r
            } else {
                return move(d, from: moved, trial: trial)
            }
        case "]":
            if d == .up || d == .down {
                let l = move(d, from: moved.direction(.left), trial: trial)
                let r = move(d, from: moved, trial: trial)
                if !trial {
                    grid[moved.direction(.left)] = "."
                }
                return l && r
            } else {
                return move(d, from: moved, trial: trial)
            }
        default:
            return false
        }
    }

    for m in movements {
        func tryMove(_ d: Direction) {
            if move(d, from: position, trial: true) {
                _ = move(d, from: position)
                position = position.direction(d)
            }
        }

        switch m {
        case "^":
            tryMove(.up)
        case ">":
            tryMove(.right)
        case "<":
            tryMove(.left)
        case "v":
            tryMove(.down)
        default:
            break
        }
    }

    var result = 0
    for i in grid.indices where grid[i] == (part1 ? "O" : "[") {
        result += i.y * 100 + i.x
    }

    return result
}
