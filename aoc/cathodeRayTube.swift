//
//  cathodeRayTube.swift
//  aoc
//
//  Created by Greg Titus on 12/10/22.
//

import Foundation

func cathodeRayTube(_ contents: String) -> Int {
    var cycle = 1
    var x = 1
    var newX: Int? = nil
    var time = 0

    var scanline = ""

    var total = 0

    func execute() {
        while time > 0 {
            if (cycle - 20) % 40 == 0 {
                total += cycle * x
            }

            let hPos = (cycle-1) % 40
            if hPos == 0 {
                print(scanline)
                scanline = ""
            }
            if abs(x - hPos) <= 1 {
                scanline.append("#")
            } else {
                scanline.append(".")
            }

            cycle += 1
            time -= 1
        }
        x = newX ?? x
    }

    contents.enumerateLines { line, _ in
        if line.hasPrefix("addx") {
            newX = x + Int(line.suffix(from: line.index(line.startIndex, offsetBy: 5)))!
            time = 2
        } else if line.hasPrefix("noop") {
            newX = nil
            time = 1
        } else {
            preconditionFailure("unknown op")
        }
        execute()
    }

    execute()
    print(scanline)
    return total
}
