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

public extension PageViewControllerDataSource {
    /// Get index for view controller
    ///
    /// - Parameters:
    ///   - viewController: View controller bound to an item of content
    ///   - content: Content which contains item for viewController
    /// - Returns: Index of item represented by viewController
    /// - Throws: When index could not be found
    public func indexOfContent(boundTo viewController: UIViewController, in content: Content) throws -> Content.Index
    {
        return try indexer(viewController, content)
    }
    
    /// Get indexes for view controllers
    ///
    /// - Parameters:
    ///   - viewControllers: View controllers bound to some items of content
    ///   - content: Content which contains items for viewControllers
    /// - Returns: Indexes of items represented by viewControllers
    /// - Throws: When indexes could not be found
    public func indexesOfContent(boundTo viewControllers: [UIViewController], in content: Content) throws -> IndexSet
    {
        var indexes = IndexSet()
        
        for viewController in viewControllers {
            let index = try indexOfContent(boundTo: viewController, in: content)
            indexes.insert(index)
        } // for
        
        return indexes
    }
    
    public typealias Update = (viewControllers: [UIViewController], direction: UIPageViewControllerNavigationDirection)
    
    /// Set content and calculate view controllers and direction to be applied to page view controller
    ///
    /// - Parameters:
    ///   - content: New content to be set
    ///   - range: Content pages to be shown
    ///   - currentViewControllers: Current displayed view controllers in page view controller
    /// - Returns: A tuple which contains new view controllers and proposed transition direction
    /// - Throws: When something goes wrong :)
    public func update(content: Content, toShowPages range: CountableRange<Content.Index>, in pageViewController: UIPageViewController) throws -> Update
    {
        // Set new content
        let oldContent = self.content
        self.content = content
        
        // Create new view controller for page in new content
        let viewControllers = try self.viewControllers(for: content, clampedTo: range, in: pageViewController)
        
        // Get best direction for transition
        let direction = try self.direction(from: pageViewController.viewControllers, for: oldContent, to: content)
        
        // Pack and return
        return (viewControllers: viewControllers, direction: direction)
    }
    
    private func viewControllers(for content: Content, clampedTo range: CountableRange<Content.Index>, in pageViewController: UIPageViewController) throws -> [UIViewController]
    {
        guard range.lowerBound >= 0 else {
            throw AccessError.outOfBounds(index: range.lowerBound, validRange: 0..<content.count)
        }
        
        guard range.upperBound < content.count else {
            throw AccessError.outOfBounds(index: range.upperBound, validRange: 0..<content.count)
        }
        
        return try range.map { index in
            let page = content[index]
            guard let viewController = try viewControllerFactory.UIElement(for: page, at: index, for: pageViewController) else { throw AccessError.invalidOutput(nil) }
            return viewController
        }
    }
    
    private func direction(from viewControllers: [UIViewController]?, for oldContent: Content, to newContent: Content) throws -> UIPageViewControllerNavigationDirection
    {
        if let firstViewController = viewControllers?.first {
            let firstViewControllerIndex = try indexOfContent(boundTo: firstViewController, in: oldContent)
            let lastNewIndex = newContent.count - 1
            
            if lastNewIndex < firstViewControllerIndex {
                return .reverse
            }
        }
        
        return .forward
    }
}

/// Data source of page view controller which displays a page indicator. It is made
/// composing base PageViewControllerDataSource.
final public class PageViewControllerWithIndicatorDataSource: NSObject, DataSource, UIPageViewControllerDataSource
{
    public let baseDataSource = PageViewControllerDataSource()
    
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
    public var presentationIndexer: (UIPageViewController, PageViewControllerDataSource.Content) throws -> Int = { _, _ in throw AccessError.invalidOutput(nil) }
    
    public var content: PageViewControllerDataSource.Content {
        get { return baseDataSource.content }
        set { baseDataSource.content = newValue }
    }
    
    public required override init() {
        super.init()
        self.presentationIndexer = { [unowned self] pageViewController, content in
            let currentViewController = try self.currentViewControllerProvider(pageViewController)
            return try self.baseDataSource.indexer(currentViewController, content)
        }
    }
    
    // MARK: UIPageViewControllerDataSource
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        return baseDataSource.pageViewController(pageViewController, viewControllerBefore: viewController)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        return baseDataSource.pageViewController(pageViewController, viewControllerAfter: viewController)
    }
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int
    {
        return presentationCounter(content)
    }
    
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int
    {
        do {
            return try presentationIndexer(pageViewController, content)
        }
        catch let error {
            fatalError("Data source can not get a valid presentation index: \(error)")
        }
    }
}

public extension UIPageViewController {
    /// Sets the view controllers to be displayed in a safe way (see http://stackoverflow.com/a/25549277)
    ///
    /// - Parameters:
    ///   - viewControllers: The view controller or view controllers to be displayed.
    ///   - direction: The navigation direction.
    ///   - animated: A Boolean value that indicates whether the transition is to be animated.
    ///   - completion: A Boolean value that indicates whether the transition is to be animated.
    public func setSafelyViewControllers(_ viewControllers: [UIViewController]?, direction: UIPageViewControllerNavigationDirection, animated: Bool, completion: ((Bool) -> Void)? = nil)
    {
        if animated == false {
            setViewControllers(viewControllers, direction: direction, animated: animated, completion: completion)
            return
        }
        
        setViewControllers(viewControllers, direction: direction, animated: animated, completion: { finished in
            if finished == true {
                DispatchQueue.main.async {
                    self.setViewControllers(viewControllers, direction: direction, animated: false, completion: completion)
                }
            }
            else if let completion = completion {
                completion(finished)
            }
        })
    }
    
    /// Set view controllers with page view data source update
    ///
    /// - Parameters:
    ///   - update: The update to apply
    ///   - animated: A Boolean value that indicates whether the transition is to be animated.
    ///   - completion: A Boolean value that indicates whether the transition is to be animated.
    public func apply(update: PageViewControllerDataSource.Update, animated: Bool, completion: ((Bool) -> Void)? = nil)
    {
        setSafelyViewControllers(update.viewControllers, direction: update.direction, animated: animated, completion: completion)
    }
}
