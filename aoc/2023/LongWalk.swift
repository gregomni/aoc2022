//
//  LongWalk.swift
//  aoc
//
//  Created by Greg Titus on 12/23/23.
//

import Foundation

func longWalk(_ contents: String) -> Int {
    struct Path {
        var fromNode: Grid<Character>.Index
        var steps = 0
        var before: Grid<Character>.Index
        var last: Grid<Character>.Index
    }


    let grid = Grid(contents: contents, mapping: { $0 })
    let start = grid.at(x: 1, y: 0)
    let end = grid.at(x: grid.xSize-2, y: grid.ySize-1)

    func followPath(_ path: Path, _ d: Grid<Character>.Direction) -> Path {
        let next = path.last.direction(d)
        return Path(fromNode: path.fromNode, steps: path.steps+1, before: path.last, last: next)
    }

    struct Connection: Equatable {
        let to: Grid<Character>.Index
        let steps: Int
    }
    var connections: [Grid<Character>.Index : [Connection]] = [:]

    func addConnection(from: Grid<Character>.Index, to: Grid<Character>.Index, steps: Int) {
        var fromList = connections[from] ?? []
        var toList = connections[to] ?? []
        let toC = Connection(to: to, steps: steps)
        let fromC = Connection(to: from, steps: steps)

        if fromList.firstIndex(of: toC) == nil {
            fromList.append(toC)
        }
        connections[from] = fromList

        if toList.firstIndex(of: fromC) == nil {
            toList.append(fromC)
        }
        connections[to] = toList
    }

    var paths: [Path] = []
    paths.append(Path(fromNode: start, steps: 0, before: start, last: start))
    while !paths.isEmpty {
        var path = paths.removeFirst()
        var valid: [Grid<Character>.Direction] = []
        for d in Grid<Character>.Direction.allCases {
            let next = path.last.direction(d)
            guard path.before != next else { continue }
            guard grid.valid(index: next) else { continue }
            guard grid[next] != "#" else { continue }
            valid.append(d)
        }
        if valid.isEmpty {
            if path.last == end {
                addConnection(from: path.fromNode, to: end, steps: path.steps)
            }
        } else if valid.count == 1 {
            paths.append(followPath(path, valid.first!))
        } else {
            let isNew = connections[path.last] == nil
            addConnection(from: path.fromNode, to: path.last, steps: path.steps)
            if isNew {
                path.fromNode = path.last
                path.steps = 0
                for d in valid {
                    paths.append(followPath(path, d))
                }
            }
        }
    }

    func findMax(start: Grid<Character>.Index, visited: Set<Grid<Character>.Index>, steps: Int) -> Int {
        guard start != end else { return steps }
        var result = 0
        var v = visited
        v.insert(start)

        for c in connections[start]!.filter({ !visited.contains($0.to) }) {
            let m = findMax(start: c.to, visited: v, steps: steps + c.steps)
            result = max(result, m)
        }
        return result
    }
    return findMax(start: start, visited: [], steps: 0)
}
