# Monviso

[![CI Status](http://img.shields.io/travis/muccy/Monviso.svg?style=flat)](https://travis-ci.org/muccy/Monviso)
[![Version](https://img.shields.io/cocoapods/v/Monviso.svg?style=flat)](http://cocoadocs.org/docsets/Monviso)
[![License](https://img.shields.io/cocoapods/l/Monviso.svg?style=flat)](http://cocoadocs.org/docsets/Monviso)
[![Platform](https://img.shields.io/cocoapods/p/Monviso.svg?style=flat)](http://cocoadocs.org/docsets/Monviso)
![Xcode 8.2+](https://img.shields.io/badge/Xcode-8.2%2B-blue.svg)
![iOS 8.0+](https://img.shields.io/badge/iOS-8.0%2B-blue.svg)
![Swift 3.0+](https://img.shields.io/badge/Swift-3.0%2B-orange.svg)

`Monviso` is a framework which gives data source structure for `UITableView`, `UICollectionView` and `UIPageViewController`.
You create a data source, you customize it with closures, you insert contents in provided structures and you set data source of your client object: that's it!
What is more, this framework provides an automated system to apply content updates to `UITableView` and `UICollectionView` animating transitions.

## How

### Sectioned views: using with `UITableView` and `UICollectionView`

*In this example I will use `UITableView`, but `UICollectionView` is very similar.*

Say you have a `UITableViewController` subclass.

```swift
class TableViewController: UITableViewController {
}
```

Start creating a data source.

```swift
import Monviso

class TableViewController: UITableViewController {
    private let dataSource = TableViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
    }
}
```

You need to provide content to you user.

```swift
import Monviso

struct Flower {
    let name: String
}

class TableViewController: UITableViewController {
    private let flowers = [ Flower(name: "Tulip"), Flower(name: "Rose") ]
    private let dataSource: TableViewDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.content.sections = [ TableViewDataSource.Section(identifier: "flowers", items: flowers, header: "Flowers") ]
        tableView.dataSource = dataSource
    }
}
```

You data source needs to know how to display content.

```swift
import Monviso

struct Flower {
    let name: String
}

class TableViewController: UITableViewController {
    private let flowers = [ Flower(name: "Tulip"), Flower(name: "Rose") ]
    private let dataSource: TableViewDataSource {
        let dataSource = TableViewDataSource()
        
        dataSource.cellFactory.creator = { item, indexPath, tableView in
            if let flower = item as? Flower {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.textLabel!.text = flower.name
                return cell
            }
            else {
                throw AccessError.noUI(for: item)
            }
        }
        
        return dataSource
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.content.sections = [ TableViewDataSource.Section(identifier: "flowers", items: flowers, header: "Flowers") ]
        tableView.dataSource = dataSource
    }
}
```
That's all. This is the minimal setup to display static contents.
If you would like to update contents with animation, you should change a couple of things. First of all, you have to make your contents able to detect updates using embedded [Ferrara](https://github.com/muccy/Ferrara).

```swift
import Monviso
import Ferrara

struct Flower: Identifiable, Matchable, Equatable {
    let identifier: String
    let name: String
    
    public static func ==(lhs: Flower, rhs: Flower) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.name == lhs.name
    }
}
```

Then, you should apply changes to your client.

```swift
var flowers = [ Flower(identifier: "tulip", name: "Tulip"), Flower(identifier: "rose", name: "Rose") ]

func updateToEmojiFlowers() {
    flowers = [ Flower(identifier: "tulip", name: "🌷"), Flower(identifier: "rose", name: "🌹") ]
    let update = dataSource.content.update(sections: [ TableViewDataSource.Section(identifier: "flowers", items: flowers, header: "Flowers") ])
    tableView.apply(update: update)
}
```

Nothing more than this.

### `UIPageViewController` integration

`Monviso` can help you when you need to display a finite number of pages inside a `UIPageViewController`.

Start creating a data source.

```swift
import Monviso

class PageViewController: UIPageViewController {
    let dataSource = PageViewControllerDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = pageDataSource
    }
}
```

You need to provide content to you user.

```swift
import Monviso

struct Flower {
    let name: String
}

class PageViewController: UIPageViewController {
    private let flowers = [ Flower(name: "Tulip"), Flower(name: "Rose") ]
    let dataSource = PageViewControllerDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = pageDataSource
    }
}
```

You data source needs to know how to display content and how to associate view controllers to content index.

```swift
import Monviso

struct Flower: Equatable {
    let name: String
    
    public static func ==(lhs: Flower, rhs: Flower) -> Bool {
        return lhs.name == lhs.name
    }
}

class PageViewController: UIPageViewController {
    private let flowers = [ Flower(name: "Tulip"), Flower(name: "Rose") ]
    private let dataSource: PageViewControllerDataSource {
        let dataSource = PageViewControllerDataSource()
        
        dataSource.viewControllerFactory.creator = { item, index, _ in
            return FlowerViewController(flower: Flower)
        }
        
        dataSource.indexer = { viewController, content in
            if let viewController = viewController as? FlowerViewController,
                let index = (content as! [Flower]).index(of: viewController.flower)
            {
                return index
            }
            else {
                throw AccessError.invalidOutput(nil)
            }
        }
        
        return dataSource
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = pageDataSource
    }
}
```

Now you need to inform you page view controller to display first page.

```swift
import Monviso

struct Flower: Equatable {
    let name: String
    
    public static func ==(lhs: Flower, rhs: Flower) -> Bool {
        return lhs.name == lhs.name
    }
}

class PageViewController: UIPageViewController {
    private let flowers = [ Flower(name: "Tulip"), Flower(name: "Rose") ]
    private let dataSource: PageViewControllerDataSource {
        let dataSource = PageViewControllerDataSource()
        
        dataSource.viewControllerFactory.creator = { item, index, _ in
            return FlowerViewController(flower: Flower)
        }
        
        dataSource.indexer = { viewController, content in
            if let viewController = viewController as? FlowerViewController,
                let index = (content as! [Flower]).index(of: viewController.flower)
            {
                return index
            }
            else {
                throw AccessError.invalidOutput(nil)
            }
        }
        
        return dataSource
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = pageDataSource
        
        let update = try! pageDataSource.update(content: flowers, toShowPages: 0...0, in: self)
        apply(update: update, animated: false)
    }
}
```

That's all.

Now, implementing page swap methods is trivial.

```swift
func goToNextPage(animated: Bool = true) throws {
    let indexes = try pageDataSource.indexesOfContent(displayedIn: self)
    let index = indexes.first! + 1
    let update = try! pageDataSource.update(toShowPages: index...index, in: self)
    apply(update: update, animated: animated)
}

func canGoToNextPage() -> Bool {
    if let indexes = try? pageDataSource.indexesOfContent(displayedIn: self), let lastIndex = indexes.last
    {
        return lastIndex < pageDataSource.content.count - 1
    }
    else {
        return false
    }
}
```

## Requirements

* iOS 8.2 SDK.
* Minimum deployment target: iOS 8.

## Installation

`Monviso` is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "Monviso"
	
## Author

Marco Muccinelli, muccymac@gmail.com

## License

`Monviso` is available under the MIT license. See the LICENSE file for more info.

## About the name

![Monviso](https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/VisoColleGianna.jpg/800px-VisoColleGianna.jpg)

Monte Viso or Monviso, is the highest mountain of the Cottian Alps. It is located in Italy close to the French border.On a very clear day it can be seen from the spires of the Milan Cathedral. On the northern slopes of Monte Viso are the headwaters of the Po, the longest Italian river. Po river source, data source... that's why ;)