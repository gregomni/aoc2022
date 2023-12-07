//
//  Plantings.swift
//  aoc
//
//  Created by Greg Titus on 12/23/22.
//

import Foundation

enum FarmGround: Character {
    case elf = "#"
    case empty = "."
}

struct Elf: Equatable {
    typealias Pos = Grid<FarmGround>.Index
    typealias Dir = Grid<FarmGround>.Direction
    var current: Pos
    var desired: Pos

    static func ==(lhs: Elf, rhs: Elf) -> Bool { lhs.current == rhs.current }

    mutating func decide(occupied: Set<Pos>, directions: [Dir]) {
        var best: Dir? = nil
        var free = 0
        for dir in directions {
            let move = current.direction(dir)
            let side1 = move.direction(dir.turnClockwise())
            let side2 = move.direction(dir.turnCCW())
            if !occupied.contains(move), !occupied.contains(side1), !occupied.contains(side2) {
                if best == nil { best = dir }
                free += 1
            }
        }

        if free < 4, let dir = best {
            desired = current.direction(dir)
        } else {
            desired = current
        }
    }

    static func findConflicts(_ elves: [Elf]) -> Set<Pos> {
        var conflicts = Set<Pos>()
        var used = Set<Pos>()
        elves.forEach {
            if used.contains($0.desired) {
                conflicts.insert($0.desired)
            } else {
                used.insert($0.desired)
            }
        }
        return conflicts
    }
}

func plantings(_ contents: String, _ part2: Bool = true) -> Int {
    // Setup
    var elves: [Elf] = []
    var directions: [Elf.Dir] = [.up, .down, .left, .right]
    let grid = Grid(contents: contents) { FarmGround(rawValue: $0)! }
    for index in grid.indices {
        if grid[index] == .elf {
            elves.append(Elf(current: index, desired: index))
        }
    }

    func step() -> Bool {
        let allCurrent = Set(elves.map({ $0.current }))
        for i in elves.indices {
            elves[i].decide(occupied: allCurrent, directions: directions)
        }
        let conflicts = Elf.findConflicts(elves)
        var moves = 0
        for i in elves.indices {
            let desired = elves[i].desired
            if !conflicts.contains(desired), elves[i].current != desired {
                elves[i].current = desired
                moves += 1
            }
        }
        if moves == 0 {
            return false
        }

        let d = directions[0]
        directions.remove(at: 0)
        directions.append(d)
        return true
    }

    if part2 {
        var n = 1
        while step() {
            print("step \(n)")
            n += 1
        }
        return n
    } else {
        for n in 0 ..< 10 {
            _ = step()
            print("step \(n)")
        }

        let minX = elves.min(by: { $0.current.x < $1.current.x })!.current.x
        let minY = elves.min(by: { $0.current.y < $1.current.y })!.current.y
        let maxX = elves.max(by: { $0.current.x < $1.current.x })!.current.x
        let maxY = elves.max(by: { $0.current.y < $1.current.y })!.current.y
        let width = maxX - minX + 1
        let height = maxY - minY + 1
        return width * height - elves.count
    }
}
