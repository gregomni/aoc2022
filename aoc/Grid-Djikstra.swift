//
//  Grid-Djikstra.swift
//  aoc
//
//  Created by Greg Titus on 12/20/24.
//

import Foundation
import Collections

protocol ScoreType : Comparable {
    func combineEqualScores(_ other: Self) -> Self
}

extension ScoreType {
    // usually it doesn't matter which one
    func combineEqualScores(_ other: Self) -> Self {
        return self
    }
}

extension Int: ScoreType {}

struct PossibleMove<State: Equatable, Score: ScoreType>: Comparable {
    let move: State
    let score: Score
    static func < (lhs: PossibleMove, rhs: PossibleMove) -> Bool { lhs.score < rhs.score }
}

extension Grid {
    func bestMoves<State: Hashable, Score: Comparable>(from start: PossibleMove<State, Score>, to end: (State) -> Bool, generator: (Grid, PossibleMove<State, Score>) -> [PossibleMove<State, Score>]) -> [State : Score] {

        var best: [State : Score] = [start.move : start.score]
        var bestRoute: Score? = nil
        var examine = Heap<PossibleMove<State, Score>>()
        examine.insert(start)

        while let possibility = examine.popMin() {
            let move = possibility.move
            if let bestRoute, possibility.score >= bestRoute { continue }
            if let bestMove = best[move], possibility.score > bestMove { continue }
            for p in generator(self, possibility) {
                if let bestHere = best[p.move] {
                    if p.score > bestHere { continue }
                    if !(p.score < bestHere) {
                        best[p.move] = p.score.combineEqualScores(bestHere)
                        continue
                    }
                }
                best[p.move] = p.score
                if end(p.move) {
                    bestRoute = p.score
                } else {
                    examine.insert(p)
                }
            }
        }
        return best
    }

    func bestMoves<State: Hashable>(from start: State, to end: (State) -> Bool, generator: (Grid, PossibleMove<State, Int>) -> [PossibleMove<State, Int>]) -> [State : Int] {
        return bestMoves(from: PossibleMove(move: start, score: 0), to: end, generator: generator)
    }

    func moveDistance<State: Hashable>(from start: State, to end: State, generator: (Grid, PossibleMove<State, Int>) -> [PossibleMove<State, Int>]) -> Int? {
        let best = bestMoves(from: PossibleMove(move: start, score: 0), to: { $0 == end }, generator: generator)
        return best[end]
    }

    func bestManhattanMoves(from start: Index, to end: Index, allowed: (Element) -> Bool) -> [Index : Int] {
        return bestMoves(from: PossibleMove(move: start, score: 0), to: { $0 == end }) { grid, possibility in
            let i = possibility.move
            let score = possibility.score + 1
            return grid.cardinalDirections(from: i)
                        .filter({ allowed(grid[$0]) })
                        .map({ PossibleMove(move: $0, score: score)})
        }
    }

    func manhattanMoveDistance(from start: Index, to end: Index, allowed: (Element) -> Bool) -> Int? {
        let best = bestManhattanMoves(from: start, to: end, allowed: allowed)
        return best[end]
    }
}

extension Grid where Element == Character {
    func bestManhattanMoves(from start: Index, to end: Index) -> [Index : Int] {
        return bestManhattanMoves(from: start, to: end, allowed: { $0 != "#" })
    }

    func manhattanMoveDistance(from start: Index, to end: Index) -> Int? {
        return bestManhattanMoves(from: start, to: end)[end]
    }
}


