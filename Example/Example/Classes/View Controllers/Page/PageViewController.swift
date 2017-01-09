//
//  PageViewController.swift
//  Example
//
//  Created by Marco on 09/01/17.
//  Copyright © 2017 MeLive. All rights reserved.
//

import UIKit
import Monviso

class PageViewController: UIPageViewController {
    let pageDataSource = PageViewControllerDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        pageDataSource.viewControllerFactory.creator = { item, index, _ in
            let viewController = LabelViewController()
            viewController.text = item as? String
            return viewController
        }
        
        pageDataSource.indexer = { viewController, content in
            if let viewController = viewController as? LabelViewController,
                let text = viewController.text,
                let index = (content as! [String]).index(of: text)
            {
                return index
            }
            else {
                throw AccessError.invalidOutput(nil)
            }
        }
        
        self.dataSource = pageDataSource
        
        let update = try! pageDataSource.update(content: ["1", "2", "3"], toShowPages: 0..<1, in: self)
        apply(update: update, animated: false)
    }
}
