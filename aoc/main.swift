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
default:
    print("unknown problem")
    exit(2)
}
exit(0)

