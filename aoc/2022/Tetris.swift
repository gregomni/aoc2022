//
//  Tetris.swift
//  aoc
//
//  Created by Greg Titus on 12/17/22.
//

import Foundation

struct Rock {
    let width: Int
    let mask: [String]

    static let all = [Rock(width: 4, mask: ["####"]),
                      Rock(width: 3, mask: [".#.", "###", ".#."]),
                      Rock(width: 3, mask: ["###", "..#", "..#"]),
                      Rock(width: 1, mask: ["#","#","#","#"]),
                      Rock(width: 2, mask: ["##", "##"])]
}

struct TetrisState : Equatable {
    var rockMask: [[Character]] = [Array(repeating:"#", count:7)]
    var x = 2
    var height = 4
    var rockIndex = 0

    var rockCount = 0
    var endingRockCount = 0
    var endingFilledHeight = 0

    var rock: Rock { Rock.all[rockIndex] }

    func visualize() {
        print("")
        for line in rockMask.reversed() {
            var s = ""
            line.forEach { s += String($0) }
            print(s)
        }
        print("ending rocks = \(endingRockCount)")
        print("ending filled height = \(endingFilledHeight)")
    }

    func intersects() -> Bool {
        for y in rock.mask.indices {
            var rockX = x
            guard (height+y) < rockMask.count else { continue }
            for c in rock.mask[y] {
                if c == "#", rockMask[height+y][rockX] != "." {
                    return true
                }
                rockX += 1
            }
        }
        return false
    }

    mutating func freezeRock() {
        for y in rock.mask.indices {
            while height+y >= rockMask.count {
                rockMask.append(Array(repeating: ".", count: 7))
            }
            var rockX = x
            for c in rock.mask[y] {
                if c == "#" {
                    assert(rockMask[height+y][rockX] == ".")
                    rockMask[height+y][rockX] = "#"
                }
                rockX += 1
            }
        }
        rockCount += 1
        rockIndex = (rockIndex + 1) % 5
        x = 2
        height = rockMask.count + 3
    }

    mutating func cleanup() {
        var stones = Array(repeating: false, count: 7)
        var blockedY = Array(repeating: 0, count: 7)
        var y = rockMask.count - 1

        for row in rockMask.reversed() {
            for i in 0 ..< 7 {
                if stones[i] {
                    // UNDONE: fill unreachable bits?
                } else if row[i] == "#" {
                    stones[i] = true
                    blockedY[i] = y
                } else {
                    var j = i - 1
                    while j >= 0, row[j] == "." {
                        stones[j] = false
                        j -= 1
                    }
                    j = i + 1
                    while j <= 6, row[j] == "." {
                        stones[j] = false
                        j += 1
                    }
                }
            }
            if stones.allSatisfy({$0}) {
                break
            }
            y -= 1
        }

        // fill unreachable pockets so equality checking of masks is better
        for n in y ..< blockedY.max()! {
            for i in 0 ..< 7 {
                if blockedY[i] > n, rockMask[n][i] == "." {
                    rockMask[n][i] = "#"
                }
            }
        }

        endingFilledHeight = y
        endingRockCount = rockCount
        rockMask = Array(rockMask.suffix(from: y))
        height -= y
        rockCount = 0
    }
}

func tetrisSimulator(_ gusts: String, _ start: TetrisState, end: (TetrisState) -> Bool) -> TetrisState {
    var state = start

    for c in gusts {
        var badGust = false
        var delta = 0

        switch c {
        case "<":
            delta = state.x > 0 ? -1 : 0
        case ">":
            delta = (state.x + state.rock.width - 1) < 6 ? +1 : 0
        default:
            badGust = true
        }
        if badGust { continue }

        state.x += delta
        if state.intersects() {
            state.x -= delta
        }

        state.height -= 1
        if state.intersects() {
            state.height += 1
            state.freezeRock()
            if (end(state)) {
                return state
            }
        }
    }
    return state
}

func tetris_part1(_ gusts: String) -> Int {
    var state = TetrisState()
    var remainingRocks = 2022
    let endCondition = { (s: TetrisState) in s.rockCount == remainingRocks }
    var totalHeight = 0

    repeat {
        state = tetrisSimulator(gusts, state, end: endCondition)
        state.cleanup()
        totalHeight += state.endingFilledHeight
        remainingRocks -= state.endingRockCount
    } while !endCondition(state)

    return totalHeight + state.rockMask.count - 1
}

func tetris(_ gusts: String) -> Int {
    var state = TetrisState()
    var previousStates: [TetrisState] = []
    var totalHeight = 0
    var loopStart: Int? = nil

    repeat {
        previousStates.append(state)
        state = tetrisSimulator(gusts, state, end: { _ in false })
        state.cleanup()

        loopStart = previousStates.firstIndex(where: { $0 == state })
    } while loopStart == nil

    var startRocks = 0
    var startHeight = 0
    var loopRocks = 0
    var loopHeight = 0

    for i in 0 ..< loopStart! {
        startRocks += previousStates[i].endingRockCount
        startHeight += previousStates[i].endingFilledHeight
    }
    for i in loopStart! ..< previousStates.count {
        loopRocks += previousStates[i].endingRockCount
        loopHeight += previousStates[i].endingFilledHeight
    }

    var remainingRocks = 1_000_000_000_000

    remainingRocks -= startRocks
    totalHeight += startHeight

    let cycles = remainingRocks / loopRocks
    totalHeight += (loopHeight * cycles)
    remainingRocks = remainingRocks % loopRocks

    let endCondition = { (s: TetrisState) in s.rockCount == remainingRocks }
    state = previousStates.last!
    repeat {
        state = tetrisSimulator(gusts, state, end: endCondition)
        state.cleanup()
        totalHeight += state.endingFilledHeight
        remainingRocks -= state.endingRockCount
    } while !endCondition(state)
    return totalHeight + state.rockMask.count - 1
}
