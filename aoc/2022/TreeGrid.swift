//
//  TreeGrid.swift
//  aoc
//
//  Created by Greg Titus on 12/8/22.
//

import Foundation

extension Sequence {
    func reduce<T>(_ initial: T, _ process: (T, Element) -> T, stopAfter: (Element) -> Bool) -> T {
        var result = initial
        for element in self {
            result = process(result, element)
            guard !stopAfter(element) else { break }
        }
        return result
    }

    func count(stopAfter: (Element) -> Bool) -> Int {
        reduce(0, { count, _ in count + 1}, stopAfter: stopAfter)
    }
}

struct Tree {
    let height: Int
    var mark: Bool = false
}

typealias TreeGrid = Grid<Tree>

extension Grid where Element == Tree {
    var marks: Int {
        self.reduce(0) { count, tree in tree.mark ? count + 1 : count }
    }
}

func visibleTrees(_ grid: TreeGrid) -> Int {
    for x in 0 ..< grid.xSize {
        var maxHeight = -1
        for index in grid.upFrom(x: x) where grid[index].height > maxHeight {
            grid[index].mark = true
            maxHeight = grid[index].height
        }
        maxHeight = -1
        for index in grid.downFrom(x: x) where grid[index].height > maxHeight {
            grid[index].mark = true
            maxHeight = grid[index].height
        }
    }

    for y in 0 ..< grid.ySize {
        var maxHeight = -1
        for index in grid.leftFrom(y: y) where grid[index].height > maxHeight {
            grid[index].mark = true
            maxHeight = grid[index].height
        }
        maxHeight = -1
        for index in grid.rightFrom(y: y) where grid[index].height > maxHeight {
            grid[index].mark = true
            maxHeight = grid[index].height
        }
    }
    return grid.marks
}

func highestScenicScore(_ grid: TreeGrid) -> Int {
    var maxScore = 0
    for position in grid.indices {
        let limit = grid[position].height
        var score = 1

        for direction in TreeGrid.Direction.allCases {
            score *= grid.walk(direction, from: position).count(stopAfter: { grid[$0].height >= limit })
        }
        if score > maxScore {
            maxScore = score
        }
    }
    return maxScore
}

func treeGrid(_ contents: String, part1: Bool = false) -> Int {
    let grid = TreeGrid(contents: contents) { Tree(height:Int(String($0))!) }
    return part1 ? visibleTrees(grid) : highestScenicScore(grid)
}
