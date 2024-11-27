//
//  ParabolicReflector.swift
//  aoc
//
//  Created by Greg Titus on 12/14/23.
//

import Foundation

func parabolicReflector(_ contents: String) -> Int {
    let grid = Grid(contents: contents, mapping: { $0 })

    func roll(_ grid: Grid<Character>, dir: Grid<Character>.Direction) -> Grid<Character> {
        let opposite = dir.opposite()
        let new = Grid(copy: grid)
        for spot in grid.indices {
            if grid[spot] == "O" {
                var moving = spot
                while grid.valid(index: moving.direction(dir)), grid[moving.direction(dir)] != "#" {
                    moving = moving.direction(dir)
                }
                while new[moving] == "O", moving != spot {
                    moving = moving.direction(opposite)
                }
                if moving != spot {
                    new[spot] = "."
                    new[moving] = "O"
                }
            }
        }
        return new
    }

    func cycle(_ grid: Grid<Character>) -> Grid<Character> {
        var result = grid
        result = roll(result, dir: .up)
        result = roll(result, dir: .left)
        result = roll(result, dir: .down)
        result = roll(result, dir: .right)
        return result
    }

    var seen = Set<Grid<Character>>()
    var result = grid
    var sequence = [grid]
    var firstInLoop = 0
    while true {
        result = cycle(result)
        if seen.contains(result) {
            firstInLoop = sequence.firstIndex(of: result)!
            break
        }
        sequence.append(result)
        seen.insert(result)
    }

    func weightOf(_ grid: Grid<Character>) -> Int {
        var total = 0
        for x in 0 ..< grid.xSize {
            for y in 0 ..< grid.ySize {
                if grid[x,y] == "O" {
                    total += grid.ySize - y
                }
            }
        }
        return total
    }
   // let weights = sequence.map { weightOf($0) }
    let loopSize = sequence.count - firstInLoop
    let indexInLoop = (1000000000 - firstInLoop) % loopSize
    return weightOf(sequence[indexInLoop + firstInLoop])
}
