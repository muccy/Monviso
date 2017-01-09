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
    private var entries = ["1", "2", "3"]
    private let dataSource = TableViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        dataSource.cellFactory.creator = { item, indexPath, tableView in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            if let entry = item as? String {
                cell.textLabel!.text = entry
            }
            
            return cell
        }
        
        tableView.dataSource = dataSource
        dataSource.content.sections = [ TableViewDataSource.Section(items: entries) ]
    }
}
