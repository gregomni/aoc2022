//
//  day12.swift
//  aoc
//
//  Created by Greg Titus on 12/11/24.
//

import Foundation

func dayTwelve(_ contents: String) -> Int {
    typealias Pos = Grid<Character>.Index
    typealias Dir = Grid<Character>.Direction
    class Region {
        let kind: Character
        var squares: Set<Pos> = []
        var area: Int { squares.count }
        var perimeter: Int {
            var result = 0
            for i in squares {
                for d in Dir.allCases {
                    if !squares.contains(i.direction(d)) {
                        result += 1
                    }
                }
            }
            return result
        }

        func sides(in grid: Grid<Character>) -> Int {
            var result = 0
            for i in squares {
                for d in Dir.allCases where !squares.contains(i.direction(d)) {
                    func lowerEdgeExtends(in dir: Dir) -> Bool {
                        let j = i.direction(dir)
                        return j < i && squares.contains(j) && !squares.contains(j.direction(d))
                    }
                    guard !lowerEdgeExtends(in: d.turnCCW()) else { continue }
                    guard !lowerEdgeExtends(in: d.turnClockwise()) else { continue }
                    result += 1
                }
            }
            return result
        }

        init(kind: Character) {
            self.kind = kind
        }

        func add(_ i: Pos, in grid: Grid<Character>) {
            squares.insert(i)
            let kind = grid[i]
            for d in Dir.allCases {
                let j = i.direction(d)
                guard grid.valid(index: j), grid[j] == kind, !squares.contains(j) else { continue }
                add(j, in: grid)
            }
        }
    }

    let grid = Grid(contents: contents)
    var regions: [Character : [Region]] = [:]

    for i in grid.indices {
        let kind = grid[i]
        if regions[kind, default: []].contains(where: { $0.squares.contains(i) }) {
            continue
        }
        let region = Region(kind: kind)
        region.add(i, in: grid)
        regions[kind, default: []].append(region)
    }

    return regions.values.flatMap({ $0 }).reduce(0, { $0 + $1.area * $1.sides(in: grid) })
}
