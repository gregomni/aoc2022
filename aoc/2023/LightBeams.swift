//
//  LightBeams.swift
//  aoc
//
//  Created by Greg Titus on 12/18/23.
//

import Foundation

func sixteen(_ contents: String) -> Int {
    var total = 0
    struct Beams {
        let mirror: Character
        var beams: [Grid<Beams>.Direction] = []
    }

    let initialGrid = Grid(contents: contents, mapping: { Beams(mirror: $0) })
    var grid = initialGrid

    func addBeam(_ at: Grid<Beams>.Index, dir: Grid<Beams>.Direction) {
        guard grid.valid(index: at) else { return }
        guard !grid[at].beams.contains(dir) else { return }

        grid[at].beams.append(dir)
        switch grid[at].mirror {
        case ".":
            addBeam(at.direction(dir), dir: dir)
        case "/":
            let newDir: Grid<Beams>.Direction
            switch dir {
            case .up: newDir = .right
            case .down: newDir = .left
            case .left: newDir = .down
            case .right: newDir = .up
            }
            addBeam(at.direction(newDir), dir: newDir)
        case "\\":
            let newDir: Grid<Beams>.Direction
            switch dir {
            case .up: newDir = .left
            case .down: newDir = .right
            case .left: newDir = .up
            case .right: newDir = .down
            }
            addBeam(at.direction(newDir), dir: newDir)
        case "|":
            switch dir {
            case .left, .right:
                addBeam(at.direction(.up), dir: .up)
                addBeam(at.direction(.down), dir: .down)
            default:
                addBeam(at.direction(dir), dir: dir)
            }
        case "-":
            switch dir {
            case .up, .down:
                addBeam(at.direction(.left), dir: .left)
                addBeam(at.direction(.right), dir: .right)
            default:
                addBeam(at.direction(dir), dir: dir)
            }
        default:
            break
        }

    }

    func check() -> Int {
        var total = 0
        for beams in grid {
            if !beams.beams.isEmpty {
                total += 1
            }
        }
        return total
    }

    for x in 0 ..< grid.xSize {
        grid = Grid(copy: initialGrid)
        addBeam(grid.at(x: x, y: 0), dir: .down)
        total = max(total, check())
        grid = Grid(copy: initialGrid)
        addBeam(grid.at(x: x, y: grid.ySize - 1), dir: .up)
        total = max(total, check())
    }
    for y in 0 ..< grid.ySize {
        grid = Grid(copy: initialGrid)
        addBeam(grid.at(x: 0, y: y), dir: .right)
        total = max(total, check())
        grid = Grid(copy: initialGrid)
        addBeam(grid.at(x: grid.xSize-1, y: y), dir: .left)
        total = max(total, check())
    }

    return total
}

