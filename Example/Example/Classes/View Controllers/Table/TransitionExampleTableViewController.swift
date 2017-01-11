//
//  TransitionTableViewController.swift
//  Example
//
//  Created by Marco on 11/01/17.
//  Copyright © 2017 MeLive. All rights reserved.
//

import UIKit
import Monviso

class TransitionExampleTableViewController: UITableViewController {
    var transitionExample: TransitionExample<[TableViewDataSource.Section]>? {
        didSet {
            title = transitionExample?.name
            dataSource.content.sections = transitionExample?.from ?? []
        }
    }
    
    private let dataSource = TableViewDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.cellFactory.creator = { item, indexPath, tableView in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            if let item = item as? CustomStringConvertible {
                cell.textLabel!.text = item.description
            }
            else {
                cell.textLabel!.text = nil
            }
            
            return cell
        }

        tableView.dataSource = dataSource
    }

    @IBAction func performTransition() {
        if let transitionExample = transitionExample {
            let update = dataSource.content.update(sections: transitionExample.to)
            tableView.apply(update: update)
        }
    }
}
