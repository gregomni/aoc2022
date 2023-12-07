//
//  Voxels.swift
//  aoc
//
//  Created by Greg Titus on 12/18/22.
//

import Foundation

struct Voxel: Hashable, Equatable {
    var x: Int
    var y: Int
    var z: Int

    init(_ coords: [Int]) {
        x = coords[0]
        y = coords[1]
        z = coords[2]
    }

    init(_ x: Int, _ y: Int, _ z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }

    func adjacent(_ other: Self) -> Bool {
        abs(x - other.x) + abs(y - other.y) + abs(z - other.z) == 1
    }

    mutating func move(_ d: Direction) {
        let delta = d.delta
        x += delta.x
        y += delta.y
        z += delta.z
    }

    enum Direction: CaseIterable {
        case up
        case down
        case north
        case south
        case east
        case west

        var delta: Voxel {
            switch self {
            case .up: return Voxel(0, 0, 1)
            case .down: return Voxel(0, 0, -1)
            case .north: return Voxel(0, 1, 0)
            case .south: return Voxel(0, -1, 0)
            case .east: return Voxel(1, 0, 0)
            case .west: return Voxel(-1, 0, 0)
            }
        }
        var opposite: Direction {
            switch self {
            case .up: return .down
            case .down: return .up
            case .north: return .south
            case .south: return .north
            case .east: return .west
            case .west: return .east
            }
        }
    }
}

func voxels_part1(_ contents: String) -> Int {
    var voxels: [Voxel] = []
    contents.enumerateLines { line, _ in
        voxels.append(Voxel(line.components(separatedBy: ",").map({Int($0)!})))
    }
    var total = 6 * voxels.count
    for i in voxels.indices {
        for j in i+1 ..< voxels.count {
            if voxels[i].adjacent(voxels[j]) {
                total -= 2
            }
        }
    }
    return total
}

func voxels(_ contents: String) -> Int {
    var voxels: [Voxel] = []
    contents.enumerateLines { line, _ in
        voxels.append(Voxel(line.components(separatedBy: ",").map({Int($0)!})))
    }
    let minX = voxels.map({$0.x}).min()! - 1
    let maxX = voxels.map({$0.x}).max()! + 1
    let xRange = minX ... maxX
    let minY = voxels.map({$0.y}).min()! - 1
    let maxY = voxels.map({$0.y}).max()! + 1
    let yRange = minY ... maxY
    let minZ = voxels.map({$0.z}).min()! - 1
    let maxZ = voxels.map({$0.z}).max()! + 1
    let zRange = minZ ... maxZ

    let lava = Set(voxels)
    var steamStack = [Voxel(minX, minY, minZ)]
    var steam = Set(steamStack)

    var total = 0
    while let s = steamStack.popLast() {
        for d in Voxel.Direction.allCases {
            var v = s
            v.move(d)
            guard xRange.contains(v.x), yRange.contains(v.y), zRange.contains(v.z) else { continue }
            guard !steam.contains(v) else { continue }
            if lava.contains(v) {
                total += 1
            } else {
                steam.insert(v)
                steamStack.append(v)
            }
        }
    }
    return total
}
