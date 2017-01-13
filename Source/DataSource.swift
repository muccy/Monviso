/// The ability to provide content
public protocol DataSource {
    /// Type of content
    associatedtype Content
    
    /// Data source content
    var content: Content { get }
}
