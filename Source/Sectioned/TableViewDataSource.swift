import UIKit

final public class TableViewDataSource<Item, CellFactory: ItemUIProviding>: NSObject, DataSource, UITableViewDataSource
    where CellFactory.Item == Item, CellFactory.Location == IndexPath, CellFactory.Client == UITableView, CellFactory.Product == UITableViewCell
{
    public var content: [Section<Item>] = []
    public let cellFactory: CellFactory
    
    public required init(cellFactory: CellFactory) {
        self.cellFactory = cellFactory
    }
    
    // MARK: UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let count = try? self.section(at: section).items.count
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
        let header = try? self.section(at: section).header
        return header as? String
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let footer = try? self.section(at: section).footer
        return footer as? String
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return content.count
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        
    }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
        
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
    }
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
    {
        
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        
    }
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        do {
            var sourceSection = try section(at: sourceIndexPath.section)
            let item = try sourceSection.item(at: sourceIndexPath.row)
            sourceSection.items.remove(at: sourceIndexPath.row)
            
            var destinationSection = try section(at: destinationIndexPath.section)
            destinationSection.items.insert(item, at: destinationIndexPath.row)
            
            var sections = content
            
            sections.remove(at: sourceIndexPath.section)
            sections.insert(sourceSection, at: sourceIndexPath.section)
            
            sections.remove(at: destinationIndexPath.section)
            sections.insert(destinationSection, at: destinationIndexPath.section)
            
            content = sections
        }
        catch let error {
            fatalError("Data source can not move item from \(sourceIndexPath) to \(destinationIndexPath): \(error)")
        }
    }
}
