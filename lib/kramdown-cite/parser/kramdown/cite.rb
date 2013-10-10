# -*- coding: utf-8 -*-
#
#--
# Copyright (C) 2013 Floreal Morandat <fmorandat@labri.fr>
#
# This file is part of kramdown which is licensed under the MIT.
#++
#

require 'kramdown/parser/kramdown/extensions'

module Kramdown
  module Parser
    class Kramdown

      CITE_INLINE = /@(#{ALD_ID_NAME})/
      CITE_INLINE_MARKER = /^@(#{ALD_ID_NAME})/
      CITE_MARKER = /^\[@#{ALD_ID_NAME}(?:;@#{ALD_ID_NAME})*\]/

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
