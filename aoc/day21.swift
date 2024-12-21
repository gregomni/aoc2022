//
//  day21.swift
//  aoc
//
//  Created by Greg Titus on 12/20/24.
//

import Foundation

func dayTwentyOne(_ contents: String, part1: Bool = true) -> Int {
    typealias Pos = Grid<Character>.Index
    typealias Dir = Grid<Character>.Direction

    let numericGrid = Grid(contents: "789\n456\n123\n 0A")
    let directionalGrid = Grid(contents: " ^A\n<v>")

    struct Move: Hashable {
        let from: Character
        let to: Character
    }

    func computeWays(_ grid: Grid<Character>) -> [Move : Set<String>] {
        var allMoves: [Move : Set<String>] = [:]
        for e in grid where e != " " {
            allMoves[Move(from: e, to: e)] = ["A"]
        }

        func prepend(_ c: Character, to: Set<String>) -> Set<String> {
            var result = Set<String>()
            for m in to {
                result.insert([c] + m)
            }
            return result
        }

        func moves(from: Pos, to: Pos) -> Set<String> {
            guard grid[from] != " " else { return [] }
            if let moves = allMoves[Move(from: grid[from], to: grid[to])] {
                return moves
            }
            var result: Set<String> = []
            if from.y > to.y {
                result.formUnion(prepend("^", to: moves(from: from.direction(.up), to: to)))
            } else if from.y < to.y {
                result.formUnion(prepend("v", to: moves(from: from.direction(.down), to: to)))
            }
            if from.x > to.x {
                result.formUnion(prepend("<", to: moves(from: from.direction(.left), to: to)))
            } else if from.x < to.x {
                result.formUnion(prepend(">", to: moves(from: from.direction(.right), to: to)))
            }
            allMoves[Move(from: grid[from], to: grid[to])] = result
            return result
        }
        for i in grid.indices where grid[i] != " " {
            for j in grid.indices where grid[j] != " " {
                _ = moves(from: i, to: j)
            }
        }
        return allMoves
    }

    let numericWays = computeWays(numericGrid)
    let directionalWays = computeWays(directionalGrid)

    func waysToPress(_ string: Substring, start: Character = "A", numeric: Bool) -> Set<String> {
        guard !string.isEmpty else { return [""] }
        let c = string.first!
        let rest = waysToPress(string.dropFirst(), start: c, numeric: numeric)

        var result = Set<String>()
        let ways = numeric ? numericWays : directionalWays
        for w in ways[Move(from: start, to: c)]! {
            for r in rest {
                result.insert(w.appending(r))
            }
        }
        return result
    }

    var directionalMinimums: [Move: Int] = [:]
    for m in directionalWays.keys {
        directionalMinimums[m] = directionalWays[m]!.reduce(Int.max, { min($0, $1.count) })
    }

    func bestWayToPressDirectional(_ string: Substring, start: Character) -> Int {
        guard !string.isEmpty else { return 0 }
        let c = string.first!
        let rest = bestWayToPressDirectional(string.dropFirst(), start: c)
        return directionalMinimums[Move(from: start, to: c)]! + rest
    }

    func directionalForNumeric(_ string: Substring) -> Set<String> {
        var result = Set<String>()
        for s in waysToPress(string[...], numeric: true) {
            result.formUnion(waysToPress(s[...], numeric: false))
        }
        return result
    }

    func splitOnA(_ string: String) -> [Substring] {
        var result: [Substring] = []
        var rest = string[...]
        while let i = rest.firstIndex(of: "A") {
            result.append(rest[...i])
            rest = rest[rest.index(after: i)...]
        }
        return result
    }

    struct State : Hashable {
        let part: Substring
        let robotDepth: Int
    }
    var memo: [State : Int] = [:]

    func directionalForDirectional(_ state: State) -> Int {
        if let n = memo[state] { return n }
        var min = Int.max

        if state.robotDepth == 1 {
            min = bestWayToPressDirectional(state.part[...], start: "A")
        } else {
            for s in waysToPress(state.part[...], numeric: false) {
                var sum = 0
                for p in splitOnA(s) {
                    sum += directionalForDirectional(State(part: p, robotDepth: state.robotDepth-1))
                }
                if sum < min {
                    min = sum
                }
            }
        }
        memo[state] = min
        return min
    }

    func lastStep(_ string: String, robotDepth: Int) -> Int {
        var min = Int.max
        for s in directionalForNumeric(string[...]) {
            var sum = 0
            for p in splitOnA(s) {
                sum += directionalForDirectional(State(part: p, robotDepth: robotDepth))
            }
            if sum < min {
                min = sum
            }
        }
        return min
    }

    var result = 0
    contents.enumerateLines { line, _ in
        let min = lastStep(line, robotDepth: part1 ? 1 : 24)
        let numeric = Int(line.replacingOccurrences(of: "A", with: ""))!
        result += min * numeric
    }
    return result
}
