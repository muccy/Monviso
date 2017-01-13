//
//  Tests.swift
//  Tests
//
//  Created by Marco on 13/01/17.
//
//

import XCTest
@testable import Monviso
import Ferrara

extension Int: Matchable {}
extension String: Matchable {}

struct Box<V: Equatable>: Matchable, Identifiable, Hashable {
    let identifier: String
    let value: V
    
    init(_ identifier: String, _ value: V) {
        self.identifier = identifier
        self.value = value
    }
    
    var hashValue: Int {
        return 4343 ^ identifier.hashValue
    }
    
    public static func ==(lhs: Box, rhs: Box) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.value == rhs.value
    }
}

// MARK: -

class Tests: XCTestCase {
    func testDataSourceCreation() {
        let content = self.content(withSectionIdentifiers: ["a", "b"])
        XCTAssertEqual(content.sections.count, 2)
        XCTAssertEqual(try! content.section(at: 0).identifier, "a")
        XCTAssertEqual(try! content.section(at: 1).identifier, "b")
    }
    
    func testSectionFind() {
        let content = self.content(withSectionIdentifiers: ["a", "b"])
        XCTAssertEqual(content.indexOfSection(withIdentifier: "a"), 0)
        XCTAssertEqual(content.indexOfSection(withIdentifier: "b"), 1)
        XCTAssertNil(content.indexOfSection(withIdentifier: "c"))
    }
    
    func testItemFind() {
        let content = self.content(withItems: [0, 1, 2])
        XCTAssertEqual(try! content.item(at: IndexPath(item: 1, section: 0)) as! Int, 1)
        
        XCTAssertEqual(content.indexPathOfItem(2), IndexPath(item: 2, section: 0))
        XCTAssertNil(content.indexPathOfItem(3))
        
        XCTAssertEqual(content.indexPathOfItem(where: { _, item in
            if let item = item as? Int, item == 1 {
                return (passed: true, stop: true)
            }
            else {
                return (passed: false, stop: false)
            }
        }), IndexPath(item: 1, section: 0))
    }
    
    func testNoUpdate() {
        var content = self.content(withSectionIdentifiers: ["a", "b"])
        let update = content.update(sections: content.sections)
        XCTAssert(update.isEmpty)
    }
    
    // MARK: - Section Updates
    
    func testSectionInsertion() {
        var content = self.content(withSectionIdentifiers: ["a", "b"])
        let update = content.update(sections: self.sections(withIdentifiers: ["a", "c", "b"]))
        
        XCTAssertEqual(update.insertedSections, IndexSet(integer: 1))
        XCTAssertEqual(update.deletedSections, IndexSet())
        XCTAssertEqual(update.reloadedSections, IndexSet())
        XCTAssertEqual(update.sectionMovements.count, 0)
        XCTAssertFalse(update.affectsItems)
    }
    
    func testSectionDeletion() {
        var content = self.content(withSectionIdentifiers: ["a", "b", "c"])
        let update = content.update(sections: self.sections(withIdentifiers: ["a", "c"]))
        
        XCTAssertEqual(update.insertedSections, IndexSet())
        XCTAssertEqual(update.deletedSections, IndexSet(integer: 1))
        XCTAssertEqual(update.reloadedSections, IndexSet())
        XCTAssertEqual(update.sectionMovements.count, 0)
        XCTAssertFalse(update.affectsItems)
    }
    
    func testSectionReload() {
        var content = self.content(withSectionIdentifiers: ["a", "b", "c"])
        
        var sections = self.sections(withIdentifiers: ["a", "b", "c"])
        sections[1].header = "Edit"
        sections[2].header = "Edit"
        
        let update = content.update(sections: sections)
        
        XCTAssertEqual(update.insertedSections, IndexSet())
        XCTAssertEqual(update.deletedSections, IndexSet())
        XCTAssertEqual(update.reloadedSections, IndexSet(1...2))
        XCTAssertEqual(update.sectionMovements.count, 0)
        XCTAssertFalse(update.affectsItems)
    }
    
    func testSectionMovement() {
        var content = self.content(withSectionIdentifiers: ["a", "b", "c", "d"])
        let update = content.update(sections: self.sections(withIdentifiers: ["c", "b", "d", "a"]))
        
        XCTAssertEqual(update.insertedSections, IndexSet())
        XCTAssertEqual(update.deletedSections, IndexSet())
        XCTAssertEqual(update.reloadedSections, IndexSet())
        XCTAssertEqual(update.sectionMovements, Set([ movement(0, 3), movement(2, 0) ]))
        XCTAssertFalse(update.affectsItems)
    }
    
    func testSectionInsertionDeletion() {
        var content = self.content(withSectionIdentifiers: ["a", "b"])
        let update = content.update(sections: self.sections(withIdentifiers: ["c", "b"]))
        
        XCTAssertEqual(update.insertedSections, IndexSet(0...0))
        XCTAssertEqual(update.deletedSections, IndexSet(0...0))
        XCTAssertEqual(update.reloadedSections, IndexSet())
        XCTAssertEqual(update.sectionMovements.count, 0)
        XCTAssertFalse(update.affectsItems)
    }
    
    func testSectionInsertionReload() {
        var content = self.content(withSectionIdentifiers: ["a", "b"])
        
        var sections = self.sections(withIdentifiers: ["c", "d", "a", "e", "b", "f"])
        sections[4].header = "Edit"
        
        let update = content.update(sections: sections)
        
        XCTAssertEqual(update.insertedSections, IndexSet([0, 1, 3, 5]))
        XCTAssertEqual(update.deletedSections, IndexSet())
        XCTAssertEqual(update.reloadedSections, IndexSet(4...4))
        XCTAssertEqual(update.sectionMovements.count, 0)
        XCTAssertFalse(update.affectsItems)
    }
    
    func testSectionInsertionMovement() {
        var content = self.content(withSectionIdentifiers: ["a", "b", "c", "d"])
        let update = content.update(sections: self.sections(withIdentifiers: ["e", "c", "b", "d", "f", "a"]))
        
        XCTAssertEqual(update.insertedSections, IndexSet([0, 4]))
        XCTAssertEqual(update.deletedSections, IndexSet())
        XCTAssertEqual(update.reloadedSections, IndexSet())
        XCTAssertEqual(update.sectionMovements, Set([ movement(0, 5), movement(1, 2) ]))
        XCTAssertFalse(update.affectsItems)
    }
    
    func testSectionDeletionReload() {
        var content = self.content(withSectionIdentifiers: ["a", "b", "c", "d"])
        
        var sections = self.sections(withIdentifiers: ["b", "d"])
        sections[1].header = "Edit"
        
        let update = content.update(sections: sections)
        
        XCTAssertEqual(update.insertedSections, IndexSet())
        XCTAssertEqual(update.deletedSections, IndexSet([0, 2]))
        XCTAssertEqual(update.reloadedSections, IndexSet(1...1))
        XCTAssertEqual(update.sectionMovements.count, 0)
        XCTAssertFalse(update.affectsItems)
    }
    
    func testSectionDeletionMovement() {
        var content = self.content(withSectionIdentifiers: ["a", "b", "c", "d", "e"])
        let update = content.update(sections: self.sections(withIdentifiers: ["b", "e", "c"]))
        
        XCTAssertEqual(update.insertedSections, IndexSet())
        XCTAssertEqual(update.deletedSections, IndexSet([0, 3]))
        XCTAssertEqual(update.reloadedSections, IndexSet())
        XCTAssertEqual(update.sectionMovements, Set([ movement(4, 1) ]))
        XCTAssertFalse(update.affectsItems)
    }
    
    func testSectionReloadMovement() {
        var content = self.content(withSectionIdentifiers: ["a", "b", "c"])
        
        var sections = self.sections(withIdentifiers: ["c", "b", "a"])
        sections[2].header = "Edit"
        
        let update = content.update(sections: sections)
        
        XCTAssertEqual(update.insertedSections, IndexSet())
        XCTAssertEqual(update.deletedSections, IndexSet())
        XCTAssertEqual(update.reloadedSections, IndexSet(2...2))
        XCTAssertEqual(update.sectionMovements, Set([ movement(0,2), movement(2, 0) ]))
        XCTAssertFalse(update.affectsItems)
    }
    
    func testSectionInsertionDeletionReload() {
        var content = self.content(withSectionIdentifiers: ["a", "b", "c"])
        
        var sections = self.sections(withIdentifiers: ["a", "d", "b", "e"])
        sections[2].header = "Edit"
        
        let update = content.update(sections: sections)
        
        XCTAssertEqual(update.insertedSections, IndexSet([1, 3]))
        XCTAssertEqual(update.deletedSections, IndexSet(2...2))
        XCTAssertEqual(update.reloadedSections, IndexSet(2...2))
        XCTAssertEqual(update.sectionMovements.count, 0)
        XCTAssertFalse(update.affectsItems)
    }
    
    func testSectionInsertionDeletionMovement() {
        var content = self.content(withSectionIdentifiers: ["a", "b", "c"])
        let update = content.update(sections: self.sections(withIdentifiers: ["b", "d", "a", "e"]))
        
        XCTAssertEqual(update.insertedSections, IndexSet([1, 3]))
        XCTAssertEqual(update.deletedSections, IndexSet(2...2))
        XCTAssertEqual(update.reloadedSections, IndexSet())
        XCTAssertEqual(update.sectionMovements, Set([ movement(0, 2) ]))
        XCTAssertFalse(update.affectsItems)
    }
    
    func testSectionDeletionReloadMovement() {
        var content = self.content(withSectionIdentifiers: ["a", "b", "c", "d"])
        
        var sections = self.sections(withIdentifiers: ["b", "a", "d"])
        sections[1].header = "Edit"
        
        let update = content.update(sections: sections)
        
        XCTAssertEqual(update.insertedSections, IndexSet())
        XCTAssertEqual(update.deletedSections, IndexSet(2...2))
        XCTAssertEqual(update.reloadedSections, IndexSet(1...1))
        XCTAssertEqual(update.sectionMovements, Set([ movement(0, 1) ]))
        XCTAssertFalse(update.affectsItems)
    }
    
    func testSectionInsertionDeletionReloadMovement() {
        var content = self.content(withSectionIdentifiers: ["a", "b", "c"])
        
        var sections = self.sections(withIdentifiers: ["b", "d", "a", "e"])
        sections[2].header = "Edit"
        
        let update = content.update(sections: sections)
        
        XCTAssertEqual(update.insertedSections, IndexSet([1, 3]))
        XCTAssertEqual(update.deletedSections, IndexSet(2...2))
        XCTAssertEqual(update.reloadedSections, IndexSet(2...2))
        XCTAssertEqual(update.sectionMovements, Set([ movement(0, 2) ]))
        XCTAssertFalse(update.affectsItems)
    }
    
    // MARK: - Item Updates
    
    func testItemInsertion() {
        var content = self.content(withItems: ["a", "b"])
        let update = content.update(sections: self.singleSection(withItems: ["a", "c", "b"]))
        
        XCTAssertEqual(update.insertedItems, indexPaths([1]))
        XCTAssertEqual(update.deletedItems, indexPaths())
        XCTAssertEqual(update.reloadedItems, indexPaths())
        XCTAssertEqual(update.itemMovements, Set())
        XCTAssertFalse(update.affectsSections)
    }
    
    func testItemDeletion() {
        var content = self.content(withItems: ["a", "b", "c"])
        let update = content.update(sections: self.singleSection(withItems: ["a", "c"]))
        
        XCTAssertEqual(update.insertedItems, indexPaths())
        XCTAssertEqual(update.deletedItems, indexPaths([1]))
        XCTAssertEqual(update.reloadedItems, indexPaths())
        XCTAssertEqual(update.itemMovements, Set())
        XCTAssertFalse(update.affectsSections)
    }
    
    func testItemReload() {
        var content = self.content(withItems: ["a", Box("b", 0), "c"])
        let update = content.update(sections: self.singleSection(withItems: ["a", Box("b", 1), "c"]))
        
        XCTAssertEqual(update.insertedItems, indexPaths())
        XCTAssertEqual(update.deletedItems, indexPaths())
        XCTAssertEqual(update.reloadedItems, indexPaths([1]))
        XCTAssertEqual(update.itemMovements, Set())
        XCTAssertFalse(update.affectsSections)
    }
    
    func testItemReloadWithSectionMovement() {
        var content = self.content(withSectionIdentifiers: ["a", "b"])
        content.sections[1].items = ["a", Box("b", 0), "c"]
        
        var destinationSections = content.sections.reversed() as TableViewDataSource.Content.Sections
        destinationSections[0].items[1] = Box("b", 1)
        
        let update = content.update(sections: destinationSections)
        
        XCTAssertEqual(update.insertedSections, IndexSet())
        XCTAssertEqual(update.deletedSections, IndexSet())
        XCTAssertEqual(update.reloadedSections, IndexSet())
        XCTAssertEqual(update.sectionMovements, Set([ movement(0, 1) ]))
        
        XCTAssertEqual(update.insertedItems, indexPaths())
        XCTAssertEqual(update.deletedItems, indexPaths())
        XCTAssertEqual(update.reloadedItems, indexPaths([1]))
        XCTAssertEqual(update.itemMovements, Set())
    }
    
    func testItemMovement() {
        var content = self.content(withItems: ["a", "b", "c", "d"])
        let update = content.update(sections: self.singleSection(withItems: ["c", "a", "d", "b"]))
        
        XCTAssertEqual(update.insertedItems, indexPaths())
        XCTAssertEqual(update.deletedItems, indexPaths())
        XCTAssertEqual(update.reloadedItems, indexPaths())
        XCTAssertEqual(update.itemMovements, Set([ movement(indexPath(0), indexPath(1)), movement(indexPath(1), indexPath(3)) ]))
        XCTAssertFalse(update.affectsSections)
    }
    
    func testItemMovementBetweenSections() {
        var content = self.content(withSectionIdentifiers: ["a", "b"])
        content.sections[0].items = ["a", "b"]
        content.sections[1].items = ["c", "d", "e", "f"]
        
        var destinationSections = content.sections
        destinationSections[0].items = ["c", "b", "f", "d"]
        destinationSections[1].items = ["a", "e"]
        
        let update = content.update(sections: destinationSections)

        XCTAssertEqual(update.insertedItems, indexPaths())
        XCTAssertEqual(update.deletedItems, indexPaths())
        XCTAssertEqual(update.reloadedItems, indexPaths())
        // a: (0, 0) -> (1, 0)
        // b: -
        // c: (1, 0) -> (0, 0)
        // d: (1, 1) -> (0, 3)
        // e: -
        // f: (1, 3) -> (0, 2)
        XCTAssertEqual(update.itemMovements, Set([
            movement(indexPath(0, 0), indexPath(1, 0)),
            movement(indexPath(1, 0), indexPath(0, 0)),
            movement(indexPath(1, 1), indexPath(0, 3)),
            movement(indexPath(1, 3), indexPath(0, 2))
        ]))
        XCTAssertFalse(update.affectsSections)
    }
    
    func testItemMovementToInsertedSection() {
        // It's prohibited. Delete item from source section, instead.
        
        var content = self.content(withSectionIdentifiers: ["a"])
        content.sections[0].items = ["a", "b"]
        
        var destinationSections = self.sections(withIdentifiers: ["a", "b"])
        destinationSections[0].items = ["b"]
        destinationSections[1].items = ["c", "a"]
        
        let update = content.update(sections: destinationSections)
        
        XCTAssertEqual(update.insertedSections, IndexSet(1...1))
        XCTAssertEqual(update.deletedSections, IndexSet())
        XCTAssertEqual(update.reloadedSections, IndexSet())
        XCTAssertEqual(update.sectionMovements.count, 0)
        
        XCTAssertEqual(update.insertedItems, indexPaths())
        XCTAssertEqual(update.deletedItems, indexPaths([0]))
        XCTAssertEqual(update.reloadedItems, indexPaths())
        XCTAssertEqual(update.itemMovements, Set())
    }
    
    func testItemMovementFromDeletedSection() {
        // It's prohibited. Insert item in destination section, instead.
        
        var content = self.content(withSectionIdentifiers: ["a", "b"])
        content.sections[0].items = ["a", "b"]
        content.sections[1].items = ["c"]
        
        var destinationSections = self.sections(withIdentifiers: ["b"])
        destinationSections[0].items = ["c", "a"]
        
        let update = content.update(sections: destinationSections)
        
        XCTAssertEqual(update.insertedSections, IndexSet())
        XCTAssertEqual(update.deletedSections, IndexSet(0...0))
        XCTAssertEqual(update.reloadedSections, IndexSet())
        XCTAssertEqual(update.sectionMovements.count, 0)
        
        XCTAssertEqual(update.insertedItems, indexPaths([1]))
        XCTAssertEqual(update.deletedItems, indexPaths())
        XCTAssertEqual(update.reloadedItems, indexPaths())
        XCTAssertEqual(update.itemMovements, Set())
    }
    
    func testItemInsertionDeletion() {
        var content = self.content(withItems: ["a", "b"])
        let update = content.update(sections: self.singleSection(withItems: ["c", "b"]))
        
        XCTAssertEqual(update.insertedItems, indexPaths([0]))
        XCTAssertEqual(update.deletedItems, indexPaths([0]))
        XCTAssertEqual(update.reloadedItems, indexPaths())
        XCTAssertEqual(update.itemMovements, Set())
        XCTAssertFalse(update.affectsSections)
    }
    
    func testItemInsertionReload() {
        var content = self.content(withItems: ["a", Box("b", 0)])
        let update = content.update(sections: self.singleSection(withItems: ["c", "d", "a", "e", Box("b", 1), "f"]))
        
        XCTAssertEqual(update.insertedItems, indexPaths([0, 1, 3, 5]))
        XCTAssertEqual(update.deletedItems, indexPaths())
        XCTAssertEqual(update.reloadedItems, indexPaths([4]))
        XCTAssertEqual(update.itemMovements, Set())
        XCTAssertFalse(update.affectsSections)
    }
    
    func testItemInsertionMovement() {
        var content = self.content(withItems: ["a", "b", "c", "d"])
        let update = content.update(sections: self.singleSection(withItems: ["e", "c", "b", "d", "f", "a"]))
        
        XCTAssertEqual(update.insertedItems, indexPaths([0, 4]))
        XCTAssertEqual(update.deletedItems, indexPaths())
        XCTAssertEqual(update.reloadedItems, indexPaths())
        XCTAssertEqual(update.itemMovements, Set([
            movement(indexPath(0), indexPath(5)),
            movement(indexPath(1), indexPath(2)),
            ]))
        XCTAssertFalse(update.affectsSections)
    }
    
    func testItemDeletionReload() {
        var content = self.content(withItems: ["a", "b", "c", Box("d", 0)])
        let update = content.update(sections: self.singleSection(withItems: ["b", Box("d", 1)]))
        
        XCTAssertEqual(update.insertedItems, indexPaths())
        XCTAssertEqual(update.deletedItems, indexPaths([0, 2]))
        XCTAssertEqual(update.reloadedItems, indexPaths([1]))
        XCTAssertEqual(update.itemMovements, Set())
        XCTAssertFalse(update.affectsSections)
    }
    
    func testItemDeletionMovement() {
        var content = self.content(withItems: ["a", "b", "c", "d", "e"])
        let update = content.update(sections: self.singleSection(withItems: ["b", "e", "c"]))
        
        XCTAssertEqual(update.insertedItems, indexPaths())
        XCTAssertEqual(update.deletedItems, indexPaths([0, 3]))
        XCTAssertEqual(update.reloadedItems, indexPaths())
        XCTAssertEqual(update.itemMovements, Set([ movement(indexPath(4), indexPath(1)) ]))
        XCTAssertFalse(update.affectsSections)
    }
    
    func testItemReloadMovement() {
        var content = self.content(withItems: [Box("a", 0), "b", "c"])
        let update = content.update(sections: self.singleSection(withItems: ["c", "b", Box("a", 1)]))
        
        XCTAssertEqual(update.insertedItems, indexPaths())
        XCTAssertEqual(update.deletedItems, indexPaths())
        XCTAssertEqual(update.reloadedItems, indexPaths([2]))
        XCTAssertEqual(update.itemMovements, Set([
            movement(indexPath(0), indexPath(2)),
            movement(indexPath(2), indexPath(0))
        ]))
        XCTAssertFalse(update.affectsSections)
    }
    
    func testItemInsertionDeletionReload() {
        var content = self.content(withItems: ["a", Box("b", 0), "c"])
        let update = content.update(sections: self.singleSection(withItems: ["a", "d", Box("b", 1), "e"]))
        
        XCTAssertEqual(update.insertedItems, indexPaths([1, 3]))
        XCTAssertEqual(update.deletedItems, indexPaths([2]))
        XCTAssertEqual(update.reloadedItems, indexPaths([2]))
        XCTAssertEqual(update.itemMovements, Set())
        XCTAssertFalse(update.affectsSections)
    }
    
    func testItemInsertionDeletionMovement() {
        var content = self.content(withItems: ["a", "b", "c"])
        let update = content.update(sections: self.singleSection(withItems: ["b", "d", "a", "e"]))
        
        XCTAssertEqual(update.insertedItems, indexPaths([1, 3]))
        XCTAssertEqual(update.deletedItems, indexPaths([2]))
        XCTAssertEqual(update.reloadedItems, indexPaths())
        XCTAssertEqual(update.itemMovements, Set([ movement(indexPath(0), indexPath(2)) ]))
        XCTAssertFalse(update.affectsSections)
    }
    
    func testItemDeletionReloadMovement() {
        var content = self.content(withItems: [Box("a", 0), "b", "c", "d"])
        let update = content.update(sections: self.singleSection(withItems: ["b", Box("a", 1), "d"]))
        
        XCTAssertEqual(update.insertedItems, indexPaths())
        XCTAssertEqual(update.deletedItems, indexPaths([2]))
        XCTAssertEqual(update.reloadedItems, indexPaths([1]))
        XCTAssertEqual(update.itemMovements, Set([ movement(indexPath(0), indexPath(1)) ]))
        XCTAssertFalse(update.affectsSections)
    }
    
    func testItemInsertionDeletionReloadMovement() {
        var content = self.content(withItems: [Box("a", 0), "b", "c"])
        let update = content.update(sections: self.singleSection(withItems: ["b", "d", Box("a", 1), "e"]))
        
        XCTAssertEqual(update.insertedItems, indexPaths([1, 3]))
        XCTAssertEqual(update.deletedItems, indexPaths([2]))
        XCTAssertEqual(update.reloadedItems, indexPaths([2]))
        XCTAssertEqual(update.itemMovements, Set([ movement(indexPath(0), indexPath(2)) ]))
        XCTAssertFalse(update.affectsSections)
    }
    
    // MARK: -
    
    private func sections(withIdentifiers identifiers: [String]) -> TableViewDataSource.Content.Sections
    {
        return identifiers.map { TableViewDataSource.Section(identifier: $0) }
    }
    
    private func content(withSectionIdentifiers identifiers: [String]) -> TableViewDataSource.Content
    {
        var content = TableViewDataSource.Content()
        content.sections = self.sections(withIdentifiers: identifiers)
        return content
    }
    
    private func singleSection(_ identifier: String = "a", withItems items: [Any]) -> TableViewDataSource.Content.Sections
    {
        return [ TableViewDataSource.Content.Element(identifier: identifier, items: items) ]
    }
    
    private func content(withItems items: [Any]) -> TableViewDataSource.Content {
        var content = TableViewDataSource.Content()
        content.sections = self.singleSection(withItems: items)
        return content
    }
    
    private func indexPath(_ item: Int) -> IndexPath {
        return IndexPath(item: item, section: 0)
    }
    
    private func indexPath(_ section: Int, _ item: Int) -> IndexPath {
        return IndexPath(item: item, section: section)
    }
    
    private func indexPaths(_ items: [Int] = []) -> Set<IndexPath> {
        return Set(items.map { indexPath($0) })
    }
    
    private func movement<L: Hashable>(_ from: L, _ to: L) -> SectionContainerUpdateMovement<L>
    {
        return SectionContainerUpdateMovement(from: from, to: to)
    }
}
