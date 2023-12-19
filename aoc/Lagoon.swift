//
//  Lagoon.swift
//  aoc
//
//  Created by Greg Titus on 12/18/23.
//

import Foundation

func eighteen(_ contents: String) -> Int {
    typealias Position = Grid<Character>.Index
    typealias Direction = Grid<Character>.Direction

    var current = Position(x: 0, y: 0)
    struct Dig {
        let start: Position
        let end: Position
        let length: Int
        let direction: Direction
    }

    var digs: [Dig] = []
    contents.enumerateLines { line, _ in
        let instruction = line.split(separator: " ")
        let instr = instruction[2].replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "#", with: "")

        var length = 0
        for c in instr.dropLast() {
            length *= 16

            let v = Int(c.asciiValue!)
            if c >= "a" {
                length += 10 + v - Int(Character("a").asciiValue!)
            } else {
                length += v - Int(Character("0").asciiValue!)
            }
        }
        let dir: Direction
        let new: Position
        switch instr.last! {
        case "0":
            dir = .right
            new = Position(x: current.x + length, y: current.y)
        case "1":
            dir = .down
            new = Position(x: current.x, y: current.y + length)
        case "2":
            dir = .left
            new = Position(x: current.x - length, y: current.y)
        default:
            dir = .up
            new = Position(x: current.x, y: current.y - length)
        }

        digs.append(Dig(start: current, end: new, length: length, direction: dir))
        current = new
    }

    // Shoelace formula + Pick's theorem
    var size = 0
    var fullLength = 0
    for d in digs {
        fullLength += d.length
        size += d.start.y * (d.start.x - d.end.x)
    }
    size = abs(size) + fullLength/2 + 1

    // Compared to a compressed grid
    let ys = Array(Set(digs.flatMap { [$0.start.y, $0.end.y] })).sorted()
    let xs = Array(Set(digs.flatMap { [$0.start.x, $0.end.x] })).sorted()

    var yIndices: [Int: Int] = [:]
    for i in ys.indices { yIndices[ys[i]] = i*2 }
    var xIndices: [Int: Int] = [:]
    for i in xs.indices { xIndices[xs[i]] = i*2 }

    let elements = String(repeating: ".", count: xs.count*2)
    let array = Array(repeating:elements, count: ys.count*2)
    let grid = Grid(contents: array.joined(separator: "\n"), mapping: {$0})

    for dig in digs {
        let start = grid.at(x: xIndices[dig.start.x]!, y: yIndices[dig.start.y]!)
        let end = grid.at(x: xIndices[dig.end.x]!, y: yIndices[dig.end.y]!)
        var move = start
        while move != end {
            grid[move] = "#"
            move = move.direction(dig.direction)
        }
    }

    var fillStart = grid.at(x: 0, y: 0)
    for x in 1 ..< grid.xSize {
        if grid[x, 0] == "#", grid[x-1, 1] == "#" {
            fillStart = grid.at(x: x, y: 1)
            break
        }
    }

    var queue = Set([fillStart])
    while let spot = queue.popFirst() {
        guard grid[spot] == "." else { continue }
        grid[spot] = "x"
        for near in grid.cardinalDirections(from: spot) {
            if grid[near] == "." {
                queue.insert(near)
            }
        }
    }

    var total = 0
    for spot in grid.indices {
        if grid[spot] != "." {
            let width: Int
            let height: Int
            if spot.x % 2 == 1 {
                width = xs[spot.x/2+1] - xs[spot.x/2] - 1
            } else {
                width = 1
            }
            if spot.y % 2 == 1 {
                height = ys[spot.y/2+1] - ys[spot.y/2] - 1
            } else {
                height = 1
            }
            total += width*height
        }
    }

    print("does total=\(total) - size=\(size): \(total-size)")
    return total
}
