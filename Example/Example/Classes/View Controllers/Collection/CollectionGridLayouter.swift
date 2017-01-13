//
//  CollectionGridLayouter.swift
//  Example
//
//  Created by Marco on 11/01/17.
//  Copyright © 2017 MeLive. All rights reserved.
//

import UIKit

struct CollectionGridLayouter {
    var itemsPerRow = 2
    var itemHeight: CGFloat = 70.0
    var headerReuseIdentifier = "Header"
    
    func headerView(for collectionView: UICollectionView, at indexPath: IndexPath, title: String? = nil) -> LabelCollectionReusableView
    {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! LabelCollectionReusableView
        view.textLabel.text = title
        return view
    }
    
    func itemSize(for collectionView: UICollectionView) -> CGSize {
        var width = collectionView.bounds.width
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        {
            width = width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * CGFloat(itemsPerRow - 1)
        }
        
        return CGSize(width: width / CGFloat(itemsPerRow), height: itemHeight)
    }
    
    func headerSize(for collectionView: UICollectionView, title: String?) -> CGSize
    {
        if let title = title, title.characters.count > 0 {
            return CGSize(width: collectionView.bounds.width, height: 30.0)
        }
        else {
            return CGSize(width: 0.0, height: 0.0) // no header
        }
    }
}
