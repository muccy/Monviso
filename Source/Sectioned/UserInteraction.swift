import UIKit

public protocol UserInteractionAttempt {
    associatedtype Content
    
    /// Content as user interaction is attempted
    var content: Content { get }
}

public protocol UserInteractionCommit {
    associatedtype Content
    
    /// Content to affect with user interaction
    var content: Content { get }
}

/// Ability to handle user interaction
public protocol UserInteractionHandling {
    associatedtype Attempt: UserInteractionAttempt
    associatedtype Commit: UserInteractionCommit
    
    /// Check if attempt could be made
    ///
    /// - Parameters:
    ///   - attempt: The attempt to check
    /// - Returns: true if attempt could be made
    func allows(userInteraction attempt: Attempt) -> Bool
    
    /// Commit user interaction
    ///
    /// - Parameters:
    ///   - commit: The commit to make
    /// - Returns: New content
    /// - Throws: If there is an error during commit
    func content(applyingUserInteraction commit: Commit) throws -> Commit.Content
}

/// Move user interaction attempt
public protocol MoveAttemptProtocol: UserInteractionAttempt {
    associatedtype Location
    
    /// Where move starts
    var from: Location { get }
}

/// Move user interaction commit
public protocol MoveCommitProtocol: UserInteractionCommit {
    associatedtype Location
    
    /// Where move starts
    var from: Location { get }
    
    /// Where move ends
    var to: Location { get }
}

/// Concrete move attempt
public struct MoveAttempt<Location, Content>: MoveAttemptProtocol {
    public let from: Location
    public let content: Content
    
    public init(from: Location, with content: Content) {
        self.from = from
        self.content = content
    }
}

/// Concrete move commit
public struct MoveCommit<Location, Content>: MoveCommitProtocol {
    public let from: Location
    public let to: Location
    public let content: Content
    
    public init(from: Location, to: Location, with content: Content) {
        self.from = from
        self.to = to
        self.content = content
    }
}


/// Concrete edit user interaction attempt
public struct EditAttempt<Location, Content>: UserInteractionAttempt {
    /// Where edit is requested
    public let at: Location
    public let content: Content
    
    public init(at: Location, with content: Content) {
        self.at = at
        self.content = content
    }
}

/// Concrete edit user interaction commit
public struct EditCommit<Location, Style, Content>: UserInteractionCommit {
    /// Where edit is committed
    public let at: Location
    /// Style of commit
    public let style: Style
    public let content: Content
    
    public init(at: Location, style: Style, with content: Content) {
        self.at = at
        self.style = style
        self.content = content
    }
}

/// Concrete user interaction handler
public struct UserInteractionHandler<Attempt: UserInteractionAttempt, Commit: UserInteractionCommit>: UserInteractionHandling
{
    /// Attempt closure type
    public typealias AttemptTest = (Attempt) -> Bool
    
    /// Commit closure type
    public typealias Maker = (Commit) throws -> Commit.Content
    
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
    
    public func content(applyingUserInteraction commit: Commit) throws -> Commit.Content
    {
        return try maker(commit)
    }
}


// MARK: - User interaction handler like UserInteractionHandler<Section, _, MoveCommit>
extension UserInteractionHandler where
    Commit.Content: RangeReplaceableCollection, Commit.Content.Iterator.Element: MutableSectionProtocol, Commit.Content.Index == Int, Commit.Content.IndexDistance == Int,
    Commit.Content.Iterator.Element.Items: RangeReplaceableCollection, Commit.Content.Iterator.Element.Items.Index == Int, Commit.Content.Iterator.Element.Items.IndexDistance == Int,
    Commit: MoveCommitProtocol, Commit.Location == IndexPath
{
    /// Default maker factory
    ///
    /// - Returns: Default maker
    public static func standardMaker() -> Maker
    {
        return { commit in
            var sourceSection = try commit.content.section(at: commit.from.section)
            let item = try sourceSection.item(at: commit.from.row)
            sourceSection.items.remove(at: commit.from.item)
            
            var destinationSection = try commit.content.section(at: commit.to.section)
            destinationSection.items.insert(item, at: commit.to.item)
            
            var sections = commit.content
            sections.remove(at: commit.from.section)
            sections.insert(sourceSection, at: commit.from.section)
            
            sections.remove(at: commit.to.section)
            sections.insert(destinationSection, at: commit.to.section)
            
            return sections
        }
    }

}
