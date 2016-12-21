import Foundation

/// The ability to provide UI for an item
public protocol ItemUIProviding {
    /// Item type
    associatedtype Item
    /// Where item is located
    associatedtype Location
    /// Who performs the request
    associatedtype Client
    /// Which product is created
    associatedtype Product

    /// Build UI
    ///
    /// - Parameters:
    ///   - item: Item which needs UI
    ///   - location: Where item is located
    ///   - client: Who requires UI for item
    /// - Returns: UI element which represents item
    /// - Throws: AccessError.noUI if UI could not be produced
    func UIElement(for item: Item, at location: Location, for client: Client) throws -> Product
}

/// Concrete UI factory
public struct ItemUIFactory<Item, Location, Client, Product>: ItemUIProviding {
    /// Creator of UI
    /// - Throws: AccessError.noUI if UI could not be produced
    public typealias Creator = (Item, Location, Client) throws -> Product
    
    /// A closure which produces UI
    public let creator: Creator
    
    public init(creator: @escaping Creator) {
        self.creator = creator
    }
    
    public func UIElement(for item: Item, at location: Location, for client: Client) throws -> Product
    {
        return try creator(item, location, client)
    }
}

public typealias TableViewCellFactory<Item, Cell: UITableViewCell> = ItemUIFactory<Item, IndexPath, UITableView, Cell>
