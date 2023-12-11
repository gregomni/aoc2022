//
//  CosmicExpansion.swift
//  aoc
//
//  Created by Greg Titus on 12/11/23.
//

import Foundation

func cosmicExpansion(_ contents: String) -> Int {
    var emptyX = Set<Int>()
    var emptyY = Set<Int>()
    let grid = Grid(contents: contents, mapping: { $0 })

    for x in 0 ..< grid.xSize {
        if (0 ..< grid.ySize).allSatisfy({ grid[x, $0] == "." }) {
            emptyX.insert(x)
        }
    }
    for y in 0 ..< grid.ySize {
        if (0 ..< grid.xSize).allSatisfy({ grid[$0, y] == "." }) {
            emptyY.insert(y)
        }
    }

    let galaxies = grid.indices.filter { grid[$0] == "#" }
    var total = 0
    for i in galaxies.indices {
        let g1 = galaxies[i]
        for j in i+1 ..< galaxies.endIndex {
            let g2 = galaxies[j]
            var distance = abs(g1.x - g2.x)
            for x in min(g1.x, g2.x) ..< max(g1.x, g2.x) {
                if emptyX.contains(x) {
                    distance += (1000000-1)
                }
            }
            distance += abs(g1.y - g2.y)
            for y in min(g1.y, g2.y) ..< max(g1.y, g2.y) {
                if emptyY.contains(y) {
                    distance += (1000000-1)
                }
            }
            total += distance
        }
    }
    return total
}

