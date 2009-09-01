# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{slug}
  s.version = "0.5.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Koski"]
  s.date = %q{2009-09-01}
  s.description = %q{Simple, straightforward slugs for your ActiveRecord models.}
  s.email = %q{ben.koski@gmail.com}
  s.files = ["README.rdoc", "VERSION.yml", "lib/slug", "lib/slug/ascii_approximations.rb", "lib/slug/slug.rb", "lib/slug.rb", "test/models.rb", "test/schema.rb", "test/test_helper.rb", "test/test_slug.rb"]
  s.homepage = %q{http://github.com/bkoski/slug}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Simple, straightforward slugs for your ActiveRecord models.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
    else
      s.add_dependency(%q<activerecord>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
  end
end
