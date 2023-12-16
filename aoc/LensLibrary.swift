//
//  LensLibrary.swift
//  aoc
//
//  Created by Greg Titus on 12/15/23.
//

import Foundation

func lensLibrary(_ contents: String) -> Int {
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
