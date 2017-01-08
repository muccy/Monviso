import Foundation

/// Access an element safely with its index
public protocol IndexSafelyAccessible {
    associatedtype Index
    associatedtype Element
    
    /// Access an element
    ///
    /// - Parameter index: Element index
    /// - Returns: The item at given index
    /// - Throws: AccessError.outOfBounds if index is out of bounds
    func element(at index: Index) throws -> Element
}

public extension IndexSafelyAccessible where
    Self: Collection, Index == Int, Element == Self.Iterator.Element,
    Self.Index == Index, Self.IndexDistance == Int
{
    func element(at index: Index) throws -> Element {
        if index >= 0 && index < count {
            return self[index]
        }
        else {
            throw AccessError.outOfBounds(index: index, validRange: 0..<count)
        }
    }
}

/// Access an element safely with its index path
public protocol IndexPathSafelyAccessible {
    associatedtype SubElement

    /// Access an element
    ///
    /// - Parameter indexPath: Element index path
    /// - Returns: The Element at given index path
    /// - Throws: AccessError.outOfBounds if indexPath is out of bounds
    func element(at indexPath: IndexPath) throws -> SubElement
}

public extension IndexPathSafelyAccessible where
    Self: IndexSafelyAccessible, Self.Element: IndexSafelyAccessible,
    Self.Index == IndexPath.Index, Self.Element.Index == IndexPath.Index,
    SubElement == Self.Element.Element
{
    func element(at indexPath: IndexPath) throws -> SubElement {
        let firstLevelElement = try self.element(at: indexPath.section)
        return try firstLevelElement.element(at: indexPath.item)
    }
}
