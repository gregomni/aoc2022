//
//  Valves.swift
//  aoc
//
//  Created by Greg Titus on 12/16/22.
//

import Foundation
import RegexBuilder

struct Valve {
    let name: String
    let rate: Int
}

extension Valve: Identifiable {
    var id: String { name }
}

struct Possibility {
    var visited: Set<String> = ["AA"]
    var time: Int = 0
    var flow: Int = 0
    var position: [String]
    var travel: [Int]
    var total: Int = 0

    init(people: Int = 1) {
        position = Array(repeating: "AA", count: people)
        travel = Array(repeating: 0, count: people)
        for person in 0 ..< people {
            travel[person] = 4 * person
        }
        travel[0] = travel.last!
    }

    mutating func openUp(rate: Int) {
        flow += rate
    }

    mutating func move(to: String, time t: Int, person: Int = 0) {
        visited.insert(to)
        position[person] = to
        travel[person] = t
    }

    mutating func wait(person: Int = 0) {
        travel[person] = 99999
    }

    mutating func passTime(max: Int, end: Bool = false) {
        var t = max - time
        if !end {
            t = min(travel.min()!, t)
        }

        time += t
        total += (flow*t)
        for person in 0 ..< travel.count {
            travel[person] -= t
        }
    }
}

func valves(_ contents: String, numberOfWorkers: Int = 2) -> Int {
    let maxTime = 30
    let valves = DirectedGraph<Valve>()

    let elapsed = Date()

    let regex = Regex {
        "Valve "
        Capture { OneOrMore(CharacterClass.anyOf("ABCDEFGHIJKLMNOPQRSTUVWXYZ")) }
        " has flow rate="
        Capture { OneOrMore(.digit) } transform: { Int($0)! }
        "; tunnel"
        ZeroOrMore("s")
        " lead"
        ZeroOrMore("s")
        " to valve"
        ZeroOrMore("s")
        " "
        Capture { OneOrMore(.any) }
    }

    // Read the valves
    contents.enumerateLines { line, _ in
        let match = line.firstMatch(of: regex)!
        let name = String(match.output.1)
        let tunnels = String(match.output.3).components(separatedBy: ", ")

        valves.addNode(Valve(name: name, rate: match.output.2))
        tunnels.forEach { valves.addEdge(from: name, to: $0) }
    }
    assert(valves.isValid())

    valves.fullyConnect()
    valves.remove(where: { $0.rate == 0 && $0.name != "AA" })

    print("Setup time: \(-elapsed.timeIntervalSinceNow)")

    func moves(_ start: Possibility, person: Int = 0) -> [Possibility] {
        let location = start.position[person]

        // We score a move by imagining we go there, open the valve, and then move on to any other place we might want to go.
        var moveScores: [String : [String : Double]] = [:]
        for tunnel in valves.edges(location) {
            guard !start.visited.contains(tunnel.key) else { continue }
            let destination = tunnel.key
            let totalPressure = Double(max(0, (maxTime - (tunnel.value + 1))) * valves[destination]!.rate)
            var scores: [String : Double] = [:]
            for secondLeg in valves.edges(destination) {
                guard !start.visited.contains(secondLeg.key) else { continue }
                scores[secondLeg.key] = totalPressure / Double(tunnel.value + 1 + secondLeg.value)
            }
            scores[destination] = totalPressure / Double(tunnel.value + 1)
            moveScores[tunnel.key] = scores
        }

        // A bad move is one where, no matter where we want to travel two moves from now, we'd be better off opening a different valve instead.
        // I'm sure there's a better scoring function to use here, but this cuts out a bunch of dumb moves, at least.
        var goodMoves = Set(moveScores.keys)
        var progress: Bool
        repeat {
            progress = false
            for testMove in goodMoves {
                let testValues = moveScores[testMove]!
                for other in goodMoves {
                    guard testMove != other else { continue }
                    let otherValues = moveScores[other]!
                    var alwaysWorse = true
                    for score in testValues {
                        guard let otherValue = otherValues[score.key] else { continue }
                        if score.value >= otherValue {
                            alwaysWorse = false
                            break
                        }
                    }
                    if alwaysWorse {
                        goodMoves.remove(testMove)
                        progress = true
                        break
                    }
                }
            }
        } while progress && goodMoves.count > 1

        var result: [Possibility] = []
        for move in goodMoves {
            guard !start.visited.contains(move) else { continue }
            var moved = start
            moved.move(to: move, time: valves.edgeCost(location, move) + 1, person: person)
            result.append(moved)
        }
        if result.isEmpty {
            var p = start
            p.wait(person: person)
            result.append(p)
        }
        return result
    }

    // Look for best solution
    var best: Possibility? = nil
    func checkScore(_ possibility: Possibility) {
        var p = possibility
        p.passTime(max: maxTime, end: true)
        if best == nil || best!.total < p.total {
            best = p
        }
    }

    let maxFlow = valves.allNodes.reduce(0) { accum, valve in accum + valve.rate }
    var possibilities = [Possibility(people: numberOfWorkers)]
    while !possibilities.isEmpty {
        var current = possibilities.popLast()!

        current.passTime(max: maxTime)
        guard current.time < maxTime else { checkScore(current); continue }

        var new: [Possibility] = [current]
        for worker in 0 ..< numberOfWorkers {
            guard current.travel[worker] == 0 else { continue }
            let starts = new
            new.removeAll()

            for possibility in starts {
                var p = possibility
                let location = current.position[worker]
                p.openUp(rate: valves[location]!.rate)
                guard p.flow < maxFlow else { checkScore(p); break }
                new.append(contentsOf: moves(p, person: worker))
            }
        }
        possibilities.append(contentsOf: new)
    }
    print("Elapsed time: \(-elapsed.timeIntervalSinceNow)")
    return best!.total
}
