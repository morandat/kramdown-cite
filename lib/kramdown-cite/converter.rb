module Kramdown
	module Converter
		class Html

			def convert_cite(el, opts)
				if @bibs == nil
					begin
						require 'bibtex' # to load bibliography
						require 'citeproc' # to render citations
						@bibs = BibTeX.open(@options[:bib], :filter => :latex)
						downcase_hash_keys(@bibs.entries)
					rescue LoadError => e
						warning("Cannot open required library '#{e}'")
						@bibs = false
					rescue Errno::ENOENT
						warning("Cannot open bibliography file '#{@options[:bib]}'")
						@bibs = false
					rescue
						begin
							@bibs = BibTeX.open(@options[:bib])
							downcase_hash_keys(@bibs.entries)
						rescue
							warning("Cannot open bibliography file '#{@options[:bib]}'")
							@bibs = false
						end
					end
				end

				if @bibs then
					@citations = Hash.new unless @citations
					cites = el.value.map{|c|
						c = c.downcase.to_sym
						@citations[c] = @bibs[c].to_citeproc unless @citations.key?(c)
						render_citelink(c, @citations[c])
					}.join(", ")
				else
					cites = el.value.map{|x| "@#{x}"}.join(";")
				end
				el.attr[:inline] ? cites : "[#{cites}]"
			end

			def downcase_hash_keys(hash)
				hash.keys.each { |k| hash[ k.downcase ] = hash.delete(k) }
			end

			def render_citelink(c, entry)
				val = CiteProc.process(entry, :style => @options[:csl], :format => :html, :mode => :cite)[0]
				"<a href=\"#bib:#{c}\" class=\"bibliography\">#{val}</a>"
			end

			old_footnote_content = instance_method(:footnote_content)

			define_method(:footnote_content) do
				result = citation_content
				result << old_footnote_content.bind(self).()
			end

			def citation_content
				return '' unless @citations
				ul = Element.new(:ul)
				style = @options[:csl]
				items = Hash.new
				@citations.each{|k, c|
					li = Element.new(:li, nil, {'id' => "bib:#{k}"})
					hash["#{c[:author].value} #{c[:year]}"] = li
					li.children << Element.new(:text, CiteProc.process(c, :style => style))
				}
				items.keys.sort{|k| ul.children << items[k]}
				format_as_indented_block_html('div', {:class => "bibliography"}, convert(ul, 2), 0)
			end
		end

		class Latex
			def convert_root(el, opts)
				inner(el, opts)
				result = inner(el, opts)
				result << render_biblio
			end

			def convert_cite(el, opts)
				cite = el.attr[:inline] ? '\citeN' : '\cite'
				"#{cite}{#{el.value.join(",")}}"
			end

			def render_biblio
				"\\bibliography{#{@options[:bib]}}"
			end
		end

		class Kramdown
			def convert_cite(el, opts)
				cites = el.value.map{|x| "@#{x}"}.join(";")
				el.attr[:inline] ? cites : "[#{cites}]"
			end
		end
	end
end
