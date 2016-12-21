import UIKit

/// Ability to handle user interaction
public protocol UserInteractionHandling {
    associatedtype Attempt
    associatedtype Commit
    associatedtype Content
    
    /// Check if attempt could be made
    ///
    /// - Parameter attempt: The attempt to check
    /// - Returns: true if attempt could be made
    func allows(userInteraction attempt: Attempt) -> Bool
    
    /// Commit user interaction
    ///
    /// - Parameters:
    ///   - commit: The commit to make
    ///   - content: Content to change
    /// - Returns: New content
    /// - Throws: If there is an error during commit
    func commit(userInteraction commit: Commit, with content: Content) throws -> Content
}

/// Move user interaction attempt
public protocol MoveAttemptProtocol {
    associatedtype Location
    
    /// Where move starts
    var from: Location { get }
}

/// Move user interaction commit
public protocol MoveCommitProtocol {
    associatedtype Location
    
    /// Where move starts
    var from: Location { get }
    
    /// Where move ends
    var to: Location { get }
}

/// Concrete move attempt
public struct MoveAttempt<Location>: MoveAttemptProtocol {
    public let from: Location
    
    public init(from: Location) {
        self.from = from
    }
}

/// Concrete move commit
public struct MoveCommit<Location>: MoveCommitProtocol {
    public let from: Location
    public let to: Location
    
    public init(from: Location, to: Location) {
        self.from = from
        self.to = to
    }
}


/// Concrete edit user interaction attempt
public struct EditAttempt<Location> {
    /// Where edit is requested
    public let at: Location
    
    public init(at: Location) {
        self.at = at
    }
}

/// Concrete edit user interaction commit
public struct EditCommit<Location, Style> {
    /// Where edit is committed
    public let at: Location
    /// Style of commit
    public let style: Style
    
    public init(at: Location, style: Style) {
        self.at = at
        self.style = style
    }
}

/// Concrete user interaction handler
public struct UserInteractionHandler<Content, Attempt, Commit>: UserInteractionHandling
{
    /// Attempt closure type
    public typealias AttemptTest = (Attempt) -> Bool
    
    /// Commit closure type
    public typealias Maker = (Commit, Content) throws -> Content
    
    /// Check if attempt could be made
    public var attemptTest: AttemptTest
    
    /// Perform commit
    public var maker: Maker
    
    public init(_ attemptTest: @escaping AttemptTest, maker: @escaping Maker) {
        self.attemptTest = attemptTest
        self.maker = maker
    }
    
    public func allows(userInteraction attempt: Attempt) -> Bool {
        return attemptTest(attempt)
    }
    
    public func commit(userInteraction commit: Commit, with content: Content) throws -> Content
    {
        return try maker(commit, content)
    }
}


// MARK: - User interaction handler like UserInteractionHandler<Section, _, MoveCommit>
extension UserInteractionHandler where
    Content: RangeReplaceableCollection, Content.Iterator.Element: MutableSectionProtocol, Content.Index == Int, Content.IndexDistance == Int,
    Content.Iterator.Element.Items: RangeReplaceableCollection, Content.Iterator.Element.Items.Index == Int, Content.Iterator.Element.Items.IndexDistance == Int,
    Commit: MoveCommitProtocol, Commit.Location == IndexPath
{
    /// Default maker factory
    ///
    /// - Returns: Default maker
    public static func standardMaker() -> Maker
    {
        return { commit, content in
            var sourceSection = try content.section(at: commit.from.section)
            let item = try sourceSection.item(at: commit.from.row)
            sourceSection.items.remove(at: commit.from.item)
            
            var destinationSection = try content.section(at: commit.to.section)
            destinationSection.items.insert(item, at: commit.to.item)
            
            var sections = content
            sections.remove(at: commit.from.section)
            sections.insert(sourceSection, at: commit.from.section)
            
            sections.remove(at: commit.to.section)
            sections.insert(destinationSection, at: commit.to.section)
            
            return sections
        }
    }

}
