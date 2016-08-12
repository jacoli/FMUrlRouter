Pod::Spec.new do |s|
  s.name         = "FMUrlRouter"
  s.version      = "1.0.0"
  s.summary      = "A simple way to manage page route of native or h5."
  s.homepage     = "https://github.com/jacoli/FMUrlRouter"
  s.license      = "MIT"
  s.authors      = { "jacoli" => "jaco.lcg@gmail.com" }
  s.source       = { :git => "https://github.com/jacoli/FMUrlRouter.git", :tag => "1.0.0" }
  s.frameworks   = 'Foundation', 'UIKit'
  s.platform     = :ios, '7.0'
  s.source_files = 'FMUrlRouter/*.{h,m}'
  s.requires_arc = true
end
