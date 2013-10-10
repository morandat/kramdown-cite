Gem::Specification.new do |gem|
	gem.name        = 'kramdown-cite'
	gem.version     = '0.0.1'
	gem.date        = '2013-10-10'
	gem.summary     = "Extend kramdown with citation support"
	gem.description = "Add to kramdown the citation support as in pandoc"
	gem.authors     = ["Floréal Morandat"]
	gem.email       = 'fmoranda@labri.fr'

	gem.add_dependency('kramdown', '~> 1.2.0')
	gem.add_dependency('citeproc-ruby', '~> 0.0.6')
	gem.add_dependency('bibtex-ruby', '~> 2.3.4')

	gem.files         = `git ls-files`.split($/)
	gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }

	gem.homepage    = 'http://github.org/morandat/kramdown-cite'
	gem.license     = 'MIT'
end
