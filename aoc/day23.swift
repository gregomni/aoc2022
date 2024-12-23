//
//  day23.swift
//  aoc
//
//  Created by Greg Titus on 12/22/24.
//

import Foundation

func dayTwentyThree(_ contents: String, part1: Bool = false) -> Int {
    class Computer {
        let id: String
        var links: Set<String>

        init(id: String) {
            self.id = id
            self.links = []
        }
    }

    var computers: [String : Computer] = [:]

    contents.enumerateLines { line, _ in
        let parts = line.components(separatedBy: "-")
        let a = parts[0]
        let b = parts[1]
        if computers[a] == nil {
            computers[a] = Computer(id: a)
        }
        if computers[b] == nil {
            computers[b] = Computer(id: b)
        }
        computers[a]!.links.insert(b)
        computers[b]!.links.insert(a)
    }

    if part1 {
        var results: Set<[String]> = []
        for c in computers.values where c.id.first == "t" {
            for (a,b) in Array(c.links).allPairs() {
                if computers[a]!.links.contains(b) {
                    results.insert([a,b,c.id].sorted())
                }
            }
        }
        return results.count
    } else {
        var overallMax = 3 // knew we had at least 3 from part1

        // given a known group and some computers that could be added, return the biggest group
        func find(group: Set<String>, possibles: Set<String>) -> Set<String> {
            var max = group.count
            var bestFind = group

            // try to form a one-bigger group with each possibility
            // but don't repeat if we've already ended up adding this one to the best find
            for c in possibles where !bestFind.contains(c) {
                if group.isSubset(of: computers[c]!.links) {
                    var new = group
                    new.insert(c)
                    let found = find(group: new, possibles: possibles)
                    if found.count > max {
                        bestFind = found
                        max = found.count
                    }
                }
            }
            return bestFind
        }

        // start with pairs and try to grow groups from them
        var bestFind = Set<String>()
        for c in computers.values {
            for l in c.links {
                let intersect = computers[l]!.links.intersection(c.links)

                // abort if even if all are added it won't be bigger than best found
                if 2 + intersect.count <= overallMax { continue }

                let found = find(group: [c.id,l], possibles: intersect)
                if found.count > overallMax {
                    bestFind = found
                    overallMax = found.count
                }
            }
        }
        print(Array(bestFind).sorted().joined(separator: ","))
        return overallMax
    }
}
