module Nanoc::Filters
	class Kramdown
		require 'kramdown-cite'

		def run(content, params={})
			params = params.merge(:bib => @item[:bib]) if @item.attributes.key?(:bib)
			::Kramdown::Document.new(content, params).to_html
		end
	end
end
