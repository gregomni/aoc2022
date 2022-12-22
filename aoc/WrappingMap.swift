//
//  WrappingMap.swift
//  aoc
//
//  Created by Greg Titus on 12/22/22.
//

import Foundation
import RegexBuilder

enum WalkSpot: Character {
    case empty = "."
    case wall = "#"
    case void = " "
}

enum Turn: String {
    case clockwise = "R"
    case ccw = "L"
}

func wrappingMap(_ contents: String, part2: Bool = true) -> Int {
    typealias Pos = Grid<WalkSpot>.Index
    typealias Dir = Grid<WalkSpot>.Direction

    // Split the input into map and instructions
    let parts = contents.components(separatedBy: "\n\n")
    assert(parts.count == 2)
    let grid = Grid(contents: parts[0]) { WalkSpot(rawValue: $0)! }
    let instructions = parts[1]

    // Start at x= first non void, y = 0
    var position = Pos()
    for p in grid.rightFrom(y: 0) {
        if grid[p] == .empty {
            position = p
            break
        }
    }
    var facing = Dir.right

    // Parse the instructions
    let regex = Regex {
        ChoiceOf {
            Capture { OneOrMore(.digit) } transform: { Int($0)! }
            Capture { ChoiceOf { "L" ; "R" } } transform: { Turn(rawValue: String($0))! }
        }
    }
    let moves = instructions.matches(of: regex)

    // Map a position to a cube face
    func mapPart(_ p: Pos) -> Int {
        let xPortion = p.x / (grid.xSize / 3)
        let yPortion = p.y / (grid.ySize / 4)
        switch (xPortion, yPortion) {
        case (1, 0): return 1
        case (2, 0): return 2
        case (1, 1): return 3
        case (0, 2): return 4
        case (1, 2): return 5
        case (0, 3): return 6
        default:
            assertionFailure("not part of the cube")
            return -1
        }
    }

    // Map a cube face back to flat x,y of where that cube face lies
    func cubeFaceToMapPart(_ cubeFace: Int) -> (x: Int, y: Int) {
        switch cubeFace {
        case 1: return (1, 0)
        case 2: return (2, 0)
        case 3: return (1, 1)
        case 4: return (0, 2)
        case 5: return (1, 2)
        case 6: return (0, 3)
        default:
            exit(4)
        }
    }

    // Given a direction you left a cube face and an edge on which you entered, where do you end up?
    // (The direction you face is always away from the edge you entered on.)
    func cubeEntryPoint(_ p: Pos, _ face: Dir, _ cubeFace: Int, _ entrySide: Dir) -> (Pos, Dir) {
        let mapPart = cubeFaceToMapPart(cubeFace)
        let cubeSize = max(grid.xSize, grid.ySize) / 4

        // the min and max coords for the destination cube face square
        let cubeMins = (x: mapPart.x * cubeSize, y: mapPart.y * cubeSize)
        let cubeMaxs = (x: cubeMins.x + cubeSize - 1, y: cubeMins.y + cubeSize - 1)

        // the origin coords from the original cube face
        let pX = p.x % cubeSize
        let pY = p.y % cubeSize

        let newP: Pos
        switch (face, entrySide) {
        // Wrapping straight around (e.g. exit going left, enter on the right)
        // The coord you enter on is the same one you exited from.
        case (.left, .right): newP = Pos(x: cubeMaxs.0, y: cubeMins.y + pY)
        case (.right, .left): newP = Pos(x: cubeMins.0, y: cubeMins.y + pY)
        case (.up, .down): newP = Pos(x: cubeMins.x + pX, y: cubeMaxs.1)
        case (.down, .up): newP = Pos(x: cubeMins.x + pX, y: cubeMins.1)
        // The coord you enter on is mirror-image the one you exit from.
        case (.left, .left): newP = Pos(x: cubeMins.0, y: cubeMaxs.y - pY)
        case (.right, .right): newP = Pos(x: cubeMaxs.0, y: cubeMaxs.y - pY)
        case (.up, .up): newP = Pos(x: cubeMaxs.x - pX, y: cubeMins.1)
        case (.down, .down): newP = Pos(x: cubeMaxs.x - pX, y: cubeMaxs.1)
        // The same as the above cases but now involves swapping x and y in the coord you exit/enter.
        case (.left, .up): newP = Pos(x: cubeMins.x + pY, y: cubeMins.y)
        case (.right, .up): newP = Pos(x: cubeMaxs.x - pY, y: cubeMins.y)
        case (.left, .down): newP = Pos(x: cubeMaxs.x - pY, y: cubeMaxs.y)
        case (.right, .down): newP = Pos(x: cubeMins.x + pY, y: cubeMaxs.y)
        case (.up, .left): newP = Pos(x: cubeMins.x, y: cubeMins.y + pX)
        case (.down, .left): newP = Pos(x: cubeMins.x, y: cubeMaxs.y - pX)
        case (.up, .right): newP = Pos(x: cubeMaxs.x, y: cubeMaxs.y - pX)
        case (.down, .right): newP = Pos(x: cubeMaxs.x, y:  cubeMins.y + pX)
        }
        return (newP, entrySide.opposite())
    }

    // Take one step, doing wrapping as necessary.
    // For part 1 this loops around the whole grid.
    // For part 2 this is how I form a cube specificly from my input data.
    // (It's possible other input data arranges the 6 faces in the flat grid differently than mine did.)
    func wrappedStep(_ p: Pos, _ face: Dir) -> (Pos, Dir) {
        var newP = p.direction(face)

        if part2 {
            if grid.valid(index: newP), grid[newP] != .void {
                return (newP, face)
            }
            let mapPart = mapPart(p)

            switch (mapPart, face) {
            case (1, .up): return cubeEntryPoint(p, face, 6, .left)
            case (1, .left): return cubeEntryPoint(p, face, 4, .left)
            case (2, .up): return cubeEntryPoint(p, face, 6, .down)
            case (2, .right): return cubeEntryPoint(p, face, 5, .right)
            case (2, .down): return cubeEntryPoint(p, face, 3, .right)
            case (3, .left): return cubeEntryPoint(p, face, 4, .up)
            case (3, .right): return cubeEntryPoint(p, face, 2, .down)
            case (4, .up): return cubeEntryPoint(p, face, 3, .left)
            case (4, .left): return cubeEntryPoint(p, face, 1, .left)
            case (5, .right): return cubeEntryPoint(p, face, 2, .right)
            case (5, .down): return cubeEntryPoint(p, face, 6, .right)
            case (6, .left): return cubeEntryPoint(p, face, 1, .up)
            case (6, .right): return cubeEntryPoint(p, face, 5, .down)
            case (6, .down): return cubeEntryPoint(p, face, 2, .up)
            default:
                assertionFailure("invalid combination of cubeface and direction")
                exit(3)
            }
        } else {
            guard !grid.valid(index: newP) else { return (newP, face) }

            switch face {
            case .left: newP = Pos(x: grid.xSize-1, y: p.y)
            case .right: newP = Pos(x: 0, y: p.y)
            case .up: newP = Pos(x: p.x, y: grid.ySize-1)
            case .down: newP = Pos(x: p.x, y: 0)
            }
            return (newP, face)
        }
    }

    // Make the actual moves, and keep going in a straight line through void.
    // (In part2 the wrappedStep() will never return a void spot, so the while loop is never used.)
    for move in moves {
        if let forward = move.output.1 {
            for _ in 0 ..< forward {
                var face = facing
                var step = position
                (step, face) = wrappedStep(step, face)
                while grid[step] == .void {
                    (step, face) = wrappedStep(step, face)
                }
                if grid[step] == .empty {
                    position = step
                    facing = face
                }
            }
        } else {
            switch move.output.2! {
            case .clockwise:
                facing = facing.turnClockwise()
            case .ccw:
                facing = facing.turnCCW()
            }
        }
    }

    // Encoding the end position and facing
    let facingValue: Int
    switch facing {
    case .left: facingValue = 2
    case .right: facingValue = 0
    case .up: facingValue = 3
    case .down: facingValue = 1
    }
    return 1000 * (position.y+1) + 4 * (position.x+1) + facingValue
}
