import UIKit
import Ferrara

/// A section of table content
public struct TableViewSection<Item, Header, Footer>: MutableSection, Identifiable, Matchable, Equatable
{
    /// Section identifier
    public var identifier: String
    /// Section items
    public var items: [Item]
    /// Section header
    public var header: Header?
    /// Section footer
    public var footer: Footer?
    
    public init(identifier: String = UUID().uuidString, items: [Item] = [], header: Header? = nil, footer: Footer? = nil)
    {
        self.identifier = identifier
        self.items = items
        self.header = header
        self.footer = footer
    }

    public static func ==(lhs: TableViewSection, rhs: TableViewSection) -> Bool {
        return lhs.identifier == rhs.identifier &&
                equalityWithMatch(between: lhs.items, and: rhs.items) &&
                equalityWithMatch(between: lhs.header, and: rhs.header) &&
                equalityWithMatch(between: lhs.footer, and: rhs.footer)
    }
}

/// A section index item of table content
public struct TableViewSectionIndexItem {
    /// Item displayed title
    let title: String
    /// Bound section identifier
    let sectionIdentifier: String
    
    public init(title: String, sectionIdentifier: String) {
        self.title = title
        self.sectionIdentifier = sectionIdentifier
    }
}

/// Content of table
public struct TableViewContent<Item, Header, Footer>: UpdatableSectionContainer, SectionContainerUpdateBuilder
{
    public typealias Element = TableViewSection<Item, Header, Footer>
    public typealias Sections = [Element]
    public typealias Items = Sections.Iterator.Element.Items
    public typealias SectionsDiff = Diff<Sections>
    public typealias ItemsDiff = Diff<Items>
    
    public var sections = Sections()
    public var sectionIndexItems: [TableViewSectionIndexItem]? = nil
    
    public func shouldReload(from sourceSection: Element, to destinationSection: Element) -> Bool
    {
        let sameHeader = equalityWithMatch(between: sourceSection.header, and: destinationSection.header)
        let sameFooter = equalityWithMatch(between: sourceSection.footer, and: destinationSection.footer)
        return sameHeader == false || sameFooter == false
    }
}

/// Data source of a table view
final public class TableViewDataSource: NSObject, DataSource, UITableViewDataSource
{
    public typealias Content = TableViewContent<Any, Any, Any>
    public typealias Section = Content.Element
    public typealias Item = Content.SubElement
    
    public typealias CellFactory = ItemUIFactory<Item, IndexPath, UITableView, UITableViewCell>
    public typealias MoveHandler = UserInteractionHandler<MoveAttempt<IndexPath, Content>, MoveCommit<IndexPath, Content>>
    public typealias EditHandler = UserInteractionHandler<EditAttempt<IndexPath, Content>, EditCommit<IndexPath, UITableViewCellEditingStyle, Content, UITableView>>
    public typealias SectionTitleMaker = (Section, Int) -> String?

    /// Content of table view data source
    public var content = Content()
    /// Factory which produces cells
    public var cellFactory = CellFactory() { item, _, _ in throw AccessError.noUI(for: item) }
    
    /// Handler of move interactions. Default handler is disabled but is able to move items through sections
    public var moveHandler = MoveHandler({ _ in return false }) { _ in }
    /// Handler of edit interactions. Default handler is disabled but is able to delete items from content
    public var editHandler = EditHandler({ _ in return false }) { _ in }
    
    /// Closure which makes section header titles
    public var sectionHeaderTitleMaker: SectionTitleMaker = { section, _ in return section.header as? String }
    /// Closure which makes section footer titles
    public var sectionFooterTitleMaker: SectionTitleMaker = { section, _ in section.footer as? String }
    
    public required override init() {
        super.init()
        
        self.moveHandler.maker = { [unowned self] commit in
            try self.content.moveItem(from: commit.from, to: commit.to)
        }
        
        self.editHandler.maker = { [unowned self] commit in
            switch commit.style {
            case .delete:
                var section = try! commit.content.section(at: commit.at.section)
                section.items.remove(at: commit.at.row)
                
                var sections = commit.content.sections
                sections[commit.at.section] = section
                
                self.content.sections = sections
                commit.client.deleteRows(at: [commit.at], with: .automatic)
            default:
                break // Do nothing
            }
        }
    }
    
    // MARK: UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let count = try? content.section(at: section).items.count
        return count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        do {
            let item = try content.item(at: indexPath)
            return try cellFactory.UIElement(for: item, at: indexPath, for: tableView)
        }
        catch let error {
            fatalError("Data source can not create a cell at index path \(indexPath): \(error)")
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        do {
            return try sectionHeaderTitleMaker(content.section(at: section), section)
        }
        catch {
            return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    {
        do {
            return try sectionFooterTitleMaker(content.section(at: section), section)
        }
        catch {
            return nil
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return content.sections.count
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        let editAttempt = EditAttempt(at: indexPath, with: content)
        if editHandler.allows(userInteraction: editAttempt) {
            return true
        }
        
        // Move needs edit mode
        let moveAttempt = MoveAttempt(from: indexPath, with: content)
        return moveHandler.allows(userInteraction: moveAttempt)
    }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
        let attempt = MoveAttempt(from: indexPath, with: content)
        return moveHandler.allows(userInteraction: attempt)
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return content.sectionIndexItems?.map { $0.title }
    }
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
    {
        do {
            guard let indexItem = try content.sectionIndexItems?.element(at: index) else {
                return 0
            }
            
            return content.indexOfSection(withIdentifier: indexItem.sectionIdentifier) ?? 0
        }
        catch let error {
            fatalError("Data source can not find section bound to index item with title \"\(title)\" at index \(index): \(error)")
        }
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        do {
            let commit = EditCommit(at: indexPath, style: editingStyle, with: content, in: tableView)
            try editHandler.apply(userInteraction: commit)
        }
        catch let error {
            fatalError("Data source can not edit item at \(indexPath) with style \(editingStyle): \(error)")
        }
    }
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        do {
            let commit = MoveCommit(from: sourceIndexPath, to: destinationIndexPath, with: content)
            try moveHandler.apply(userInteraction: commit)
        }
        catch let error {
            fatalError("Data source can not move item from \(sourceIndexPath) to \(destinationIndexPath): \(error)")
        }
    }
}
