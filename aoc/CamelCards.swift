//
//  CamelCards.swift
//  aoc
//
//  Created by Greg Titus on 12/7/23.
//

import Foundation

extension Array {
    func number(where f: (Element) -> Bool) -> Int {
        var result = 0
        for element in self {
            if f(element) {
                result += 1
            }
        }
        return result
    }
}

func camelCards(_ contents: String) -> Int {
    enum Strength: Int {
        case five
        case four
        case fullHouse
        case three
        case twoPair
        case two
        case high

        init(_ cards: [Character]) {
            var seen = Set<Character>()
            var numbers: [Int] = []
            seen.insert("J")
            for c in cards {
                if seen.contains(c) { continue }
                let num = cards.number(where: {$0 == c})
                if num > 1 {
                    numbers.append(num)
                }
                seen.insert(c)
            }
            let wild = cards.number(where: {$0 == "J"})
            if numbers.isEmpty, wild > 0 {
                numbers.append(1)
            }
            if numbers.isEmpty { self = .high }
            else if numbers.count > 1 {
                if wild > 0 { self = .fullHouse }
                else if numbers.firstIndex(of: 3) != nil { self = .fullHouse }
                else { self = .twoPair }
            } else {
                switch numbers.first! + wild {
                case 5: self = .five
                case 4: self = .four
                case 3: self = .three
                case 2: self = .two
                default: self = .five
                }
            }
        }
    }
    struct Hand: Comparable {
        let cards: [Character]
        let bid: Int
        let strength: Strength

        init(cards: [Character], bid: Int) {
            self.cards = cards
            self.bid = bid
            self.strength = Strength(cards)
        }

        static func < (lhs: Self, rhs: Self) -> Bool {
            if lhs.strength == rhs.strength {
                let order = Array("AKQT98765432J")
                for (l, r) in zip(lhs.cards, rhs.cards) {
                    if l == r { continue }
                    return order.firstIndex(of: l)! < order.firstIndex(of: r)!
                }
                return false
            } else {
                return lhs.strength.rawValue < rhs.strength.rawValue
            }
        }
    }

    var hands: [Hand] = []
    contents.enumerateLines { line, _ in
        let parts = line.components(separatedBy: " ")
        let hand = Array(parts[0])
        let bid = Int(parts[1])!
        hands.append(Hand(cards: hand, bid: bid))
    }
    hands = hands.sorted().reversed()

    var total = 0
    for i in hands.indices {
        total += hands[i].bid * (i+1)
    }
    return total
}
