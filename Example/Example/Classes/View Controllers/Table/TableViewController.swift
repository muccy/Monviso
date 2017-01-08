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
    private struct Entry {
        let title: String
    }
 
    private var entries = [Entry(title: "1"), Entry(title: "2"), Entry(title: "3")]
    
    private let dataSource: TableViewDataSource = {
        let cellFactory = TableViewDataSource.CellFactory() { item, indexPath, tableView in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            if let entry = item as? Entry {
                cell.textLabel!.text = entry.title
            }
            
            return cell
        }
        
        return TableViewDataSource(cellFactory: cellFactory)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = dataSource
        
        dataSource.content.sections = [ TableViewDataSource.Section(items: entries) ]
    }
}
