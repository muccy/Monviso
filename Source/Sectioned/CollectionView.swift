import UIKit
import Ferrara

/// A section of collection content
public struct CollectionViewSection<Item>: MutableSection, Identifiable, Matchable, Equatable
{
    /// Section identifier
    public var identifier: String
    /// Section items
    public var items: [Item]
    /// Section supplementary infos
    public var userInfo: [AnyHashable: Any]
    
    public init(identifier: String = UUID().uuidString, items: [Item] = [], userInfo: [AnyHashable: Any] = [AnyHashable: Any]())
    {
        self.identifier = identifier
        self.items = items
        self.userInfo = userInfo
    }
    
    public static func ==(lhs: CollectionViewSection, rhs: CollectionViewSection) -> Bool
    {
        return lhs.identifier == rhs.identifier &&
            equalityWithMatch(between: lhs.items, and: rhs.items) &&
            equalityWithMatch(between: lhs.userInfo, and: rhs.userInfo)
    }
}

/// Content of collection
public struct CollectionViewContent<Item>: UpdatableSectionContainer, SectionContainerUpdateBuilder
{
    public typealias Element = CollectionViewSection<Item>
    public typealias Sections = [Element]
    public typealias Items = Sections.Iterator.Element.Items
    public typealias SectionsDiff = Diff<Sections>
    public typealias ItemsDiff = Diff<Items>

    public var sections = Sections()
    
    public func shouldReload(from sourceSection: Element, to destinationSection: Element) -> Bool
    {
        let sameUserInfo = equalityWithMatch(between: sourceSection.userInfo, and: destinationSection.userInfo)
        return sameUserInfo == false
    }
}

/// Data source of collection view
final public class CollectionViewDataSource: NSObject, DataSource, UICollectionViewDataSource
{
    public typealias Content = CollectionViewContent<Any>
    public typealias Section = Content.Element
    public typealias Item = Content.SubElement
    
    public typealias CellFactory = ItemUIFactory<Item, IndexPath, UICollectionView, UICollectionViewCell>
    public typealias SupplementaryViewFactory = ItemUIFactory<Section, IndexPath, UICollectionView, UICollectionReusableView>
    public typealias MoveHandler = UserInteractionHandler<MoveAttempt<IndexPath, Content>, MoveCommit<IndexPath, Content>>

    /// Content of collection view data source
    public var content = Content()
    /// Factory which produces cells
    public var cellFactory = CellFactory() { item, _, _ in throw AccessError.noUI(item: item) }
    /// Factory which produces supplementary views
    public var supplementaryViewFactory = SupplementaryViewFactory() { section, _, _ in throw AccessError.noUI(item: section) }
    
    /// Handler of move interactions. Default handler is disabled but is able to move items through sections
    public var moveHandler = MoveHandler({ _ in return false }) { _ in }
    
    public required override init() {
        super.init()
        self.moveHandler.maker = { [unowned self] commit in
            try self.content.moveItem(from: commit.from, to: commit.to)
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let count = try? content.section(at: section).items.count
        return count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        do {
            let item = try content.item(at: indexPath)
            return try cellFactory.UIElement(for: item, at: indexPath, for: collectionView)
        }
        catch let error {
            fatalError("Data source can not create a cell at index path \(indexPath): \(error)")
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return content.sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        do {
            let section = try content.section(at: indexPath.section)
            return try supplementaryViewFactory.UIElement(for: section, at: indexPath, for: collectionView)
        }
        catch let error {
            fatalError("Data source can not create a supplementary view at index path \(indexPath): \(error)")
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool
    {
        let attempt = MoveAttempt(from: indexPath, with: content)
        return moveHandler.allows(userInteraction: attempt)
    }
    
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
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
