//
//  LabelViewController.swift
//  Example
//
//  Created by Marco on 09/01/17.
//  Copyright © 2017 MeLive. All rights reserved.
//

import UIKit

class LabelViewController: UIViewController {
    weak var textLabel: UILabel?
    var text: String? {
        didSet {
            textLabel?.text = text
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textLabel = UILabel(frame: view.bounds)
        textLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textLabel.textAlignment = .center
        textLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        view.addSubview(textLabel)
        self.textLabel = textLabel

        textLabel.text = text
    }
}
