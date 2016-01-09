# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "heapr/version"

Gem::Specification.new do |spec|
  spec.name          = "heapr"
  spec.version       = Heapr::VERSION
  spec.authors       = ["Tim Pease"]
  spec.email         = ["tim.pease@gmail.com"]
  spec.summary       = %q{A tool for analyzing Ruby heap dumps}
  spec.description   = %q{Heapr is a tool for analyzing Ruby heap dumps. It
                          provides a small web application that you can run
                          locally for analyzing and interacting with the
                          information stored in the heap dump.}
  spec.homepage      = "https://github.com/TwP/heapr"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "amalgalite", "~> 1.5"
  spec.add_dependency "sinatra",    "~> 1.4"

  spec.add_development_dependency "bundler",  "~> 1.5"
  spec.add_development_dependency "minitest", "~> 5.8"
  spec.add_development_dependency "rake",     "~> 10.4"
end
