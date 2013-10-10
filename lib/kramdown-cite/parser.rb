module Kramdown
	module Parser
		class Kramdown
			old_init = instance_method(:initialize)

			define_method(:initialize) {|source, options|
				old_init.bind(self).(source, options)
				@span_parsers.insert(@span_parsers.find_index(:link), :citations, :inline_citation)
			}

			CITE_KEY = "[-a-zA-Z:0-9]+"
			CITE_INLINE = /@(#{CITE_KEY})/
			CITE_INLINE_MARKER = /^@(#{CITE_KEY})/
			CITE_MARKER = /^\[@#{CITE_KEY}(?:;@#{CITE_KEY})*\]/

			# Parse protected citations at the current location.
			def parse_citations
				@src.pos += @src.matched_size
				add_citation(@src.matched.scan(CITE_INLINE).flatten)
				true
			end
			define_parser(:citations, CITE_MARKER, '\[')

			# Parse inline citations at the current location.
			def parse_inline_citation
				@src.pos += @src.matched_size
				add_citation( [ @src.matched.match(CITE_INLINE)[1] ], true)
				true
			end
			define_parser(:inline_citation, CITE_INLINE_MARKER, '@')

			# Add citation
			def add_citation(cite, inline=false)
				cite_def = Element.new(:cite, cite, {:inline => inline}, :category => :span)
				@refs = Array.new unless @refs
				@refs << cite_def
				@tree.children << cite_def
				cite_def
			end
		end
	end
end
