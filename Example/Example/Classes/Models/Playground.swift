//
//  Playground.swift
//  Example
//
//  Created by Marco on 12/01/17.
//  Copyright © 2017 MeLive. All rights reserved.
//

import Foundation
import Ferrara
import Monviso

enum Playground {
    enum Command: String, Matchable, Equatable {
        case addRow = "Add Row"
        
        static func ==(lhs: Command, rhs: Command) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }
    
    static func defaultSections<S: Section>(_ creator: (String, String?, [Any]) -> S) -> [S]
    {
        return [
            creator("commands", nil, [ Command.addRow ]),
            creator("a", "A", ["a", "b", "c"]),
            creator("b", "B", ["d", "e", "f"]),
            creator("c", "C", ["g", "h", "i"])
        ]
    }
}
