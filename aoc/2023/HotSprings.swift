//
//  HotSprings.swift
//  aoc
//
//  Created by Greg Titus on 12/11/23.
//

import Foundation

func hotSprings(_ contents: String) -> Int {
    enum NodeType {
        case startOfGroup
        case midGroup
        case endOfGroup
        case finished

        var operationalMove: Int? {
            switch self {
            case .startOfGroup, .finished: return 0
            case .midGroup: return nil
            case .endOfGroup: return 1
            }
        }
        var damagedMove: Int? {
            switch self {
            case .startOfGroup, .midGroup: return 1
            case .endOfGroup, .finished: return nil
            }
        }
    }

    func makeNodeTypes(groups: [Int]) -> [NodeType] {
        var result: [NodeType] = []
        for group in groups {
            result.append(.startOfGroup)
            for _ in 0 ..< (group-1) {
                result.append(.midGroup)
            }
            result.append(.endOfGroup)
        }
        result.append(.finished)
        return result
    }

    func next(_ c: Character, nodes: [NodeType], counts: inout [Int]) {
        let operationMove = c != "#"
        let damageMove = c != "."
        for i in nodes.indices.reversed() {
            let n = counts[i]
            guard n > 0 else { continue }
            counts[i] = 0
            if damageMove, let move = nodes[i].damagedMove {
                counts[i+move] += n
            }
            if operationMove, let move = nodes[i].operationalMove {
                counts[i+move] += n
            }
        }
    }

    var total = 0
    contents.enumerateLines { line, _ in
        let parts = line.split(separator: " ")
        let springs = parts[0]
        let groups = parts[1].split(separator: ",").map({ Int($0)! })

        var longGroups: [Int] = []
        for _ in 0 ..< 5 {
            longGroups.append(contentsOf: groups)
        }
        let nodes = makeNodeTypes(groups: longGroups)
        var counts = Array(repeating: 0, count: nodes.count)
        counts[0] = 1
        for i in 0 ..< 5 {
            for c in springs {
                next(c, nodes: nodes, counts: &counts)
            }
            if i != 4 {
                next("?", nodes: nodes, counts: &counts)
            }
        }
        total += counts[nodes.count-1] + counts[nodes.count-2]
    }
    return total
}
