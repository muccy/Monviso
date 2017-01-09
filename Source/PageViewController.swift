import Foundation

/// Data source of page view controller
final public class PageViewControllerDataSource: NSObject, DataSource, UIPageViewControllerDataSource
{
    public typealias Content = [Any]
    public typealias ViewControllerFactory = ItemUIFactory<Content.Iterator.Element, Content.Index, UIPageViewController, UIViewController?>
    public typealias Indexer = (UIViewController, Content) throws -> Content.Index
    
    /// Content of page view controller data source
    public var content = Content()
    /// Factory which produces view controllers
    public var viewControllerFactory = ViewControllerFactory() { _, _, _ in return nil }
    /// Closure which associates view controller to index of content item. You need to provide a valid implementation of this closure.
    public var indexer: Indexer = { viewController in throw AccessError.invalidInput(viewController) }
    
    // MARK: UIPageViewControllerDataSource
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        do {
            let index = try indexer(viewController, content)
            let previousIndex = index - 1
            if let item = try? content.element(at: previousIndex) {
                return try viewControllerFactory.UIElement(for: item, at: previousIndex, for: pageViewController)
            }
            else {
                return nil
            }
        }
        catch let error {
            fatalError("Data source can not create a view controller before \(viewController): \(error)")
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        do {
            let index = try indexer(viewController, content)
            let nextIndex = index + 1
            if let item = try? content.element(at: nextIndex) {
                return try viewControllerFactory.UIElement(for: item, at: nextIndex, for: pageViewController)
            }
            else {
                return nil
            }
        }
        catch let error {
            fatalError("Data source can not create a view controller after \(viewController): \(error)")
        }
    }
}

/// Data source of page view controller which displays a page indicator
final public class PageViewControllerWithIndicatorDataSource: NSObject, DataSource, UIPageViewControllerDataSource
{
    private let dataSource = PageViewControllerDataSource()
    
    /// A clouse which provides counter for page indicator
    public var presentationCounter: (PageViewControllerDataSource.Content) -> Int = { content in
        return content.count
    }
    
    /// A clousure which provides current view controller for client page view controller
    public var currentViewControllerProvider: (UIPageViewController) throws -> UIViewController = { pageViewController in
        if let viewControllers = pageViewController.viewControllers,
            let viewController = try? viewControllers.element(at: 0)
        {
            return viewController
        }
        else {
            throw AccessError.invalidOutput(nil)
        }
    }
    /// A clousure which returns presentation index for page indicator. Actual
    /// default implementation calls indexer with the result of currentViewControllerProvider
    public var presentationIndexer: (PageViewControllerDataSource.Content, UIPageViewController) throws -> Int = { _, _ in throw AccessError.invalidOutput(nil) }
    
    public var content: PageViewControllerDataSource.Content {
        get { return dataSource.content }
        set { dataSource.content = newValue }
    }
    
    public var viewControllerFactory: PageViewControllerDataSource.ViewControllerFactory {
        get { return dataSource.viewControllerFactory }
        set { dataSource.viewControllerFactory = newValue }
    }
    
    public var indexer: PageViewControllerDataSource.Indexer {
        get { return dataSource.indexer }
        set { dataSource.indexer = newValue }
    }
    
    public required override init() {
        super.init()
        self.presentationIndexer = { [unowned self] content, pageViewController in
            let currentViewController = try self.currentViewControllerProvider(pageViewController)
            return try self.indexer(currentViewController, content)
        }
    }
    
    // MARK: UIPageViewControllerDataSource
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        return dataSource.pageViewController(pageViewController, viewControllerBefore: viewController)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        return dataSource.pageViewController(pageViewController, viewControllerAfter: viewController)
    }
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int
    {
        return presentationCounter(content)
    }
    
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int
    {
        do {
            return try presentationIndexer(content, pageViewController)
        }
        catch let error {
            fatalError("Data source can not get a valid presentation index: \(error)")
        }
    }
}
