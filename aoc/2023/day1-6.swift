//
//  day1.swift
//  aoc
//
//  Created by Greg Titus on 12/1/23.
//

import Foundation

func dayOne(_ contents: String) -> Int {
    var current = 0
    contents.enumerateLines { line, _ in
        var first: Int? = nil
        var firstPosition = 9999
        var last: Int? = nil
        var lastPosition = -1

        let values = ["1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9,
                      "one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9]
        for (key, digit) in values {
            let matches = line.matches(of: key)
            if let match = matches.first {
                let location = line.distance(from: line.startIndex, to: match.startIndex)
                if location < firstPosition {
                    first = digit
                    firstPosition = location
                }
            }
            if let match = matches.last {
                let location = line.distance(from: line.startIndex, to: match.startIndex)
                if location > lastPosition {
                    last = digit
                    lastPosition = location
                }
            }
        }
        let code = first! * 10 + last!
        current += code
    }
    return current
}

func dayTwo(_ contents: String) -> Int {
    struct Pull {
        var red: Int = 0
        var blue: Int = 0
        var green: Int = 0
    }

    var total = 0
    contents.enumerateLines { line, _ in
        var smallest = Pull()
        let game = line.split(separator: ":")
        //let gameNumber = Int(game[0].matches(of: /Game (\d+)/).first!.1)
        let rounds = game[1].split(separator: ";")
        let pulls = rounds.map {
            var pull = Pull()
            for match in $0.matches(of: /((\d+) (red|green|blue))+/) {
                let count = Int(match.2)!
                if match.3 == "red" {
                    pull.red = count
                } else if match.3 == "blue" {
                    pull.blue = count
                } else if match.3 == "green" {
                    pull.green = count
                } else {
                    abort()
                }
            }
            return pull
        }

        for pull in pulls {
            smallest.red = max(smallest.red, pull.red)
            smallest.blue = max(smallest.blue, pull.blue)
            smallest.green = max(smallest.green, pull.green)
        }
        total += smallest.red * smallest.blue * smallest.green
    }
    return total
}

extension Grid<Character> {
    func isASymbol(_ index: Index) -> Bool {
        guard self.valid(index: index) else { return false }
        return self[index] == "*"// self[index] != "." && !self[index].isNumber
    }

    func adjacentSymbol(_ index: Index) -> Index? {
        for possibility in diagonalAdjacencies(from: index) {
            if isASymbol(possibility) {
                return possibility
            }
        }
        return nil
    }
}

func dayThree(_ contents: String) -> Int {
    let grid = Grid(contents: contents, mapping: {$0})
    var total = 0

    var index = grid.startIndex
    var currentNumber = 0
    var near: Grid<Character>.Index? = nil
    var nextToGear: [Grid<Character>.Index : [Int]] = [:]

    while index != grid.endIndex {
        if grid[index].isNumber {
            let digit = Int(grid[index].asciiValue! - "0".first!.asciiValue!)
            currentNumber = (currentNumber * 10) + digit
            near = grid.adjacentSymbol(index) ?? near
        } else {
            if let near {
                nextToGear[near, default: []].append(currentNumber)
            }
            near = nil
            currentNumber = 0
        }
        if (grid.valid(index: index.direction(.right))) {
            index = index.direction(.right)
        } else {
            if let near {
                nextToGear[near, default: []].append(currentNumber)
            }
            near = nil
            currentNumber = 0
            index = Grid.Index(x: 0, y: index.y + 1)
        }
    }

    for (_, value) in nextToGear {
        if value.count == 2 {
            total += value[0] * value[1]
        }
    }
    return total
}

func dayFour(_ contents: String) -> Int {
    var wins: [Int: Int] = [:]
    contents.enumerateLines { line, _ in
        let game = line.split(separator: ":")
        let gameNumber = Int(game[0].split(separator: " ").last!)!
        let parts = game[1].split(separator: "|")
        let winners = Set(parts[0].split(separator: " "))
        let numbers = Set(parts[1].split(separator: " "))

        wins[gameNumber] = winners.intersection(numbers).count
    }

    let allNumbers = Array(wins.keys).sorted()
    var copies = Dictionary(uniqueKeysWithValues: allNumbers.map({ ($0, 1) }))
    for gameNumber in allNumbers {
        let numberOfCards = copies[gameNumber]!
        let score = wins[gameNumber]!

        if score > 0 {
            for i in gameNumber+1...gameNumber+score {
                copies[i, default: 1] += numberOfCards
            }
        }
    }

    return copies.reduce(into: 0, { $0 += $1.value })
}

func dayFive(_ contents: String) -> Int {
    struct Map {
        let destination: Int
        let source: Int
        let length: Int

        var sourceRange: Range<Int> { source ..< source+length }
        func destination(for value: Int) -> Int {
            return value - source + destination
        }
        func destRange(for range: Range<Int>) -> Range<Int> {
            let start = destination(for: range.lowerBound)
            let clamp = range.clamped(to: sourceRange)
            return start ..< start + (clamp.upperBound - clamp.lowerBound)
        }
    }

    var seeds: [Int] = []
    var maps: [[Map]] = []
    contents.enumerateLines { line, _ in
        if line.isEmpty {
        } else if seeds.isEmpty {
            let bits = line.components(separatedBy: ":")
            seeds = bits[1].components(separatedBy: " ").compactMap { Int($0) }
        } else if line.firstIndex(of: ":") != nil {
            maps.append([])
        } else {
            let nums = line.components(separatedBy: " ").compactMap { Int($0) }
            assert(nums.count == 3)
            maps[maps.count-1].append(Map(destination: nums[0], source: nums[1], length: nums[2]))
        }
    }

    var minResult = 999999999
    for seedIndex in seeds.indices {
        guard seedIndex % 2 == 0 else { continue }

        let seedStart = seeds[seedIndex]
        let seedLength = seeds[seedIndex+1]
        var range = seedStart ..< seedStart + seedLength

        while !range.isEmpty {
            var current = range
            for map in maps {
                var found = false
                var nearest = current.upperBound
                for entry in map {
                    if entry.sourceRange.contains(current.lowerBound) {
                        current = entry.destRange(for: current)
                        found = true
                        break
                    } else if entry.source > current.lowerBound && entry.source <= nearest {
                        nearest = entry.source
                    }
                }
                if (!found && nearest < current.upperBound) {
                    current = current.lowerBound ..< nearest
                }
            }
            if current.lowerBound < minResult {
                minResult = current.lowerBound
            }
            let length = current.upperBound - current.lowerBound
            let rangeLength = range.upperBound - range.lowerBound
            let newLow = range.lowerBound + min(length, rangeLength)
            if newLow >= range.upperBound {
                break
            }
            range = newLow ..< range.upperBound
        }
    }
    return minResult
}

func daySix(_ contents: String) -> Int {
    let lines = contents.components(separatedBy: "\n")
    let time = Int(lines[0].replacingOccurrences(of: " ", with: "").components(separatedBy: ":")[1])!
    let distance = Int(lines[1].replacingOccurrences(of: " ", with: "").components(separatedBy: ":")[1])!

    var ways = 0
    for i in 1 ..< time {
        if (time - i) * i > distance {
            ways += 1
        }
    }
    return ways
}

