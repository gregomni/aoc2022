//
//  day1.swift
//  aoc
//
//  Created by Greg Titus on 11/27/24.
//

import Foundation
import RegexBuilder

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

