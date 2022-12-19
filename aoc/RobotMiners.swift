//
//  RobotMiners.swift
//  aoc
//
//  Created by Greg Titus on 12/19/22.
//

import Foundation
import RegexBuilder

struct Blueprint {
    let oreRobotOre: Int
    let clayRobotOre: Int
    let obsidianRobotOre: Int
    let obsidianRobotClay: Int
    let geodeRobotOre: Int
    let geodeRobotObsidian: Int
}

struct RobotState {
    let blueprint: Blueprint

    var time = 0

    var oreRobots = 1
    var clayRobots = 0
    var obsidianRobots = 0
    var geodeRobots = 0

    var ore = 0
    var clay = 0
    var obsidian = 0
    var geode = 0

    mutating func collect() {
        ore += oreRobots
        clay += clayRobots
        obsidian += obsidianRobots
        geode += geodeRobots
        time += 1
    }

    func buildingOreRobot() -> RobotState {
        var s = self
        s.ore -= blueprint.oreRobotOre
        s.collect()
        s.oreRobots += 1
        return s
    }

    func buildingClayRobot() -> RobotState {
        var s = self
        s.ore -= blueprint.clayRobotOre
        s.collect()
        s.clayRobots += 1
        return s
    }

    func buildingObsidianRobot() -> RobotState {
        var s = self
        s.ore -= blueprint.obsidianRobotOre
        s.clay -= blueprint.obsidianRobotClay
        s.collect()
        s.obsidianRobots += 1
        return s
    }

    func buildingGeodeRobot() -> RobotState {
        var s = self
        s.ore -= blueprint.geodeRobotOre
        s.obsidian -= blueprint.geodeRobotObsidian
        s.collect()
        s.geodeRobots += 1
        return s
    }
}

func robotMiners(_ contents: String, part2: Bool = false) -> Int {
    let regex = Regex {
        "Blueprint "
        OneOrMore(.digit)
        ": Each ore robot costs "
        Capture { OneOrMore(.digit) } transform: { Int($0)! }
        " ore. Each clay robot costs "
        Capture { OneOrMore(.digit) } transform: { Int($0)! }
        " ore. Each obsidian robot costs "
        Capture { OneOrMore(.digit) } transform: { Int($0)! }
        " ore and "
        Capture { OneOrMore(.digit) } transform: { Int($0)! }
        " clay. Each geode robot costs "
        Capture { OneOrMore(.digit) } transform: { Int($0)! }
        " ore and "
        Capture { OneOrMore(.digit) } transform: { Int($0)! }
        " obsidian."
    }

    var blueprints: [Blueprint] = []
    contents.enumerateLines { line, _ in
        let match = line.firstMatch(of: regex)!
        blueprints.append(Blueprint(oreRobotOre: match.output.1, clayRobotOre: match.output.2, obsidianRobotOre: match.output.3, obsidianRobotClay: match.output.4, geodeRobotOre: match.output.5, geodeRobotObsidian: match.output.6))
    }

    var blueprintNumber = 1
    var total = part2 ? 1 : 0

    if part2 {
        blueprints.replaceSubrange(3..., with: [])
    }
    let endTime = part2 ? 32 : 24

    for blueprint in blueprints {
        let elapsed = Date()
        var best: Int = 0
        var states = [RobotState(blueprint: blueprint)]

        while !states.isEmpty {
            var state = states.popLast()!

            // Building something new in the last minute doesn't make any difference so always just collect in the last minute
            if state.time == (endTime-1) {
                state.collect()
                if best < state.geode {
                    best = state.geode
                }
                continue
            }

            if state.ore >= blueprint.geodeRobotOre, state.obsidian >= blueprint.geodeRobotObsidian {
                // If we can make a geode robot, definitely always just make a geode robot.
                states.append(state.buildingGeodeRobot())
            } else if state.time == (endTime-2) {
                // If we're in the second to last minute, if we aren't making a geode robot, nothing else will help.
                state.collect()
                states.append(state)
            } else if state.obsidianRobots == 0, state.ore >= blueprint.obsidianRobotOre, state.clay >= blueprint.obsidianRobotClay {
                // If we don't have any obsidian robots yet and can make one that's an obvious second choice.
                states.append(state.buildingObsidianRobot())
            } else {
                // Otherwise we could try making anything or making nothing.
                // But since we can only ever make one robot per minute, never make more robots of one type than we need as inputs for another type.
                if state.ore >= blueprint.obsidianRobotOre, state.clay >= blueprint.obsidianRobotClay, state.obsidianRobots < blueprint.geodeRobotObsidian {
                    states.append(state.buildingObsidianRobot())
                }
                if state.ore >= blueprint.clayRobotOre, state.clayRobots < blueprint.obsidianRobotClay {
                    states.append(state.buildingClayRobot())
                }
                if state.ore >= blueprint.oreRobotOre, state.oreRobots < max(blueprint.geodeRobotOre, blueprint.obsidianRobotOre, blueprint.clayRobotOre, blueprint.oreRobotOre) {
                    states.append(state.buildingOreRobot())
                }
                state.collect()
                states.append(state)
            }
        }
        print("blueprint #\(blueprintNumber), best: \(best), elapsed: \(-elapsed.timeIntervalSinceNow)")
        if part2 {
            total *= best
        } else {
            total += blueprintNumber * best
        }
        blueprintNumber += 1
    }
    return total
}
