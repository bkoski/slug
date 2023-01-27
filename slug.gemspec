# -*- encoding: utf-8 -*-
# stub: slug 4.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "slug"
  s.version = "5.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Ben Koski"]
  s.date = "2018-11-17"
  s.description = "Simple, straightforward slugs for your ActiveRecord models."
  s.email = "ben.koski@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    "LICENSE",
    "README.md",
    "Rakefile",
    "lib/slug.rb",
    "lib/slug/slug.rb",
    "slug.gemspec",
    "test/models.rb",
    "test/schema.rb",
    "test/test_helper.rb",
    "test/slug_test.rb"
  ]
  s.homepage = "http://github.com/bkoski/slug"
  s.rubygems_version = "2.2.0"
  s.summary = "Simple, straightforward slugs for your ActiveRecord models."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
      s.add_runtime_dependency(%q<activerecord>, ["> 3.0.0"])
      s.add_runtime_dependency(%q<activesupport>, ["> 3.0.0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
      s.add_dependency(%q<activerecord>, ["> 3.0.0"])
      s.add_dependency(%q<activesupport>, ["> 3.0.0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
    s.add_dependency(%q<activerecord>, ["> 3.0.0"])
    s.add_dependency(%q<activesupport>, ["> 3.0.0"])
  end
end

