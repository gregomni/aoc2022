//
//  HillClimb.swift
//  aoc
//
//  Created by Greg Titus on 12/12/22.
//

import Foundation

struct Spot {
    let height: Int
    let start: Bool
    let end: Bool
    var steps: Int? = nil
}

func hillClimb(_ contents: String, part1: Bool = false) -> Int {
    typealias Position = Grid<Spot>.Index

    let endCondition: (Spot) -> Bool = part1 ? { $0.start } : { $0.height == 0 }

    let grid = Grid(contents: contents) {
        if $0 == "S" {
            return Spot(height: 0, start: true, end: false)
        } else if $0 == "E" {
            return Spot(height: 25, start: true, end: true)
        } else if let height = characterOneOf($0, "abcdefghijklmnopqrstuvwxyz") {
            return Spot(height: height, start: false, end: false)
        } else {
            preconditionFailure("bad char")
        }
    }

    let start = grid.firstIndex(where: {$0.end})!
    var explore: Set<Position> = [start]

    grid[start].steps = 0
    while !explore.isEmpty {
        var new: Set<Position> = []

        for position in explore {
            guard let steps = grid[position].steps else { preconditionFailure("exploring from somewhere without step count") }
            let fromHeight = grid[position].height

            for i in grid.cardinalDirections(from: position) {
                guard grid[i].height - fromHeight >= -1 else { continue }
                guard grid[i].steps == nil else { continue }

                if endCondition(grid[i]) {
                    return steps + 1
                }
                grid[i].steps = steps + 1
                new.insert(i)
            }
        }
        explore = new
    }
    return -1
}
