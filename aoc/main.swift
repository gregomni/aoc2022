//
//  main.swift
//  aoc
//
//  Created by Greg Titus on 12/7/22.
//

import Foundation
import RegexBuilder

let args = CommandLine.arguments
if (args.count < 2) {
    print("not enough arguments")
    exit(1)
}
if args[1] == "all" {
    for problem in 1 ... 11 {
        run(problem: problem)
    }
} else {
    run(problem: Int(args[1])!)
}


func run(problem: Int) -> Void {
    let path: String
    if (args.count == 3) {
        path = args[2]
    } else {
        path = "/Users/toon/AdventOfCode/input\(problem).txt"
    }

    let begin = Date()
    let contents = try! String(contentsOf: URL(fileURLWithPath: path), encoding: .ascii)

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
        print(daySeven(contents))
    case 8:
        print(dayEight(contents))
    case 9:
        print(dayNine(contents))
    case 10:
        print(dayTen(contents))
    case 11:
        print(dayEleven(contents))
    case 12:
        print(dayTwelve(contents))
    case 13:
        print(dayThirteen(contents))
   default:
        print("unknown problem")
        exit(2)
    }
    print("time= \(Date().timeIntervalSince(begin))")
}

