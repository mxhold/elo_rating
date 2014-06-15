Gem::Specification.new do |s|
  s.name        = 'elo_rating'
  s.version     = '0.1.0'
  s.date        = '2014-06-14'
  s.summary     = "Tiny library for calculating Elo ratings"
  s.description = "Tiny library for calculating Elo ratings. Handles multiplayer matches and allows for custom k-factor functions."
  s.author      = "Max Holder"
  s.email       = 'mxhold@gmail.com'
  s.files       = [
                    "lib/elo_rating.rb",
                    "README.md",
                    "LICENSE"
                  ]
  s.homepage    = 'http://github.com/mxhold/elo_rating'
  s.license     = 'MIT'
  s.test_files  = ['spec/elo_rating_spec.rb']
end
