//
//  PlaygroundCollectionViewController.swift
//  Example
//
//  Created by Marco on 12/01/17.
//  Copyright © 2017 MeLive. All rights reserved.
//

import UIKit
import Monviso
import Ferrara

class PlaygroundCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout
{
    private let dataSource: CollectionViewDataSource = {
        let dataSource = CollectionViewDataSource()
        
        dataSource.cellFactory.creator = { item, indexPath, collectionView in
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LabelCell", for: indexPath) as? LabelCollectionCell
            {
                if let command = item as? Playground.Command {
                    cell.textLabel!.text = command.rawValue
                }
                else {
                    cell.textLabel!.text = item as? String
                }
                
                return cell
            }
            else {
                throw AccessError.noUI(item: item)
            }
        }
        
        dataSource.moveHandler.attemptTest = { attempt in
            let item = try? attempt.content.item(at: attempt.from)
            return (item is Playground.Command) == false
        }
        
        return dataSource
    }()
    
    private let gridLayouter: CollectionGridLayouter = {
        var layouter = CollectionGridLayouter()
        layouter.itemHeight = 40.0
        return layouter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.supplementaryViewFactory.creator = { [unowned self] section, indexPath, collectionView in
            return self.gridLayouter.headerView(for: collectionView, at: indexPath, title: section.userInfo["name"] as? String)
        }
        
        collectionView!.dataSource = dataSource
        dataSource.content.sections = originalSections()
        
        setEditing(true, animated: false)
    }

    private func originalSections() -> CollectionViewDataSource.Content.Sections {
        return Playground.defaultSections { identifier, name, items in
            let name = name == nil ? "" : name!
            return CollectionViewDataSource.Section(identifier: identifier, items: items, userInfo: ["name": name])
        }
    }
    
    @IBAction func refreshButtonPressed() {
        let update = dataSource.content.update(sections: originalSections())
        collectionView!.apply(update: update)
    }

    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
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
                collectionView.apply(update: update)
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
