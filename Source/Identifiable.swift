import Foundation

/// The ability to be identified through modifications
public protocol Identifiable {
    /// The identifier which remains the same through modifications
    var identifier: AnyHashable? { get }
}
