//
//  SensorBeacon.swift
//  aoc
//
//  Created by Greg Titus on 12/15/22.
//

import Foundation
import RegexBuilder

func fifteen_part1(_ contents: String) -> Int {
    let regex = Regex {
        "Sensor at x="
        Capture { ZeroOrMore("-"); OneOrMore(.digit) } transform: { Int($0)! }
        ", y="
        Capture { ZeroOrMore("-"); OneOrMore(.digit) } transform: { Int($0)! }
        ": closest beacon is at x="
        Capture { ZeroOrMore("-"); OneOrMore(.digit) } transform: { Int($0)! }
        ", y="
        Capture { ZeroOrMore("-"); OneOrMore(.digit) } transform: { Int($0)! }
    }

    let rowY = 2_000_000
    var coveredSet: [ClosedRange<Int>] = []
    var beaconsOnLine: Set<Int> = []

    contents.enumerateLines { line, _ in
        let match = line.firstMatch(of: regex)!
        let (sensorX, sensorY) = (match.output.1, match.output.2)
        let (beaconX, beaconY) = (match.output.3, match.output.4)

        if beaconY == rowY {
            beaconsOnLine.insert(beaconX)
        }

        let beaconDistance = abs(sensorX - beaconX) + abs(sensorY - beaconY)
        let fromRowDistance = abs(sensorY - rowY)
        let leftoverDistance = beaconDistance - fromRowDistance
        guard leftoverDistance >= 0 else { return }

        var coveredRange = (sensorX - leftoverDistance) ... (sensorX + leftoverDistance)
        for i in coveredSet.indices.reversed() {
            let set = coveredSet[i]
            if set.overlaps(coveredRange) {
                coveredRange = min(set.lowerBound, coveredRange.lowerBound) ... max(set.upperBound, coveredRange.upperBound)
                coveredSet.remove(at: i)
            }
        }
        coveredSet.append(coveredRange)
    }
    var total = coveredSet.reduce(0, { accum, element in accum + element.count })

    for beaconX in beaconsOnLine {
        for range in coveredSet {
            if range.contains(beaconX) {
                total -= 1
                break;
            }
        }
    }
    return total
}

struct Sensor {
    let x: Int
    let y: Int
    let range: Int
}

func sensorBeacon(_ contents: String) -> Int {
    let regex = Regex {
        "Sensor at x="
        Capture { ZeroOrMore("-"); OneOrMore(.digit) } transform: { Int($0)! }
        ", y="
        Capture { ZeroOrMore("-"); OneOrMore(.digit) } transform: { Int($0)! }
        ": closest beacon is at x="
        Capture { ZeroOrMore("-"); OneOrMore(.digit) } transform: { Int($0)! }
        ", y="
        Capture { ZeroOrMore("-"); OneOrMore(.digit) } transform: { Int($0)! }
    }

    var sensors: [Sensor] = []
    contents.enumerateLines { line, _ in
        let match = line.firstMatch(of: regex)!
        let (sensorX, sensorY) = (match.output.1, match.output.2)
        let (beaconX, beaconY) = (match.output.3, match.output.4)

        let beaconDistance = abs(sensorX - beaconX) + abs(sensorY - beaconY)
        sensors.append(Sensor(x: sensorX, y: sensorY, range: beaconDistance))
    }

    func overlap(x: Int, y: Int) -> Bool {
        guard x >= 0, x <= 4_000_000, y >= 0, y <= 4_000_000 else { return true }
        for sensor in sensors {
            if (abs(sensor.x - x) + abs(sensor.y - y)) <= sensor.range {
                return true
            }
        }
        return false
    }

    // If there's one spot that's out of range, it'll be just one step away from the range of one or more sensors.
    // So let's circle around just outside of detection of each, seeing if any other can see that spot.
    for sensor in sensors {
        let top = (sensor.x, sensor.y - sensor.range - 1)
        let right = (sensor.x + sensor.range + 1, sensor.y)
        let bottom = (sensor.x, sensor.y + sensor.range + 1)
        let left = (sensor.x - sensor.range - 1, sensor.y)

        var p = top
        while p != right {
            if !overlap(x: p.0, y: p.1) { return (p.0 * 4_000_000) + p.1 }
            p = (p.0 + 1, p.1 + 1)
        }
        while p != bottom {
            if !overlap(x: p.0, y: p.1) { return (p.0 * 4_000_000) + p.1 }
            p = (p.0 - 1, p.1 + 1)
        }
        while p != left {
            if !overlap(x: p.0, y: p.1) { return (p.0 * 4_000_000) + p.1 }
            p = (p.0 - 1, p.1 - 1)
        }
        while p != top {
            if !overlap(x: p.0, y: p.1) { return (p.0 * 4_000_000) + p.1 }
            p = (p.0 + 1, p.1 - 1)
        }
    }
    return 0
}

