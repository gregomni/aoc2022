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

        init(_ s: String) {
            switch s.first {
            case "x": self = .x(Int(s.dropFirst())!)
            case "y": self = .y(Int(s.dropFirst())!)
            default: self = .gate(s)
            }
        }
    }

    func inputValue(_ input: Input, cachingBelowBit: Int?) -> Bool {
        switch input {
        case .x(let i): return xValues[i]
        case .y(let i): return yValues[i]
        case .gate(let s): return getValue(s, cachingBelowBit: cachingBelowBit)
        }
    }

    enum GateType {
        case and
        case or
        case xor

        func compute(a: Bool, b: Bool) -> Bool {
            switch self {
            case .and:
                return a && b
            case .or:
                return a || b
            case .xor:
                return (a || b) && !(a && b)
            }
        }

        init(_ s: String) {
            switch s {
            case "AND": self = .and
            case "OR": self = .or
            default: self = .xor
            }
        }
    }

    struct Gate {
        var inputA: Input
        var inputB: Input
        let output: String
        let type: GateType
        var cached: Bool? = nil
        var highBitDependency: Int? = nil

        mutating func clearCache() {
            cached = nil
            highBitDependency = nil
        }
    }

    contents.enumerateLines { line, _ in
        if line.isEmpty {
            valuesSection = false
        } else if valuesSection {
            let parts = line.components(separatedBy: ": ")
            let i = Int(parts[0].dropFirst())!
            if parts[0].first == "x" {
                xValues[i] = parts[1] == "1"
            } else {
                yValues[i] = parts[1] == "1"
            }
        } else {
            let parts = line.components(separatedBy: " -> ")
            let inputs = parts[0].components(separatedBy: " ")
            let gate = Gate(inputA: Input(inputs[0]), inputB: Input(inputs[2]), output: parts[1], type: GateType(inputs[1]))
            gates[String(gate.output)] = gate
        }
    }

    func getValue(_ string: String, cachingBelowBit: Int? = nil) -> Bool {
        let gate = gates[string]!
        var cache = false
        if let cachingBelowBit, let high = gate.highBitDependency, high < cachingBelowBit {
            if let v = gate.cached { return v }
            cache = true
        }
        let a = inputValue(gate.inputA, cachingBelowBit: cachingBelowBit)
        let b = inputValue(gate.inputB, cachingBelowBit: cachingBelowBit)
        let result = gate.type.compute(a: a, b: b)
        if cache { gates[string]!.cached = result }
        return result
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

    var gateNamesByHighBit: [[String]] = []
    var gateDependencies: [String : Set<String>] = [:]

    func computeDependencies() {
        func findGates(involved: Input) -> (g: Set<String>, v: Int) {
            switch involved {
            case .x(let i), .y(let i):
                return ([], i)
            case .gate(let s):
                return findGates(involved: s)
            }
        }

        func findGates(involved: String) -> (g: Set<String>, v: Int) {
            var gate = gates[involved]!
            if let v = gate.highBitDependency {
                return (gateDependencies[involved]!, v)
            }
            let (ag, av) = findGates(involved: gate.inputA)
            let (bg, bv) = findGates(involved: gate.inputB)
            let g = ag.union(bg).union([involved])
            let v = max(av, bv)
            gate.highBitDependency = v
            gate.cached = nil
            gates[involved] = gate
            gateDependencies[involved] = g
            gateNamesByHighBit[v].append(involved)
            return (g,v)
        }

        gateNamesByHighBit = Array(repeating: [], count: 45)
        gateDependencies = [:]

        for k in gates.keys {
            gates[k]!.clearCache()
        }
        for g in gates.keys {
            _ = findGates(involved: g)
        }
    }

    func testBit(_ z: Int, caching: Bool = false) -> Bool {
        let zGate = gateFor(start: "z", bit: z)
        let cacheBits = caching ? z-1 : nil
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
                let v = getValue(zGate, cachingBelowBit: cacheBits) ? 1 : 0
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
                        let v = getValue(zGate, cachingBelowBit: cacheBits) ? 1 : 0
                        guard (x + y + carry) & 1 == v else { return false }
                    }
                }
            }
        }
        return true
    }

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
        guard testBit(and, caching: true) else { return false }
        for b in goodBits {
            guard testBit(b, caching: true) else { return false }
        }
        return true
    }

    func findPossibleSwaps() -> [(String,String)] {
        computeDependencies()
        var possibleSwaps: [(String,String)] = []
        for z in 0 ... 45 where !goodBits.contains(z) {
            for a in gateDependencies[gateFor(start: "z", bit: z)]! {
                let aInvolved = gateDependencies[a]!
                for b in gateNamesByHighBit[z] where !aInvolved.contains(b) {
                    let bInvolved = gateDependencies[b]!
                    guard !bInvolved.contains(a) else { continue }
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
