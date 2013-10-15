module Kramdown
	module Converter
		class Html

			def load_bibliography(mode)
				begin
					require 'bibtex' # to load bibliography
					require 'citeproc' # to render citations
					@csl = @options[:csl]
					@citations = Hash.new
					@cites_backlink = Hash.new 

					if [:compress, :numbered].include?(mode)
						@cites_number = Hash.new
					end
					begin
						@csl = CSL::Style.new(@csl) if File.exists?(@csl)
					rescue Errno::ENOENT
						warning "Style '#{@csl} not found, using default"
						@csl = CSL::default_style
					end
					begin
						require 'latex/decode'
						@bibs = BibTeX.open(@options[:bib], :filter => :latex)
					rescue
						@bibs = BibTeX.open(@options[:bib])
					end
					downcase_hash_keys(@bibs.entries)
				rescue LoadError => e
					warning("Cannot open required library '#{e}'")
					@bibs = false
				rescue Exception => e
					warning("Cannot open bibliography file '#{@options[:bib]}' (#{e.class})")
					@bibs = false
				end
			end

			def compress_range(numbers)
				lst = Array.new
				first = numbers.first
				last = first - 1
				last_idx = numbers.size - 1
				numbers.sort.each_index do |i|
					x = numbers[i]
					last = x if i == last_idx
					if last + 1 == x
						last = x
					elsif first == last
						lst << first
						first = last = x
					else
						lst << "#{first}-#{last}"
						first = last = x
					end
				end
				lst
			end

			def convert_cite(el, opts)
				mode = @options.fetch(:bibstyle, :plain).to_sym
				load_bibliography(mode) if @bibs == nil

				if @bibs then
					cites = render_citations(el.value, mode, el.attr[:inline])
				else
					cites = el.value.map{|x| "@#{x}"}.join(";")
					el.attr[:inline] ? cites : "[#{cites}]"
				end
			end

			def downcase_hash_keys(hash)
				hash.keys.each { |k| hash[ k.downcase ] = hash.delete(k) }
			end

			def load_cite_keys(cites)
				cites.map do |c|
					c = c.downcase.to_sym
					unless @citations.key?(c)
						@citations[c] = @bibs[c].to_citeproc 
						# TODO check that key is found
						# warning("Citation @#{c} is not found! ")
					end
					c
				end
			end

			def render_citations(cites, mode, inline=false)
				cites = load_cite_keys(cites)
				rendered = ""
				case mode
				when :numbered, :compress
					names = cites.map{|c| render_citetext(c)}.join(", ") if inline
					rendered = cites.map{|c| render_citenumbered(c, inline)}.join(", ")
					#cites = compress_range(cites) if mode == :compress and !inline
					inline ? "#{names}&nbsp;[#{rendered}]" : "[#{rendered}]"
				else
					rendered = cites.map{|c| render_citetext(c)}.join(", ")
					inline ? rendered : "[#{rendered}]"
				end
			end

			def render_citenumbered(c, reuselink=false)
				@cites_number[c] = @cites_number.size + 1 unless @cites_number.key?(c)
				if reuselink
					render_citelink(c, @cites_number[c], @cites_backlink[c])
				else
					render_citelink(c, @cites_number[c])
				end
			end

			def render_citetext(c)
				render_citelink(c, CiteProc.process(@citations[c], :style => @csl, :format => :html, :mode => :cite)[0])
			end

			def render_citelink(c, text, id=nil)
				id = @cites_backlink[c] = @cites_backlink.fetch(c, 0) + 1 unless id
				"<a href=\"#bib:#{c}\" class=\"bibliography\" id=\"bib:#{c}-#{id}\">#{text}</a>"
			end

			old_footnote_content = instance_method(:footnote_content)

			define_method(:footnote_content) do
				result = citation_content
				result << old_footnote_content.bind(self).()
			end

			def render_citation_index(k)
				item = nil
				begin
					text = CiteProc.process(@citations[k], :style => @csl)
					if text
						item = Element.new(:li, nil, {'id' => "bib:#{k}"})
						item.children << Element.new(:text, text)
						1.upto(@cites_backlink[k]).each do |n|
							item.children << Element.new(:text, " [")
							a = Element.new(:a, n.to_s, { 'href'=> "#bib:#{k}-#{n}" } )
							a.children << Element.new(:text, n.to_s)
							item.children << a
							item.children << Element.new(:text, "] ")
						end
					end
				rescue Exception => e
				end
				item
			end

			def citation_content
				return '' unless @citations
				mode = @options.fetch(:bibstyle, :plain).to_sym

				case mode
				when :numbered, :compress
					biblio = Array.new(@cites_number.size)
					@cites_number.each{|k, idx| biblio[idx - 1] = render_citation_index k}
				else
					biblio = @citations.keys.map{|k| render_citation_index k}.sort
				end
				biblio = biblio.compact
				if biblio.size > 0 then
					ul = Element.new(:ol)
					ul.children.concat biblio
					format_as_indented_block_html('div', {:class => "bibliography"}, convert(ul, 2), 0)
				else
					''
				end
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
