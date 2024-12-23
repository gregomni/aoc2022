//
//  day24.swift
//  aoc
//
//  Created by Greg Titus on 12/23/24.
//

import Foundation

func dayTwentyFour(_ contents: String, part1: Bool = false) -> Int {
    var values: [String: Bool] = [:]
    var valuesSection = true
    var gates: [String: Gate] = [:]

    struct Gate {
        var inputA: String
        var inputB: String
        let output: String
        let type: String
    }

    contents.enumerateLines { line, _ in
        if line.isEmpty {
            valuesSection = false
        } else if valuesSection {
            let parts = line.components(separatedBy: ": ")
            values[parts[0]] = parts[1] == "1"
        } else {
            let match = line.firstMatch(of: /([^ ]+) ([^ ]+) ([^ ]+) -> (.+)/)!
            let gate = Gate(inputA: String(match.1), inputB: String(match.3), output: String(match.4), type: String(match.2))
            gates[String(gate.output)] = gate
        }
    }

    func getValue(_ string: String) -> Bool {
        if let v = values[string] { return v }
        let gate = gates[string]!
        let a = getValue(gate.inputA)
        let b = getValue(gate.inputB)
        switch gate.type {
        case "AND":
            return a && b
        case "OR":
            return a || b
        case "XOR":
            return (a || b) && !(a && b)
        default:
            assertionFailure()
            return false
        }
    }

    func gateFor(start: String, bit: Int) -> String {
        start + (bit < 10 ? "0" + bit.description : bit.description)
    }

    func getInt(_ string: String) -> Int {
        var result = 0
        for i in (0 ..< 45).reversed() {
            let s = gateFor(start: string, bit: i)
            if gates[s] == nil && values[s] == nil { continue }
            let v = getValue(s)
            result = (result << 1) | (v ? 1 : 0)
        }
        return result
    }

    if part1 {
        return getInt("z")
    }

    func findGates(involved: String, g: inout Set<String>, v: inout Set<String>) {
        if values[involved] != nil {
            v.insert(involved)
            return
        }
        let gate = gates[involved]!
        g.insert(involved)
        findGates(involved: gate.inputA, g: &g, v: &v)
        findGates(involved: gate.inputB, g: &g, v: &v)
    }
    func findGates(involved: String) -> (g: Set<String>, v: Set<String>) {
        var g = Set<String>()
        var v = Set<String>()
        findGates(involved: involved, g: &g, v: &v)
        return (g,v)
    }

    func highBitInvolvement(allValues: Set<String>) -> Int {
        return allValues.map({ Int($0.dropFirst())! }).max()!
    }

    func testBit(_ z: Int) -> Bool {
        if z == 0 {
            for x in [0, 1] {
                values[gateFor(start: "x", bit: z)] = x == 1
                for y in [0, 1] {
                    values[gateFor(start: "y", bit: z)] = y == 1
                    let v = getValue(gateFor(start: "z", bit: z)) ? 1 : 0
                    guard (x + y) & 1 == v else { return false }
                }
            }
        } else if z == 45 {
            for carry in [0, 1] {
                values[gateFor(start: "x", bit: z-1)] = carry == 1
                values[gateFor(start: "y", bit: z-1)] = carry == 1
                let v = getValue(gateFor(start: "z", bit: z)) ? 1 : 0
                guard carry == v else { return false }
            }
        } else {
            for carry in [0, 1] {
                values[gateFor(start: "x", bit: z-1)] = carry == 1
                values[gateFor(start: "y", bit: z-1)] = carry == 1
                for x in [0, 1] {
                    values[gateFor(start: "x", bit: z)] = x == 1
                    for y in [0, 1] {
                        values[gateFor(start: "y", bit: z)] = y == 1
                        let v = getValue(gateFor(start: "z", bit: z)) ? 1 : 0
                        guard (x + y + carry) & 1 == v else { return false }
                    }
                }
            }
        }
        return true
    }

    let allGateNames = Array(gates.keys)
    var goodBits = Set<Int>()

    func findGoodBits() {
        goodBits = []
        for i in 0 ... 45 {
            if testBit(i) {
                goodBits.insert(i)
            }
        }
    }

    findGoodBits()

    func testGoodBits(and: Int) -> Bool {
        guard testBit(and) else { return false }
        for b in goodBits {
            guard testBit(b) else { return false }
        }
        return true
    }

    func findPossibleSwaps() -> [(String,String)] {
        var possibleSwaps: [(String,String)] = []
        for z in 0 ... 45 {
            if goodBits.contains(z) { continue }
            let (g,_) = findGates(involved: gateFor(start: "z", bit: z))
            for a in g {
                let (aInvolved, _) = findGates(involved: a)
                for b in allGateNames where !aInvolved.contains(b) {
                    guard a != b else { continue }
                    let (bInvolved, bValues) = findGates(involved: b)
                    guard !bInvolved.contains(a) else { continue }
                    guard highBitInvolvement(allValues: bValues) == z else { continue }
                    let gA = gates[a]!
                    let gB = gates[b]!
                    gates[a] = gB
                    gates[b] = gA
                    if testGoodBits(and: z) {
                        possibleSwaps.append((a,b))
                    }
                    gates[a] = gA
                    gates[b] = gB
                }
            }
        }
        return possibleSwaps
    }

    func search(_ depth: Int) -> [String]? {
        if depth == 5 { return nil }
        findGoodBits()
        if goodBits.count == 46 {
            return []
        }
        let swaps = findPossibleSwaps()
        for s in swaps {
            let gA = gates[s.0]!
            let gB = gates[s.1]!
            gates[s.0] = gB
            gates[s.1] = gA
            if let result = search(depth+1) {
                return [s.0, s.1] + result
            }
            gates[s.0] = gA
            gates[s.1] = gB
        }
        return nil
    }

    let results = search(0)!
    print(results.sorted().joined(separator: ","))
    return 0
}
