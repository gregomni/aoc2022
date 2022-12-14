//
//  Sand.swift
//  aoc
//
//  Created by Greg Titus on 12/14/22.
//

import Foundation

func sand(_ contents: String, part2: Bool = true) -> Int {
    enum Contents {
        case air
        case rock
        case sand
    }

    typealias Position = Grid<Contents>.Index
    var lines: [[Position]] = []
    var minX = 500, maxX = 500, maxY = 0

    contents.enumerateLines { line, _ in
        let points = line.components(separatedBy: " -> ").map() {
            let bits = $0.components(separatedBy: ",")
            return Position(x: Int(bits[0])!, y: Int(bits[1])!)
        }
        for point in points {
            minX = min(minX, point.x)
            maxX = max(maxX, point.x)
            maxY = max(maxY, point.y)
        }
        lines.append(points)
    }
    let ySize = maxY + 1

    if (part2) {
        minX = min(minX, 500 - (ySize + 3))
        maxX = max(maxX, 500 + (ySize + 3))
    }
    let xSize = maxX - minX + 1

    var spots: [[Contents]] = []
    for _ in 0 ..< ySize {
        spots.append(Array(repeating: .air, count: xSize))
    }
    if part2 {
        spots.append(Array(repeating: .air, count: xSize))
        spots.append(Array(repeating: .rock, count: xSize))
    }
    let grid = Grid<Contents>()
    grid.elements = spots

    for line in lines {
        var from: Position? = nil
        for point in line {
            let adjusted = Position(x: point.x - minX, y: point.y)
            if let from = from {
                grid[from] = .rock
                let dir = from.direction(to: adjusted)
                for pt in grid.walk(dir, from: from) {
                    guard grid.valid(index: pt) else { break }
                    grid[pt] = .rock
                    guard pt != adjusted else { break }
                }
            }
            from = adjusted
        }
    }

    func bitmap() {
        grid.bitmap(url: URL(filePath: "/Users/toon/grid.png"), pixelSize: 4) {
            switch $0 {
            case .air: return (1.0,1.0,1.0)
            case .rock: return (0.0,0.0,0.0)
            case .sand: return (1.0,1.0,0.0)
            }
        }
    }

    var count = 0
    repeat {
        var p = Position(x: 500 - minX, y: 0)
        repeat {
            let next = p.direction(.down)
            guard grid.valid(index: next) else { bitmap(); return count }
            if grid[next] == .air {
                p = next
                continue
            }
            let left = next.direction(.left)
            guard grid.valid(index: left) else { bitmap(); return count }
            if grid[left] == .air {
                p = left
                continue
            }
            let right = next.direction(.right)
            guard grid.valid(index: right) else { bitmap(); return count }
            if grid[right] == .air {
                p = right
                continue
            }
            grid[p] = .sand
            break
        } while true

        count += 1

        if part2, p == Position(x: 500 - minX, y: 0) {
            bitmap()
            return count
        }
    } while true
}
