//
//  TableViewController.swift
//  Monviso
//
//  Created by Marco on 16/12/16.
//  Copyright © 2016 MeLive. All rights reserved.
//

import UIKit
import Monviso

class TableViewController: UITableViewController {
    enum Example {
        case playground
        case transition(TransitionExample<[TableViewDataSource.Section]>)
    }
    
    private let dataSource = TableViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.cellFactory.creator = { item, indexPath, tableView in
            if let example = item as? Example {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                
                switch example {
                case .playground:
                    cell.textLabel!.text = "Playground"
                case .transition(let transition):
                    cell.textLabel!.text = transition.name
                }
                
                return cell
            }
            else {
                throw AccessError.noUI(item: item)
            }
        }
        
        tableView.dataSource = dataSource
        dataSource.content.sections = originalSections()
        
//        dataSource.content.sectionIndexItems = [
//            TableViewSectionIndexItem(title: "Section", sectionIdentifier: "section"),
//            TableViewSectionIndexItem(title: "•", sectionIdentifier: "section"),
//            TableViewSectionIndexItem(title: "Row", sectionIdentifier: "row")
//        ]
    }
    
    private func originalSections() -> TableViewDataSource.Content.Sections {
        let playground = TableViewDataSource.Section(items: [ Example.playground ])
 
        let sectionExamples = TransitionExample.defaultSectionExamples { TableViewDataSource.Section(identifier: $0,  items: [""], header: "Section: \($1)") }
        let section = TableViewDataSource.Section(identifier: "section", items: sectionExamples.map { Example.transition($0) }, header: "Section")
        
        let rowExamples = TransitionExample.defaultRowExamples { TableViewDataSource.Section(identifier: $0,  items: $2, header: "Section: \($1)") }
        let row = TableViewDataSource.Section(identifier: "row", items: rowExamples.map { Example.transition($0) }, header: "Row")
        
        return [playground, section, row]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier {
        case .some("transition"):
            if let cell = sender as? UITableViewCell,
                let indexPath = tableView.indexPath(for: cell),
                let item = try? dataSource.content.item(at: indexPath),
                let example = item as? Example,
                let viewController = segue.destination as? TransitionExampleTableViewController
            {
                switch example {
                case .transition(let transition):
                    viewController.transitionExample = transition
                default:
                    break
                }
            }
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = try? dataSource.content.item(at: indexPath)
        
        if let example = item as? Example {
            switch example {
            case .playground:
                performSegue(withIdentifier: "playground", sender: nil)
            case .transition:
                let cell = tableView.cellForRow(at: indexPath)
                performSegue(withIdentifier: "transition", sender: cell)
            }
        }
    }
}
