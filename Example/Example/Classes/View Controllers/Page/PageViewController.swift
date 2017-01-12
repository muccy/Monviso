//
//  PageViewController.swift
//  Example
//
//  Created by Marco on 09/01/17.
//  Copyright © 2017 MeLive. All rights reserved.
//

import UIKit
import Monviso

class PageViewController: UIPageViewController, UIPageViewControllerDelegate {
    @IBOutlet var backBarButtonItem: UIBarButtonItem!
    @IBOutlet var nextBarButtonItem: UIBarButtonItem!
    
    let pageDataSource: PageViewControllerDataSource = {
        let dataSource = PageViewControllerDataSource()
        
        dataSource.viewControllerFactory.creator = { item, index, _ in
            let viewController = LabelViewController()
            viewController.text = item as? String
            return viewController
        }
        
        dataSource.indexer = { viewController, content in
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
        
        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white

        self.delegate = self
        self.dataSource = pageDataSource
        
        let update = try! pageDataSource.update(content: ["1", "2", "3"], toShowPages: 0...0, in: self)
        apply(update: update, animated: false)
        updatePaginationButtons()
    }
    
    @IBAction func nextButtonPressed() {
        if let indexes = try? pageDataSource.indexesOfContent(displayedIn: self), let firstIndex = indexes.first
        {
            let index = firstIndex + 1
            let update = try! pageDataSource.update(toShowPages: index...index, in: self)
            apply(update: update, animated: true)
            updatePaginationButtons()
        }
    }
    
    @IBAction func previousButtonPressed() {
        if let indexes = try? pageDataSource.indexesOfContent(displayedIn: self), let firstIndex = indexes.first
        {
            let index = firstIndex - 1
            let update = try! pageDataSource.update(toShowPages: index...index, in: self)
            apply(update: update, animated: true)
            updatePaginationButtons()
        }
    }
    
    private func updatePaginationButtons() {
        if let indexes = try? pageDataSource.indexesOfContent(displayedIn: self), let firstIndex = indexes.first, let lastIndex = indexes.last
        {
            backBarButtonItem.isEnabled = firstIndex > 0
            nextBarButtonItem.isEnabled = lastIndex < pageDataSource.content.count - 1
        }
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    {
        if completed == true {
            updatePaginationButtons()
        }
    }
}
