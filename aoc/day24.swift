//
//  day24.swift
//  aoc
//
//  Created by Greg Titus on 12/23/24.
//

import Foundation

func dayTwentyFour(_ contents: String, part1: Bool = false) -> Int {
    var valuesSection = true
    var gates: [String: Gate] = [:]
    var xValues = Array(repeating: false, count: 45)
    var yValues = Array(repeating: false, count: 45)

    enum Input {
        case x(Int)
        case y(Int)
        case gate(String)

        init(_ s: Substring) {
            switch s.first {
            case "x": self = .x(Int(s.dropFirst())!)
            case "y": self = .y(Int(s.dropFirst())!)
            default: self = .gate(String(s))
            }
        }
    }

    func inputValue(_ input: Input) -> Bool {
        switch input {
        case .x(let i): return xValues[i]
        case .y(let i): return yValues[i]
        case .gate(let s): return getValue(s)
        }
    }

    struct Gate {
        var inputA: Input
        var inputB: Input
        let output: String
        let type: String
    }

    contents.enumerateLines { line, _ in
        if line.isEmpty {
            valuesSection = false
        } else if valuesSection {
            let match = line.firstMatch(of: /(.)(..): (.)/)!
            let i = Int(match.2)!
            if match.1 == "x" {
                xValues[i] = match.3 == "1"
            } else {
                yValues[i] = match.3 == "1"
            }
        } else {
            let match = line.firstMatch(of: /([^ ]+) ([^ ]+) ([^ ]+) -> (.+)/)!
            let gate = Gate(inputA: Input(match.1), inputB: Input(match.3), output: String(match.4), type: String(match.2))
            gates[String(gate.output)] = gate
        }
    }

    func getValue(_ string: String) -> Bool {
        let gate = gates[string]!
        let a = inputValue(gate.inputA)
        let b = inputValue(gate.inputB)
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

    if part1 {
        var result = 0
        for i in (0 ... 45).reversed() {
            let s = gateFor(start: "z", bit: i)
            let v = getValue(s)
            result = (result << 1) | (v ? 1 : 0)
        }
        return result
    }

    var valueHighBitDependencies: [String : Int] = [:]
    var gateDependencies: [String : Set<String>] = [:]

    func resetDependencies() {
        valueHighBitDependencies = [:]
        gateDependencies = [:]
    }

    func findGates(involved: Input) -> (g: Set<String>, v: Int) {
        switch involved {
        case .x(let i), .y(let i):
            return ([], i)
        case .gate(let s):
            return findGates(involved: s)
        }
    }

    func findGates(involved: String) -> (g: Set<String>, v: Int) {
        if let v = valueHighBitDependencies[involved] {
            return (gateDependencies[involved]!, v)
        }
        let gate = gates[involved]!
        let (ag, av) = findGates(involved: gate.inputA)
        let (bg, bv) = findGates(involved: gate.inputB)
        let g = ag.union(bg).union([involved])
        let v = max(av, bv)
        valueHighBitDependencies[involved] = v
        gateDependencies[involved] = g
        return (g,v)
    }

    func testBit(_ z: Int) -> Bool {
        let zGate = gateFor(start: "z", bit: z)
        if z == 0 {
            for x in [0, 1] {
                xValues[z] = x == 1
                for y in [0, 1] {
                    yValues[z] = y == 1
                    let v = getValue(zGate) ? 1 : 0
                    guard (x + y) & 1 == v else { return false }
                }
            }
        } else if z == 45 {
            for carry in [0, 1] {
                xValues[z-1] = carry == 1
                yValues[z-1] = carry == 1
                let v = getValue(zGate) ? 1 : 0
                guard carry == v else { return false }
            }
        } else {
            for carry in [0, 1] {
                xValues[z-1] = carry == 1
                yValues[z-1] = carry == 1
                for x in [0, 1] {
                    xValues[z] = x == 1
                    for y in [0, 1] {
                        yValues[z] = y == 1
                        let v = getValue(zGate) ? 1 : 0
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

    func testGoodBits(and: Int) -> Bool {
        guard testBit(and) else { return false }
        for b in goodBits {
            guard testBit(b) else { return false }
        }
        return true
    }

    func findPossibleSwaps() -> [(String,String)] {
        resetDependencies()
        var possibleSwaps: [(String,String)] = []
        for z in 0 ... 45 where !goodBits.contains(z) {
            let (g,_) = findGates(involved: gateFor(start: "z", bit: z))
            for a in g {
                let (aInvolved, _) = findGates(involved: a)
                for b in allGateNames where !aInvolved.contains(b) {
                    guard a != b else { continue }
                    let (bInvolved, bHighBitValue) = findGates(involved: b)
                    guard !bInvolved.contains(a), bHighBitValue == z else { continue }
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
