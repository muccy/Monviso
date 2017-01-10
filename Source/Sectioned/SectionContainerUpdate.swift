import Foundation
import Ferrara

/// Movement from a location to another location inside section container
public struct SectionContainerUpdateMovement<Location: Hashable>: Hashable, CustomDebugStringConvertible
{
    /// Source
    public var from: Location
    /// Destination
    public var to: Location
    
    public var hashValue: Int {
        return 158875 ^ from.hashValue ^ to.hashValue
    }
    
    public static func ==(lhs: SectionContainerUpdateMovement, rhs: SectionContainerUpdateMovement) -> Bool
    {
        return lhs.from == rhs.from && lhs.to == rhs.to
    }
    
    public var debugDescription: String {
        return "\(from) -> \(to)"
    }
}

/// Update from a section container to another
public struct SectionContainerUpdate: CustomDebugStringConvertible {
    /// Sections movements
    public var sectionMovements: Set<SectionContainerUpdateMovement<Int>>
    /// Indexes of inserted sections
    public var insertedSections: IndexSet
    /// Indexes of deleted sections
    public var deletedSections: IndexSet
    /// Indexes of reloaded sections (in destination container)
    public var reloadedSections: IndexSet
    
    /// Index paths of inserted items
    public var insertedItems: Set<IndexPath>
    /// Index paths of deleted items
    public var deletedItems: Set<IndexPath>
    /// Index paths of reloaded items (in destination container)
    public var reloadedItems: Set<IndexPath>
    /// Item movements
    public var itemMovements: Set<SectionContainerUpdateMovement<IndexPath>>
    
    /// true if update affects sections
    public var affectsSections: Bool {
        return insertedSections.count > 0 || deletedSections.count > 0 ||
            reloadedSections.count > 0 || sectionMovements.count > 0
    }
    
    /// true if update affects items
    public var affectsItems: Bool {
        return insertedItems.count > 0 || deletedItems.count > 0 ||
                reloadedItems.count > 0 || itemMovements.count > 0
    }
    
    /// true if no update has occurred
    public var empty: Bool {
        return affectsSections == false && affectsItems == false
    }
    
    public var debugDescription: String {
        func line(_ title: String, _ object: CustomDebugStringConvertible) -> String {
            return "\n\(title): \(object)"
        }
        
        var string = ""
        
        if (affectsSections) {
            string.append("SECTIONS\n========")
            
            if insertedSections.count > 0 {
                string.append(line("Inserted", insertedSections))
            }
            
            if deletedSections.count > 0 {
                string.append(line("Deleted", deletedSections))
            }
            
            if reloadedSections.count > 0 {
                string.append(line("Reloaded", reloadedSections))
            }
            
            if sectionMovements.count > 0 {
                string.append(line("Movements", sectionMovements))
            }
        }
        
        if (affectsItems) {
            if string.characters.count > 0 {
                string.append("\n\n")
            }
            
            string.append("ITEMS\n=====")
            
            if insertedItems.count > 0 {
                string.append(line("Inserted", insertedItems))
            }
            
            if deletedItems.count > 0 {
                string.append(line("Deleted", deletedItems))
            }
            
            if reloadedItems.count > 0 {
                string.append(line("Reloaded", reloadedItems))
            }
            
            if itemMovements.count > 0 {
                string.append(line("Movements", itemMovements))
            }
        }
        
        return string
    }
}

// MARK: -

/// A section container which could be updated
public protocol UpdatableSectionContainer: MutableSectionContainer {
    /// Update sections and generate an update description
    ///
    /// - Parameter sections: New sections to be set
    /// - Returns: Update description
    mutating func update(sections: Sections) -> SectionContainerUpdate
}

/// An object which is able to build a section container update
public protocol SectionContainerUpdateBuilder {
    associatedtype Sections: Collection
    associatedtype Items: Collection
    associatedtype SectionsDiff
    associatedtype ItemsDiff
    
    /// Build section movements
    ///
    /// - Parameter diff: Diff from source sections to destination sections
    /// - Returns: A set of movements
    func sectionMovements(from diff: SectionsDiff) -> Set<SectionContainerUpdateMovement<Int>>
    /// Build inserted section indexes
    ///
    /// - Parameter diff: Diff from source sections to destination sections
    /// - Returns: A set of inserted indexes
    func insertedSections(from diff: SectionsDiff) -> IndexSet
    /// Build deleted section indexes
    ///
    /// - Parameter diff: Diff from source sections to destination sections
    /// - Returns: A set of deleted indexes
    func deletedSections(from diff: SectionsDiff) -> IndexSet
    /// Decide if sections should be reloaded. This method is invoked when
    /// there is a change between old section and new section.
    ///
    /// - Parameters:
    ///   - sourceSection: Source section
    ///   - destinationSection: Destination section
    /// - Returns: true if section should be reloaded
    func shouldReload(from sourceSection: Sections.Iterator.Element, to destinationSection: Sections.Iterator.Element) -> Bool
    /// Build section to reload index
    ///
    /// - Parameter match: The match between sections
    /// - Returns: Index of section to reload
    func reloadedSection(from match: DiffMatch) -> Int
    
    /// Build item movements
    ///
    /// - Parameters:
    ///   - diff: Diff from source items to destination items
    ///   - sourceSection: Source section index
    ///   - destinationSection: Destination section index
    /// - Returns: A set of movements
    func itemMovements(from diff: ItemsDiff, _ sourceSection: Int, to destinationSection: Int) -> Set<SectionContainerUpdateMovement<IndexPath>>
    /// Build inserted item index paths
    ///
    /// - Parameters:
    ///   - diff: Diff from source items to destination items
    ///   - section: Destination section index
    /// - Returns: A set of inserted index paths
    func insertedItems(from diff: ItemsDiff, at section: Int) -> Set<IndexPath>
    /// Build deleted item index paths
    ///
    /// - Parameters:
    ///   - diff: Diff from source items to destination items
    ///   - section: Source section index
    /// - Returns: A set of deleted index paths
    func deletedItems(from diff: ItemsDiff, at section: Int) -> Set<IndexPath>
    /// Decide if item should be reloaded. This method is invoked when
    /// there is a change between old item and new item.
    ///
    /// - Parameters:
    ///   - sourceItem: Source item
    ///   - destinationItem: Destination item
    /// - Returns: true if item should be reloaded
    func shouldReload(from sourceItem: Items.Iterator.Element, to destinationItem: Items.Iterator.Element) -> Bool
    /// Build item to reload index path
    ///
    /// - Parameters:
    ///   - match: Match between items
    ///   - section: Index of enclosing section
    /// - Returns: Index path of item to reload
    func reloadedItem(from match: DiffMatch, at section: Int) -> IndexPath
}

public extension SectionContainerUpdateBuilder where
    SectionsDiff == Diff<Sections>, Sections.Iterator.Element: Section,
    Sections.Index == Int, Sections.IndexDistance == Int,
    ItemsDiff == Diff<Items>, Items == Sections.Iterator.Element.Items,
    Items.Index == Int, Items.IndexDistance == Int
{
    public func sectionMovements(from diff: SectionsDiff) -> Set<SectionContainerUpdateMovement<Int>>
    {
        return Set(diff.movements.map { SectionContainerUpdateMovement(from: $0.from, to: $0.to) })
    }
    
    public func insertedSections(from diff: SectionsDiff) -> IndexSet {
        return diff.inserted
    }
    
    public func deletedSections(from diff: SectionsDiff) -> IndexSet {
        return diff.deleted
    }
    
    public func reloadedSection(from match: DiffMatch) -> Int {
        return match.to
    }
    
    public func itemMovements(from diff: ItemsDiff, _ sourceSection: Int, to destinationSection: Int) -> Set<SectionContainerUpdateMovement<IndexPath>>
    {
        return Set(diff.movements.map { match in
            let source = IndexPath(item: match.from, section: sourceSection)
            let destination = IndexPath(item: match.to, section: destinationSection)
            return SectionContainerUpdateMovement(from: source, to: destination)
        })
    }

    public func insertedItems(from diff: ItemsDiff, at section: Int) -> Set<IndexPath>
    {
        return Set(diff.inserted.map { IndexPath(item: $0, section: section) })
    }
    
    public func deletedItems(from diff: ItemsDiff, at section: Int) -> Set<IndexPath>
    {
        return Set(diff.deleted.map { IndexPath(item: $0, section: section) })
    }
    
    public func shouldReload(from sourceItem: Items.Iterator.Element, to destinationItem: Items.Iterator.Element) -> Bool
    {
        return true
    }
    
    public func reloadedItem(from match: DiffMatch, at section: Int) -> IndexPath
    {
        return IndexPath(item: match.to, section: section)
    }
}

public extension UpdatableSectionContainer where
    Self: SectionContainerUpdateBuilder,
    Element: Section, Sections.Iterator.Element == Element,
    Sections.Index == Int, Sections.IndexDistance == Int,
    Self.SectionsDiff == Diff<Sections>, Self.ItemsDiff == Diff<Element.Items>,
    Element.Items.Index == Int, Element.Items.IndexDistance == Int,
    Self.Items == Element.Items
{
    mutating func update(sections: Sections) -> SectionContainerUpdate {
        // Store new sections
        let oldSections = self.sections
        self.sections = sections
        
        // Calculate diff from old sections to new sections
        let sectionsDiff = Diff(from: oldSections, to: sections)
        
        let insertedSections = self.insertedSections(from: sectionsDiff)
        let deletedSections = self.deletedSections(from: sectionsDiff)
        let sectionMovements = self.sectionMovements(from: sectionsDiff)
        
        // Cycle though section changes and get reloads and unresolved changes
        let (unresolvedSectionChanges, reloadedSections) = unresolvedAndReloadedSections(from: sectionsDiff, oldSections, sections)

        // Now cycle through all not resolved changes looking for their deltas and
        // compose rows update
        let (insertedItems, deletedItems, reloadedItems, itemMovements) = rawItemsUpdate(with: unresolvedSectionChanges, from: oldSections, to: sections)
        
        // But it's not over because some items could be moved between sections: in that
        // case we would have detected false insertion-deletion
        let (invalidInsertedItems, invalidDeletedItems, crossReloadedItems, crossItemMovements) = crossingItemsUpdate(from: oldSections, to: sections, validatingInserted: insertedItems, deleted: deletedItems)
        
        // Compose valid sets
        let validInsertedItems = insertedItems.subtracting(invalidInsertedItems)
        let validDeletedItems = deletedItems.subtracting(invalidDeletedItems)
        let validReloadedItems = reloadedItems.union(crossReloadedItems)
        let validItemMovements = itemMovements.union(crossItemMovements)
        
        return SectionContainerUpdate(sectionMovements: sectionMovements, insertedSections: insertedSections, deletedSections: deletedSections, reloadedSections: reloadedSections, insertedItems: validInsertedItems, deletedItems: validDeletedItems, reloadedItems: validReloadedItems, itemMovements: validItemMovements)
    }
    
    private func unresolvedAndReloadedSections(from diff: Diff<Sections>, _ sourceSections: Sections, _ destinationSections: Sections) -> (Set<DiffMatch>, IndexSet)
    {
        var reloadSectionDestinations = IndexSet()
        var unresolvedSectionChanges = Set<DiffMatch>()
        
        for change in diff.matches where change.changed == true {
            let sourceSection = sourceSections[change.from]
            let destinationSection = destinationSections[change.to]
            
            if equalityWithMatch(between: sourceSection, and: destinationSection) == false
            {
                unresolvedSectionChanges.insert(change)
            }
            
            if shouldReload(from: sourceSection, to: destinationSection) {
                let index = reloadedSection(from: change)
                reloadSectionDestinations.insert(index)
            }
        } // for
        
        return (unresolvedSectionChanges, reloadSectionDestinations)
    }
    
    private func rawItemsUpdate(with unresolvedSectionChanges: Set<DiffMatch>, from sourceSections: Sections, to destinationSections: Sections) -> (inserted: Set<IndexPath>, deleted: Set<IndexPath>, reloaded: Set<IndexPath>, movements: Set<SectionContainerUpdateMovement<IndexPath>>)
    {
        var inserted = Set<IndexPath>()
        var deleted = Set<IndexPath>()
        var reloaded = Set<IndexPath>()
        var movements = Set<SectionContainerUpdateMovement<IndexPath>>()
        
        for sectionChange in unresolvedSectionChanges {
            let sourceSection = sourceSections[sectionChange.from]
            let destinationSection = destinationSections[sectionChange.to]
            
            let diff = Diff(from: sourceSection.items, to: destinationSection.items)
            
            inserted.formUnion(insertedItems(from: diff, at: sectionChange.to))
            deleted.formUnion(deletedItems(from: diff, at: sectionChange.from))
            movements.formUnion(itemMovements(from: diff, sectionChange.from, to: sectionChange.to))
            reloaded.formUnion(Set(diff.matches.flatMap { match in
                guard match.changed == true else { return nil }
                
                let sourceItem = sourceSection.items[match.from]
                let destinationItem = destinationSection.items[match.to]
                
                if shouldReload(from: sourceItem, to: destinationItem) {
                    return reloadedItem(from: match, at: sectionChange.to)
                }
                else {
                    return nil
                }
            }))
        } // for
        
        return (inserted: inserted, deleted: deleted, reloaded: reloaded, movements: movements)
    }
    
    private func crossingItemsUpdate(from sourceSections: Sections, to destinationSections: Sections, validatingInserted insertedIndexPaths: Set<IndexPath>, deleted deletedIndexPaths: Set<IndexPath>) -> (invalidInserted: Set<IndexPath>, invalidDeleted: Set<IndexPath>, reloaded: Set<IndexPath>, movements: Set<SectionContainerUpdateMovement<IndexPath>>)
    {
        var invalidDeleted = Set<IndexPath>()
        var invalidInserted = Set<IndexPath>()
        var reloaded = Set<IndexPath>()
        var movements = Set<SectionContainerUpdateMovement<IndexPath>>()
        
        for deleted in deletedIndexPaths {
            let sectionOfDeleted = sourceSections[deleted.section]
            let deletedItem = sectionOfDeleted.items[deleted.item]
            
            for inserted in insertedIndexPaths.subtracting(invalidInserted) {
                let sectionOfInserted = destinationSections[inserted.section]
                let insertedItem = sectionOfInserted.items[inserted.item]
                
                var stop: Bool
                
                switch match(between: insertedItem, and: deletedItem) {
                case .equal:
                    movements.insert(SectionContainerUpdateMovement(from: deleted, to: inserted))
                    invalidDeleted.insert(deleted)
                    invalidInserted.insert(inserted)
                    stop = true
                case .change:
                    movements.insert(SectionContainerUpdateMovement(from: deleted, to: inserted))
                    invalidDeleted.insert(deleted)
                    invalidInserted.insert(inserted)
                    reloaded.insert(inserted)
                    stop = true
                case .none:
                    stop = false
                } // switch
                
                if stop == true { break }
            } // for
        } // for
        
        return (invalidInserted: invalidInserted, invalidDeleted: invalidDeleted, reloaded: reloaded, movements: movements)
    }
}

// MARK: -

/// The ability to validate an update
public protocol SectionContainerUpdateValidator {
    /// Decide if update could be performed in a batched way
    ///
    /// - Parameter update: The update
    /// - Returns: true if update can be performed in a batched way
    func isBatchable(update: SectionContainerUpdate) -> Bool
}

public extension SectionContainerUpdateValidator {
    public func isBatchable(update: SectionContainerUpdate) -> Bool {
        for indexPath in update.insertedItems {
            if update.sectionMovements.contains(where: { $0.to == indexPath.section })
            {
                // Throws "-[__NSArrayM insertObject:atIndex:]: object cannot be nil"
                // when you insert a row in a moved section
                return false
            }
        } // for
        
        for indexPath in update.deletedItems {
            if update.sectionMovements.contains(where: { $0.from == indexPath.section })
            {
                // Throws "-[__NSArrayM insertObject:atIndex:]: object cannot be nil"
                // when you delete a row in a moved section
                return false
            }
        } // for
        
        for movement in update.itemMovements {
            if update.sectionMovements.contains(where: { $0.to == movement.to.section })
            {
                // Throws "-[__NSArrayM insertObject:atIndex:]: object cannot be nil"
                // when you move a row to a moved section
                return false
            }
        } // for
        
        // There other errors managed in code, like:
        // - moving a row to newly inserted section
        // - moving a row from a deleted section
        
        return true
    }
}

// MARK: - Table view

extension UITableView: SectionContainerUpdateValidator {}

public extension UITableView {
    /// Apply update in a batched way
    ///
    /// - Parameters:
    ///   - update: Update to apply
    ///   - sectionInsertAnimation: Animation for inserted sections
    ///   - sectionDeleteAnimation: Animation for deleted sections
    ///   - sectionReloadAnimation: Animation for reloaded sections
    ///   - itemInsertAnimation: Animation for inserted items
    ///   - itemDeleteAnimation: Animation for deleted items
    ///   - itemReloadAnimation: Animation for reloaded items
    public func apply(update: SectionContainerUpdate, withSectionInsertAnimation sectionInsertAnimation: UITableViewRowAnimation = .automatic, sectionDeleteAnimation: UITableViewRowAnimation = .automatic,
        sectionReloadAnimation: UITableViewRowAnimation = .automatic,
        itemInsertAnimation: UITableViewRowAnimation = .automatic,
        itemDeleteAnimation: UITableViewRowAnimation = .automatic,
        itemReloadAnimation: UITableViewRowAnimation = .automatic)
    {
        guard update.empty == false else { return }
        guard isBatchable(update: update) else {
            reloadData()
            return
        }
        
        let exception = tryBlock {
            // Insert, delete, move
            self.beginUpdates()
            
            self.insertSections(update.insertedSections, with: sectionInsertAnimation)
            self.deleteSections(update.deletedSections, with: sectionDeleteAnimation)
            
            for movement in update.sectionMovements {
                self.moveSection(movement.from, toSection: movement.to)
            }
            
            self.insertRows(at: Array(update.insertedItems), with: itemInsertAnimation)
            self.deleteRows(at: Array(update.deletedItems), with: itemDeleteAnimation)
            
            for movement in update.itemMovements {
                self.moveRow(at: movement.from, to: movement.to)
            }
            
            self.endUpdates()

            // Reload
            self.beginUpdates()

            self.reloadSections(update.reloadedSections, with: sectionReloadAnimation)
            self.reloadRows(at: Array(update.reloadedItems), with: itemReloadAnimation)
            
            self.endUpdates()
        }
        
        if let exception = exception {
            // Build a more explainatory failure reason
            fatalError("Table view batch update failed: \(exception.name.rawValue), \(exception.reason != nil ? exception.reason! : "no reason"). Update = \n\(update)")
        }
    }
}

// MARK: - Collection view

extension UICollectionView: SectionContainerUpdateValidator {}

public extension UICollectionView {
    /// Apply update in a batched way
    ///
    /// - Parameters:
    ///   - update: Update to apply
    ///   - completion: Optional closure called at completion
    public func apply(update: SectionContainerUpdate, completion: ((Bool) -> Void)?)
    {
        guard update.empty == false else {
            if let completion = completion { completion(true) }
            return
        }
        guard isBatchable(update: update) else {
            reloadData()
            if let completion = completion { completion(true) }
            return
        }
        
        let exception = tryBlock {
            self.performBatchUpdates({
                // Insert, delete, move
                self.insertSections(update.insertedSections)
                self.deleteSections(update.deletedSections)
                
                for movement in update.sectionMovements {
                    self.moveSection(movement.from, toSection: movement.to)
                }
                
                self.insertItems(at: Array(update.insertedItems))
                self.deleteItems(at: Array(update.deletedItems))
                
                for movement in update.itemMovements {
                    self.moveItem(at: movement.from, to: movement.to)
                }
            }, completion: { finished in
                // Reload
                self.performBatchUpdates({ 
                    self.reloadSections(update.reloadedSections)
                    self.reloadItems(at: Array(update.reloadedItems))
                }, completion: completion)
            })
        }
        
        if let exception = exception {
            // Build a more explainatory failure reason
            fatalError("Collection view batch update failed: \(exception.name.rawValue), \(exception.reason != nil ? exception.reason! : "no reason"). Update = \n\(update)")
        }
    }
}
