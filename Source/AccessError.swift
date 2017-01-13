import Foundation

/// Error accessing data
///
/// - outOfBounds: The requested index is out of bounds
/// - noUI: There is no UI for requested item
/// - invalidInput: Given input is not valid
/// - invalidOutput: Returned output is not valid
public enum AccessError: Error {
    case outOfBounds(index: Int, validRange: Range<Int>)
    case noUI(for: Any)
    case invalidInput(Any)
    case invalidOutput(Any?)
}

// MARK: - Conversion to string
extension AccessError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .outOfBounds(let index, let validRange):
            return "\(index) is out of bounds (\(validRange))"
        case .noUI(let object):
            return "No UI for object \(object)"
        case .invalidInput(let object):
            return "Invalid input \(object)"
        case .invalidOutput(let object):
            return "Invalid output \(object)"
        }
    }
}
