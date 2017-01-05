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
    
    private typealias CellFactory = TableViewCellFactory<Entry, UITableViewCell>
    private typealias DataSource = TableViewDataSource<Entry, CellFactory>
    
    private var entries = [Entry(title: "1"), Entry(title: "2"), Entry(title: "3")]
    
    private let dataSource: DataSource = {
        let cellFactory = CellFactory() { item, indexPath, tableView in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel!.text = item.title
            return cell
        }
        
        var dataSource = DataSource(cellFactory: cellFactory)
        
        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = dataSource
        
        dataSource.content = [ Section(items: entries) ]
    }
}
