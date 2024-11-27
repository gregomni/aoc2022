//
//  Aplenty.swift
//  aoc
//
//  Created by Greg Titus on 12/19/23.
//

import Foundation

func aplenty(_ contents: String) -> Int {
    enum Category: Character {
        case x = "x"
        case m = "m"
        case a = "a"
        case s = "s"
    }
    struct Rule {
        let category: Category
        let operationLT: Bool
        let value: Int
        let destination: String

        init(category: Category, operationLT: Bool, value: Int, destination: String) {
            self.category = category
            self.operationLT = operationLT
            self.value = value
            self.destination = destination
        }

        init(_ s: String) {
            let match = s.firstMatch(of: /(.)(.)(.*):(.*)/)!
            category = Category(rawValue: match.1.first!)!
            operationLT = match.2 == "<"
            value = Int(String(match.3))!
            destination = String(match.4)
        }
    }
    struct Workflow {
        let name: String
        let rules: [Rule]
        let other: String

        init(_ s: String) {
            let match = s.firstMatch(of: /(.*){(.*)}/)!
            self.name = String(match.1)
            let ruleStrings = match.2.components(separatedBy: ",")
            self.other = String(ruleStrings.last!)
            self.rules = ruleStrings.dropLast().map { Rule($0) }
        }
    }
    struct Part {
        let x: Int
        let m: Int
        let a: Int
        let s: Int

        subscript(c: Category) -> Int {
            get {
                switch c {
                case .x: return x
                case .m: return m
                case .a: return a
                case .s: return s
                }
            }
        }
    }

    var workflows: [String : Workflow] = [:]
    var parts: [Part] = []
    let lines = contents.components(separatedBy: "\n")
    var readingFlows = true
    for line in lines {
        if line.isEmpty {
            readingFlows = false
        } else if readingFlows {
            let wf = Workflow(line)
            workflows[wf.name] = wf
        } else {
            let match = line.firstMatch(of: /{x=(.*),m=(.*),a=(.*),s=(.*)}/)!
            parts.append(Part(x: Int(String(match.1))!, m: Int(String(match.2))!, a: Int(String(match.3))!, s: Int(String(match.4))!))
        }
    }

    /* PART 1
    var total = 0
    for part in parts {
        var workflowName = "in"
        while workflowName != "A" && workflowName != "R" {
            let flow = workflows[workflowName]!
            for r in flow.rules {
                let n = part[r.category]
                if (r.operationLT && n < r.value) || (!r.operationLT && n > r.value) {
                    workflowName = r.destination
                    break
                }
            }
            if workflowName == flow.name {
                workflowName = flow.other
            }
        }
        if workflowName == "A" {
            total += part.x + part.m + part.a + part.s
        }
    }
    return total
     */

    struct Conditions {
        var x: ClosedRange<Int> = 1 ... 4000
        var m: ClosedRange<Int> = 1 ... 4000
        var a: ClosedRange<Int> = 1 ... 4000
        var s: ClosedRange<Int> = 1 ... 4000

        subscript(_ c: Category) -> ClosedRange<Int> {
            get {
                switch c {
                case .x: return x
                case .m: return m
                case .a: return a
                case .s: return s
                }
            }
            set {
                switch c {
                case .x: x = newValue
                case .m: m = newValue
                case .a: a = newValue
                case .s: s = newValue
                }
            }
        }

        mutating func addMatch(_ rule: Rule) -> Bool {
            let r = self[rule.category]
            var newRange: ClosedRange<Int>
            if rule.operationLT {
                if r.lowerBound >= rule.value {
                    return false
                } else if r.upperBound >= rule.value {
                    newRange = r.lowerBound ... rule.value-1
                } else {
                    newRange = r
                }
            } else {
                if r.upperBound <= rule.value {
                    return false
                } else if r.lowerBound <= rule.value {
                    newRange = rule.value+1 ... r.upperBound
                } else {
                    newRange = r
                }
            }
            self[rule.category] = newRange
            return true
        }

        mutating func addNonMatch(_ rule: Rule) -> Bool {
            return addMatch(Rule(category: rule.category, operationLT: !rule.operationLT, value: rule.operationLT ? rule.value-1 : rule.value+1, destination: rule.destination))
        }

        func inhabitants() -> Int {
            return x.count * m.count * a.count * s.count
        }
    }

    func runthroughConditions(_ conditions: Conditions, wfName: String) -> Int {
        if wfName == "R" { return 0 }
        if wfName == "A" {
            return conditions.inhabitants()
        }

        var total = 0
        let flow = workflows[wfName]!
        var current = conditions
        for r in flow.rules {
            var follow = current
            if follow.addMatch(r) {
                total += runthroughConditions(follow, wfName: r.destination)
            }
            if !current.addNonMatch(r) {
                return total
            }
        }
        total += runthroughConditions(current, wfName: flow.other)
        return total
    }

    return runthroughConditions(Conditions(), wfName: "in")
}
