//
//  MarkedBase.swift
//  Example
//
//  Created by Marco on 11/01/17.
//  Copyright © 2017 MeLive. All rights reserved.
//

import Foundation
import Ferrara

struct MarkedBase<Base: Equatable, Mark: Equatable>: Equatable, Matchable, CustomStringConvertible
{
    var base: Base
    var mark: Mark
    
    func match(with object: Any) -> Match {
        guard let markedBase = object as? MarkedBase else { return .none }
        
        if base == markedBase.base {
            if mark == markedBase.mark {
                return .equal
            }
            else {
                return .change
            }
        }
        else {
            return .none
        }
    }
    
    init(_ base: Base, _ mark: Mark) {
        self.base = base
        self.mark = mark
    }
    
    var description: String {
        return "\(base)\(mark)"
    }
}
