Pod::Spec.new do |s|
  s.name = "DDMathParser"
  s.version = "0.1"
  s.summary = "NSString → NSNumber"
  s.description = <<-DESC
                   * NSString → NSNumber
                   DESC
  s.homepage = "https://github.com/davedelong/DDMathParser"
  s.license = {
    :type => 'MIT'
  }
  s.platform = :ios, '7.0'
  s.source = {
    :git => 'https://github.com/davedelong/DDMathParser.git',
    :tag => s.version.to_s
  }
  s.source_files = 'DDMathParser/*.{h,m}'
  s.frameworks = 'Foundation'
  s.requires_arc = true
end
