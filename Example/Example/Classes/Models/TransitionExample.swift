//
//  TransitionExample.swift
//  Example
//
//  Created by Marco on 11/01/17.
//  Copyright © 2017 MeLive. All rights reserved.
//

import Foundation
import Monviso
import Ferrara

struct TransitionExample<T> {
    var name: String
    var from: T
    var to: T
}

extension TransitionExample where T: Section {
    static func defaultSectionExamples(_ sectionCreator: @escaping (String, String) -> T) -> [TransitionExample<[T]>]
    {
        typealias Tr = TransitionExample<[T]>
        
        func section(_ identifier: String, name: String? = nil) -> T {
            return sectionCreator(identifier, name ?? identifier.uppercased())
        }

        return [
            Tr(name: "Insertion",
               from: [section("A"), section("B")],
               to: [section("A"), section("C"), section("B")]),
            Tr(name: "Insertion from empty",
               from: [],
               to: [section("A"), section("B"), section("C")]),
            
            Tr(name: "Deletion",
               from: [section("A"), section("B"), section("C")],
               to: [section("A")]),
            Tr(name: "Deletion to empty",
               from: [section("A"), section("B"), section("C")],
               to: []),
            
            Tr(name: "Reload",
               from: [section("A"), section("B"), section("C")],
               to: [section("A"), section("B", name: "B'"), section("C")]),
            Tr(name: "Movement",
               from: [section("A"), section("B"), section("C")],
               to: [ section("C"), section("A"), section("B")]),
            
            Tr(name: "Insertion + Deletion",
               from: [section("A"), section("B")],
               to: [section("C"), section("B")]),
            Tr(name: "Insertion + Reload",
               from: [section("A"), section("B"), section("C")],
               to: [section("A"), section("B", name: "B'"), section("D"), section("C")]),
            Tr(name: "Insertion + Movement",
               from: [section("A"), section("B"), section("C"), section("D")],
               to: [section("E"), section("C"), section("B"), section("D"), section("F"), section("A")]),
            
            Tr(name: "Deletion + Reload",
               from: [section("A"), section("B"), section("C"), section("D")],
               to: [section("B"), section("D", name: "D'")]),
            Tr(name: "Deletion + Movement",
               from: [section("A"), section("B"), section("C"), section("D"), section("E")],
               to: [section("B"), section("E"), section("C")]),
            
            Tr(name: "Reload + Movement",
               from: [section("A"), section("B"), section("C")],
               to: [section("C"), section("B"), section("A", name: "A'")]),
            
            Tr(name: "Insertion + Deletion + Reload",
               from: [section("A"), section("B"), section("C")],
               to: [section("A"), section("D"), section("B", name: "B'"), section("E")]),
            Tr(name: "Insertion + Deletion + Movement",
               from: [section("A"), section("B"), section("C")],
               to: [section("B"), section("D"), section("A"), section("E")]),
            
            Tr(name: "Deletion + Reload + Movement",
               from: [section("A"), section("B"), section("C"), section("D")],
               to: [section("B"), section("A", name: "A'"), section("D")]),
            
            Tr(name: "Insertion + Deletion + Reload + Movement",
               from: [section("A"), section("B"), section("C")],
               to: [section("B"), section("D"), section("A", name: "A'"), section("E")])
        ]
    }
}
