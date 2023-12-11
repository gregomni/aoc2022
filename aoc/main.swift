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

let problem = Int(args[1])!
let contents = try! String(contentsOf: URL(fileURLWithPath: args[2]), encoding: .ascii)

switch problem {
case 1:
    print(dayOne(contents))
case 2:
    print(dayTwo(contents))
case 3:
    print(dayThree(contents))
case 4:
    print(dayFour(contents))
case 5:
    print(dayFive(contents))
case 6:
    print(daySix(contents))
case 7:
    print(camelCards(contents))
case 8:
    print(ghostCamels(contents))
case 9:
    print(mirage(contents))
case 10:
    print(fullOfPipes(contents))
case 11:
    print(cosmicExpansion(contents))
default:
    print("unknown problem")
    exit(2)
}
exit(0)

