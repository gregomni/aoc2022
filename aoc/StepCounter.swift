//
//  StepCounter.swift
//  aoc
//
//  Created by Greg Titus on 12/21/23.
//

import Foundation

func stepCounter(_ contents: String) -> Int {
    struct Square {
        let type: Character
        var steps: Int? = nil
    }
    let original = Grid(contents: contents, mapping: { Square(type: $0) })
    let grid = Grid(copy: original)

    func findAllSteps(_ grid: Grid<Square>, start: Grid<Square>.Index, stepCount: Int = 0) {
        grid[start].steps = stepCount

        var stepCount = stepCount
        var progress = true
        while progress {
            progress = false
            for spot in grid.indices {
                guard grid[spot].steps == stepCount else { continue }
                for dest in grid.cardinalDirections(from: spot) {
                    var s = grid[dest]
                    guard s.type != "#" else { continue }
                    guard s.steps == nil else { continue }
                    s.steps = stepCount+1
                    grid[dest] = s
                    progress = true
                }
            }
            stepCount += 1
        }
    }

    let start = grid.firstIndex(where: { $0.type == "S" } )!
    //findAllSteps(grid, start: start)

    func oneStep(_ grid: Grid<Square>, inSet: Set<Grid<Square>.Index>) -> Set<Grid<Square>.Index> {
        var result = Set<Grid<Square>.Index>()

        for start in inSet {
            for d in Grid<Square>.Direction.allCases {
                let end = start.direction(d)
                if grid[end.wrap(in: grid)].type != "#" {
                    result.insert(end)
                }
            }
        }
        return result
    }

    let halfSize = grid.xSize / 2
    var visited = Set<Grid<Square>.Index>()
    var v0 = 0
    var v1 = 0
    var v2 = 0
    visited.insert(start)
    for i in 1 ... (grid.xSize*2 + halfSize) {
        visited = oneStep(grid, inSet: visited)
        if i == halfSize {
            v0 = visited.count
        } else if i == grid.xSize + halfSize {
            v1 = visited.count
        } else if i == grid.xSize*2 + halfSize {
            v2 = visited.count
        }
    }

    let totalSteps = 26501365

    func simplifiedLagrange(_ v0: Int, _ v1: Int, _ v2: Int) -> Int {
        let a = v0/2 - v1 + v2/2
        let b = -3*(v0/2) + 2*v1 - v2/2
        let c = v0
        let x = totalSteps / grid.xSize
        return a*x*x + b*x + c
    }

    return simplifiedLagrange(v0, v1, v2)

/*
    var bigContents = ""
    for line in contents.components(separatedBy: "\n") {
        for _ in 0..<5 {
            bigContents.append(line)
        }
        bigContents.append("\n")
    }
    var biggerContents = bigContents
    for _ in 1..<5 {
        biggerContents.append(bigContents)
    }
    let big = Grid(contents: biggerContents, mapping: { Square(type: $0) })
    assert(big.xSize == grid.xSize*5)
    assert(big.ySize == grid.ySize*5)

    let bigStart = big.firstIndex(where: { $0.type == "S" } )!
    findAllSteps(big, start: bigStart)
*/
    /*
    let allTheSteps = 50
    let gridSizes = allTheSteps / grid.xSize
    let remainder = allTheSteps % grid.xSize

    func reachable(_ grid: Grid<Square>, steps reachable: Int) -> Int {
        let modEquals = reachable % 2
        return grid.filter({
            guard let steps = $0.steps else { return false }
            return steps <= reachable && steps % 2 == modEquals
        }).count
    }

    let halfSize = grid.xSize / 2
    let v0 = reachable(big, steps: halfSize)
    let v1 = reachable(big, steps: grid.xSize + halfSize)
    let v2 = reachable(big, steps: grid.xSize * 2 + halfSize)
    return simplifiedLagrange(v0, v1, v2) + reachable(grid, steps: remainder)
     */
}

