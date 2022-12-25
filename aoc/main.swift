//
//  main.swift
//  aoc
//
//  Created by Greg Titus on 12/7/22.
//

import Foundation
import RegexBuilder

let args = CommandLine.arguments
if (args.count < 3) {
    print("not enough arguments")
    exit(1)
}

let contents = try! String(contentsOf: URL(fileURLWithPath: args[2]), encoding: .ascii)
let problem = Int(args[1])!

switch problem {
case 1:
    print(mostCalories(contents))
case 2:
    print(rockPaperScissorsScore(contents))
case 3:
    print(ruckSacks(contents))
case 4:
    print(assignmentPairs(contents))
case 5:
    print(crateStacks(contents))
case 6:
    print(packetMarker(contents))
case 7:
    print(directoryContents(contents))
case 8:
    print(treeGrid(contents))
case 9:
    print(ropeBridge(contents))
case 10:
    print(cathodeRayTube(contents))
case 11:
    print(monkeys(contents))
case 12:
    print(hillClimb(contents))
case 13:
    print(distressSignal(contents))
case 14:
    print(sand(contents))
case 15:
    print(sensorBeacon(contents))
case 16:
    print(valves(contents))
case 17:
    print(tetris(contents))
case 18:
    print(voxels(contents))
case 19:
    print(robotMiners(contents))
case 20:
    print(twenty(contents))
case 21:
    print(monkeyShouts(contents))
case 22:
    print(wrappingMap(contents))
case 23:
    print(plantings(contents))
case 24:
    print(blizzard(contents))
case 25:
    print(snafu(contents))
default:
    print("unknown problem")
    exit(2)
}
exit(0)

func snafu(_ contents: String) -> String {
    func fromSnafu(_ s: String) -> Int {
        func digitFromSnafu(_ c: Character) -> Int {
            switch c {
            case "=": return -2
            case "-": return -1
            case "0": return 0
            case "1": return 1
            case "2": return 2
            default:
                assertionFailure("bad snafu")
                exit(1)
            }
        }

        var number = 0
        for c in s {
            number *= 5
            number += digitFromSnafu(c)
        }
        return number
    }

    func toSnafu(_ i: Int) -> String {
        var powers = [1]
        var power = 1
        while power < i {
            power *= 5
            powers.append(power)
        }

        var places = Array(repeating: 0, count: powers.count)
        var leftover = i

        func carry(_ n: Int, _ start: Int) {
            var index = start
            while !(-2 ... 2).contains(places[index] + n) {
                leftover += powers[index] * places[index]
                places[index] = 0
                index += 1
            }
            places[index] += n
            leftover -= powers[index] * n
        }

        var index = places.count - 1
        while index >= 0 {
            let power = powers[index]
            let range = power * 5 / 2

            if leftover > range {
                carry(1, index+1)
            } else if leftover < -range {
                carry(-1, index+1)
            } else {
                places[index] = leftover / power
                leftover -= power * places[index]
                index -= 1
            }
        }
        assert(leftover == 0)

        var result = ""
        for digit in places.reversed() {
            switch digit {
            case 2: result += "2"
            case 1: result += "1"
            case 0:
                if !result.isEmpty {
                    result += "0"
                }
            case -1: result += "-"
            case -2: result += "="
            default:
                assertionFailure("bad computing")
                exit(1)
            }
        }
        assert(i == fromSnafu(result))
        return result
    }

    var total = 0
    contents.enumerateLines { line, _ in
        total += fromSnafu(line)
    }
    return toSnafu(total)
}
