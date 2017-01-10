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
                }
                
                return cell
            }
            else {
                throw AccessError.noUI(item: item)
            }
        }
        
        tableView.dataSource = dataSource
        dataSource.content.sections = [
            TableViewDataSource.Section(items: [ Example.playground ]),
            TableViewDataSource.Section(items: [], header: "Section"),
            TableViewDataSource.Section(items: [], header: "Row")
        ]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = try? dataSource.content.item(at: indexPath)
        
        if let example = item as? Example {
            switch example {
            case .playground:
                performSegue(withIdentifier: "playground", sender: nil)
            }
        }
    }
}
