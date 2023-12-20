//
//  PulsePropogation.swift
//  aoc
//
//  Created by Greg Titus on 12/20/23.
//

import Foundation

func pulsePropogation(_ contents: String) -> Int {
    var modules: [String : Module] = [:]
    var pulses: [Pulse] = []

    struct Pulse {
        let from: String
        let low: Bool
        let to: String
    }

    enum Type: Character {
        case flipFlop = "%"
        case conjunction = "&"
        case broadcaster = "b"
    }
    struct Module {
        let name: String
        let type: Type
        let destination: [String]
        var status = false
        var state: [String: Bool] = [:]

        mutating func hasInput(_ named: String) {
            if case .conjunction = type {
                state[named] = true
            }
        }

        mutating func pulse(from: String, low: Bool, pulses: inout [Pulse]) {
            switch type {
            case .flipFlop:
                guard low else { return }
                self.status.toggle()
                destination.forEach {
                    pulses.append(Pulse(from: name, low: !status, to: $0))
                }
            case .conjunction:
                state[from] = low
                let anyLow = state.values.firstIndex(of: true) != nil
                destination.forEach {
                    pulses.append(Pulse(from: name, low: !anyLow, to: $0))
                }
            case .broadcaster:
                destination.forEach {
                    pulses.append(Pulse(from: name, low: low, to: $0))
                }
            }
        }
    }

    contents.enumerateLines { line, _ in
        let match = line.firstMatch(of: /(.)(.*) -> (.*)/)!
        let module = Module(name: String(match.2), type: Type(rawValue: match.1.first!)!, destination: match.3.components(separatedBy: ", "))
        modules[module.name] = module
    }

    let keyNames = modules.keys.map { $0 }
    for key in keyNames {
        let destinations = modules[key]!.destination
        for d in destinations {
            var m = modules[d]
            m?.hasInput(key)
            modules[d] = m
        }
    }

    let interesting = Set(["kr", "zs", "kf", "qk"])
    for presses in 1 ..< 10000 {
        pulses = [Pulse(from: "", low: true, to: "roadcaster")]
        while !pulses.isEmpty {
            let pulse = pulses.removeFirst()
            if pulse.to == "rx", pulse.low == true {
                return presses
            }
            if !pulse.low, interesting.contains(pulse.from) {
                print("\(pulse.from) on \(presses)")
            }
            modules[pulse.to]?.pulse(from: pulse.from, low: pulse.low, pulses: &pulses)
        }
    }
    return 0
}
