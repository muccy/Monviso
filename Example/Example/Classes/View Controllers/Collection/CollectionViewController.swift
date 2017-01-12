//
//  CollectionViewController.swift
//  Monviso
//
//  Created by Marco on 16/12/16.
//  Copyright © 2016 MeLive. All rights reserved.
//

import UIKit
import Monviso

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout
{
    enum Example {
        case playground
        case transition(TransitionExample<[CollectionViewDataSource.Section]>)
    }
    
    private let dataSource = CollectionViewDataSource()
    private let gridLayouter = CollectionGridLayouter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        dataSource.cellFactory.creator = { item, indexPath, collectionView in
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelCell", for: indexPath) as? LabelCollectionCell,
                let example = item as? Example
            {
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
        
        dataSource.supplementaryViewFactory.creator = { section, indexPath, collectionView in
            return self.gridLayouter.headerView(for: collectionView, at: indexPath, title: section.userInfo["name"] as? String)
        }
        
        collectionView!.dataSource = dataSource
        dataSource.content.sections = originalSections()
    }

    private func originalSections() -> CollectionViewDataSource.Content.Sections {
        let playground = CollectionViewDataSource.Section(items: [ Example.playground ])
        
        let sectionExamples = TransitionExample.defaultSectionExamples { CollectionViewDataSource.Section(identifier: $0, items: [""], userInfo: ["name": $1]) }
        let section = CollectionViewDataSource.Section(identifier: "section", items: sectionExamples.map { Example.transition($0) }, userInfo: ["name": "Section"])
        
        let rowExamples = TransitionExample.defaultRowExamples { CollectionViewDataSource.Section(identifier: $0, items: $2, userInfo: ["name": $1]) }
        let row = CollectionViewDataSource.Section(identifier: "row", items: rowExamples.map { Example.transition($0) }, userInfo: ["name": "Row"])
        
        return [playground, section, row]
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let item = try? dataSource.content.item(at: indexPath)
        
        if let example = item as? Example {
            switch example {
            case .playground:
                performSegue(withIdentifier: "playground", sender: nil)
            case .transition:
                let cell = collectionView.cellForItem(at: indexPath)
                performSegue(withIdentifier: "transition", sender: cell)
            }
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
