//
//  Crucible.swift
//  aoc
//
//  Created by Greg Titus on 12/18/23.
//

import Foundation

func seventeen(_ contents: String) -> Int {
    struct Square {
        var heat: Int
        var bestV = 999999
        var bestH = 999999
    }

    func indexForPossibleMove(_ direction: Grid<Square>.Direction, _ distance: Int) -> Int {
        direction.rawValue * 3 + (distance-1)
    }

    let grid = Grid(contents: contents, mapping: { Square(heat: Int(String($0))!) })
    let index = grid.at(x: 0, y: 0)
    grid[index].heat = 0
    grid[index].bestH = 0
    grid[index].bestV = 0

    /*
    var easyMax = 0
    var position = index
    let end = grid.at(x: grid.xSize-1, y: grid.ySize-1)
    while position != end {
        position = position.direction(.right)
        easyMax += grid[position].heat
        position = position.direction(.down)
        easyMax += grid[position].heat
    }
     */

    struct Node: Hashable {
        let index: Grid<Square>.Index
        let lastVertical: Bool

        func value(_ grid: Grid<Square>) -> Int { lastVertical ? grid[index].bestV : grid[index].bestH }
    }

    var unvisited = Set<Node>()

    let endPosition = grid.at(x: grid.xSize-1, y: grid.ySize-1)
    unvisited.insert(Node(index: index, lastVertical: true))
    unvisited.insert(Node(index: index, lastVertical: false))

    while !unvisited.isEmpty {
        let current = unvisited.min(by: { $0.value(grid) < $1.value(grid) })!
        let directions: [Grid<Square>.Direction] = current.lastVertical ? [.left, .right] : [.up, .down]
        let startHeat = current.lastVertical ? grid[current.index].bestV : grid[current.index].bestH

        for dir in directions {
            var lastPos = current.index
            var lastHeat = startHeat
            for distance in 1 ... 10 {
                let nextPos = lastPos.direction(dir)
                guard grid.valid(index: nextPos) else { break }
                lastHeat += grid[nextPos].heat
                if distance > 3 {
                    if dir.vertical, lastHeat < grid[nextPos].bestV {
                        grid[nextPos].bestV = lastHeat
                        unvisited.insert(Node(index: nextPos, lastVertical: true))
                    } else if !dir.vertical, lastHeat < grid[nextPos].bestH {
                        grid[nextPos].bestH = min(lastHeat, grid[nextPos].bestH)
                        unvisited.insert(Node(index: nextPos, lastVertical: false))
                    }
                }
                lastPos = nextPos
            }
        }
        unvisited.remove(current)
    }
    return min(grid[endPosition].bestH, grid[endPosition].bestV)
}

