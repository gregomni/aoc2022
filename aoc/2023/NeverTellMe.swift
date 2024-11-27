//
//  NeverTellMe.swift
//  aoc
//
//  Created by Greg Titus on 12/24/23.
//

import Foundation

func neverTellMe(_ contents: String) -> Int {
    struct Coords: Equatable {
        let x: Double
        let y: Double
        let z: Double
    }
    struct Hailstone: Equatable {
        let position: Coords
        let velocity: Coords

        var second: Coords { Coords(x: position.x + velocity.x, y: position.y + velocity.y, z: position.z + velocity.z) }
    }

    var hailstones: [Hailstone] = []
    contents.enumerateLines { line, _ in
        let match = line.firstMatch(of: /(.*), (.*), (.*) @ (.*), (.*), (.*)/)!
        hailstones.append(Hailstone(position: Coords(x: Double(String(match.1))!, y: Double(String(match.2))!, z: Double(String(match.3))!), velocity: Coords(x: Double(String(match.4))!, y: Double(String(match.5))!, z: Double(String(match.6))!)))
    }
    print("\(hailstones.count) stones")

    func xyIntersection(_ a: Hailstone, _ b: Hailstone) -> (Coords, Double)? {
        let A = a.velocity.x * (b.position.y - a.position.y)
        let B = a.velocity.y * (b.position.x - a.position.x)
        let C = a.velocity.y * b.velocity.x
        let D = a.velocity.x * b.velocity.y

        if (C - D) == 0 {
            return nil
        }

        let q = Double(A - B) / Double(C - D)
        let p = (b.position.x - a.position.x + q * b.velocity.x) / a.velocity.x
        if p < 0 || q < 0 {
            return nil
        }
        return (Coords(x: round(b.position.x + q * b.velocity.x), y: round(b.position.y + q * b.velocity.y), z: round(b.position.z + q * b.velocity.z)), p)
    }

    func xzIntersection(_ a: Hailstone, _ b: Hailstone) -> (Coords, Double)? {
        let A = a.velocity.x * (b.position.z - a.position.z)
        let B = a.velocity.z * (b.position.x - a.position.x)
        let C = a.velocity.z * b.velocity.x
        let D = a.velocity.x * b.velocity.z

        if (C - D) == 0 {
            return nil
        }

        let q = Double(A - B) / Double(C - D)
        let p = (b.position.x - a.position.x + q * b.velocity.x) / a.velocity.x
        if p < 0 || q < 0 {
            return nil
        }
        return (Coords(x: round(b.position.x + q * b.velocity.x), y: round(b.position.y + q * b.velocity.y), z: round(b.position.z + q * b.velocity.z)), p)
    }

    func yzIntersection(_ a: Hailstone, _ b: Hailstone) -> (Coords, Double)? {
        let A = a.velocity.y * (b.position.z - a.position.z)
        let B = a.velocity.z * (b.position.y - a.position.y)
        let C = a.velocity.z * b.velocity.y
        let D = a.velocity.y * b.velocity.z

        if (C - D) == 0 {
            return nil
        }

        let q = Double(A - B) / Double(C - D)
        let p = (b.position.y - a.position.y + q * b.velocity.y) / a.velocity.y
        if p < 0 || q < 0 {
            return nil
        }
        return (Coords(x: round(b.position.x + q * b.velocity.x), y: round(b.position.y + q * b.velocity.y), z: round(b.position.z + q * b.velocity.z)), p)
    }

    func intersect(_ a: Hailstone, _ b: Hailstone) -> (Coords, Double)? {
        if let s = xyIntersection(a, b) { return s }
        if let s = xzIntersection(a, b) { return s }
        return yzIntersection(a, b)
    }

    let range = -500 ... 500
    let a = hailstones[0]
    let b = hailstones[1]
    var m: Double = 9999999
    for x in range {
        for y in range {
            for z in range {
                let vx = Double(x)
                let vy = Double(y)
                let vz = Double(z)
                let va = Hailstone(position: a.position, velocity: Coords(x: a.velocity.x - vx, y: a.velocity.y - vy, z: a.velocity.z - vz))
                let vb = Hailstone(position: b.position, velocity: Coords(x: b.velocity.x - vx, y: b.velocity.y - vy, z: b.velocity.z - vz))

                if let (point, p) = intersect(va, vb) {
                    var all = true
                    for i in 2 ..< hailstones.count {
                        let c = hailstones[i]
                        let vc = Hailstone(position: c.position, velocity: Coords(x: c.velocity.x - vx, y: c.velocity.y - vy, z: c.velocity.z - vz))
                        if let (point2, _) = intersect(va, vc) {
                            let diff = abs(point.x - point2.x) + abs(point.y - point2.y) + abs(point.z - point2.z)
                            m = min(m, diff)
                            if diff >= 3 {
                                all = false
                                break
                            }
                        } else {
                            all = false
                            break
                        }
                    }
                    if all {
                        let hitX = a.position.x + p * a.velocity.x
                        let hitY = a.position.y + p * a.velocity.y
                        let hitZ = a.position.z + p * a.velocity.z
                        let originX = hitX - p * vx
                        let originY = hitY - p * vy
                        let originZ = hitZ - p * vz
                        return Int(originX) + Int(originY) + Int(originZ)
                    }
                }
            }
        }
    }
    print("found no result, closest: \(m)")
    return 0
/*
    var total = 0
    for aIndex in hailstones.indices {
        let a = hailstones[aIndex]
        for bIndex in (aIndex+1) ..< hailstones.endIndex {
            let b = hailstones[bIndex]
            let minRegion: Double = 200000000000000
            let maxRegion: Double = 400000000000000
            if let p = xyIntersection(a, b), p.x >= minRegion, p.x <= maxRegion, p.y >= minRegion, p.y <= maxRegion {
                total += 1
            }
        }
    }
    return total
 */
}
