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
default:
    print("unknown problem")
    exit(2)
}
exit(0)

func twenty_part1(_ contents: String) -> Int {
    let numbers = contents.components(separatedBy: "\n").filter({ !$0.isEmpty }).map({ Int($0)! })
    let count = numbers.count
    var mixed = Array(zip(numbers, 0 ..< count))

    for i in numbers.indices {
        let index = mixed.firstIndex(where: { $0.1 == i })!
        var newPosition = (index + numbers[i]) % (count-1)
        guard index != newPosition else { continue }
        if newPosition == 0, numbers[i] < 0 {
            newPosition = count - 1
        } else if newPosition < 0 {
            newPosition += count - 1
        }
        mixed.remove(at: index)
        mixed.insert((numbers[i], i), at: newPosition)
    }

    let index = mixed.firstIndex(where: { $0.0 == 0 })!
    let first = mixed[(index+1000) % count]
    let second = mixed[(index+2000) % count]
    let third = mixed[(index+3000) % count]
    return first.0 + second.0 + third.0
}

func twenty(_ contents: String) -> Int {
    let numbers = contents.components(separatedBy: "\n").filter({ !$0.isEmpty }).map({ Int($0)! * 811589153 })
    let count = numbers.count
    var mixed = Array(zip(numbers, 0 ..< count))

    for _ in 0 ..< 10 {
        for i in numbers.indices {
            let index = mixed.firstIndex(where: { $0.1 == i })!
            var newPosition = (index + numbers[i]) % (count-1)
            guard index != newPosition else { continue }
            if newPosition == 0, numbers[i] < 0 {
                newPosition = count - 1
            } else if newPosition < 0 {
                newPosition += count - 1
            }
            mixed.remove(at: index)
            mixed.insert((numbers[i], i), at: newPosition)
        }
    }
    let index = mixed.firstIndex(where: { $0.0 == 0 })!
    let first = mixed[(index+1000) % count]
    let second = mixed[(index+2000) % count]
    let third = mixed[(index+3000) % count]
    return first.0 + second.0 + third.0
}
