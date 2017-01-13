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
    
    private func content(withItems items: [Any]) -> TableViewDataSource.Content {
        var content = TableViewDataSource.Content()
        content.sections = [ TableViewDataSource.Content.Element(items: items) ]
        return content
    }
    
    private func movement<L: Hashable>(_ from: L, _ to: L) -> SectionContainerUpdateMovement<L>
    {
        return SectionContainerUpdateMovement(from: from, to: to)
    }
}
