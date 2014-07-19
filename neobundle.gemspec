# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'neobundle/version'

Gem::Specification.new do |spec|
  spec.name          = "neobundle"
  spec.version       = NeoBundle::VERSION
  spec.authors       = ["Yuichi Murata"]
  spec.email         = ["mrk21info+rubygems@gmail.com"]
  spec.summary       = %q{NeoBundle command line tools.}
  spec.description   = %q{NeoBundle command line tools.}
  spec.homepage      = "https://github.com/mrk21/neobundle-cmd"
  spec.license       = "MIT"
  
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
end
