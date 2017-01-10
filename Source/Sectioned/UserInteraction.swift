import UIKit

/// A step of user interaction on content
public protocol UserInteractionStep {
    associatedtype Content
    
    /// Content manipulated by user interaction
    var content: Content { get }
}

/// Ability to handle user interaction
public protocol UserInteractionHandling {
    associatedtype Attempt: UserInteractionStep
    associatedtype Commit: UserInteractionStep
    
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
    /// - Throws: If there is an error during commit
    func apply(userInteraction commit: Commit) throws
}

/// Move attempt
public struct MoveAttempt<Location, Content>: UserInteractionStep {
    public let from: Location
    public let content: Content
    
    public init(from: Location, with content: Content) {
        self.from = from
        self.content = content
    }
}

/// Move commit
public struct MoveCommit<Location, Content>: UserInteractionStep {
    public let from: Location
    public let to: Location
    public let content: Content
    
    public init(from: Location, to: Location, with content: Content) {
        self.from = from
        self.to = to
        self.content = content
    }
}

/// Edit user interaction attempt
public struct EditAttempt<Location, Content>: UserInteractionStep {
    /// Where edit is requested
    public let at: Location
    public let content: Content
    
    public init(at: Location, with content: Content) {
        self.at = at
        self.content = content
    }
}

/// Edit user interaction commit
public struct EditCommit<Location, Style, Content, Client>: UserInteractionStep {
    /// Where edit is committed
    public let at: Location
    /// Style of commit
    public let style: Style
    public let content: Content
    public let client: Client
    
    public init(at: Location, style: Style, with content: Content, in client: Client) {
        self.at = at
        self.style = style
        self.content = content
        self.client = client
    }
}

/// Concrete user interaction handler
public struct UserInteractionHandler<Attempt: UserInteractionStep, Commit: UserInteractionStep>: UserInteractionHandling
{
    /// Attempt closure type
    public typealias AttemptTest = (Attempt) -> Bool
    
    /// Commit maker closure type
    public typealias Maker = (Commit) throws -> Void
    
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
    
    public func apply(userInteraction commit: Commit) throws {
        try maker(commit)
    }
}
