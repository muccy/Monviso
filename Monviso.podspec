Pod::Spec.new do |s|
  s.name         = "Monviso"
  s.version      = "0.0.1"
  s.summary      = "Data sources in protocol-oriented, type-safe, modular, swifty sauce"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
  Data sources in protocol-oriented, type-safe, modular, swifty sauce
                   DESC

  s.homepage     = "https://github.com/muccy/Monviso"
  s.license      = "MIT"
  s.author       = { "Marco Muccinelli" => "muccymac@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/muccy/Monviso.git", :tag => s.version }
  s.source_files  = "Source", "Source/**/*.{swift,h,m}"
  
  s.dependency  "Ferrara", "~> 1.1"
end
