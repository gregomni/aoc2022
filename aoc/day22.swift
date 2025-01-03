//
//  day22.swift
//  aoc
//
//  Created by Greg Titus on 12/21/24.
//

import Foundation
import Collections

func dayTwentyTwo(_ contents: String, part1: Bool = false) -> Int {
    func evolve(_ n: Int) -> Int {
        var n = n
        let m = n << 6
        n = (m ^ n) % 16777216
        let p = n >> 5
        n = (p ^ n) % 16777216
        let o = n << 11
        n = (o ^ n) % 16777216
        return n
    }

    func keyForChanges(_ changes: [Int]) -> Int {
        let a = changes[0]+9
        let b = changes[1]+9
        let c = changes[2]+9
        let d = changes[3]+9
        return ((a * 19 + b) * 19 + c) * 19 + d
    }

    var summedPriceForChanges: [Int16] = Array(repeating: 0, count: 19*19*19*19)
    var best: Int16 = 0

    func loadMonkey(_ secret: Int) {
        var foundKeys = BitSet(reservingCapacity: 19*19*19*19)
        var n = secret
        var changes: [Int] = []
        var lastP: Int? = nil
        for _ in 1...2000 {
            let p = n % 10
            if let lastP {
                changes.append(p - lastP)
                if changes.count > 4 {
                    changes.remove(at: 0)
                }
                if changes.count == 4 {
                    let key = keyForChanges(changes)
                    if !foundKeys.contains(key) {
                        foundKeys.insert(key)
                        if p > 0 {
                            summedPriceForChanges[key] += Int16(p)
                            let total = summedPriceForChanges[key]
                            if total > best {
                                best = total
                            }
                        }
                    }
                }
            }
            lastP = p
            n = evolve(n)
        }
    }

    contents.enumerateLines { line, _ in
        loadMonkey(Int(line)!)
    }

    return Int(best)
}
