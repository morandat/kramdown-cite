require 'kramdown-cite/version'
require 'kramdown'

module Kramdown
	class Element
		CATEGORY[:cite] = :span
	end

	module Options
    define(:csl, String, "apa", <<EOF)
CiteProc style

This option can be used to specify the CiteProc style used to render citations.

Default: document.bib
EOF
    define(:bib, String, "document.bib", <<EOF)
Bibliography file used for citations

This option can be used to specify the BibTeX file used to render citations.

Default: document.bib
EOF
	end

end

require 'kramdown-cite/parser.rb'
require 'kramdown-cite/converter.rb'
