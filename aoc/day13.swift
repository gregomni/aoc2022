//
//  day13.swift
//  aoc
//
//  Created by Greg Titus on 12/12/24.
//

import Foundation

func dayThirteen(_ contents: String, part1: Bool = false) -> Int {
    let more = part1 ? 0 : 10000000000000
    let aButtons = contents.matches(of: /Button A: X\+([0-9]+), Y\+([0-9]+)/)
    let bButtons = contents.matches(of: /Button B: X\+([0-9]+), Y\+([0-9]+)/)
    let prizes = contents.matches(of: /Prize: X=([0-9]+), Y=([0-9]+)/)
    var result = 0

    for i in aButtons.indices {
        let (ax,ay) = (Int(aButtons[i].1)!, Int(aButtons[i].2)!)
        let (bx,by) = (Int(bButtons[i].1)!, Int(bButtons[i].2)!)
        let (px,py) = (Int(prizes[i].1)! + more, Int(prizes[i].2)! + more)

        guard (by*ax - bx*ay) != 0, (py*ax - ay*px) % (by*ax - bx*ay) == 0 else { continue }
        let bCount = (py*ax - ay*px) / (by*ax - bx*ay)
        guard ax != 0, (px - bx*bCount) % ax == 0 else { continue }
        let aCount = (px - bx*bCount) / ax

        result += aCount*3 + bCount
    }

    return result
}
