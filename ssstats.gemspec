# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ssstats/version'

Gem::Specification.new do |spec|
  spec.name          = 'ssstats'
  spec.version       = Ssstats::VERSION
  spec.authors       = ["Costa Shapiro", "Owlytics Healthcare (former BandManage)"]
  spec.email         = ['costa@mouldwarp.com', 'contact@owlytics.com']
  spec.summary       = "Stupid Simple Statistics (for unstructured data)"
  spec.description   = "Consumes simple data structures, produces elementary statistics"
  spec.homepage      = "https://github.com/bandmanage/ssstats"

  spec.files         = `find . -print0`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
