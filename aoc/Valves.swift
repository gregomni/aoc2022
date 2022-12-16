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
    struct Worker {
        var position: String
        var busy: Int
    }

    var remaining: Set<String> = ["AA"]
    var time: Int = 0
    var flow: Int = 0
    var workers: [Worker]
    var total: Int = 0

    init(people: Int = 1, allValves: [String]) {
        remaining = Set(allValves)
        remaining.remove("AA")
        workers = (0 ..< people).map { Worker(position: "AA", busy: $0 * 4) }
        workers[0].busy = workers.last!.busy
    }

    func available(_ person: Int) -> Bool {
        workers[person].busy == 0
    }

    mutating func openUp(rate: Int) {
        flow += rate
    }

    func moved(to: String, time t: Int, person: Int = 0) -> Possibility {
        var p = self
        p.remaining.remove(to)
        p.workers[person] = Worker(position: to, busy: t)
        return p
    }

    func snoozed(person: Int = 0) -> Possibility {
        var p = self
        p.workers[person].busy = 99999
        return p
    }

    mutating func passTime(max: Int, end: Bool = false) {
        var t = max - time
        if !end {
            t = min(workers.map({$0.busy}).min()!, t)
        }
        time += t
        total += (flow*t)
        workers = workers.map { Worker(position: $0.position, busy: $0.busy - t) }
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
        "; tunnel" ; ZeroOrMore("s") ; " lead" ; ZeroOrMore("s") ; " to valve" ; ZeroOrMore("s") ; " "
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
        // If there are no more places to go, this person can just rest.
        guard !start.remaining.isEmpty else { return [start.snoozed(person: person)] }

        // We score a move by imagining we go there, open the valve, and then move on to any other place we might want to go.
        // Each score is the pressure gained (over all remaining time) per minute spent.
        var moveScores: [String : [String : Double]] = [:]
        let location = start.workers[person].position
        for to in start.remaining {
            let firstTunnel = valves.edgeCost(location, to)
            let totalPressure = Double(max(0, (maxTime - (firstTunnel + 1))) * valves[to]!.rate)
            moveScores[to] = Dictionary(uniqueKeysWithValues: start.remaining.map { (key: $0, value: totalPressure / Double(firstTunnel + 1 + valves.edgeCost(to, $0))) })
        }

        // A bad move is one where, no matter where we want to travel after it, we'd be better off opening a different valve instead.
        // I'm sure there's a better scoring function to use here, but this cuts out a bunch of dumb moves, at least.
        var goodMoves = Set(moveScores.keys)
        for test in moveScores {
            for other in moveScores where test.key != other.key {
                if test.value.allSatisfy({ other.value[$0.key]! > $0.value }) {
                    goodMoves.remove(test.key)
                    break
                }
            }
        }
        return goodMoves.map { start.moved(to: $0, time: valves.edgeCost(location, $0) + 1, person: person) }
    }

    // Look for best solution
    let maxFlow = valves.allNodes.reduce(0) { accum, valve in accum + valve.rate }
    var best: Int = 0
    var possibilities = [Possibility(people: numberOfWorkers, allValves: valves.allNodes.map({ $0.name }))]
    while !possibilities.isEmpty {
        var current = possibilities.popLast()!

        // Pass as much time as possible, workers who are no longer busy have now opened valves.
        // (Note: this depends upon AA having a flow rate of 0, workers won't ever be at the same valve afterwards.)
        current.passTime(max: maxTime)
        for person in 0 ..< numberOfWorkers {
            guard current.available(person) else { continue }
            current.openUp(rate: valves[current.workers[person].position]!.rate)
        }
        guard current.flow < maxFlow, current.time < maxTime else {
            current.passTime(max: maxTime, end: true)
            best = max(best, current.total)
            continue
        }

        // New possibilities are the permutations of any available workers choosing new moves.
        var new: [Possibility] = [current]
        for worker in 0 ..< numberOfWorkers {
            guard current.available(worker) else { continue }
            let starts = new
            new.removeAll()

            for possibility in starts {
                new.append(contentsOf: moves(possibility, person: worker))
            }
        }
        possibilities.append(contentsOf: new)
    }
    print("Elapsed time: \(-elapsed.timeIntervalSinceNow)")
    return best
}
