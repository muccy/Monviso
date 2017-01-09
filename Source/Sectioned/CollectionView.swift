import UIKit

public struct CollectionViewSection: Section {
    public var items: [Any]
    public var supplementary: Any?
}


//final public class CollectionViewDataSource<Item, Cell: UICollectionViewCell>: NSObject, SectionedViewDataSource, UICollectionViewDataSource
//{
//    public var content: [Section<Item>] = []
//    public var cellFactories: [SectionedViewCellFactory<Item, Cell, UICollectionView>] = []
//    
//    // MARK: UICollectionViewDataSource
//    
//    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
//    {
//        let count = try? self.section(at: section).items.count
//        return count ?? 0
//    }
//    
//    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
//    {
//        do {
//            let item = try self.item(at: indexPath)
//            let factory = try cellFactories.firstUIFactory(for: item, location: indexPath)
//            return factory.builder(item, indexPath, collectionView)
//        }
//        catch let error {
//            fatalError("Data source can not create a cell at index path \(indexPath): \(error)")
//        }
//    }
//    
//    public func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return content.count
//    }
//}
