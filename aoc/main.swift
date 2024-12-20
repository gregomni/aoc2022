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
let format = FloatingPointFormatStyle<Double>.number.rounded(increment: 0.001).precision(.fractionLength(3))
if args[1] == "all" {
    var times: [Double] = []
    for problem in 1 ... 20 {
        times.append(run(problem: problem))
    }
    for (i,t) in zip(times.indices, times) {
        print("#\(i+1)\t\(t.formatted(format))s")
    }
    let sum = times.reduce(0,+)
    print("total\t\(sum.formatted(format))s")
} else {
    let time = run(problem: Int(args[1])!)
    print("time= \(time)")
}


func run(problem: Int) -> Double {
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
    case 14:
        print(dayFourteen(contents))
    case 15:
        print(dayFifteen(contents))
    case 16:
        print(daySixteen(contents))
    case 17:
        print(daySeventeen(contents))
    case 18:
        print(dayEighteen(contents))
    case 19:
        print(dayNineteen(contents))
    case 20:
        print(dayTwenty(contents))
    default:
        print("unknown problem")
        exit(2)
    }
    return Date().timeIntervalSince(begin)
}

