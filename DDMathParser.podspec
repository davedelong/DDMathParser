Pod::Spec.new do |s|

  s.name         = "MegaBits-DDMathParser"
  s.version      = "1.0.0"
  s.summary      = "NSString => NSNumber"

  s.homepage     = "https://github.com/MegaBits/DDMathParser"

  # s.license      = 'MIT (example)'
  # s.license      = { :type => 'MIT', :file => 'FILE_LICENSE' }

  s.author             = { "MegaBits" => "dev@megabitsapp.com" }
  s.platform     = :ios

  s.source       = {
      :git => "https://github.com/MegaBits/DDMathParser.git",
      :tag => "v1.0.0"
  }

  s.source_files  = 'DDMathParser/*.{h,m}'
  s.requires_arc = true

end
