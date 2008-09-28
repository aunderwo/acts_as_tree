Gem::Specification.new do |s|
  s.name = 'acts_as_tree'
  s.version = '1.0.0'
  s.date = '2008-09-27'
  
  s.summary = "Allows ActiveRecord Models to be easily structured as a tree"
  s.description = ""
  
  s.authors = ["RailsJedi", 'David Heinemeier Hansson']
  s.email = 'railsjedi@gmail.com'
  s.homepage = 'http://github.com/jcnetdev/acts_as_tree'
  
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]

  s.add_dependency 'rails', ['>= 2.1']
   
  s.files = ["README",
             "acts_as_list.gemspec",
             "init.rb",
             "lib/acts_as_list.rb",
             "rails/init.rb"]
      
  s.test_files = ["test/list_test.rb"]
end