Pod::Spec.new do |s|
  s.name         = "Monviso"
  s.version      = "1.0.0"
  s.summary      = "Data sources in protocol-oriented, type-safe, modular, swifty sauce"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
  A framework which gives data source structure for UITableView, UICollectionView and UIPageViewController.
  You create a data source, you customize it with closures, you insert contents in provided structure and you set data source of your client object: that's it!
  What is more, this framework provides an automated system to apply content updates to UITableView and UICollectionView animating transitions.
                   DESC

  s.homepage     = "https://github.com/muccy/#{s.name}"
  s.license      = "MIT"
  s.author       = { "Marco Muccinelli" => "muccymac@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/muccy/#{s.name}.git", :tag => s.version }
  s.source_files  = "Source", "Source/**/*.{swift,h,m}"
  
  s.dependency  "Ferrara", "~> 1.1"
end
