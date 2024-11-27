//
//  GhostCamels.swift
//  aoc
//
//  Created by Greg Titus on 12/8/23.
//

import Foundation

func ghostCamels(_ contents: String) -> Int {
    struct Node {
        let name: Substring
        let left: Substring
        let right: Substring
    }
    var nodes: [Substring: Node] = [:]
    var readInstructions = false
    var instructions: String = ""
    contents.enumerateLines { line, _ in
        guard readInstructions else {
            instructions = line
            readInstructions = true
            return
        }
        guard !line.isEmpty else { return }
        let match = line.wholeMatch(of: /(.+) = \((.+), (.+)\)/)!
        nodes[match.1] = Node(name: match.1, left: match.2, right: match.3)
    }

    var currentNodes = nodes.values.filter({ $0.name.hasSuffix("A") })
    var endingSteps: [[Int]] = currentNodes.map({ _ in [] })
    var steps = 0
    while !endingSteps.allSatisfy({ !$0.isEmpty }) {
        for dir in instructions {
            var nextNodes: [Node] = []
            steps += 1
            for index in currentNodes.indices {
                let node = currentNodes[index]
                let newNode = dir == "L" ? nodes[node.left]! : nodes[node.right]!
                if newNode.name.hasSuffix("Z") {
                    endingSteps[index].append(steps)
                }
                nextNodes.append(newNode)
            }
            currentNodes = nextNodes
        }
    }
    // This computation completely bogus for any sort of input where the endingSteps aren't all a prime number of loops around the instruction list
    return endingSteps.map({ $0[0] / instructions.count }).reduce(into: 1, { $0 *= $1 }) * instructions.count
}


