//
//  DistressSignal.swift
//  aoc
//
//  Created by Greg Titus on 12/13/22.
//

import Foundation

indirect enum ListValue : Equatable, Comparable {
    case int(Int)
    case list([ListValue])

    static func readValue(_ line: String, startingAt: String.Index? = nil) -> (ListValue, String.Index) {
        var index = startingAt ?? line.startIndex

        if line[index] == "[" {
            index = line.index(after: index)
            if line[index] == "]" {
                return (.list([]), line.index(after: index))
            }

            var list: [ListValue] = []
            repeat {
                let v: ListValue
                (v, index) = readValue(line, startingAt: index)
                list.append(v)
                guard line[index] == "," else { break }
                index = line.index(after: index)
            } while true
            return (.list(list), line.index(after: index))
        } else {
            var i = 0
            while let c = characterOneOf(line[index], "0123456789") {
                index = line.index(after: index)
                i *= 10
                i += c
            }
            return (.int(i), index)
        }
    }

    init(_ line: String) {
        (self, _) = ListValue.readValue(line)
    }

    static func < (lhs: ListValue, rhs: ListValue) -> Bool {
        switch (lhs, rhs) {
        case (.int(let l), .int(let r)):
            return l < r
        case (.list(let l), .list(let r)):
            for (li, ri) in zip(l, r) {
                guard li <= ri else { return false }
                guard li == ri else { return true }
            }
            return l.count < r.count
        case (.int(_), .list(_)):
            return .list([lhs]) < rhs
        case (.list(_), .int(_)):
            return lhs < .list([rhs])
        }
    }
}

func distressSignal_part1(_ contents: String) -> Int {
    var first = ListValue.int(0)
    var second = ListValue.int(0)
    var firstLine = true
    var pairNumber = 1
    var total = 0

    contents.enumerateLines { line, _ in
        if line.isEmpty {
            // nothing
        } else if firstLine {
            first = ListValue(line)
            firstLine = false
        } else {
            second = ListValue(line)
            if first < second {
                total += pairNumber
            }
            pairNumber += 1
            firstLine = true
        }
    }
    return total
}

func distressSignal(_ contents: String) -> Int {
    var all: [ListValue] = []
    let divider1 = ListValue.list([.list([.int(2)])])
    let divider2 = ListValue.list([.list([.int(6)])])

    all.append(divider1)
    all.append(divider2)

    contents.enumerateLines { line, _ in
        if !line.isEmpty {
            all.append(ListValue(line))
        }
    }
    all.sort()
    let a = all.firstIndex(of: divider1)! + 1
    let b = all.firstIndex(of: divider2)! + 1
    return a * b
}
