import UIKit

final public class TableViewDataSource<Item, CellFactory: ItemUIProviding>: NSObject, DataSource, UITableViewDataSource
    where CellFactory.Item == Item, CellFactory.Location == IndexPath, CellFactory.Client == UITableView, CellFactory.Product == UITableViewCell
{
    public typealias Content = [Section<Item>]
    public typealias MoveHandler = UserInteractionHandler<Content, MoveAttempt<IndexPath>, MoveCommit<IndexPath>>

    public var content: Content = []
    public let cellFactory: CellFactory
    public var moveHandler = MoveHandler({ _ in return false}, maker: MoveHandler.standardMaker())
    
    public required init(cellFactory: CellFactory) {
        self.cellFactory = cellFactory
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
            let item = try self.item(at: indexPath)
            return try cellFactory.UIElement(for: item, at: indexPath, for: tableView)
        }
        catch let error {
            fatalError("Data source can not create a cell at index path \(indexPath): \(error)")
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let header = try? content.section(at: section).header
        return header as? String
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let footer = try? content.section(at: section).footer
        return footer as? String
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return content.count
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return false
    }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
        let attempt = MoveAttempt(from: indexPath)
        return moveHandler.allows(userInteraction: attempt)
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
    {
        return 0
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        
    }
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        do {
            let commit = MoveCommit(from: sourceIndexPath, to: destinationIndexPath)
            content = try moveHandler.commit(userInteraction: commit, with: content)
        }
        catch let error {
            fatalError("Data source can not move item from \(sourceIndexPath) to \(destinationIndexPath): \(error)")
        }
    }
}
