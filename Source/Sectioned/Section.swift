import Foundation
import Ferrara

public protocol Section: IndexSafelyAccessible {
    associatedtype Items: Collection
    var items: Items { get }
}

public protocol MutableSection: Section {
    var items: Items { get set }
}

public extension Section {
    public func item(at index: Index) throws -> Element {
        return try element(at: index)
    }
}

public extension Section where
    Items.Index == Int, Items.IndexDistance == Int
{
    func element(at index: Items.Index) throws -> Items.Iterator.Element
    {
        if index >= 0 && index < items.count {
            return items[index]
        }
        else {
            throw AccessError.outOfBounds(index: index, validRange: 0..<items.count)
        }

    }
}

// MARK: -

public protocol SectionContainer: IndexSafelyAccessible, IndexPathSafelyAccessible
{
    associatedtype Sections: Collection
    var sections: Sections { get }
}

public protocol MutableSectionContainer: SectionContainer {
    var sections: Sections { get set }
}

public extension SectionContainer where Element: Section {
    public func section(at index: Index) throws -> Element {
        return try element(at: index)
    }
    
    public func item(at indexPath: IndexPath) throws -> SubElement {
        return try element(at: indexPath)
    }
}

public extension SectionContainer where
    Sections.Index == IndexPath.Index, Sections.IndexDistance == IndexPath.Index
{
    func element(at index: Sections.Index) throws -> Sections.Iterator.Element
    {
        if index >= 0 && index < sections.count {
            return sections[index]
        }
        else {
            throw AccessError.outOfBounds(index: index, validRange: 0..<sections.count)
        }
    }
}

public extension SectionContainer where
    Sections.Index == IndexPath.Index, Sections.IndexDistance == IndexPath.Index,
    Sections.Iterator.Element: IndexSafelyAccessible, Sections.Iterator.Element.Index == IndexPath.Index
{
    func element(at indexPath: IndexPath) throws -> Sections.Iterator.Element.Element
    {
        let firstLevelElement = try self.element(at: indexPath.section)
        return try firstLevelElement.element(at: indexPath.item)
    }
}

public extension MutableSectionContainer where
    Sections: RangeReplaceableCollection, Sections.Iterator.Element == Element, Element: MutableSection,
    Element.Items: RangeReplaceableCollection, Sections.Index == Index,
    Index == IndexPath.Index, Element.Items.Index == Index,
    SubElement == Element.Items.Iterator.Element
{
    public mutating func move(itemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) throws
    {
        var sourceSection = try section(at: sourceIndexPath.section)
        let item = try self.item(at: sourceIndexPath)
        sourceSection.items.remove(at: sourceIndexPath.item)
        
        var destinationSection = try section(at: destinationIndexPath.section)
        destinationSection.items.insert(item, at: destinationIndexPath.item)
        
        sections.remove(at: sourceIndexPath.section)
        sections.insert(sourceSection, at: sourceIndexPath.section)
        
        sections.remove(at: destinationIndexPath.section)
        sections.insert(destinationSection, at: destinationIndexPath.section)
    }
}
