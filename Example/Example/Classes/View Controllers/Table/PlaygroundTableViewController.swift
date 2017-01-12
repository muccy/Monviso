//
//  PlaygroundTableViewController.swift
//  Example
//
//  Created by Marco on 10/01/17.
//  Copyright © 2017 MeLive. All rights reserved.
//

import UIKit
import Monviso
import Ferrara

class PlaygroundTableViewController: UITableViewController {
    private let dataSource = TableViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.cellFactory.creator = { item, indexPath, tableView in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            if let command = item as? Playground.Command {
                cell.textLabel!.text = command.rawValue
                cell.selectionStyle = .default
            }
            else {
                cell.textLabel!.text = item as? String
                cell.selectionStyle = .none
            }
            
            return cell
        }
        
        dataSource.editHandler.attemptTest = { attempt in
            let item = try? attempt.content.item(at: attempt.at)
            return (item is Playground.Command) == false
        }
        
        dataSource.moveHandler.attemptTest = { attempt in
            let item = try? attempt.content.item(at: attempt.from)
            return (item is Playground.Command) == false
        }
        
        tableView.dataSource = dataSource
        dataSource.content.sections = originalSections()
        
        setEditing(true, animated: false)
    }
    
    private func originalSections() -> TableViewDataSource.Content.Sections {
        return Playground.defaultSections { TableViewDataSource.Section(identifier: $0, items: $2, header: $1) }
    }
    
    @IBAction func refreshButtonPressed() {
        let update = dataSource.content.update(sections: originalSections())
        tableView.apply(update: update)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let item = try? dataSource.content.item(at: indexPath)
        
        if let command = item as? Playground.Command {
            switch command {
            case .addRow:
                let maxSectionIndex = dataSource.content.sections.count - 2
                let sectionIndex = Int(arc4random_uniform(UInt32(maxSectionIndex))) + 1 // skip commands section
                var section = try! dataSource.content.section(at: sectionIndex)
                
                let maxRowIndex = section.items.count - 1
                let rowIndex = Int(arc4random_uniform(UInt32(maxRowIndex)))
                section.items.insert(Date().description, at: rowIndex)
                
                var sections = dataSource.content.sections
                sections[sectionIndex] = section
                
                let update = dataSource.content.update(sections: sections)
                tableView.apply(update: update)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath
    {
        if let proposedTargetSection = try? dataSource.content.section(at: proposedDestinationIndexPath.section)
        {
            if proposedTargetSection.identifier == "commands" {
                return IndexPath(row: 0, section: proposedDestinationIndexPath.section + 1)
            }
        }
        
        return proposedDestinationIndexPath
    }
}
