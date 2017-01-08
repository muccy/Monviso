import UIKit

public struct TableViewSection<Item, Header, Footer>: MutableSection {
    public var items: [Item]
    public var header: Header?
    public var footer: Footer?
    
    public init(items: [Item] = [], header: Header? = nil, footer: Footer? = nil)
    {
        self.items = items
        self.header = header
        self.footer = footer
    }
}

public struct TableViewContent<Item, Header, Footer>: MutableSectionContainer {
    public typealias Element = TableViewSection<Item, Header, Footer>
    public var sections = [Element]()
}

final public class TableViewDataSource: NSObject, DataSource, UITableViewDataSource
{
    public typealias Content = TableViewContent<Any, Any, Any>
    public typealias Section = Content.Element
    public typealias Item = Content.SubElement
    
    public typealias CellFactory = ItemUIFactory<Item, IndexPath, UITableView, UITableViewCell>
    public typealias MoveHandler = UserInteractionHandler<MoveAttempt<IndexPath, Content>, MoveCommit<IndexPath, Content>>
    public typealias EditHandler = UserInteractionHandler<EditAttempt<IndexPath, Content>, EditCommit<IndexPath, UITableViewCellEditingStyle, Content>>
    public typealias SectionTitleMaker = (Section, Int) -> String?

    public var content = Content()
    public let cellFactory: CellFactory
    
    public var moveHandler = MoveHandler({ _ in return false }) { _ in }
    public var editHandler = EditHandler({ _ in return false}) { _ in }
    
    public var sectionHeaderTitleMaker: SectionTitleMaker = { section, _ in return section.header as? String }
    public var sectionFooterTitleMaker: SectionTitleMaker = { section, _ in section.footer as? String }
    
    public required init(cellFactory: CellFactory) {
        self.cellFactory = cellFactory
        
        super.init()
        self.moveHandler.maker = { [unowned self] commit in
            try self.content.move(itemAt: commit.from, to: commit.to)
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
        return nil // TODO
    }
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
    {
        return 0 // TODO
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        do {
            let commit = EditCommit(at: indexPath, style: editingStyle, with: content)
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
