//
//  Pipes.swift
//  aoc
//
//  Created by Greg Titus on 12/10/23.
//

import Foundation

func fullOfPipes(_ contents: String) -> Int {
    enum Pipe: Character, CaseIterable {
        case ns = "|"
        case ew = "-"
        case ne = "L"
        case nw = "J"
        case sw = "7"
        case se = "F"
        case none = "."
        case unknown = "S"

        func valid(_ dir: Grid<Square>.Direction) -> Bool {
            switch dir {
            case .up:
                return self == .ns || self == .ne || self == .nw
            case .down:
                return self == .ns || self == .sw || self == .se
            case .left:
                return self == .ew || self == .nw || self == .sw
            case .right:
                return self == .ew || self == .ne || self == .se
            }
        }
    }
    struct Square {
        var pipe: Pipe
        var steps: Int? = nil
        var isLoop: Bool { return steps != nil }

        init(_ pipe: Pipe) {
            self.pipe = pipe
        }
    }

    let grid = Grid(contents: contents, mapping: { Square(Pipe(rawValue: $0)!) })
    let start = grid.firstIndex(where: { $0.pipe == .unknown })!
    grid[start].steps = 0

    var goodDirs: [Grid<Square>.Direction] = []
    for d in Grid<Square>.Direction.allCases {
        let next = start.direction(d)
        guard grid.valid(index: next) else { continue }
        guard grid[next].pipe.valid(d.opposite()) else { continue }
        goodDirs.append(d)
    }
    assert(goodDirs.count == 2)
    for p in Pipe.allCases {
        if p.valid(goodDirs[0]), p.valid(goodDirs[1]) {
            grid[start].pipe = p
            break
        }
    }

    var queue = [start]
    while !queue.isEmpty {
        let index = queue.removeFirst()
        for d in Grid<Square>.Direction.allCases {
            guard grid[index].pipe.valid(d) else { continue }
            let next = index.direction(d)
            guard grid[next].pipe.valid(d.opposite()) else { continue }
            guard grid[next].steps == nil else { continue }
            grid[next].steps = grid[index].steps! + 1
            queue.append(next)
        }
    }

    //let end = grid.max(by: { ($0.steps ?? 0) < ($1.steps ?? 0) })!
    //return end.steps!
    var insideCount = 0
    for y in 0 ..< grid.ySize {
        var slidingAlongBottom = false
        var slidingAlongTop = false
        var pipeCount = 0
        for x in 0 ..< grid.xSize {
            let index = Grid<Square>.Index(x: x, y: y)
            if grid[index].isLoop {
                switch grid[index].pipe {
                case .ns:
                    pipeCount += 1
                case .ew:
                    break
                case .ne:
                    slidingAlongBottom = true
                case .nw:
                    if slidingAlongTop {
                        pipeCount += 1
                        slidingAlongTop = false
                    } else {
                        slidingAlongBottom = false
                    }
                case .sw:
                    if slidingAlongBottom {
                        pipeCount += 1
                        slidingAlongBottom = false
                    } else {
                        slidingAlongTop = false
                    }
                case .se:
                    slidingAlongTop = true
                default:
                    break
                }
            } else if pipeCount % 2 == 1 {
                insideCount += 1
            }
        }
    }
    return insideCount
}
