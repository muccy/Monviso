//
//  TransitionExampleCollectionViewController.swift
//  Example
//
//  Created by Marco on 12/01/17.
//  Copyright © 2017 MeLive. All rights reserved.
//

import UIKit
import Monviso

class TransitionExampleCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout
{
    var transitionExample: TransitionExample<[CollectionViewDataSource.Section]>? {
        didSet {
            title = transitionExample?.name
            dataSource.content.sections = transitionExample?.from ?? []
        }
    }
    
    private let gridLayouter: CollectionGridLayouter = {
        var layouter = CollectionGridLayouter()
        layouter.itemHeight = 40.0
        return layouter
    }()
    
    private let dataSource: CollectionViewDataSource = {
        let dataSource = CollectionViewDataSource()
        
        dataSource.cellFactory.creator = { item, indexPath, collectionView in
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelCell", for: indexPath) as? LabelCollectionCell
            {
                if let item = item as? CustomStringConvertible {
                    cell.textLabel!.text = item.description
                }
                else {
                    cell.textLabel!.text = nil
                }
                
                return cell
            }
            else {
                throw AccessError.noUI(item: item)
            }
        }
        
        return dataSource
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.supplementaryViewFactory.creator = { [unowned self] section, indexPath, collectionView in
            return self.gridLayouter.headerView(for: collectionView, at: indexPath, title: section.userInfo["name"] as? String)
        }
        
        collectionView!.dataSource = dataSource
    }
    
    @IBAction func performTransition() {
        if let transitionExample = transitionExample {
            let update = dataSource.content.update(sections: transitionExample.to)
            collectionView!.apply(update: update)
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return gridLayouter.itemSize(for: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection sectionIndex: Int) -> CGSize
    {
        let section = try! dataSource.content.section(at: sectionIndex)
        return gridLayouter.headerSize(for: collectionView, title: section.userInfo["name"] as? String)
    }
}
