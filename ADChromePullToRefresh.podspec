Pod::Spec.new do |s|
  s.name             = "ADChromePullToRefresh"
  s.version          = "1.0.0"
  s.summary          = "Google Chrome iOS app pull to refresh"
  s.description      = <<-DESC
                       Yet another pull to refresh for your needs
                       DESC
  s.homepage         = "https://github.com/Antondomashnev/ADChromePullToRefresh"
  s.license          = 'MIT'
  s.author           = { "Anton Domashnev" => "antondomashnev@gmail.com" }
  s.source           = { :git => "https://github.com/Antondomashnev/ADChromePullToRefresh.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.1'
  s.requires_arc = true

  s.source_files = 'Source/*'

  s.frameworks = 'UIKit'
end
