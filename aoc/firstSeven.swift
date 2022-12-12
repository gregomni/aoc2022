//
//  firstFive.swift
//  aoc
//
//  Created by Greg Titus on 12/7/22.
//

import Foundation
import RegexBuilder

func mostCalories(_ contents: String, _ elves: Int = 3) -> Int {
    var most: [Int] = []
    var current = 0
    contents.enumerateLines { line, _ in
        if line.isEmpty {
            if most.count < elves {
                most.append(current)
            } else if most.first! < current {
                most[0] = current
            }
            most.sort()
            current = 0
        } else {
            current += Int(line)!
        }
    }
    return most.reduce(0, +)
}

func characterOneOf(_ char: Character, _ choices: String) -> Int? {
    guard let index = choices.firstIndex(of: char) else { return nil }
    return choices.distance(from: choices.startIndex, to: index)
}

func rockPaperScissorsScore(_ contents: String) -> Int {
    //let scores = [[4,8,3],[1,5,9],[7,2,6]]
    let scores = [[3,4,8],[1,5,9],[2,6,7]]

    var total = 0
    contents.enumerateLines { line, _ in
        let opponent = characterOneOf(line.first!, "ABC")!
        let mine = characterOneOf(line.last!, "XYZ")!
        total += scores[opponent][mine]
    }
    return total
}

func ruckSacks(_ contents: String, _ compartments: Bool = false) -> Int {
    var priorities = 0

    func priorityOf(_ char: Character) -> Int {
        if let priority = characterOneOf(char, "abcdefghijklmnopqrstuvwxyz") {
            return priority + 1
        } else {
            return characterOneOf(char, "ABCDEFGHIJKLMNOPQRSTUVWXYZ")! + 27
        }
    }

    func inAllStrings(_ strings: [String]) -> Character? {
        let first = strings.first!
        let rest = strings.suffix(from: 1)

        for char in first {
            if rest.allSatisfy({ $0.firstIndex(of: char) != nil }) {
                return char
            }
        }
        return nil
    }

    var lines: [String] = []
    contents.enumerateLines { line, _ in
        if compartments {
            let middle = line.index(line.startIndex, offsetBy: line.count / 2)
            let a = String(line.prefix(upTo: middle))
            let b = String(line.suffix(from: middle))
            assert(a.count == b.count)

            priorities += priorityOf(inAllStrings([a,b])!)
        } else {
            lines.append(line)
            if lines.count == 3 {
                priorities += priorityOf(inAllStrings(lines)!)
                lines = []
            }
        }
    }
    return priorities
}

extension ClosedRange where Bound == Int {
    init(string: String) {
        let dashIndex = string.firstIndex(of: "-")!
        self = Int(string.prefix(upTo: dashIndex))! ... Int(string.suffix(from: string.index(after: dashIndex)))!
    }
}
extension ClosedRange {
    func fullyContains(_ other: Self) -> Bool {
        self.lowerBound <= other.lowerBound && self.upperBound >= other.upperBound
    }
}

func assignmentPairs(_ contents: String) -> Int {
    var count = 0
    contents.enumerateLines { line, _ in
        let ranges = line.components(separatedBy: ",").map({ ClosedRange<Int>(string: $0) })
        //if ranges[0].fullyContains(ranges[1]) || ranges[1].fullyContains(ranges[0]) {
        if ranges[0].overlaps(ranges[1]) {
            count += 1
        }
    }
    return count
}

func crateStacks(_ contents: String) -> String {
    var stacks: [[Character]] = []
    var stackDescription: [String] = []
    let moveRegex = Regex {
        "move "
        Capture { OneOrMore(.digit) } transform: { Int($0)! }
        " from "
        Capture { OneOrMore(.digit) } transform: { Int($0)! }
        " to "
        Capture { OneOrMore(.digit) } transform: { Int($0)! }
    }

    func parseStackDescription() {
        for line in stackDescription.reversed() {
            var subline = line[...]
            var stackIndex = 0
            while let index = subline.firstIndex(of: "[") {
                stackIndex += (subline.distance(from: subline.startIndex, to: index) + 1) / 4
                subline = line.suffix(from: subline.index(after: index))
                while stacks.count <= stackIndex {
                    stacks.append([])
                }
                stacks[stackIndex].append(subline.first!)
            }
        }
        stackDescription = []
    }

    contents.enumerateLines { line, _ in
        if line.hasPrefix("move") {
            parseStackDescription()

            if let match = line.firstMatch(of: moveRegex) {
                let (_, number, from, to) = match.output
                // stack mover 9000:
                //for _ in 0 ..< number {
                //    stacks[to-1].append(stacks[from-1].popLast()!)
                //}
                // stack mover 9001:
                stacks[to-1].append(contentsOf: stacks[from-1].suffix(number))
                stacks[from-1].removeLast(number)
            }
        } else {
            stackDescription.append(line)
        }
    }
    return stacks.map({$0.last!}).reduce("", { $0.appending(String($1)) })
}

func packetMarker(_ contents: String, markerLength: Int = 14) -> Int {
    var last: [Character] = []
    var index = 0

    for c in contents {
        last.append(c)
        if last.count == (markerLength+1) {
            last.remove(at: 0)
            if Set(last).count == markerLength {
                return index + 1
            }
        }
        index += 1
    }
    return contents.count
}

func directoryContents(_ contents: String) -> Int {
    var sizes: [[String]: Int] = [:]
    var cwd = [""]
    var calc = false

    contents.enumerateLines { line, _ in
        if line.hasPrefix("$ cd ") {
            let dir = line.suffix(from: line.index(line.startIndex, offsetBy: 5))
            if dir == "/" {
                cwd = [""]
            } else if dir == ".." {
                _ = cwd.popLast()
            } else {
                cwd.append(String(dir))
            }
        } else if line.hasPrefix("$ ls") {
            calc = sizes[cwd] == nil
        } else if line.hasPrefix("dir") {
        } else if calc {
            let size = Int(line.components(separatedBy: " ")[0])!
            var dir = cwd

            while dir.count > 0 {
                sizes[dir, default: 0] += size
                _ = dir.popLast()
            }
        }
    }

    let used = sizes[[""]]!
    let unused = 70000000 - used
    let needed = 30000000 - unused
    var smallest = used + 1
    for i in sizes {
        if i.1 >= needed && i.1 < smallest {
            smallest = i.1
        }
    }
    return smallest
}

