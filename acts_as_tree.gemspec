Gem::Specification.new do |s|
  s.name = 'acts_as_tree'
  s.version = '1.0.4'
  s.date = '2008-10-02'
  
  s.summary = "Allows ActiveRecord Models to be easily structured as a tree"
  s.description = ""
  
  s.authors = ["RailsJedi", 'David Heinemeier Hansson']
  s.email = 'railsjedi@gmail.com'
  s.homepage = 'http://github.com/aunderwo/acts_as_tree'
  
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]

  s.add_dependency 'rails', ['>= 2.1']
   

  s.files =  ["README",
               "Rakefile",
               "acts_as_tree.gemspec",
               "init.rb",
               "lib/active_record/acts/tree.rb",
               "lib/acts_as_tree.rb",
               "rails/init.rb"]
      
  s.test_files = ["test/abstract_unit.rb",
                   "test/acts_as_tree_test.rb",
                   "test/database.yml",
                   "test/fixtures/mixin.rb",
                   "test/fixtures/mixins.yml",
                   "test/schema.rb"]
end
