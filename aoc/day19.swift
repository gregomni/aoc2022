//
//  day19.swift
//  aoc
//
//  Created by Greg Titus on 12/18/24.
//

import Foundation

func dayNineteen(_ contents: String, part1: Bool = false) -> Int {
    let lines = contents.components(separatedBy: "\n").dropLast()
    let patterns = lines[0].components(separatedBy: ", ")

    // sort the patterns by size and put them in sets
    var patternInfo: [Set<Substring>] = []
    for pattern in patterns {
        while patternInfo.count < pattern.count {
            patternInfo.append(Set())
        }
        patternInfo[pattern.count-1].insert(pattern[...])
    }

    var memo: [Substring : Int] = [:]
    func make(design: Substring) -> Int {
        guard !design.isEmpty else { return 1 }
        if let result = memo[design] {
            return result
        }

        var result = 0
        for i in patternInfo.indices {
            // check prefix sets by size so we don't need to compare many patterns
            if patternInfo[i].contains(design.prefix(i+1)) {
                let leftoverStart = design.index(design.startIndex, offsetBy: i+1)
                result += make(design: design[leftoverStart...])
            }
        }
        memo[design] = result
        return result
    }

    if part1 {
        return lines[2...].count(where: { make(design: $0[...]) > 0 })
    } else {
        return lines[2...].reduce(0, { $0 + make(design: $1[...]) })
    }
}
