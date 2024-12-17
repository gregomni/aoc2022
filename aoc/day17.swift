//
//  day17.swift
//  aoc
//
//  Created by Greg Titus on 12/16/24.
//

import Foundation

func daySeventeen_part1(_ contents: String) -> Int {
    enum Instruction: Int {
        case adv
        case bxl
        case bst
        case jnz
        case bxc
        case out
        case bdv
        case cdv
    }

    var registerA = 51571418
    var registerB = 0
    var registerC = 0
    let program = [2,4,1,1,7,5,0,3,1,4,4,5,5,5,3,0]
    //let program = [0,3,5,4,3,0]
    var instructionPtr = 0
    var output: [Int] = []

    func combo(operand: Int) -> Int {
        switch operand {
        case 0...3:
            return operand
        case 4:
            return registerA
        case 5:
            return registerB
        case 6:
            return registerC
        case 7:
            assertionFailure("reserved")
            break
        default:
            assertionFailure("invalid")
            break
        }
        return 0
    }

    func execute(_ i: Instruction, operand: Int) -> Bool {
        switch i {
        case .adv:
            registerA = registerA / (1 << combo(operand: operand))
        case .bxl:
            registerB ^= operand
        case .bst:
            registerB = combo(operand: operand) & 7
        case .jnz:
            if registerA != 0 {
                instructionPtr = operand
                return true
            }
        case .bxc:
            registerB ^= registerC
        case .out:
            let value = combo(operand: operand) % 8
            if program.count <= output.count || value != program[output.count] {
                return false
            }
            output.append(value)
        case .bdv:
            registerB = registerA / (1 << combo(operand: operand))
        case .cdv:
            registerC = registerA / (1 << combo(operand: operand))
        }
        instructionPtr += 2
        return true
    }

    for n in 0 ..< .max {
        instructionPtr = 0
        registerA = n
        registerB = 0
        registerC = 0
        output = []

        while program.indices.contains(instructionPtr) {
            if !execute(Instruction(rawValue: program[instructionPtr])!, operand: program[instructionPtr+1]) {
                break
            }
        }
        if output == program {
            return n
        }
    }
    print(output.map({ $0.description }).joined(separator: ","))
    return 0
}

/*
[2,4, 1,1, 7,5, 0,3, 1,4, 4,5, 5,5, 3,0]

B = A % 8
B = B ^ 1
C = A / 2^B
A = A / 2^3
B = B ^ 4
B = B ^ C
output B % 8
loop if A not zero
*/
func daySeventeen(_ contents: String) -> Int {
    func backward(desired: [Int], previousValue: Int) -> Int? {
        guard !desired.isEmpty else { return previousValue }
        for i in 0 ... 7 {
            let previous = (previousValue << 3) | i
            let b = i ^ 1
            let c = (previous >> b) % 8
            let out = ((b ^ 4) ^ c) % 8
            if out == desired.last {
                if let result = backward(desired: desired.dropLast(), previousValue: previous) {
                    return result
                }
            }
        }
        return nil
    }

    let program = [2,4,1,1,7,5,0,3,1,4,4,5,5,5,3,0]
    return backward(desired: program, previousValue: 0)!
}
