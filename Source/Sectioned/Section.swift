import Foundation
import Ferrara

/// Section of items
public protocol Section: IndexSafelyAccessible {
    associatedtype Items: Collection
    var items: Items { get }
}

/// Mutable section of items
public protocol MutableSection: Section {
    var items: Items { get set }
}

public extension Section {
    /// Access to item
    ///
    /// - Parameter index: Item index
    /// - Returns: Item at given index
    /// - Throws: AccessError.outOfBounds when index is out of bounds
    public func item(at index: Index) throws -> Element {
        return try element(at: index)
    }
}

// Conformance to IndexSafelyAccessible
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

/// Container of sections
public protocol SectionContainer: IndexSafelyAccessible, IndexPathSafelyAccessible
{
    associatedtype Sections: Collection
    var sections: Sections { get }
}

/// Mutable container of sections
public protocol MutableSectionContainer: SectionContainer {
    var sections: Sections { get set }
}

public extension SectionContainer where Element: Section {
    /// Access to section
    ///
    /// - Parameter index: Section index
    /// - Returns: Section at given index
    /// - Throws: AccessError.outOfBounds when index is out of bounds
    public func section(at index: Index) throws -> Element {
        return try element(at: index)
    }
    
    /// Access to item
    ///
    /// - Parameter indexPath: Item index path
    /// - Returns: Item at given index path
    /// - Throws: AccessError.outOfBounds when index path is out of bounds
    public func item(at indexPath: IndexPath) throws -> SubElement {
        return try element(at: indexPath)
    }
}

public extension SectionContainer where Element: Section, Sections.Iterator.Element == Element, Sections.Index == IndexPath.Index
{
    /// Find section index with a closure
    ///
    /// - Parameter test: Closure which perform test of sections
    /// - Returns: Section index if found
    public func indexOfSection(where test: (Sections.Index, Element) -> (passed: Bool, stop: Bool)) -> Sections.Index?
    {
        for (index, section) in sections.enumerated() {
            let result = test(index, section)
            if result.passed == true, result.stop == true {
                return index
            }
            else if result.stop == true {
                return nil
            }
        } // for
        
        return nil
    }
}

public extension SectionContainer where Element: Section & Identifiable, Sections.Iterator.Element == Element, Sections.Index == IndexPath.Index
{
    /// Find section index via identifier
    ///
    /// - Parameter identifier: Section identifier to use to find section
    /// - Returns: Section index if found
    public func indexOfSection(with identifier: Element.Identifier) -> Sections.Index?
    {
        return indexOfSection(where: { _, section in
            if identifier == section.identifier {
                return (passed: true, stop: true)
            }
            else {
                return (passed: false, stop: false)
            }
        })
    }
}

// Conformance to IndexSafelyAccessible
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

// Conformance to IndexPathSafelyAccessible
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

public extension SectionContainer where
    Sections.Index == IndexPath.Index, Sections.IndexDistance == IndexPath.Index,
    Element: Section, SubElement == Element.Items.Iterator.Element,
    Sections.Iterator.Element == Element, Element.Items.Iterator.Element == SubElement
{
    /// Find item index path with a closure
    ///
    /// - Parameter test: Closure which perform test of items
    /// - Returns: Item index path if found
    public func indexPathOfItem(where test: (IndexPath, SubElement) -> (passed: Bool, stop: Bool)) -> IndexPath?
    {
        for (sectionIndex, section) in sections.enumerated() {
            for (itemIndex, item) in section.items.enumerated() {
                let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                let result = test(indexPath, item)
                
                if result.passed == true, result.stop == true {
                    return indexPath
                }
                else if result.stop == true {
                    return nil
                }
            } // for
        } // for
        
        return nil
    }
    
    /// Find item index path
    ///
    /// - Parameters:
    ///   - itemToFind: Item to be searched
    ///   - evenIfChanged: If true, find is accomplished including changes, not only complete matches
    /// - Returns: Item index path if found
    public func indexPathOfItem(_ itemToFind: SubElement, evenIfChanged: Bool = true) -> IndexPath?
    {
        return indexPathOfItem(where: { indexPath, item in
            switch match(between: itemToFind, and: item) {
            case .equal:
                return (passed: true, stop: true)
            case .change:
                return (passed: evenIfChanged, stop: evenIfChanged)
            case .none:
                return (passed: false, stop: false)
            } // switch
        })
    }
}

public extension MutableSectionContainer where
    Sections: RangeReplaceableCollection, Sections.Iterator.Element == Element, Element: MutableSection,
    Element.Items: RangeReplaceableCollection, Sections.Index == Index,
    Index == IndexPath.Index, Element.Items.Index == Index,
    SubElement == Element.Items.Iterator.Element
{
    /// Move an item through sections
    ///
    /// - Parameters:
    ///   - sourceIndexPath: Source item index path
    ///   - destinationIndexPath: Destination index path
    /// - Throws: AccessError.outOfBounds when any index path is out of bounds
    public mutating func moveItem(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) throws
    {
        var sourceSection = try section(at: sourceIndexPath.section)
        let item = try self.item(at: sourceIndexPath)
        sourceSection.items.remove(at: sourceIndexPath.item)
        sections.remove(at: sourceIndexPath.section)
        sections.insert(sourceSection, at: sourceIndexPath.section)
        
        var destinationSection = try section(at: destinationIndexPath.section)
        destinationSection.items.insert(item, at: destinationIndexPath.item)
        sections.remove(at: destinationIndexPath.section)
        sections.insert(destinationSection, at: destinationIndexPath.section)
    }
}
