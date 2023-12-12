//
//  HotSprings.swift
//  aoc
//
//  Created by Greg Titus on 12/11/23.
//

import Foundation

func hotSprings(_ contents: String) -> Int {
    var total = 0

    struct State {
        var groupIndex = 0
        var brokeCount = 0
        var copies = 1
    }

    func applyDot(groups: [Int], possibilities: [State]) -> [State] {
        return possibilities.compactMap { state in
            if state.brokeCount == 0 {
                return state
            }
            guard state.groupIndex < groups.count else { return nil }
            guard state.brokeCount == groups[state.groupIndex] else { return nil }
            return State(groupIndex: state.groupIndex+1, brokeCount: 0, copies: state.copies)
        }
    }

    func applyHash(groups: [Int], possibilities: [State]) -> [State] {
        return possibilities.compactMap { state in
            guard state.groupIndex < groups.count else { return nil }
            guard state.brokeCount < groups[state.groupIndex] else { return nil }
            return State(groupIndex: state.groupIndex, brokeCount: state.brokeCount+1, copies: state.copies)
        }
    }

    func applyQuestion(groups: [Int], possibilities: [State]) -> [State] {
        let dot = applyDot(groups: groups, possibilities: possibilities)
        let hash = applyHash(groups: groups, possibilities: possibilities)
        return combinePossibilities(dot + hash)
    }

    func applyDone(groups: [Int], possibilities: [State]) -> [State] {
        return possibilities.compactMap { state in
            if state.brokeCount > 0 {
                guard state.groupIndex+1 == groups.count else { return nil }
                guard state.brokeCount == groups[state.groupIndex] else { return nil }
            } else {
                guard state.groupIndex == groups.count else { return nil }
            }
            return state
        }
    }

    func combinePossibilities(_ possibilities: [State]) -> [State] {
        struct PartialState: Hashable {
            let groupIndex: Int
            let brokeCount: Int
        }

        var counts: [PartialState : Int] = [:]
        for p in possibilities {
            let partial = PartialState(groupIndex: p.groupIndex, brokeCount: p.brokeCount)
            if let match = counts[partial] {
                counts[partial] = match + p.copies
            } else {
                counts[partial] = p.copies
            }
        }
        return counts.map { key, value in State(groupIndex: key.groupIndex, brokeCount: key.brokeCount, copies: value) }
    }

    contents.enumerateLines { line, _ in
        let parts = line.split(separator: " ")
        let springs = parts[0]
        var groups = parts[1].split(separator: ",").map({ Int($0)! })

        var longGroups: [Int] = []
        for _ in 0 ..< 5 {
            longGroups.append(contentsOf: groups)
        }
        groups = longGroups

        var possibilities = [State()]
        for i in 0 ..< 5 {
            for c in springs {
                if c == "." {
                    possibilities = applyDot(groups: groups, possibilities: possibilities)
                } else if c == "#" {
                    possibilities = applyHash(groups: groups, possibilities: possibilities)
                } else if c == "?" {
                    possibilities = applyQuestion(groups: groups, possibilities: possibilities)
                }
            }
            if i != 4 {
                possibilities = applyQuestion(groups: groups, possibilities: possibilities)
            }
        }
        possibilities = applyDone(groups: groups, possibilities: possibilities)
        let matches = possibilities.reduce(0, { $0 + $1.copies })
        total += matches
    }
    return total
}
