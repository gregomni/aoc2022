//
//  Blizzard.swift
//  aoc
//
//  Created by Greg Titus on 12/23/22.
//

import Foundation

enum IcyGround: Equatable {
    case wall
    case clear
    case blizzard([Grid<IcyGround>.Direction])
}

extension Grid where Element == IcyGround {
    func visualize() {
        var currentY = 0
        var line = ""
        for i in self.indices {
            if i.y != currentY {
                print(line)
                line = ""
                currentY = i.y
            }
            switch(self[i]) {
            case .wall:
                line.append("#")
            case .clear:
                line.append(".")
            case .blizzard(let dirs):
                if dirs.count > 1 {
                    line.append("\(dirs.count)")
                } else {
                    switch dirs.first! {
                    case .up:
                        line.append("^")
                    case .down:
                        line.append("v")
                    case .left:
                        line.append("<")
                    case .right:
                        line.append(">")
                    }
                }
            }
        }
        print(line)
    }
}

func blizzard(_ contents: String, part2: Bool = true) -> Int {
    let startingGrid = Grid<IcyGround>(contents: contents) {
        switch $0 {
        case "#": return .wall
        case ".": return .clear
        case "^": return .blizzard([.up])
        case "v": return .blizzard([.down])
        case "<": return .blizzard([.left])
        case ">": return .blizzard([.right])
        default:
            assertionFailure("unrecognized map element")
            exit(1)
        }
    }
    let emptyGrid = Grid<IcyGround>(contents: contents) { $0 == "#" ? .wall : .clear }

    func advance(grid: Grid<IcyGround>) -> Grid<IcyGround> {
        let new = Grid<IcyGround>(copy: emptyGrid)

        for i in grid.indices {
            guard case let .blizzard(dirs) = grid[i] else { continue }
            for d in dirs {
                var p = i.direction(d)
                if grid[p] == .wall {
                    switch d {
                    case .up:
                        p = Grid<IcyGround>.Index(x: p.x, y: grid.ySize-2)
                    case .down:
                        p = Grid<IcyGround>.Index(x: p.x, y: 1)
                    case .left:
                        p = Grid<IcyGround>.Index(x: grid.xSize-2, y: p.y)
                    case .right:
                        p = Grid<IcyGround>.Index(x: 1, y: p.y)
                    }
                }
                if case let .blizzard(existing) = new[p] {
                    assert(existing.count <= 3 && !existing.contains(d))
                    new[p] = .blizzard(existing + [d])
                } else {
                    new[p] = .blizzard([d])
                }
            }
        }
        return new
    }

    var gridAtTime = [startingGrid]
    var time = 0
    let startingSpot = Grid<IcyGround>.Index(x: 1, y: 0)
    let endingSpot = Grid<IcyGround>.Index(x: startingGrid.xSize-2, y: startingGrid.ySize-1)
    var possiblePositions = [Set<Grid<IcyGround>.Index>([startingSpot])]

    func findAWay(toEnd: Bool = true) -> Int {
        repeat {
            let starts = possiblePositions[time]
            var newPossible = Set<Grid<IcyGround>.Index>()

            for here in starts {
                while gridAtTime.count <= time + 1 {
                    print("generating time \(gridAtTime.count), \(possiblePositions.last!.count) possibilities")
                    gridAtTime.append(advance(grid: gridAtTime.last!))
                }
                let nextTime = time + 1
                let nextGrid = gridAtTime[nextTime]
                if toEnd, here.y == startingGrid.ySize - 2, nextGrid[here.direction(.down)] == .clear {
                    return nextTime
                } else if !toEnd, here.y == 1, nextGrid[here.direction(.up)] == .clear {
                    return nextTime
                } else {
                    if nextGrid[here] == .clear {
                        newPossible.insert(here)
                    }
                    for d in Grid<IcyGround>.Direction.allCases {
                        let p = here.direction(d)
                        if nextGrid.valid(index: p), nextGrid[p] == .clear {
                            newPossible.insert(here.direction(d))
                        }
                    }
                }
            }
            possiblePositions.append(newPossible)
            time += 1
        } while true
    }

    if part2 {
        _ = findAWay(toEnd: true)
        possiblePositions.append([endingSpot])
        time += 1
        _ = findAWay(toEnd: false)
        possiblePositions.append([startingSpot])
        time += 1
        return findAWay(toEnd: true)
    } else {
        return findAWay()
    }
}
