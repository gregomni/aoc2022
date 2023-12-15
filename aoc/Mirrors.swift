//
//  Mirrors.swift
//  aoc
//
//  Created by Greg Titus on 12/13/23.
//

import Foundation

func mirrors(_ contents: String, part2: Bool = true) -> Int {
    var total = 0
    let desiredSmudges = part2 ? 1 : 0

    let blocksOfLines = contents.split(separator:"\n\n")
    gridLoop: for lines in blocksOfLines {
        let grid = Grid(contents: String(lines), mapping: { $0 })

        for x in 1 ..< grid.xSize {
            var smudges = 0
            reflectXLoop: for reflect in 0 ..< min(x, grid.xSize-x) {
                for y in 0 ..< grid.ySize {
                    if grid[x-(reflect+1),y] != grid[x+reflect,y] {
                        smudges += 1
                        guard smudges <= desiredSmudges else { break reflectXLoop }
                    }
                }
            }
            if smudges == desiredSmudges {
                total += x
                continue gridLoop
            }
        }

        for y in 1 ..< grid.ySize {
            var smudges = 0
            reflectYLoop: for reflect in 0 ..< min(y, grid.ySize-y) {
                for x in 0 ..< grid.xSize {
                    if grid[x,y-(reflect+1)] != grid[x,y+reflect] {
                        smudges += 1
                        guard smudges <= desiredSmudges else { break reflectYLoop }
                    }
                }
            }
            if smudges == desiredSmudges {
                total += (y * 100)
                continue gridLoop
            }
        }
    }
    return total
}
