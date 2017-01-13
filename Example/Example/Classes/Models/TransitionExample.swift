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
    private typealias Tr = TransitionExample<[T]>
    
    static func defaultSectionExamples(_ sectionCreator: @escaping (String, String) -> T) -> [TransitionExample<[T]>]
    {
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
    
    static func defaultRowExamples(_ sectionCreator: @escaping (String, String, [Any]) -> T) -> [TransitionExample<[T]>]
    {
        func section(_ identifier: String, name: String? = nil, items: [Any] = []) -> T
        {
            return sectionCreator(identifier, name ?? identifier.uppercased(), items)
        }
        
        func oneSection(_ items: [Any]) -> [T] {
            return [ section("a", name: nil, items: items) ]
        }
        
        return [
            Tr(name: "Insertion",
               from: oneSection(["a", "b"]),
               to: oneSection(["a", "c", "b"])),
            Tr(name: "Insertion (with section reload)",
               from: [ section("a", items: ["a", "b"]) ],
               to: [ section("a", name: "A'", items: ["a", "c", "b"]) ]),
            Tr(name: "Insertion (with section movement)",
               from: [ section("a", items: ["a", "b"]), section("b") ],
               to: [ section("b"), section("a", items: ["a", "c", "b"]) ]),
            
            Tr(name: "Deletion",
               from: oneSection(["a", "b", "c"]),
               to: oneSection(["a", "c"])),
            Tr(name: "Deletion (with section reload)",
               from: [ section("a", items: ["a", "b", "c"]) ],
               to: [ section("a", name: "A'", items: ["a", "c"]) ]),
            Tr(name: "Deletion (with section movement)",
               from: [ section("a", items: ["a", "b", "c"]), section("b") ],
               to: [ section("b"), section("a", items: ["a", "c"]) ]),
            
            Tr(name: "Reload",
               from: oneSection(["a", MarkedBase("b", ""), "c"]),
               to: oneSection(["a", MarkedBase("b", "'"), "c"])),
            Tr(name: "Reload (with section reload)",
               from: [ section("a", items: ["a", MarkedBase("b", ""), "c"]) ],
               to: [ section("a", name: "A'", items: ["a", MarkedBase("b", "'"), "c"]) ]),
            Tr(name: "Reload (with section movement)",
               from: [ section("a", items: ["a", MarkedBase("b", ""), "c"]), section("b") ],
               to: [ section("b"), section("a", items: ["a", MarkedBase("b", "'"), "c"]) ]),
            
            Tr(name: "Movement",
               from: oneSection(["a", "b", "c", "d"]),
               to: oneSection(["c", "a", "d", "b"])),
            Tr(name: "Movement between sections",
               from: [ section("a", items: ["a", "b"]), section("b", items: ["c", "d", "e", "f"]) ],
               to: [ section("a", items: ["c", "b", "f", "d"]), section("b", items: ["a", "e"]) ]),
            Tr(name: "Movement (with section reload)",
               from: [ section("a", items: ["a", "b", "c", "d"]) ],
               to: [ section("a", name: "A'", items: ["c", "a", "d", "b"]) ]),
            Tr(name: "Movement (with section movement)",
               from: [ section("a", items: ["a", "b"]), section("b", items: ["c", "d"]), section("c", items: ["e", "f"]) ],
               to: [ section("a", items: ["b"]), section("c", items: ["e", "f"]), section("b", items: ["c", "a", "d"]) ]),
            Tr(name: "Movement to inserted section",
               from: [ section("a", items: ["a", "b"]) ],
               to: [ section("a", items: ["b"]), section("b", items: ["c", "a"]) ]),
            Tr(name: "Movement from deleted section",
               from: [ section("a", items: ["a", "b"]), section("b", items: ["c"]) ],
               to: [ section("b", items: ["c", "a"]) ]),
            
            Tr(name: "Insertion + Deletion",
               from: oneSection(["a", "b"]),
               to: oneSection(["c", "b"])),
            Tr(name: "Insertion + Reload",
               from: oneSection(["a", MarkedBase("b", "")]),
               to: oneSection(["c", "d", "a", "e", MarkedBase("b", "'"), "f"])),
            Tr(name: "Insertion + Movement",
               from: oneSection(["a", "b", "c", "d"]),
               to: oneSection(["e", "c", "b", "d", "f", "a"])),
            
            Tr(name: "Deletion + Reload",
               from: oneSection(["a", "b", "c", MarkedBase("d", "")]),
               to: oneSection(["b", MarkedBase("d", "'")])),
            Tr(name: "Deletion + Movement",
               from: oneSection(["a", "b", "c", "d", "e"]),
               to: oneSection(["b", "e", "c"])),
            
            Tr(name: "Reload + Movement",
               from: oneSection([MarkedBase("a", ""), "b", "c"]),
               to: oneSection(["c", "b", MarkedBase("a", "'")])),
            
            Tr(name: "Insertion + Deletion + Reload",
               from: oneSection(["a", MarkedBase("b", ""), "c"]),
               to: oneSection(["a", "d", MarkedBase("b", "'"), "e"])),
            Tr(name: "Insertion + Deletion + Movement",
               from: oneSection(["a", "b", "c"]),
               to: oneSection(["b", "d", "a", "e"])),
            Tr(name: "Deletion + Reload + Movement",
               from: oneSection([MarkedBase("a", ""), "b", "c", "d"]),
               to: oneSection(["b", MarkedBase("a", "'"), "d"])),
            Tr(name: "Insertion + Deletion + Reload + Movement",
               from: oneSection([MarkedBase("a", ""), "b", "c"]),
               to: oneSection(["b", "d", MarkedBase("a", "'"), "e"]))
        ]
    }
}
