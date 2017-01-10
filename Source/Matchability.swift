import Foundation
import Ferrara

extension Array: Matchable {
    public func match(with object: Any) -> Match {
        guard let otherArray = object as? Array, count == otherArray.count else {
            return .none
        }
        
        var noneCount = 0
        var changeCount = 0
        var equalCount = 0
        
        for (index, element) in self.enumerated() {
            if let element = element as? Matchable {
                switch element.match(with: otherArray[index]) {
                case .equal:
                    equalCount = equalCount + 1
                case .change:
                    changeCount = changeCount + 1
                case .none:
                    noneCount = noneCount + 1
                } // switch
                
                if noneCount > 0 {
                    break // Abort early
                }
            } // if
        } // for
        
        if noneCount > 0 {
            return .none
        }
        else if changeCount > 0 {
            return .change
        }
        else {
            return .equal
        }
    }
}

extension Dictionary: Matchable {
    public func match(with object: Any) -> Match {
        guard let otherDict = object as? Dictionary, count == otherDict.count else
        {
            return .none
        }
        
        var noneCount = 0
        var changeCount = 0
        var equalCount = 0
        
        for (key, value) in self {
            if let value = value as? Matchable {
                if let otherValue = otherDict[key] {
                    switch value.match(with: otherValue) {
                    case .equal:
                        equalCount = equalCount + 1
                    case .change:
                        changeCount = changeCount + 1
                    case .none:
                        noneCount = noneCount + 1
                    } // switch
                }
                else {
                    noneCount = noneCount + 1
                }
                
                if noneCount > 0 {
                    break // Abort early
                }
            } // if
        } // for
        
        if noneCount > 0 {
            return .none
        }
        else if changeCount > 0 {
            return .change
        }
        else {
            return .equal
        }
    }
}

func match(between a: Any?, and b: Any?) -> Match {
    if a == nil && b == nil {
        return .equal
    }
    
    guard let object = a as? Matchable, b != nil else {
        return .none
    }
    
    return object.match(with: b!)
}

func equalityWithMatch(between a: Any?, and b: Any?) -> Bool {
    return match(between: a, and: b) == .equal
}
