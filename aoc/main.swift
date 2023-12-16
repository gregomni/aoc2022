//
//  main.swift
//  aoc
//
//  Created by Greg Titus on 12/7/22.
//

import Foundation
import RegexBuilder

let args = CommandLine.arguments
if (args.count < 3) {
    print("not enough arguments")
    exit(1)
}

let problem = Int(args[1])!
let contents = try! String(contentsOf: URL(fileURLWithPath: args[2]), encoding: .ascii)

switch problem {
case 1:
    print(dayOne(contents))
case 2:
    print(dayTwo(contents))
case 3:
    print(dayThree(contents))
case 4:
    print(dayFour(contents))
case 5:
    print(dayFive(contents))
case 6:
    print(daySix(contents))
case 7:
    print(camelCards(contents))
case 8:
    print(ghostCamels(contents))
case 9:
    print(mirage(contents))
case 10:
    print(fullOfPipes(contents))
case 11:
    print(cosmicExpansion(contents))
case 12:
    print(hotSprings(contents))
case 13:
    print(mirrors(contents))
case 14:
    print(parabolicReflector(contents))
case 15:
    print(lensLibrary(contents))
case 16:
    print(sixteen(contents))
default:
    print("unknown problem")
    exit(2)
}
exit(0)

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
