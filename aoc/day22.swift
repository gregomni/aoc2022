//
//  day22.swift
//  aoc
//
//  Created by Greg Titus on 12/21/24.
//

import Foundation

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
        return a << 15 + b << 10 + c << 5 + d
    }

    struct Monkey {
        var changesForPrice: [Int:Int] = [:]

        init(_ secret: Int) {
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
                        if changesForPrice[key] == nil {
                            changesForPrice[key] = p
                        }
                    }
                }
                lastP = p
                n = evolve(n)
            }
        }
    }

    var monkeys: [Monkey] = []
    contents.enumerateLines { line, _ in
        monkeys.append(Monkey(Int(line)!))
    }

    func sellBananas(_ changes: [Int]) -> Int {
        var total = 0
        let key = keyForChanges(changes)
        for m in monkeys {
            total += m.changesForPrice[key, default: 0]
        }
        return total
    }

    func rangeForPrevious(_ changes: [Int]) -> ClosedRange<Int> {
        var max = 9
        var min = 0
        for c in changes {
            max += c
            min += c
            if max > 9 { max = 9 }
            if min < 0 { min = 0 }
        }
        return (0 - max) ... (9 - min)
    }

    var max = 0
    for n in -9 ... 9 {
        for o in rangeForPrevious([n]) {
            for p in rangeForPrevious([n,o]) {
                for q in rangeForPrevious([n,o,p]) {
                    let sold = sellBananas([n,o,p,q])
                    if sold > max {
                        max = sold
                    }
                }
            }
        }
    }
    return max
}
