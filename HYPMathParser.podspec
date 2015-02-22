Pod::Spec.new do |s|
  s.name = "HYPMathParser"
  s.version = "0.3"
  s.summary = "A fork of DDMathParser but with a Podfile"
  s.description = <<-DESC
                   * NSString → NSNumber
                   DESC
  s.homepage = "https://github.com/hyperoslo/HYPMathParser"
  s.license = {
    :type => 'MIT',
    :file => 'LICENSE.md'
  }
  s.author = { "Hyper" => "teknologi@hyper.no" }
  s.platform = :ios, '7.0'
  s.source = {
    :git => 'https://github.com/hyperoslo/HYPMathParser.git',
    :tag => s.version.to_s
  }
  s.source_files = 'DDMathParser/*.{h,m}'
  s.frameworks = 'Foundation'
  s.requires_arc = true
end
