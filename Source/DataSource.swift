import Foundation


/// An object compliant to this protocol is able to provide content
protocol DataSource {
    /// Type of content
    associatedtype Content
    
    /// Data source content
    var content: Content? { get set }
}
