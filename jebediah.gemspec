Gem::Specification.new do |s|
  s.name        = 'jebediah'
  s.executables << 'jeb'
  s.version     = '1.0.1'
  s.date        = '2014-02-04'
  s.summary     = "Converts hashes to names, and names to hashes"
  s.description = "A Gem to convert git hashes to memorable names, and vice versa"
  s.authors     = ["Jonas Acres"]
  s.email       = 'jonas@becuddle.com'
  s.files       = ['dictionaries/adverbs.txt', 'dictionaries/animals.txt', 'dictionaries/verbs.txt', 'lib/jebediah.rb']
  s.homepage    = 'http://github.com/jonasacres/jebediah'
  s.license     = 'MIT'
end
