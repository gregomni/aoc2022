//
//  SandSlabs.swift
//  aoc
//
//  Created by Greg Titus on 12/22/23.
//

import Foundation

func sandSlabs(_ contents: String) -> Int {
    struct Position {
        var x: Int
        var y: Int
        var z: Int
    }
    struct Brick {
        var a: Position
        var b: Position
        var supports: [Int] = []
        var supportedBy: [Int] = []

        var xs: ClosedRange<Int> { min(a.x,b.x) ... max(a.x,b.x) }
        var ys: ClosedRange<Int> { min(a.y,b.y) ... max(a.y,b.y) }
        var minZ: Int {
            get { min(a.z,b.z) }
            set {
                let diff = newValue - minZ
                a.z += diff
                b.z += diff
            }
        }
        var maxZ: Int { max(a.z,b.z) }

        func wouldSupport(_ other: Brick) -> Bool {
            return xs.overlaps(other.xs) && ys.overlaps(other.ys)
        }

        func supports(_ other: Brick) -> Bool {
            if other.minZ - 1 != self.maxZ { return false }
            return wouldSupport(other)
        }
    }

    var bricks: [Brick] = []
    contents.enumerateLines { line, _ in
        let match = line.firstMatch(of: /(.*),(.*),(.*)~(.*),(.*),(.*)/)!
        bricks.append(Brick(a: Position(x: Int(match.1)!, y: Int(match.2)!, z: Int(match.3)!), b: Position(x: Int(match.4)!, y: Int(match.5)!, z: Int(match.6)!)))
    }
    bricks.sort(by: { min($0.a.z, $0.b.z) < min($1.a.z, $1.b.z) })

    for i in bricks.indices {
        let b = bricks[i]
        var at = 1
        for j in 0 ..< i {
            if bricks[j].wouldSupport(b) {
                at = max(at, bricks[j].maxZ + 1)
            }
        }
        bricks[i].minZ = at
    }
    for i in bricks.indices {
        for j in 0 ..< i {
            if bricks[j].supports(bricks[i]) {
                bricks[j].supports = bricks[j].supports + [i]
                bricks[i].supportedBy = bricks[i].supportedBy + [j]
            }
        }
    }
/*
    for i in bricks.indices {
        print("\(i): supports \(bricks[i].supports) supported-by \(bricks[i].supportedBy)")
    }
*/
    var safe = Set<Int>()
    for i in bricks.indices {
        let b = bricks[i]
        var ok = true
        for j in b.supports {
            if bricks[j].supportedBy.count == 1 {
                assert(bricks[j].supportedBy[0] == i)
                ok = false
                break
            }
        }
        if (ok) {
            safe.insert(i)
        }
    }

    func fallFor(_ i: Int, _ set: Set<Int>) -> Set<Int> {
        var falls = set
        falls.insert(i)
        for j in bricks[i].supports {
            if bricks[j].supportedBy.allSatisfy({ falls.contains($0) }) {
                falls = fallFor(j, falls)
            }
        }
        return falls
    }

    var total = 0
    for i in bricks.indices {
        guard !safe.contains(i) else { continue }
        total += fallFor(i, []).count - 1
    }
    return total
}
