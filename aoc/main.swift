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
case 12:
    print(hotSprings(contents))
case 13:
    print(mirrors(contents))
case 14:
    print(parabolicReflector(contents))
case 15:
    print(dayFifteen(contents))
default:
    print("unknown problem")
    exit(2)
}
exit(0)

func dayFifteen(_ contents: String) -> Int {
    struct Lens {
        let name: String
        let focal: Int
    }
    var boxes: [[Lens]] = Array(repeating: [], count: 256)

    for instruction in contents.replacingOccurrences(of: "\n", with: "").components(separatedBy: ",") {
        var value = 0
        var name = ""
        for c in instruction {
            if c == "=" {
                let new = Lens(name: name, focal: Int(instruction.suffix(1))!)
                if let index = boxes[value].firstIndex(where: {$0.name == name}) {
                    boxes[value][index] = new
                } else {
                    boxes[value].append(new)
                }
            } else if c == "-" {
                if let index = boxes[value].firstIndex(where: {$0.name == name}) {
                    boxes[value].remove(at: index)
                }
            } else {
                name.append(c)
                value += Int(c.asciiValue!)
                value *= 17
                value = value % 256
            }
        }
    }

    var total = 0
    for i in boxes.indices {
        for j in boxes[i].indices {
            total += (1+i)*(1+j)*boxes[i][j].focal
        }
    }
    return total
}
