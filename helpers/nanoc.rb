module Nanoc::Filters
	class Kramdown
		require 'kramdown-cite'

		def run(content, params={})
			params = params.merge(:bib => @item[:bib]) if @item.attributes.key?(:bib)
			params = params.merge(:csl => @item[:csl]) if @item.attributes.key?(:csl)
			params = params.merge(:bibstyle => @item[:bibstyle]) if @item.attributes.key?(:bibstyle)
			params = params.merge(:bibsort => @item[:bibsort]) if @item.attributes.key?(:bibsort)
			::Kramdown::Document.new(content, params).to_html
		end
	end
end
