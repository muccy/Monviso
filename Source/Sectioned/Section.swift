import Foundation

/// The representation of a section of content in a sectioned view
public protocol SectionProtocol: Identifiable {
    /// How the items are stored inside the section
    associatedtype Items: Collection
    
    /// Type of header
    associatedtype Header
    
    /// The of footer
    associatedtype Footer
    
    /// Items contained inside section
    var items: Items { get }
    
    /// Header of section
    var header: Header? { get }
    
    /// Footer of section
    var footer: Footer? { get }
}

/// Mutable version of SectionProtocol
public protocol MutableSectionProtocol: SectionProtocol {
    var items: Items { get set}
    var header: Header? { get set }
    var footer: Footer? { get set }
}

// MARK: - A section of items accessible via an Int index (e.g.: items is an array)
extension SectionProtocol where Items.Index == Int, Items.IndexDistance == Int {
    /// Access to item
    ///
    /// - Parameter index: Item index
    /// - Returns: The item at given index
    /// - Throws: AccessError.outOfBounds if index is out of bounds
    func item(at index: Items.Index) throws -> Items.Iterator.Element {
        if index >= 0 && index < self.items.count {
            return self.items[index]
        }
        else {
            throw AccessError.outOfBounds(index: index, validRange: 0..<self.items.count)
        }
    }
}

// MARK: - Collection containing sections
extension Collection where Iterator.Element: SectionProtocol, Index == Int, IndexDistance == Int
{
    /// Access a section
    ///
    /// - Parameter index: Section index
    /// - Returns: Section at given index
    /// - Throws: AccessError.outOfBounds if index is out of bounds
    func section(at index: Index) throws -> Iterator.Element {
        if index >= 0 && index < count {
            return self[index]
        }
        else {
            throw AccessError.outOfBounds(index: index, validRange: 0..<count)
        }
    }
}

// MARK: - Data source containing a collection of sections
extension DataSource where
    Content: Collection,
    Content.Index == Int,
    Content.IndexDistance == Int,
    Content.Iterator.Element: SectionProtocol,
    Content.Iterator.Element.Items: Collection,
    Content.Iterator.Element.Items.Index == Int,
    Content.Iterator.Element.Items.IndexDistance == Int
{
    typealias Section = Content.Iterator.Element
    typealias Item = Section.Items.Iterator.Element
    
    /// Access an item
    ///
    /// - Parameter indexPath: Item index path
    /// - Returns: Item at given index path
    /// - Throws: AccessError.outOfBounds if index path is out of bounds
    func item(at indexPath: IndexPath) throws -> Item {
        let section = try content.section(at: indexPath.section)
        return try section.item(at: indexPath.item)
    }
}

/// Concrete section struct
public struct Section<Item>: MutableSectionProtocol {
    public var identifier: AnyHashable?
    public var items: [Item]
    public var header: Any?
    public var footer: Any?
    
    public init(items: [Item]) {
        self.items = items
    }
}
