//
//  CollectionViewController.swift
//  Monviso
//
//  Created by Marco on 16/12/16.
//  Copyright © 2016 MeLive. All rights reserved.
//

import UIKit
import Monviso

class CollectionViewController: UICollectionViewController {
    private var entries = ["1", "2", "3"]
    private let dataSource = CollectionViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.cellFactory.creator = { item, indexPath, collectionView in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelCell", for: indexPath) as! LabelCollectionCell
            
            if let entry = item as? String {
                cell.textLabel.text = entry
            }
            
            return cell
        }
        
        collectionView!.dataSource = dataSource
        dataSource.content.sections = [ CollectionViewDataSource.Section(items: entries) ]
    }

}
