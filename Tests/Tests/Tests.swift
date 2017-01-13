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

class Tests: XCTestCase {
    func testDataSourceCreation() {
        let dataSource = self.dataSource(withSectionIdentifiers: ["a", "b"])
        XCTAssertEqual(dataSource.content.sections.count, 2)
        XCTAssertEqual(try! dataSource.content.section(at: 0).identifier, "a")
        XCTAssertEqual(try! dataSource.content.section(at: 1).identifier, "b")
    }
    
    func testSectionFind() {
        let dataSource = self.dataSource(withSectionIdentifiers: ["a", "b"])
        XCTAssertEqual(dataSource.content.indexOfSection(withIdentifier: "a"), 0)
        XCTAssertEqual(dataSource.content.indexOfSection(withIdentifier: "b"), 1)
        XCTAssertNil(dataSource.content.indexOfSection(withIdentifier: "c"))
    }
    
    func testItemFind() {
        let dataSource = self.dataSource(withItems: [0, 1, 2])
        XCTAssertEqual(try! dataSource.content.item(at: IndexPath(item: 1, section: 0)) as! Int, 1)
        
        XCTAssertEqual(dataSource.content.indexPathOfItem(2), IndexPath(item: 2, section: 0))
        XCTAssertNil(dataSource.content.indexPathOfItem(3))
        
        XCTAssertEqual(dataSource.content.indexPathOfItem(where: { _, item in
            if let item = item as? Int, item == 1 {
                return (passed: true, stop: true)
            }
            else {
                return (passed: false, stop: false)
            }
        }), IndexPath(item: 1, section: 0))
    }
    
    private func dataSource(withSectionIdentifiers identifiers: [String]) -> TableViewDataSource
    {
        let dataSource = TableViewDataSource()
        dataSource.content.sections = identifiers.map { TableViewDataSource.Section(identifier: $0) }
        return dataSource
    }
    
    private func dataSource(withItems items: [Any]) -> TableViewDataSource {
        let dataSource = TableViewDataSource()
        dataSource.content.sections = [ TableViewDataSource.Section(items: items) ]
        return dataSource
    }
}
